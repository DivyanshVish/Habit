import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:habit_tracker/core/error/failure.dart';
import 'package:habit_tracker/core/platform/platform_services.dart';
import 'package:habit_tracker/features/invitations/data/invitation_repository_impl.dart';
import 'package:habit_tracker/features/invitations/domain/invitation_domain.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fakes.dart';

class MockInvitationRepository extends Mock implements InvitationRepository {}

void main() {
  group('normalizeInviteCode', () {
    test('ignores case, spaces and dashes', () {
      expect(normalizeInviteCode(' ab-cd 23 '), 'ABCD23');
    });
  });

  group('use cases', () {
    late MockInvitationRepository repository;

    setUpAll(() => registerFallbackValue(InvitationType.group));
    setUp(() => repository = MockInvitationRepository());

    test(
      'PreviewInvitation rejects a too short code without calling',
      () async {
        final result = await PreviewInvitation(repository)('ab');

        expect(result.getLeft().toNullable(), isA<ValidationFailure>());
        verifyNever(() => repository.preview(any()));
      },
    );

    test('PreviewInvitation sends the normalized code', () async {
      when(() => repository.preview('ABCD1234')).thenAnswer(
        (_) async => right(
          const InvitationPreview(
            type: InvitationType.group,
            name: 'Runners',
            inviterName: 'Ann',
          ),
        ),
      );

      final result = await PreviewInvitation(repository)('abcd-1234');

      expect(result.getRight().toNullable()!.name, 'Runners');
    });

    test('RespondToInvitation passes accept and decline through', () async {
      when(
        () => repository.respond(
          code: any(named: 'code'),
          accept: any(named: 'accept'),
        ),
      ).thenAnswer(
        (_) async => right(
          const InvitationResult(
            accepted: true,
            type: InvitationType.shared,
            targetId: 's1',
          ),
        ),
      );

      await RespondToInvitation(repository)(
        const RespondToInvitationParams(code: 'abcd 1234', accept: false),
      );

      verify(
        () => repository.respond(code: 'ABCD1234', accept: false),
      ).called(1);
    });

    test('RespondToInvitation rejects a bad code', () async {
      final result = await RespondToInvitation(repository)(
        const RespondToInvitationParams(code: '--', accept: true),
      );

      expect(result.getLeft().toNullable(), isA<ValidationFailure>());
    });

    group('CreateInvitation', () {
      setUp(() {
        when(
          () => repository.create(
            type: any(named: 'type'),
            targetId: any(named: 'targetId'),
            maxUses: any(named: 'maxUses'),
            ttlHours: any(named: 'ttlHours'),
          ),
        ).thenAnswer(
          (_) async =>
              right(const InvitationCode(invitationId: 'i1', code: 'ABCD1234')),
        );
      });

      test('shared invitations are always single use', () async {
        await CreateInvitation(repository)(
          const CreateInvitationParams(
            type: InvitationType.shared,
            targetId: 's1',
            maxUses: 20,
          ),
        );

        verify(
          () => repository.create(
            type: InvitationType.shared,
            targetId: 's1',
            maxUses: 1,
            ttlHours: 72,
          ),
        ).called(1);
      });

      test('group codes keep the requested number of uses', () async {
        await CreateInvitation(repository)(
          const CreateInvitationParams(
            type: InvitationType.group,
            targetId: 'g1',
            maxUses: 20,
            ttlHours: 24,
          ),
        );

        verify(
          () => repository.create(
            type: InvitationType.group,
            targetId: 'g1',
            maxUses: 20,
            ttlHours: 24,
          ),
        ).called(1);
      });

      for (final (label, uses, hours) in [
        ('0 uses', 0, 72),
        ('51 uses', 51, 72),
        ('0 hours', 1, 0),
        ('more than 14 days', 1, 24 * 14 + 1),
      ]) {
        test('rejects $label', () async {
          final result = await CreateInvitation(repository)(
            CreateInvitationParams(
              type: InvitationType.group,
              targetId: 'g1',
              maxUses: uses,
              ttlHours: hours,
            ),
          );

          expect(result.getLeft().toNullable(), isA<ValidationFailure>());
        });
      }
    });
  });

  group('InvitationRepositoryImpl', () {
    late FakeCallableClient callable;
    late InvitationRepositoryImpl repository;
    late FakeFirebaseFirestore firestore;

    setUp(() {
      callable = FakeCallableClient();
      firestore = FakeFirebaseFirestore();
      repository = InvitationRepositoryImpl(
        callable,
        firestore: firestore,
        userIdProvider: FakeUserIdProvider('alice'),
      );
    });

    test('create returns the code the server generated', () async {
      callable.responses['createInvitation'] = {
        'invitationId': 'i1',
        'code': 'ABCD1234',
      };

      final result = await repository.create(
        type: InvitationType.group,
        targetId: 'g1',
        maxUses: 5,
        ttlHours: 48,
      );

      expect(result.getRight().toNullable()!.code, 'ABCD1234');
      expect(callable.calls.single.data, {
        'type': 'group',
        'targetId': 'g1',
        'maxUses': 5,
        'ttlHours': 48,
      });
    });

    test('an expired code surfaces the server message', () async {
      callable.error = const CallableException(
        'failed-precondition',
        'This invitation has expired.',
      );

      final result = await repository.preview('ABCD1234');

      final failure = result.getLeft().toNullable()!;
      expect(failure, isA<ValidationFailure>());
      expect(failure.message, 'This invitation has expired.');
    });

    test('rate limiting is reported as a failure, not a crash', () async {
      callable.error = const CallableException(
        'resource-exhausted',
        'Too many attempts. Try again later.',
      );

      final result = await repository.respond(code: 'ABCD1234', accept: true);

      expect(result.getLeft().toNullable()!.message, contains('Too many'));
    });

    test('an unexpected response shape becomes a server failure', () async {
      callable.responses['createInvitation'] = {'invitationId': 5};

      final result = await repository.create(
        type: InvitationType.group,
        targetId: 'g1',
        maxUses: 1,
        ttlHours: 1,
      );

      expect(result.getLeft().toNullable(), isA<ServerFailure>());
    });

    test('respond maps the result', () async {
      callable.responses['respondToInvitation'] = {
        'accepted': true,
        'type': 'group',
        'targetId': 'g1',
      };

      final result = await repository.respond(code: 'ABCD1234', accept: true);

      final value = result.getRight().toNullable()!;
      expect(value.accepted, isTrue);
      expect(value.type, InvitationType.group);
      expect(value.targetId, 'g1');
    });

    test('inviting a person sends their id and no code comes back', () async {
      final result = await repository.createForPerson(
        type: InvitationType.shared,
        targetId: 's1',
        inviteeUid: 'bob',
        ttlHours: 48,
      );

      expect(result, right(unit));
      expect(callable.calls.single.name, 'createInvitation');
      expect(callable.calls.single.data, {
        'type': 'shared',
        'targetId': 's1',
        'inviteeUid': 'bob',
        'ttlHours': 48,
      });
    });

    test('the server refusing a stranger is explained', () async {
      callable.error = const CallableException(
        'permission-denied',
        'You can only invite people you share a group with.',
      );

      final result = await repository.createForPerson(
        type: InvitationType.group,
        targetId: 'g1',
        inviteeUid: 'stranger',
        ttlHours: 72,
      );

      expect(result.getLeft().toNullable()!.message, contains('share a group'));
    });

    test('lists the people who can be invited', () async {
      callable.responses['listInvitablePeople'] = {
        'people': [
          {'uid': 'bob', 'displayName': 'Bob'},
          {'uid': 'cy'},
        ],
      };

      final result = await repository.listPeople(
        type: InvitationType.group,
        targetId: 'g1',
      );

      final people = result.getRight().toNullable()!;
      expect(people.map((p) => p.uid), ['bob', 'cy']);
      expect(people.last.displayName, 'Habitry user');
      expect(callable.calls.single.data, {'type': 'group', 'targetId': 'g1'});
    });

    test('an empty list is fine', () async {
      callable.responses['listInvitablePeople'] = {'people': []};

      final result = await repository.listPeople(
        type: InvitationType.shared,
        targetId: 's1',
      );

      expect(result.getRight().toNullable(), isEmpty);
    });

    test('answering by id sends the id, not a code', () async {
      callable.responses['respondToInvitation'] = {
        'accepted': true,
        'type': 'group',
        'targetId': 'g1',
        'pendingApproval': true,
      };

      final result = await repository.respondById(
        invitationId: 'i1',
        accept: true,
      );

      final value = result.getRight().toNullable()!;
      expect(value.pendingApproval, isTrue);
      expect(value.accepted, isTrue);
      expect(callable.calls.single.data, {
        'invitationId': 'i1',
        'accept': true,
      });
    });

    test('a code response without approval is not pending', () async {
      callable.responses['respondToInvitation'] = {
        'accepted': true,
        'type': 'group',
        'targetId': 'g1',
      };

      final result = await repository.respond(code: 'ABCD1234', accept: true);

      expect(result.getRight().toNullable()!.pendingApproval, isFalse);
    });

    group('invitations waiting for me', () {
      final future = DateTime.now().add(const Duration(days: 2));
      final past = DateTime.now().subtract(const Duration(hours: 1));

      Future<void> pending(
        String uid,
        String id, {
        required DateTime expires,
        String name = 'Gym Bros',
      }) {
        return firestore.doc('users/$uid/pendingInvitations/$id').set({
          'type': 'group',
          'targetName': name,
          'inviterName': 'Ann',
          'expiresAtMs': expires.millisecondsSinceEpoch,
        });
      }

      test('lists them with who invited and to what', () async {
        await pending('alice', 'i1', expires: future);

        final items = (await repository.watchPending().first)
            .getRight()
            .toNullable()!;

        expect(items, hasLength(1));
        expect(items.single.invitationId, 'i1');
        expect(items.single.type, InvitationType.group);
        expect(items.single.targetName, 'Gym Bros');
        expect(items.single.inviterName, 'Ann');
      });

      test('leaves out expired ones', () async {
        await pending('alice', 'old', expires: past);
        await pending('alice', 'new', expires: future);

        final items = (await repository.watchPending().first)
            .getRight()
            .toNullable()!;

        expect(items.map((i) => i.invitationId), ['new']);
      });

      test('shows only my own', () async {
        await pending('bob', 'theirs', expires: future);

        final items = (await repository.watchPending().first)
            .getRight()
            .toNullable()!;

        expect(items, isEmpty);
      });

      test('soonest to expire comes first', () async {
        await pending(
          'alice',
          'later',
          expires: future.add(const Duration(days: 3)),
        );
        await pending('alice', 'sooner', expires: future);

        final items = (await repository.watchPending().first)
            .getRight()
            .toNullable()!;

        expect(items.map((i) => i.invitationId), ['sooner', 'later']);
      });
    });

    test('revoke calls the function', () async {
      final result = await repository.revoke('i1');

      expect(result, right(unit));
      expect(callable.calls.single.name, 'revokeInvitation');
    });
  });
}

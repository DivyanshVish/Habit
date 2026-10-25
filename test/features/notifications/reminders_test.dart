import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:habit_tracker/core/error/failure.dart';
import 'package:habit_tracker/features/notifications/data/reminder_repository_impl.dart';
import 'package:habit_tracker/features/notifications/domain/reminders_domain.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fakes.dart';

class MockReminderRepository extends Mock implements ReminderRepository {}

void main() {
  group('targets', () {
    test('each habit has one stable reminder id', () {
      expect(const PersonalReminderTarget('h1').docId, 'personal_h1');
      expect(const SharedReminderTarget('s1').docId, 'shared_s1');
      expect(const GroupReminderTarget('g1', 'h1').docId, 'group_g1_h1');
    });
  });

  group('ReminderRepositoryImpl', () {
    late FakeFirebaseFirestore firestore;

    ReminderRepositoryImpl build(String? uid) => ReminderRepositoryImpl(
      firestore: firestore,
      userIdProvider: FakeUserIdProvider(uid),
    );

    setUp(() => firestore = FakeFirebaseFirestore());

    test('no reminder yet is null, not an error', () async {
      final result = await build(
        'alice',
      ).watch(const PersonalReminderTarget('h1')).first;

      expect(result, right<Failure, ReminderSetting?>(null));
    });

    test('saves and reads a personal reminder with its identity', () async {
      final repo = build('alice');

      await repo.save(
        const PersonalReminderTarget('h1'),
        const ReminderSetting(enabled: true, minutesOfDay: 18 * 60 + 30),
      );

      final doc = await firestore
          .doc('users/alice/reminders/personal_h1')
          .get();
      expect(doc.data(), {
        'kind': 'personal',
        'itemId': 'h1',
        'enabled': true,
        'minutesOfDay': 1110,
        'onlyIfIncomplete': true,
      });
      final read = (await repo.watch(const PersonalReminderTarget('h1')).first)
          .getRight()
          .toNullable();
      expect(read, const ReminderSetting(enabled: true, minutesOfDay: 1110));
    });

    test('shared and group reminders carry the ids the server needs', () async {
      final repo = build('alice');
      const setting = ReminderSetting(enabled: true, minutesOfDay: 480);

      await repo.save(const SharedReminderTarget('s1'), setting);
      await repo.save(const GroupReminderTarget('g1', 'h9'), setting);

      final shared = await firestore
          .doc('users/alice/reminders/shared_s1')
          .get();
      final group = await firestore
          .doc('users/alice/reminders/group_g1_h9')
          .get();
      expect(shared.data()!['kind'], 'shared');
      expect(shared.data()!['sharedId'], 's1');
      expect(group.data()!['kind'], 'group');
      expect(group.data()!['groupId'], 'g1');
      expect(group.data()!['habitId'], 'h9');
    });

    test('saving again edits the same reminder', () async {
      final repo = build('alice');
      const target = PersonalReminderTarget('h1');

      await repo.save(
        target,
        const ReminderSetting(enabled: true, minutesOfDay: 480),
      );
      await repo.save(
        target,
        const ReminderSetting(enabled: false, minutesOfDay: 600),
      );

      final all = await firestore.collection('users/alice/reminders').get();
      expect(all.docs, hasLength(1));
      expect(all.docs.single.data()['minutesOfDay'], 600);
      expect(all.docs.single.data()['enabled'], isFalse);
    });

    test('remove deletes it', () async {
      final repo = build('alice');
      const target = PersonalReminderTarget('h1');
      await repo.save(
        target,
        const ReminderSetting(enabled: true, minutesOfDay: 480),
      );

      await repo.remove(target);

      final read = (await repo.watch(target).first).getRight().toNullable();
      expect(read, isNull);
    });

    test('reminders are private to their owner', () async {
      await build('alice').save(
        const PersonalReminderTarget('h1'),
        const ReminderSetting(enabled: true, minutesOfDay: 480),
      );

      final bobs =
          (await build('bob').watch(const PersonalReminderTarget('h1')).first)
              .getRight()
              .toNullable();
      expect(bobs, isNull);
    });

    test('signed out users cannot set reminders', () async {
      final result = await build(null).save(
        const PersonalReminderTarget('h1'),
        const ReminderSetting(enabled: true, minutesOfDay: 480),
      );

      expect(result.getLeft().toNullable(), isA<UnauthenticatedFailure>());
    });
  });

  group('SaveReminder', () {
    late MockReminderRepository repository;

    setUpAll(() {
      registerFallbackValue(const PersonalReminderTarget('x'));
      registerFallbackValue(
        const ReminderSetting(enabled: true, minutesOfDay: 0),
      );
    });
    setUp(() {
      repository = MockReminderRepository();
      when(
        () => repository.save(any(), any()),
      ).thenAnswer((_) async => right(unit));
    });

    for (final minutes in [-1, 24 * 60, 5000]) {
      test('rejects $minutes minutes', () async {
        final result = await SaveReminder(repository)(
          SaveReminderParams(
            const PersonalReminderTarget('h1'),
            ReminderSetting(enabled: true, minutesOfDay: minutes),
          ),
        );

        expect(result.getLeft().toNullable(), isA<ValidationFailure>());
        verifyNever(() => repository.save(any(), any()));
      });
    }

    for (final minutes in [0, 1, 1439]) {
      test('accepts $minutes minutes', () async {
        final result = await SaveReminder(repository)(
          SaveReminderParams(
            const PersonalReminderTarget('h1'),
            ReminderSetting(enabled: true, minutesOfDay: minutes),
          ),
        );

        expect(result.isRight(), isTrue);
      });
    }
  });
}

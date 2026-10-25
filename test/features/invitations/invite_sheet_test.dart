import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:habit_tracker/core/di/injection.dart';
import 'package:habit_tracker/core/error/failure.dart';
import 'package:habit_tracker/features/invitations/domain/invitation_domain.dart';
import 'package:habit_tracker/features/invitations/presentation/invite_sheet.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/pump_app.dart';

class MockInvitationRepository extends Mock implements InvitationRepository {}

void main() {
  late MockInvitationRepository repository;

  void stubPeople(List<InvitablePerson> people) {
    when(
      () => repository.listPeople(
        type: any(named: 'type'),
        targetId: any(named: 'targetId'),
      ),
    ).thenAnswer((_) async => right(people));
  }

  setUp(() {
    repository = MockInvitationRepository();
    getIt.registerSingleton<CreateInvitation>(CreateInvitation(repository));
    getIt.registerSingleton<RevokeInvitation>(RevokeInvitation(repository));
    getIt.registerSingleton<ListInvitablePeople>(
      ListInvitablePeople(repository),
    );
    getIt.registerSingleton<InvitePerson>(InvitePerson(repository));
    stubPeople(const []);
  });

  tearDown(() async => getIt.reset());

  void stubCreate(Either<Failure, InvitationCode> result) {
    when(
      () => repository.create(
        type: any(named: 'type'),
        targetId: any(named: 'targetId'),
        maxUses: any(named: 'maxUses'),
        ttlHours: any(named: 'ttlHours'),
      ),
    ).thenAnswer((_) async => result);
  }

  Future<void> open(WidgetTester tester, {double textScale = 1}) async {
    await tester.pumpWidget(
      themedApp(
        Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => showInviteSheet(
                context,
                type: InvitationType.group,
                targetId: 'g1',
                subject: "Gym Bro's",
              ),
              child: const Text('open'),
            ),
          ),
        ),
        textScale: textScale,
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  setUpAll(() => registerFallbackValue(InvitationType.group));

  testWidgets('shows the code, a Copy button and Cancel, laid out cleanly', (
    tester,
  ) async {
    useSmallPhone(tester);
    stubCreate(
      right(const InvitationCode(invitationId: 'i1', code: 'JR8PQZ33')),
    );
    await open(tester);

    await tester.tap(find.text('Create code'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byKey(const Key('invite-code')), findsOneWidget);
    expect(find.text('JR8PQZ33'), findsOneWidget);
    expect(find.text('Copy'), findsOneWidget);
    expect(find.text('Cancel invitation'), findsOneWidget);
  });

  testWidgets('the code does not overlap the title', (tester) async {
    useSmallPhone(tester);
    stubCreate(
      right(const InvitationCode(invitationId: 'i1', code: 'JR8PQZ33')),
    );
    await open(tester);
    await tester.tap(find.text('Create code'));
    await tester.pumpAndSettle();

    final title = tester.getRect(find.text("Invite to Gym Bro's"));
    final code = tester.getRect(find.byKey(const Key('invite-code')));
    final copy = tester.getRect(find.text('Copy'));

    expect(code.top, greaterThanOrEqualTo(title.bottom));
    expect(copy.top, greaterThanOrEqualTo(code.bottom));
  });

  testWidgets('works at 2x text size on a small phone', (tester) async {
    useSmallPhone(tester);
    stubCreate(
      right(const InvitationCode(invitationId: 'i1', code: 'JR8PQZ33')),
    );
    await open(tester, textScale: 2);

    // At 2x the button is below the visible part of the sheet, so scroll.
    await tester.ensureVisible(find.text('Create code'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Create code'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('JR8PQZ33'), findsOneWidget);
    await tester.ensureVisible(find.text('Copy'));
    await tester.pumpAndSettle();
    expect(find.text('Copy'), findsOneWidget);
  });

  testWidgets('a server refusal is shown in words and no code appears', (
    tester,
  ) async {
    stubCreate(
      left(const Failure.validation(message: 'Only admins can invite.')),
    );
    await open(tester);

    await tester.tap(find.text('Create code'));
    await tester.pumpAndSettle();

    expect(find.text('Only admins can invite.'), findsOneWidget);
    expect(find.byKey(const Key('invite-code')), findsNothing);
  });

  testWidgets('cancelling the invitation clears the code', (tester) async {
    stubCreate(
      right(const InvitationCode(invitationId: 'i1', code: 'JR8PQZ33')),
    );
    when(() => repository.revoke('i1')).thenAnswer((_) async => right(unit));
    await open(tester);
    await tester.tap(find.text('Create code'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cancel invitation'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('invite-code')), findsNothing);
    expect(find.text('Create code'), findsOneWidget);
    verify(() => repository.revoke('i1')).called(1);
  });

  group('inviting a person you know', () {
    const ann = InvitablePerson(uid: 'ann', displayName: 'Ann');
    const bob = InvitablePerson(uid: 'bob', displayName: 'Bob');

    void stubInvite(Either<Failure, Unit> result) {
      when(
        () => repository.createForPerson(
          type: any(named: 'type'),
          targetId: any(named: 'targetId'),
          inviteeUid: any(named: 'inviteeUid'),
          ttlHours: any(named: 'ttlHours'),
        ),
      ).thenAnswer((_) async => result);
    }

    testWidgets('lists the people and still offers a code', (tester) async {
      stubPeople(const [ann, bob]);
      await open(tester);

      expect(find.text('Ann'), findsOneWidget);
      expect(find.text('Bob'), findsOneWidget);
      expect(find.text('Invite'), findsNWidgets(2));
      expect(find.text('Create code'), findsOneWidget);
      expect(find.text('OR SHARE A CODE'), findsOneWidget);
    });

    testWidgets('no people means no list and no extra heading', (tester) async {
      stubPeople(const []);
      await open(tester);

      expect(find.text('PEOPLE YOU KNOW'), findsNothing);
      expect(find.text('OR SHARE A CODE'), findsNothing);
      expect(find.text('Create code'), findsOneWidget);
    });

    testWidgets('inviting marks the person as invited, in words', (
      tester,
    ) async {
      stubPeople(const [ann, bob]);
      stubInvite(right(unit));
      await open(tester);

      await tester.tap(find.text('Invite').first);
      await tester.pumpAndSettle();

      expect(find.text('Invited'), findsOneWidget);
      expect(find.text('Invite'), findsOneWidget); // Bob can still be invited
      verify(
        () => repository.createForPerson(
          type: InvitationType.group,
          targetId: 'g1',
          inviteeUid: 'ann',
          ttlHours: 72,
        ),
      ).called(1);
    });

    testWidgets('a person cannot be invited twice from the sheet', (
      tester,
    ) async {
      stubPeople(const [ann]);
      stubInvite(right(unit));
      await open(tester);

      await tester.tap(find.text('Invite'));
      await tester.pumpAndSettle();
      expect(find.text('Invite'), findsNothing);

      verify(
        () => repository.createForPerson(
          type: any(named: 'type'),
          targetId: any(named: 'targetId'),
          inviteeUid: any(named: 'inviteeUid'),
          ttlHours: any(named: 'ttlHours'),
        ),
      ).called(1);
    });

    testWidgets('a refusal is shown and the person stays invitable', (
      tester,
    ) async {
      stubPeople(const [ann]);
      stubInvite(
        left(const Failure.validation(message: 'They are already in.')),
      );
      await open(tester);

      await tester.tap(find.text('Invite'));
      await tester.pumpAndSettle();

      expect(find.text('They are already in.'), findsOneWidget);
      expect(find.text('Invite'), findsOneWidget);
      expect(find.text('Invited'), findsNothing);
    });

    testWidgets('if the list cannot load, the code still works', (
      tester,
    ) async {
      when(
        () => repository.listPeople(
          type: any(named: 'type'),
          targetId: any(named: 'targetId'),
        ),
      ).thenAnswer((_) async => left(const Failure.network()));
      stubCreate(
        right(const InvitationCode(invitationId: 'i1', code: 'JR8PQZ33')),
      );
      await open(tester);

      await tester.tap(find.text('Create code'));
      await tester.pumpAndSettle();

      expect(find.text('JR8PQZ33'), findsOneWidget);
    });

    testWidgets('each Invite button says who it invites to screen readers', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      stubPeople(const [ann]);
      await open(tester);

      expect(find.bySemanticsLabel('Invite Ann'), findsOneWidget);
      handle.dispose();
    });
  });
}

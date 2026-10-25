import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go_router/go_router.dart';
import 'package:habit_tracker/core/di/injection.dart';
import 'package:habit_tracker/core/error/failure.dart';
import 'package:habit_tracker/core/theme/app_theme.dart';
import 'package:habit_tracker/features/invitations/domain/invitation_domain.dart';
import 'package:habit_tracker/features/invitations/presentation/pending_invitations.dart';
import 'package:mocktail/mocktail.dart';

class MockInvitationRepository extends Mock implements InvitationRepository {}

PendingInvitation _invite(
  String id, {
  InvitationType type = InvitationType.group,
  String name = 'Gym Bros',
}) => PendingInvitation(
  invitationId: id,
  type: type,
  targetName: name,
  inviterName: 'Ann',
  expiresAt: DateTime.now().add(const Duration(days: 1)),
);

void main() {
  late MockInvitationRepository repository;

  setUp(() {
    repository = MockInvitationRepository();
    getIt
      ..registerSingleton<WatchPendingInvitations>(
        WatchPendingInvitations(repository),
      )
      ..registerSingleton<RespondToPending>(RespondToPending(repository));
  });

  tearDown(() async => getIt.reset());

  void stubPending(List<PendingInvitation> items) {
    when(
      () => repository.watchPending(),
    ).thenAnswer((_) => Stream.value(right(items)));
  }

  void stubRespond(Either<Failure, InvitationResult> result) {
    when(
      () => repository.respondById(
        invitationId: any(named: 'invitationId'),
        accept: any(named: 'accept'),
      ),
    ).thenAnswer((_) async => result);
  }

  Future<void> pump(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 3000);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (c, s) => const Scaffold(
            body: SingleChildScrollView(child: PendingInvitationsSection()),
          ),
        ),
        GoRoute(
          path: '/groups/:id',
          builder: (c, s) => Text('group ${s.pathParameters['id']}'),
        ),
        GoRoute(
          path: '/shared/:id',
          builder: (c, s) => Text('shared ${s.pathParameters['id']}'),
        ),
      ],
    );
    await tester.pumpWidget(
      MaterialApp.router(theme: AppTheme.light(), routerConfig: router),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows nothing when there are no invitations', (tester) async {
    stubPending(const []);
    await pump(tester);

    expect(find.textContaining('INVITATIONS'), findsNothing);
    expect(find.text('Accept'), findsNothing);
  });

  testWidgets('shows who invited you to what, with a count', (tester) async {
    stubPending([
      _invite('i1'),
      _invite('i2', type: InvitationType.shared, name: 'Read'),
    ]);
    await pump(tester);

    expect(find.text('INVITATIONS FOR YOU (2)'), findsOneWidget);
    expect(find.text('Ann invited you to a group'), findsOneWidget);
    expect(find.text('Ann invited you to a shared habit'), findsOneWidget);
    expect(find.text('Gym Bros'), findsOneWidget);
    expect(find.text('Accept'), findsNWidgets(2));
  });

  testWidgets('shows nothing if the list cannot load', (tester) async {
    when(
      () => repository.watchPending(),
    ).thenAnswer((_) => Stream.value(left(const Failure.network())));
    await pump(tester);

    expect(find.text('Accept'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Accept answers by id and opens the group', (tester) async {
    stubPending([_invite('i1')]);
    stubRespond(
      right(
        const InvitationResult(
          accepted: true,
          type: InvitationType.group,
          targetId: 'g1',
        ),
      ),
    );
    await pump(tester);

    await tester.tap(find.text('Accept'));
    await tester.pumpAndSettle();

    verify(
      () => repository.respondById(invitationId: 'i1', accept: true),
    ).called(1);
    expect(find.text('group g1'), findsOneWidget);
  });

  testWidgets('accepting a shared habit opens that habit', (tester) async {
    stubPending([_invite('i1', type: InvitationType.shared)]);
    stubRespond(
      right(
        const InvitationResult(
          accepted: true,
          type: InvitationType.shared,
          targetId: 's9',
        ),
      ),
    );
    await pump(tester);

    await tester.tap(find.text('Accept'));
    await tester.pumpAndSettle();

    expect(find.text('shared s9'), findsOneWidget);
  });

  testWidgets('Decline answers no and stays on the page', (tester) async {
    stubPending([_invite('i1')]);
    stubRespond(
      right(
        const InvitationResult(
          accepted: false,
          type: InvitationType.group,
          targetId: 'g1',
        ),
      ),
    );
    await pump(tester);

    await tester.tap(find.text('Decline'));
    await tester.pumpAndSettle();

    verify(
      () => repository.respondById(invitationId: 'i1', accept: false),
    ).called(1);
    expect(find.text('Invitation declined'), findsOneWidget);
    expect(find.textContaining('group '), findsNothing);
  });

  testWidgets('a group that wants approval says the request was sent', (
    tester,
  ) async {
    stubPending([_invite('i1')]);
    stubRespond(
      right(
        const InvitationResult(
          accepted: true,
          type: InvitationType.group,
          targetId: 'g1',
          pendingApproval: true,
        ),
      ),
    );
    await pump(tester);

    await tester.tap(find.text('Accept'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Request sent'), findsOneWidget);
    expect(find.text('group g1'), findsNothing);
  });

  testWidgets('an expired invitation shows the server message', (tester) async {
    stubPending([_invite('i1')]);
    stubRespond(
      left(const Failure.validation(message: 'This invitation has expired.')),
    );
    await pump(tester);

    await tester.tap(find.text('Accept'));
    await tester.pumpAndSettle();

    expect(find.text('This invitation has expired.'), findsOneWidget);
  });
}

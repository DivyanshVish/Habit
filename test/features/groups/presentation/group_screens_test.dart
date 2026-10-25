import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go_router/go_router.dart';
import 'package:habit_tracker/core/auth/user_id_provider.dart';
import 'package:habit_tracker/core/di/injection.dart';
import 'package:habit_tracker/core/error/failure.dart';
import 'package:habit_tracker/core/theme/app_theme.dart';
import 'package:habit_tracker/core/time/clock.dart';
import 'package:habit_tracker/core/time/date_key.dart';
import 'package:habit_tracker/features/groups/domain/entities/completion_rule.dart';
import 'package:habit_tracker/features/groups/domain/entities/cycle_snapshot.dart';
import 'package:habit_tracker/features/groups/domain/entities/group_entities.dart';
import 'package:habit_tracker/features/groups/domain/repositories/group_repository.dart';
import 'package:habit_tracker/features/groups/domain/services/streak_history_calculator.dart';
import 'package:habit_tracker/features/groups/domain/usecases/group_usecases.dart';
import 'package:habit_tracker/features/groups/presentation/pages/group_activity_page.dart';
import 'package:habit_tracker/features/groups/presentation/pages/group_habit_edit_page.dart';
import 'package:habit_tracker/features/groups/presentation/pages/group_settings_page.dart';
import 'package:habit_tracker/features/groups/presentation/pages/groups_pages.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fakes.dart';

class MockGroupRepository extends Mock implements GroupRepository {}

HabitGroup _group({
  bool requireApproval = false,
  bool membersCanInvite = false,
  GroupEmblem? emblem,
}) => HabitGroup(
  id: 'g1',
  name: 'Gym Bros',
  description: 'Lift things',
  ownerUid: 'me',
  memberCount: 3,
  membersCanInvite: membersCanInvite,
  archived: false,
  requireApproval: requireApproval,
  emblem: emblem,
);

GroupMember _member(String uid, String name, MemberRole role) =>
    GroupMember(uid: uid, displayName: name, role: role, active: true);

GroupHabit _habit({
  Set<int> weekdays = const {1, 2, 3, 4, 5, 6, 7},
  CompletionRule target = const CompletionRule.majority(),
  DateKey? endDate,
  DateKey? pendingFrom,
}) => GroupHabit(
  id: 'h1',
  name: 'Legs',
  description: 'Squats',
  weekdays: weekdays,
  target: target,
  startDate: DateKey.parse('2026-10-01'),
  endDate: endDate,
  archived: false,
  groupStreak: const GroupStreak(current: 0, best: 0),
  pendingFrom: pendingFrom,
);

void main() {
  late MockGroupRepository repository;
  final today = DateKey.parse('2026-10-18');

  setUpAll(() {
    registerFallbackValue(MemberRole.member);
    registerFallbackValue(DateKey.parse('2026-01-01'));
    registerFallbackValue(const GroupEmblem(icon: 'people', color: 0));
    registerFallbackValue(const CompletionRule.majority());
  });

  setUp(() {
    repository = MockGroupRepository();
    getIt
      ..registerSingleton<UserIdProvider>(FakeUserIdProvider('me'))
      ..registerSingleton<Clock>(FixedClock(DateTime(2026, 10, 18, 9)))
      ..registerSingleton<WatchGroupOverview>(WatchGroupOverview(repository))
      ..registerSingleton<WatchJoinRequests>(WatchJoinRequests(repository))
      ..registerSingleton<ReviewJoinRequest>(ReviewJoinRequest(repository))
      ..registerSingleton<UpdateGroupSettings>(UpdateGroupSettings(repository))
      ..registerSingleton<UpdateGroupHabit>(UpdateGroupHabit(repository))
      ..registerSingleton<WatchGroupAudit>(WatchGroupAudit(repository))
      ..registerSingleton<WatchGroupHabitDetail>(
        WatchGroupHabitDetail(
          repository,
          FixedClock(DateTime(2026, 10, 18, 9)),
          const StreakHistoryCalculator(),
        ),
      );
    when(
      () => repository.watchJoinRequests(any()),
    ).thenAnswer((_) => Stream.value(right(const <JoinRequest>[])));
  });

  tearDown(() async => getIt.reset());

  void stubOverview({
    required MemberRole myRole,
    HabitGroup? group,
    List<GroupMember>? members,
    List<GroupHabit>? habits,
  }) {
    when(
      () => repository.watchGroup('g1'),
    ).thenAnswer((_) => Stream.value(right(group ?? _group())));
    when(() => repository.watchMembers('g1')).thenAnswer(
      (_) => Stream.value(
        right(
          members ??
              [
                _member('me', 'Me', myRole),
                _member('ann', 'Ann', MemberRole.member),
              ],
        ),
      ),
    );
    when(
      () => repository.watchHabits('g1'),
    ).thenAnswer((_) => Stream.value(right(habits ?? [_habit()])));
  }

  /// Shows [page] on top of a home page, so leaving it (a pop) has somewhere to go.
  Future<GoRouter> pumpPage(WidgetTester tester, Widget page) async {
    // A tall phone, so a button near the bottom of a long page is on screen.
    tester.view.physicalSize = const Size(1200, 4800);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (c, s) => const Text('home page')),
        GoRoute(path: '/page', builder: (context, state) => page),
        GoRoute(path: '/groups', builder: (c, s) => const Text('groups tab')),
        GoRoute(
          path: '/groups/:id/settings',
          builder: (c, s) => const Text('settings page'),
        ),
        GoRoute(
          path: '/groups/:id/activity',
          builder: (c, s) => const Text('activity page'),
        ),
        GoRoute(
          path: '/groups/:id/habits/new',
          builder: (c, s) => const Text('new habit page'),
        ),
        GoRoute(
          path: '/groups/:gid/habits/:hid/edit',
          builder: (c, s) => const Text('edit page'),
        ),
      ],
    );
    await tester.pumpWidget(
      MaterialApp.router(theme: AppTheme.light(), routerConfig: router),
    );
    await tester.pumpAndSettle();
    unawaited(router.push('/page'));
    await tester.pumpAndSettle();
    return router;
  }

  group('group detail', () {
    testWidgets('an admin sees settings, activity and add habit', (
      tester,
    ) async {
      stubOverview(myRole: MemberRole.admin);
      await pumpPage(tester, const GroupDetailPage(groupId: 'g1'));

      expect(find.text('Group settings'), findsOneWidget);
      expect(find.text('Activity'), findsOneWidget);
      expect(find.text('Add habit'), findsOneWidget);
    });

    testWidgets('a plain member sees none of the admin tools', (tester) async {
      stubOverview(myRole: MemberRole.member);
      await pumpPage(tester, const GroupDetailPage(groupId: 'g1'));

      expect(find.text('Group settings'), findsNothing);
      expect(find.text('Activity'), findsNothing);
      expect(find.text('Add habit'), findsNothing);
      expect(find.text('Waiting to join'), findsNothing);
    });

    testWidgets('a member never even asks for the join requests', (
      tester,
    ) async {
      stubOverview(myRole: MemberRole.member);
      await pumpPage(tester, const GroupDetailPage(groupId: 'g1'));

      verifyNever(() => repository.watchJoinRequests(any()));
    });

    testWidgets('the settings button opens settings', (tester) async {
      stubOverview(myRole: MemberRole.owner);
      await pumpPage(tester, const GroupDetailPage(groupId: 'g1'));

      await tester.ensureVisible(find.text('Group settings'));
      await tester.tap(find.text('Group settings'));
      await tester.pumpAndSettle();

      expect(find.text('settings page'), findsOneWidget);
    });

    testWidgets('the activity button opens the log', (tester) async {
      stubOverview(myRole: MemberRole.admin);
      await pumpPage(tester, const GroupDetailPage(groupId: 'g1'));

      await tester.ensureVisible(find.text('Activity'));
      await tester.tap(find.text('Activity'));
      await tester.pumpAndSettle();

      expect(find.text('activity page'), findsOneWidget);
    });

    testWidgets('says new members need approval when the group asks for it', (
      tester,
    ) async {
      stubOverview(
        myRole: MemberRole.member,
        group: _group(requireApproval: true),
      );
      await pumpPage(tester, const GroupDetailPage(groupId: 'g1'));

      expect(find.textContaining('need an admin to approve'), findsOneWidget);
    });

    group('join requests', () {
      void stubRequests(List<JoinRequest> requests) {
        when(
          () => repository.watchJoinRequests('g1'),
        ).thenAnswer((_) => Stream.value(right(requests)));
      }

      testWidgets('an admin sees who is waiting', (tester) async {
        stubOverview(myRole: MemberRole.admin);
        stubRequests(const [
          JoinRequest(uid: 'bob', displayName: 'Bob'),
          JoinRequest(uid: 'cy', displayName: 'Cy'),
        ]);
        await pumpPage(tester, const GroupDetailPage(groupId: 'g1'));

        expect(find.text('WAITING TO JOIN (2)'), findsOneWidget);
        expect(find.text('Bob'), findsOneWidget);
        expect(find.text('Cy'), findsOneWidget);
        expect(find.text('Let in'), findsNWidgets(2));
      });

      testWidgets('nobody waiting means no section', (tester) async {
        stubOverview(myRole: MemberRole.admin);
        stubRequests(const []);
        await pumpPage(tester, const GroupDetailPage(groupId: 'g1'));

        expect(find.textContaining('WAITING TO JOIN'), findsNothing);
      });

      testWidgets('Let in approves that person', (tester) async {
        stubOverview(myRole: MemberRole.admin);
        stubRequests(const [JoinRequest(uid: 'bob', displayName: 'Bob')]);
        when(
          () => repository.reviewJoinRequest(
            groupId: any(named: 'groupId'),
            uid: any(named: 'uid'),
            approve: any(named: 'approve'),
          ),
        ).thenAnswer((_) async => right(unit));
        await pumpPage(tester, const GroupDetailPage(groupId: 'g1'));

        await tester.tap(find.text('Let in'));
        await tester.pumpAndSettle();

        verify(
          () => repository.reviewJoinRequest(
            groupId: 'g1',
            uid: 'bob',
            approve: true,
          ),
        ).called(1);
      });

      testWidgets('Decline rejects that person', (tester) async {
        stubOverview(myRole: MemberRole.admin);
        stubRequests(const [JoinRequest(uid: 'bob', displayName: 'Bob')]);
        when(
          () => repository.reviewJoinRequest(
            groupId: any(named: 'groupId'),
            uid: any(named: 'uid'),
            approve: any(named: 'approve'),
          ),
        ).thenAnswer((_) async => right(unit));
        await pumpPage(tester, const GroupDetailPage(groupId: 'g1'));

        await tester.tap(find.text('Decline'));
        await tester.pumpAndSettle();

        verify(
          () => repository.reviewJoinRequest(
            groupId: 'g1',
            uid: 'bob',
            approve: false,
          ),
        ).called(1);
      });

      testWidgets('a refusal from the server is shown', (tester) async {
        stubOverview(myRole: MemberRole.admin);
        stubRequests(const [JoinRequest(uid: 'bob', displayName: 'Bob')]);
        when(
          () => repository.reviewJoinRequest(
            groupId: any(named: 'groupId'),
            uid: any(named: 'uid'),
            approve: any(named: 'approve'),
          ),
        ).thenAnswer(
          (_) async =>
              left(const Failure.validation(message: 'This group is full.')),
        );
        await pumpPage(tester, const GroupDetailPage(groupId: 'g1'));

        await tester.tap(find.text('Let in'));
        await tester.pumpAndSettle();

        expect(find.text('This group is full.'), findsOneWidget);
      });
    });

    group('members list', () {
      List<GroupMember> many(int n) => [
        _member('me', 'Me', MemberRole.admin),
        for (var i = 1; i < n; i++)
          _member('u$i', 'Person $i', MemberRole.member),
      ];

      testWidgets('shows all of a small group', (tester) async {
        stubOverview(myRole: MemberRole.admin, members: many(5));
        await pumpPage(tester, const GroupDetailPage(groupId: 'g1'));

        expect(find.textContaining('Show all'), findsNothing);
      });

      testWidgets('a large group starts with 20 and can show the rest', (
        tester,
      ) async {
        stubOverview(myRole: MemberRole.admin, members: many(30));
        await pumpPage(tester, const GroupDetailPage(groupId: 'g1'));

        expect(find.byKey(const ValueKey('member-u19')), findsOneWidget);
        expect(find.byKey(const ValueKey('member-u20')), findsNothing);
        await tester.ensureVisible(find.text('Show all 30 members'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Show all 30 members'));
        await tester.pumpAndSettle();

        expect(find.text('Show all 30 members'), findsNothing);
        expect(find.byKey(const ValueKey('member-u29')), findsOneWidget);
      });
    });
  });

  group('group settings', () {
    setUp(() {
      when(
        () => repository.updateSettings(
          groupId: any(named: 'groupId'),
          name: any(named: 'name'),
          description: any(named: 'description'),
          membersCanInvite: any(named: 'membersCanInvite'),
          requireApproval: any(named: 'requireApproval'),
          emblem: any(named: 'emblem'),
        ),
      ).thenAnswer((_) async => right(unit));
    });

    testWidgets('a member is told it is for admins', (tester) async {
      stubOverview(myRole: MemberRole.member);
      await pumpPage(tester, const GroupSettingsPage(groupId: 'g1'));

      expect(find.textContaining('Only admins'), findsOneWidget);
      expect(find.text('Save'), findsNothing);
    });

    testWidgets('shows the current values', (tester) async {
      stubOverview(
        myRole: MemberRole.admin,
        group: _group(requireApproval: true, membersCanInvite: true),
      );
      await pumpPage(tester, const GroupSettingsPage(groupId: 'g1'));

      expect(find.text('Gym Bros'), findsOneWidget);
      expect(find.text('Lift things'), findsOneWidget);
      final switches = tester.widgetList<Switch>(find.byType(Switch)).toList();
      expect(switches.map((s) => s.value), [true, true]);
    });

    testWidgets('saving without a change just closes', (tester) async {
      stubOverview(myRole: MemberRole.admin);
      await pumpPage(tester, const GroupSettingsPage(groupId: 'g1'));

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      verifyNever(
        () => repository.updateSettings(
          groupId: any(named: 'groupId'),
          name: any(named: 'name'),
          description: any(named: 'description'),
          membersCanInvite: any(named: 'membersCanInvite'),
          requireApproval: any(named: 'requireApproval'),
          emblem: any(named: 'emblem'),
        ),
      );
    });

    testWidgets('sends only what changed', (tester) async {
      stubOverview(myRole: MemberRole.admin);
      await pumpPage(tester, const GroupSettingsPage(groupId: 'g1'));

      await tester.enterText(
        find.widgetWithText(TextField, 'Gym Bros'),
        'Iron Club',
      );
      await tester.tap(find.byType(Switch).last); // approve new members
      await tester.pump();
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      verify(
        () => repository.updateSettings(
          groupId: 'g1',
          name: 'Iron Club',
          description: null,
          membersCanInvite: null,
          requireApproval: true,
          emblem: null,
        ),
      ).called(1);
    });

    testWidgets('a new picture is sent', (tester) async {
      stubOverview(myRole: MemberRole.admin);
      await pumpPage(tester, const GroupSettingsPage(groupId: 'g1'));

      await tester.ensureVisible(find.byKey(const ValueKey('emblem-icon-run')));
      await tester.tap(find.byKey(const ValueKey('emblem-icon-run')));
      await tester.pump();
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      final sent =
          verify(
                () => repository.updateSettings(
                  groupId: 'g1',
                  name: null,
                  description: null,
                  membersCanInvite: null,
                  requireApproval: null,
                  emblem: captureAny(named: 'emblem'),
                ),
              ).captured.single
              as GroupEmblem;
      expect(sent.icon, 'run');
    });

    testWidgets('a blank name is refused before anything is sent', (
      tester,
    ) async {
      stubOverview(myRole: MemberRole.admin);
      await pumpPage(tester, const GroupSettingsPage(groupId: 'g1'));

      await tester.enterText(find.widgetWithText(TextField, 'Gym Bros'), '   ');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text('Give the group a name.'), findsOneWidget);
    });

    testWidgets('a server refusal is shown and the form stays', (tester) async {
      stubOverview(myRole: MemberRole.admin);
      when(
        () => repository.updateSettings(
          groupId: any(named: 'groupId'),
          name: any(named: 'name'),
          description: any(named: 'description'),
          membersCanInvite: any(named: 'membersCanInvite'),
          requireApproval: any(named: 'requireApproval'),
          emblem: any(named: 'emblem'),
        ),
      ).thenAnswer(
        (_) async =>
            left(const Failure.validation(message: 'Only admins can do this.')),
      );
      await pumpPage(tester, const GroupSettingsPage(groupId: 'g1'));

      await tester.enterText(find.widgetWithText(TextField, 'Gym Bros'), 'New');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text('Only admins can do this.'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
    });
  });

  group('edit group habit', () {
    void stubDetail(GroupHabit habit) {
      when(
        () => repository.watchHabit('g1', 'h1'),
      ).thenAnswer((_) => Stream.value(right(habit)));
      when(
        () => repository.watchCycle('g1', 'h1', today),
      ).thenAnswer((_) => Stream.value(right(null as CycleSnapshot?)));
      when(() => repository.watchMyCompletions('g1', 'h1')).thenAnswer(
        (_) => Stream.value(
          right(const MyCompletions(dates: {}, hasPendingWrites: false)),
        ),
      );
      when(
        () => repository.updateHabit(
          groupId: any(named: 'groupId'),
          habitId: any(named: 'habitId'),
          name: any(named: 'name'),
          description: any(named: 'description'),
          weekdays: any(named: 'weekdays'),
          target: any(named: 'target'),
          endDate: any(named: 'endDate'),
          clearEndDate: any(named: 'clearEndDate'),
        ),
      ).thenAnswer((_) async => right(unit));
    }

    Future<void> pumpEdit(WidgetTester tester) => pumpPage(
      tester,
      const GroupHabitEditPage(groupId: 'g1', habitId: 'h1'),
    );

    testWidgets('shows the habit as it is now', (tester) async {
      stubDetail(_habit(target: const CompletionRule.percentage(80)));
      await pumpEdit(tester);

      expect(find.text('Legs'), findsWidgets);
      expect(find.text('Squats'), findsOneWidget);
      expect(find.text('80'), findsOneWidget);
      expect(find.text('None'), findsOneWidget); // no end date
    });

    testWidgets('saving without a change just closes', (tester) async {
      stubDetail(_habit());
      await pumpEdit(tester);

      await tester.tap(find.text('Save changes'));
      await tester.pumpAndSettle();

      verifyNever(
        () => repository.updateHabit(
          groupId: any(named: 'groupId'),
          habitId: any(named: 'habitId'),
          name: any(named: 'name'),
          description: any(named: 'description'),
          weekdays: any(named: 'weekdays'),
          target: any(named: 'target'),
          endDate: any(named: 'endDate'),
          clearEndDate: any(named: 'clearEndDate'),
        ),
      );
    });

    testWidgets('a rename sends only the name', (tester) async {
      stubDetail(_habit());
      await pumpEdit(tester);

      await tester.enterText(find.widgetWithText(TextField, 'Legs'), 'Leg day');
      await tester.tap(find.text('Save changes'));
      await tester.pumpAndSettle();

      verify(
        () => repository.updateHabit(
          groupId: 'g1',
          habitId: 'h1',
          name: 'Leg day',
          description: null,
          weekdays: null,
          target: null,
          endDate: null,
          clearEndDate: false,
        ),
      ).called(1);
    });

    testWidgets('changing days warns they start in two days', (tester) async {
      stubDetail(_habit());
      await pumpEdit(tester);
      expect(find.byKey(const Key('schedule-note')), findsNothing);

      await tester.ensureVisible(find.text('Sun ✓'));
      await tester.tap(find.text('Sun ✓'));
      await tester.pump();

      expect(find.byKey(const Key('schedule-note')), findsOneWidget);
      expect(find.textContaining('start in two days'), findsOneWidget);
    });

    testWidgets('the warning goes away when the change is undone', (
      tester,
    ) async {
      stubDetail(_habit());
      await pumpEdit(tester);

      await tester.ensureVisible(find.text('Sun ✓'));
      await tester.tap(find.text('Sun ✓'));
      await tester.pump();
      await tester.tap(find.text('Sun'));
      await tester.pump();

      expect(find.byKey(const Key('schedule-note')), findsNothing);
    });

    testWidgets('mentions a change that is already queued', (tester) async {
      stubDetail(_habit(pendingFrom: DateKey.parse('2026-10-20')));
      await pumpEdit(tester);

      expect(find.textContaining('already queued'), findsOneWidget);
      expect(find.textContaining('20 Oct 2026'), findsOneWidget);
    });

    testWidgets('clearing an end date sends the clear flag', (tester) async {
      stubDetail(_habit(endDate: DateKey.parse('2026-12-31')));
      await pumpEdit(tester);

      await tester.ensureVisible(find.text('Clear'));
      await tester.tap(find.text('Clear'));
      await tester.pump();
      await tester.tap(find.text('Save changes'));
      await tester.pumpAndSettle();

      verify(
        () => repository.updateHabit(
          groupId: 'g1',
          habitId: 'h1',
          name: null,
          description: null,
          weekdays: null,
          target: null,
          endDate: null,
          clearEndDate: true,
        ),
      ).called(1);
    });

    testWidgets('no days selected is refused with a clear message', (
      tester,
    ) async {
      stubDetail(_habit(weekdays: const {1}));
      await pumpEdit(tester);

      await tester.ensureVisible(find.text('Mon ✓'));
      await tester.tap(find.text('Mon ✓'));
      await tester.pump();
      await tester.tap(find.text('Save changes'));
      await tester.pumpAndSettle();

      expect(find.text('Pick at least one day of the week.'), findsOneWidget);
    });
  });

  group('activity log', () {
    testWidgets('lists what happened in words, with names', (tester) async {
      stubOverview(myRole: MemberRole.admin);
      when(
        () => repository.watchAudit('g1', limit: any(named: 'limit')),
      ).thenAnswer(
        (_) => Stream.value(
          right([
            AuditEntry(
              id: 'a2',
              action: 'member.removed',
              actorUid: 'me',
              at: DateTime(2026, 10, 18, 9, 30),
              details: const {'uid': 'ann'},
            ),
            AuditEntry(
              id: 'a1',
              action: 'group.created',
              actorUid: 'me',
              at: DateTime(2026, 10, 1, 8),
              details: const {},
            ),
          ]),
        ),
      );
      await pumpPage(tester, const GroupActivityPage(groupId: 'g1'));

      expect(find.text('Me removed Ann'), findsOneWidget);
      expect(find.text('Me created the group'), findsOneWidget);
      expect(find.textContaining('18 Oct 2026, 09:30'), findsOneWidget);
    });

    testWidgets('an empty log says so', (tester) async {
      stubOverview(myRole: MemberRole.admin);
      when(
        () => repository.watchAudit('g1', limit: any(named: 'limit')),
      ).thenAnswer((_) => Stream.value(right(const <AuditEntry>[])));
      await pumpPage(tester, const GroupActivityPage(groupId: 'g1'));

      expect(find.text('Nothing has happened yet.'), findsOneWidget);
    });

    testWidgets('a full page offers older entries', (tester) async {
      stubOverview(myRole: MemberRole.admin);
      when(
        () => repository.watchAudit('g1', limit: any(named: 'limit')),
      ).thenAnswer((invocation) {
        final limit = invocation.namedArguments[#limit] as int;
        return Stream.value(
          right([
            for (var i = 0; i < limit; i++)
              AuditEntry(
                id: 'a$i',
                action: 'member.left',
                actorUid: 'me',
                at: DateTime(2026, 10, 18, 9, i % 60),
                details: const {},
              ),
          ]),
        );
      });
      await pumpPage(tester, const GroupActivityPage(groupId: 'g1'));
      final more = find.text('Show older');
      await tester.ensureVisible(more);
      await tester.pumpAndSettle();

      await tester.tap(more);
      await tester.pumpAndSettle();

      verify(
        () => repository.watchAudit('g1', limit: 60),
      ).called(greaterThan(0));
    });

    testWidgets('a person who lost access is told so, not shown an error', (
      tester,
    ) async {
      stubOverview(myRole: MemberRole.admin);
      when(
        () => repository.watchAudit('g1', limit: any(named: 'limit')),
      ).thenAnswer((_) => Stream.value(left(const Failure.unauthenticated())));
      await pumpPage(tester, const GroupActivityPage(groupId: 'g1'));

      expect(find.text('No access'), findsOneWidget);
    });
  });
}

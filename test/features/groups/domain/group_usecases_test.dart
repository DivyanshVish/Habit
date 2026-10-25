import 'package:fpdart/fpdart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/core/error/failure.dart';
import 'package:habit_tracker/core/platform/platform_services.dart';
import 'package:habit_tracker/core/time/date_key.dart';
import 'package:habit_tracker/core/usecase/usecase.dart';
import 'package:habit_tracker/features/groups/data/datasources/group_remote_data_source.dart';
import 'package:habit_tracker/features/groups/data/repositories/group_repository_impl.dart';
import 'package:habit_tracker/features/groups/domain/entities/completion_rule.dart';
import 'package:habit_tracker/features/groups/domain/entities/cycle_snapshot.dart';
import 'package:habit_tracker/features/groups/domain/entities/group_entities.dart';
import 'package:habit_tracker/features/groups/domain/repositories/group_repository.dart';
import 'package:habit_tracker/features/groups/domain/services/streak_history_calculator.dart';
import 'package:habit_tracker/features/groups/domain/usecases/group_usecases.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fakes.dart';

class MockGroupRepository extends Mock implements GroupRepository {}

class MockRemote extends Mock implements GroupRemoteDataSource {}

GroupHabit _habit({
  Set<int> weekdays = const {1, 2, 3, 4, 5, 6, 7},
  String start = '2026-10-01',
}) => GroupHabit(
  id: 'h1',
  name: 'Run',
  description: '',
  weekdays: weekdays,
  target: const CompletionRule.majority(),
  startDate: DateKey.parse(start),
  endDate: null,
  archived: false,
  groupStreak: const GroupStreak(current: 0, best: 0),
  pendingFrom: null,
);

CycleSnapshot _cycle({
  List<String> eligible = const ['a', 'b', 'c', 'd', 'e'],
  int completed = 3,
}) => CycleSnapshot(
  dateKey: DateKey.parse('2026-10-18'),
  eligibleUids: eligible,
  visibleCompletedUids: const [],
  completedCount: completed,
  rule: const CompletionRule.percentage(80),
  closed: false,
);

void main() {
  late MockGroupRepository repository;

  setUpAll(() {
    registerFallbackValue(MemberRole.member);
    registerFallbackValue(DateKey.parse('2026-01-01'));
    registerFallbackValue(
      NewGroupHabit(
        name: 'x',
        description: '',
        weekdays: const {1},
        target: const CompletionRule.majority(),
        startDate: DateKey.parse('2026-01-01'),
      ),
    );
  });

  setUp(() {
    repository = MockGroupRepository();
  });

  Failure? failureOf<T>(Either<Failure, T> result) =>
      result.getLeft().toNullable();

  group('CreateGroup', () {
    setUp(() {
      when(
        () => repository.createGroup(
          name: any(named: 'name'),
          description: any(named: 'description'),
          membersCanInvite: any(named: 'membersCanInvite'),
        ),
      ).thenAnswer((_) async => right('g1'));
    });

    test('trims and passes the input through', () async {
      final result = await CreateGroup(repository)(
        const CreateGroupParams(name: '  Runners  ', description: ' Hi '),
      );

      expect(result, right('g1'));
      verify(
        () => repository.createGroup(
          name: 'Runners',
          description: 'Hi',
          membersCanInvite: false,
        ),
      ).called(1);
    });

    for (final (label, params) in [
      ('a blank name', const CreateGroupParams(name: '   ')),
      ('a 61 character name', CreateGroupParams(name: 'x' * 61)),
      (
        'a 301 character description',
        CreateGroupParams(name: 'ok', description: 'x' * 301),
      ),
    ]) {
      test('rejects $label without calling the server', () async {
        final result = await CreateGroup(repository)(params);

        expect(failureOf(result), isA<ValidationFailure>());
        verifyNever(
          () => repository.createGroup(
            name: any(named: 'name'),
            description: any(named: 'description'),
            membersCanInvite: any(named: 'membersCanInvite'),
          ),
        );
      });
    }

    test('accepts the longest allowed values', () async {
      final result = await CreateGroup(repository)(
        CreateGroupParams(name: 'x' * 60, description: 'y' * 300),
      );
      expect(result.isRight(), isTrue);
    });
  });

  group('CreateGroupHabit', () {
    CreateGroupHabitParams params({
      String name = 'Run',
      String description = '',
      Set<int> weekdays = const {1, 2, 3},
      CompletionRule target = const CompletionRule.majority(),
      String start = '2026-10-18',
      String? end,
    }) => CreateGroupHabitParams(
      groupId: 'g1',
      name: name,
      description: description,
      weekdays: weekdays,
      target: target,
      startDate: DateKey.parse(start),
      endDate: end == null ? null : DateKey.parse(end),
    );

    setUp(() {
      when(
        () => repository.createHabit(any(), any()),
      ).thenAnswer((_) async => right('h1'));
    });

    final invalid = <String, CreateGroupHabitParams>{
      'blank name': params(name: ' '),
      'name over 60': params(name: 'x' * 61),
      'description over 200': params(description: 'x' * 201),
      'no weekdays': params(weekdays: const {}),
      'weekday 0': params(weekdays: const {0, 1}),
      'weekday 8': params(weekdays: const {8}),
      'fixed target of 0': params(target: const CompletionRule.fixed(0)),
      'percentage of 101': params(target: const CompletionRule.percentage(101)),
      'end before start': params(start: '2026-10-18', end: '2026-10-17'),
    };
    invalid.forEach((label, input) {
      test('rejects $label', () async {
        final result = await CreateGroupHabit(repository)(input);

        expect(failureOf(result), isA<ValidationFailure>());
        verifyNever(() => repository.createHabit(any(), any()));
      });
    });

    test('accepts a one day habit (end equals start)', () async {
      final result = await CreateGroupHabit(repository)(
        params(start: '2026-10-18', end: '2026-10-18'),
      );
      expect(result, right('h1'));
    });

    test('sends the trimmed habit to the repository', () async {
      await CreateGroupHabit(repository)(params(name: ' Run '));

      final habit =
          verify(
                () => repository.createHabit('g1', captureAny()),
              ).captured.single
              as NewGroupHabit;
      expect(habit.name, 'Run');
      expect(habit.weekdays, {1, 2, 3});
    });
  });

  group('UpdateGroupSettings', () {
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

    test('trims the name and sends only what was given', () async {
      await UpdateGroupSettings(repository)(
        const UpdateGroupSettingsParams(groupId: 'g1', name: '  New  '),
      );

      verify(
        () => repository.updateSettings(
          groupId: 'g1',
          name: 'New',
          description: null,
          membersCanInvite: null,
          requireApproval: null,
          emblem: null,
        ),
      ).called(1);
    });

    for (final (label, params) in [
      (
        'a blank name',
        const UpdateGroupSettingsParams(groupId: 'g1', name: '  '),
      ),
      (
        'a 61 character name',
        UpdateGroupSettingsParams(groupId: 'g1', name: 'x' * 61),
      ),
      (
        'a 301 character description',
        UpdateGroupSettingsParams(groupId: 'g1', description: 'x' * 301),
      ),
    ]) {
      test('rejects $label', () async {
        final result = await UpdateGroupSettings(repository)(params);

        expect(failureOf(result), isA<ValidationFailure>());
      });
    }

    test('clearing the description is allowed', () async {
      final result = await UpdateGroupSettings(repository)(
        const UpdateGroupSettingsParams(groupId: 'g1', description: ''),
      );

      expect(result.isRight(), isTrue);
    });
  });

  group('UpdateGroupHabit', () {
    setUp(() {
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
    });

    final invalid = <String, UpdateGroupHabitParams>{
      'blank name': const UpdateGroupHabitParams(
        groupId: 'g',
        habitId: 'h',
        name: ' ',
      ),
      'name over 60': UpdateGroupHabitParams(
        groupId: 'g',
        habitId: 'h',
        name: 'x' * 61,
      ),
      'description over 200': UpdateGroupHabitParams(
        groupId: 'g',
        habitId: 'h',
        description: 'x' * 201,
      ),
      'no weekdays': const UpdateGroupHabitParams(
        groupId: 'g',
        habitId: 'h',
        weekdays: {},
      ),
      'weekday 8': const UpdateGroupHabitParams(
        groupId: 'g',
        habitId: 'h',
        weekdays: {8},
      ),
      'fixed target of 0': const UpdateGroupHabitParams(
        groupId: 'g',
        habitId: 'h',
        target: CompletionRule.fixed(0),
      ),
      'percentage of 101': const UpdateGroupHabitParams(
        groupId: 'g',
        habitId: 'h',
        target: CompletionRule.percentage(101),
      ),
      'end before start': UpdateGroupHabitParams(
        groupId: 'g',
        habitId: 'h',
        startDate: DateKey.parse('2026-10-18'),
        endDate: DateKey.parse('2026-10-17'),
      ),
    };
    invalid.forEach((label, params) {
      test('rejects $label', () async {
        final result = await UpdateGroupHabit(repository)(params);

        expect(failureOf(result), isA<ValidationFailure>());
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
    });

    test('accepts a change of target and days', () async {
      final result = await UpdateGroupHabit(repository)(
        const UpdateGroupHabitParams(
          groupId: 'g',
          habitId: 'h',
          weekdays: {1, 3, 5},
          target: CompletionRule.percentage(80),
        ),
      );

      expect(result.isRight(), isTrue);
    });

    test('an end date on the start date is fine (a one day habit)', () async {
      final result = await UpdateGroupHabit(repository)(
        UpdateGroupHabitParams(
          groupId: 'g',
          habitId: 'h',
          startDate: DateKey.parse('2026-10-18'),
          endDate: DateKey.parse('2026-10-18'),
        ),
      );

      expect(result.isRight(), isTrue);
    });
  });

  group('SetMemberRole', () {
    test('cannot make someone the owner', () async {
      final result = await SetMemberRole(repository)(
        const SetMemberRoleParams('g1', 'bob', MemberRole.owner),
      );

      expect(failureOf(result), isA<ValidationFailure>());
      verifyNever(() => repository.setRole(any(), any(), any()));
    });

    test('promotes to admin', () async {
      when(
        () => repository.setRole('g1', 'bob', MemberRole.admin),
      ).thenAnswer((_) async => right(unit));

      final result = await SetMemberRole(repository)(
        const SetMemberRoleParams('g1', 'bob', MemberRole.admin),
      );

      expect(result.isRight(), isTrue);
    });
  });

  group('WatchMemberships', () {
    GroupMembership membership(
      String name, {
      MembershipStatus status = MembershipStatus.active,
      bool archived = false,
    }) => GroupMembership(
      groupId: name,
      groupName: name,
      role: MemberRole.member,
      status: status,
      groupArchived: archived,
    );

    test('hides groups I left and sinks archived ones', () async {
      when(() => repository.watchMemberships()).thenAnswer(
        (_) => Stream.value(
          right([
            membership('zeta'),
            membership('Alpha'),
            membership('old', archived: true),
            membership('gone', status: MembershipStatus.left),
            membership('kicked', status: MembershipStatus.removed),
          ]),
        ),
      );

      final result = await WatchMemberships(repository)(const NoParams()).first;

      expect(result.getRight().toNullable()!.map((m) => m.groupName), [
        'Alpha',
        'zeta',
        'old',
      ]);
    });

    test('passes failures through', () async {
      when(
        () => repository.watchMemberships(),
      ).thenAnswer((_) => Stream.value(left(const Failure.network())));

      final result = await WatchMemberships(repository)(const NoParams()).first;

      expect(failureOf(result), isA<NetworkFailure>());
    });
  });

  group('WatchGroupHabitDetail', () {
    final clock = FixedClock(DateTime(2026, 10, 18, 9));

    void stub({
      GroupHabit? habit,
      CycleSnapshot? cycle,
      Set<DateKey> done = const {},
      bool pending = false,
    }) {
      when(
        () => repository.watchHabit('g1', 'h1'),
      ).thenAnswer((_) => Stream.value(right(habit ?? _habit())));
      when(
        () => repository.watchCycle('g1', 'h1', DateKey.parse('2026-10-18')),
      ).thenAnswer((_) => Stream.value(right(cycle)));
      when(() => repository.watchMyCompletions('g1', 'h1')).thenAnswer(
        (_) => Stream.value(
          right(MyCompletions(dates: done, hasPendingWrites: pending)),
        ),
      );
    }

    WatchGroupHabitDetail build() => WatchGroupHabitDetail(
      repository,
      clock,
      const StreakHistoryCalculator(),
    );

    test('combines the habit, today cycle and my own streak', () async {
      stub(
        cycle: _cycle(),
        done: {
          DateKey.parse('2026-10-16'),
          DateKey.parse('2026-10-17'),
          DateKey.parse('2026-10-18'),
        },
      );

      final detail = (await build()(
        const GroupHabitRef(groupId: 'g1', habitId: 'h1'),
      ).first).getRight().toNullable()!;

      expect(detail.today, DateKey.parse('2026-10-18'));
      expect(detail.doneToday, isTrue);
      expect(detail.personalStats.currentStreak, 3);
      expect(detail.cycle!.progress.required, 4); // 80% of 5
      expect(detail.cycle!.progress.remaining, 1);
      expect(detail.pendingSync, isFalse);
    });

    test('includes weekly and monthly history of my own completions', () async {
      stub(
        cycle: _cycle(),
        done: {
          DateKey.parse('2026-10-16'),
          DateKey.parse('2026-10-17'),
          DateKey.parse('2026-10-18'),
        },
      );

      final detail = (await build()(
        const GroupHabitRef(groupId: 'g1', habitId: 'h1'),
      ).first).getRight().toNullable()!;

      // 2026-10-18 is a Sunday, so the week runs Mon 12th to Sun 18th.
      final week = detail.history.weeks.last;
      expect(week.start, DateKey.parse('2026-10-12'));
      expect(week.done, 3);
      expect(detail.history.months.last.start, DateKey.parse('2026-10-01'));
    });

    test('a member who joined after the day opened is not eligible', () async {
      stub(cycle: _cycle(eligible: const ['a', 'b']));

      final detail = (await build()(
        const GroupHabitRef(groupId: 'g1', habitId: 'h1'),
      ).first).getRight().toNullable()!;

      expect(detail.isEligible('a'), isTrue);
      expect(detail.isEligible('late-joiner'), isFalse);
    });

    test('no cycle yet still lets the member tick the habit', () async {
      stub(cycle: null, done: {DateKey.parse('2026-10-18')});

      final detail = (await build()(
        const GroupHabitRef(groupId: 'g1', habitId: 'h1'),
      ).first).getRight().toNullable()!;

      expect(detail.cycle, isNull);
      expect(detail.doneToday, isTrue);
      expect(detail.isEligible('a'), isFalse);
    });

    test('reports a completion that is still waiting to sync', () async {
      stub(cycle: _cycle(), pending: true);

      final detail = (await build()(
        const GroupHabitRef(groupId: 'g1', habitId: 'h1'),
      ).first).getRight().toNullable()!;

      expect(detail.pendingSync, isTrue);
    });

    test(
      'a missed day does not reset anyone else (only my records count)',
      () async {
        stub(
          cycle: _cycle(completed: 0),
          done: {DateKey.parse('2026-10-17'), DateKey.parse('2026-10-18')},
        );

        final detail = (await build()(
          const GroupHabitRef(groupId: 'g1', habitId: 'h1'),
        ).first).getRight().toNullable()!;

        // The group did not reach its target today, but my own streak is intact.
        expect(detail.cycle!.progress.reached, isFalse);
        expect(detail.personalStats.currentStreak, 2);
      },
    );

    test('a failure from any source becomes a single Left', () async {
      when(
        () => repository.watchHabit('g1', 'h1'),
      ).thenAnswer((_) => Stream.value(left(const Failure.notFound())));
      when(
        () => repository.watchCycle(any(), any(), any()),
      ).thenAnswer((_) => Stream.value(right(null)));
      when(() => repository.watchMyCompletions(any(), any())).thenAnswer(
        (_) => Stream.value(
          right(const MyCompletions(dates: {}, hasPendingWrites: false)),
        ),
      );

      final result = await build()(
        const GroupHabitRef(groupId: 'g1', habitId: 'h1'),
      ).first;

      expect(failureOf(result), isA<NotFoundFailure>());
    });
  });

  group('WatchGroupOverview', () {
    test('finds my role and drops members who left', () async {
      when(() => repository.watchGroup('g1')).thenAnswer(
        (_) => Stream.value(
          right(
            const HabitGroup(
              id: 'g1',
              name: 'Runners',
              description: '',
              ownerUid: 'alice',
              memberCount: 2,
              membersCanInvite: false,
              archived: false,
            ),
          ),
        ),
      );
      when(() => repository.watchMembers('g1')).thenAnswer(
        (_) => Stream.value(
          right(const [
            GroupMember(
              uid: 'alice',
              displayName: 'Alice',
              role: MemberRole.owner,
              active: true,
            ),
            GroupMember(
              uid: 'bob',
              displayName: 'Bob',
              role: MemberRole.admin,
              active: true,
            ),
            GroupMember(
              uid: 'carl',
              displayName: 'Carl',
              role: MemberRole.member,
              active: false,
            ),
          ]),
        ),
      );
      when(
        () => repository.watchHabits('g1'),
      ).thenAnswer((_) => Stream.value(right([_habit()])));

      final overview = (await WatchGroupOverview(repository)(
        const WatchGroupOverviewParams(groupId: 'g1', myUid: 'bob'),
      ).first).getRight().toNullable()!;

      expect(overview.myRole, MemberRole.admin);
      expect(overview.members.map((m) => m.uid), ['alice', 'bob']);
      expect(overview.habits, hasLength(1));
    });
  });

  group('GroupRepositoryImpl failure mapping', () {
    late MockRemote remote;
    late GroupRepositoryImpl impl;

    setUp(() {
      remote = MockRemote();
      impl = GroupRepositoryImpl(remote);
    });

    final cases = <String, Matcher>{
      'permission-denied': isA<UnauthenticatedFailure>(),
      'unauthenticated': isA<UnauthenticatedFailure>(),
      'not-found': isA<NotFoundFailure>(),
      'unavailable': isA<NetworkFailure>(),
      'failed-precondition': isA<ValidationFailure>(),
      'already-exists': isA<ValidationFailure>(),
      'resource-exhausted': isA<ValidationFailure>(),
      'invalid-argument': isA<ValidationFailure>(),
      'internal': isA<ServerFailure>(),
    };
    cases.forEach((code, matcher) {
      test('callable "$code" becomes the right Failure', () async {
        when(
          () => remote.leave(any()),
        ).thenThrow(CallableException(code, 'Transfer ownership first.'));

        final result = await impl.leave('g1');

        expect(failureOf(result), matcher);
      });
    });

    test('the server message is kept for validation failures', () async {
      when(() => remote.leave(any())).thenThrow(
        const CallableException(
          'failed-precondition',
          'Transfer ownership before leaving, or archive the group.',
        ),
      );

      final result = await impl.leave('g1');

      expect(
        failureOf(result)!.message,
        'Transfer ownership before leaving, or archive the group.',
      );
    });

    test('a stream error becomes a Left and ends the stream', () async {
      when(() => remote.watchGroup('g1')).thenAnswer(
        (_) => Stream.error(const CallableException('unavailable', 'x')),
      );

      final events = await impl.watchGroup('g1').toList();

      expect(events, hasLength(1));
      expect(failureOf(events.single), isA<NetworkFailure>());
    });
  });
}

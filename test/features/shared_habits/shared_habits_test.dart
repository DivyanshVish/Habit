import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:habit_tracker/core/error/exceptions.dart';
import 'package:habit_tracker/core/error/failure.dart';
import 'package:habit_tracker/core/time/date_key.dart';
import 'package:habit_tracker/core/usecase/usecase.dart';
import 'package:habit_tracker/features/groups/domain/entities/completion_rule.dart';
import 'package:habit_tracker/features/groups/domain/entities/cycle_snapshot.dart';
import 'package:habit_tracker/features/groups/domain/entities/group_entities.dart';
import 'package:habit_tracker/features/groups/domain/services/streak_history_calculator.dart';
import 'package:habit_tracker/features/shared_habits/data/datasources/shared_habit_remote_data_source.dart';
import 'package:habit_tracker/features/shared_habits/domain/entities/shared_habit_entities.dart';
import 'package:habit_tracker/features/shared_habits/domain/repositories/shared_habit_repository.dart';
import 'package:habit_tracker/features/shared_habits/domain/usecases/shared_habit_usecases.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fakes.dart';

class MockSharedRepository extends Mock implements SharedHabitRepository {}

SharedHabit _habit({
  String id = 's1',
  String name = 'Read',
  bool archived = false,
}) => SharedHabit(
  id: id,
  name: name,
  description: '',
  points: 10,
  ownerUid: 'alice',
  weekdays: const {1, 2, 3, 4, 5, 6, 7},
  startDate: DateKey.parse('2026-10-01'),
  participantCount: 5,
  archived: archived,
);

void main() {
  late FakeFirebaseFirestore firestore;
  late FakeCallableClient callable;

  SharedHabitRemoteDataSourceImpl source(String? uid) =>
      SharedHabitRemoteDataSourceImpl(
        firestore: firestore,
        userIdProvider: FakeUserIdProvider(uid),
        callable: callable,
      );

  setUpAll(() {
    registerFallbackValue(DateKey.parse('2026-01-01'));
    registerFallbackValue(
      NewSharedHabit(
        name: 'x',
        description: '',
        points: 1,
        weekdays: const {1},
        startDate: DateKey.parse('2026-01-01'),
      ),
    );
  });

  setUp(() {
    firestore = FakeFirebaseFirestore();
    callable = FakeCallableClient();
  });

  group('data source', () {
    test('lists only shared habits I take part in', () async {
      await firestore.doc('sharedHabits/s1').set({
        'name': 'Read',
        'ownerUid': 'alice',
        'startDate': '2026-10-01',
        'status': 'active',
        'participantUids': ['alice', 'bob'],
        'participantCount': 2,
        'points': 10,
      });
      await firestore.doc('sharedHabits/s2').set({
        'name': 'Secret',
        'ownerUid': 'carl',
        'startDate': '2026-10-01',
        'status': 'active',
        'participantUids': ['carl'],
      });

      final mine = await source('bob').watchMine().first;

      expect(mine.map((h) => h.id), ['s1']);
      expect(mine.single.participantCount, 2);
    });

    test(
      'a left participant is marked inactive but kept in the list',
      () async {
        await firestore.doc('sharedHabits/s1/participants/alice').set({
          'displayName': 'Alice',
          'status': 'active',
          'joinedAt': Timestamp.fromDate(DateTime(2026, 10, 1)),
        });
        await firestore.doc('sharedHabits/s1/participants/bob').set({
          'displayName': 'Bob',
          'status': 'left',
          'joinedAt': Timestamp.fromDate(DateTime(2026, 10, 2)),
        });

        final people = await source('alice').watchParticipants('s1').first;

        expect(people.map((p) => (p.displayName, p.active)), [
          ('Alice', true),
          ('Bob', false),
        ]);
      },
    );

    test('shows 3 of 5 as 60 percent from the cycle', () async {
      await firestore.doc('sharedHabits/s1/cycles/2026-10-18').set({
        'eligibleUids': ['a', 'b', 'c', 'd', 'e'],
        'visibleCompletedUids': ['a', 'b', 'c'],
        'completedCount': 3,
        'rule': {'type': 'individual'},
        'closed': false,
      });

      final cycle = await source(
        'a',
      ).watchCycle('s1', DateKey.parse('2026-10-18')).first;

      expect(cycle!.completedCount, 3);
      expect(cycle.eligibleCount, 5);
      expect(cycle.progress.percent, 60);
      expect(cycle.pendingCount, 2);
    });

    test('a repeated completion leaves a single record', () async {
      final day = DateKey.parse('2026-10-18');
      final bob = source('bob');
      for (var i = 0; i < 3; i++) {
        await bob.setCompletion(sharedId: 's1', dateKey: day, done: true);
      }

      final all = await firestore
          .collection('sharedHabits/s1/completions')
          .get();
      expect(all.docs.map((d) => d.id), ['bob_2026-10-18']);
      expect(all.docs.single.data()['uid'], 'bob');
    });

    test('undo removes only my completion', () async {
      final day = DateKey.parse('2026-10-18');
      await source(
        'alice',
      ).setCompletion(sharedId: 's1', dateKey: day, done: true);
      await source(
        'bob',
      ).setCompletion(sharedId: 's1', dateKey: day, done: true);

      await source(
        'bob',
      ).setCompletion(sharedId: 's1', dateKey: day, done: false);

      final all = await firestore
          .collection('sharedHabits/s1/completions')
          .get();
      expect(all.docs.map((d) => d.id), ['alice_2026-10-18']);
    });

    test('create sends the form and the link to a personal habit', () async {
      callable.responses['createSharedHabit'] = {'sharedHabitId': 's9'};

      final id = await source('alice').create(
        NewSharedHabit(
          name: 'Read',
          description: 'Daily',
          points: 15,
          weekdays: const {3, 1},
          startDate: DateKey.parse('2026-10-18'),
          sourceHabitId: 'personal-1',
        ),
      );

      expect(id, 's9');
      expect(callable.calls.single.data, {
        'name': 'Read',
        'description': 'Daily',
        'points': 15,
        'weekdays': [1, 3],
        'startDate': '2026-10-18',
        'sourceHabitId': 'personal-1',
      });
    });

    test('saving a completion asks the server to recompute that day', () async {
      await source('bob').setCompletion(
        sharedId: 's1',
        dateKey: DateKey.parse('2026-10-18'),
        done: true,
      );
      await Future<void>.delayed(Duration.zero);

      expect(callable.calls.single.name, 'refreshCycle');
      expect(callable.calls.single.data, {
        'kind': 'shared',
        'sharedId': 's1',
        'dateKey': '2026-10-18',
      });
    });

    test('a missing habit surfaces as NotFoundException', () {
      expect(
        source('alice').watchHabit('nope').first,
        throwsA(isA<NotFoundException>()),
      );
    });

    test('signed-out users are rejected', () {
      expect(
        () => source(null).watchMine(),
        throwsA(isA<UnauthenticatedException>()),
      );
    });
  });

  group('use cases', () {
    late MockSharedRepository repository;

    setUp(() => repository = MockSharedRepository());

    test(
      'WatchSharedHabits lists active first, then archived, alphabetically',
      () async {
        when(() => repository.watchMine()).thenAnswer(
          (_) => Stream.value(
            right([
              _habit(id: '1', name: 'zebra'),
              _habit(id: '2', name: 'Old', archived: true),
              _habit(id: '3', name: 'apple'),
            ]),
          ),
        );

        final result = await WatchSharedHabits(repository)(
          const NoParams(),
        ).first;

        expect(result.getRight().toNullable()!.map((h) => h.id), [
          '3',
          '1',
          '2',
        ]);
      },
    );

    group('CreateSharedHabit', () {
      setUp(() {
        when(
          () => repository.create(any()),
        ).thenAnswer((_) async => right('s1'));
      });

      CreateSharedHabitParams params({
        String name = 'Read',
        String description = '',
        int points = 10,
        Set<int> weekdays = const {1, 2},
      }) => CreateSharedHabitParams(
        name: name,
        description: description,
        points: points,
        weekdays: weekdays,
        startDate: DateKey.parse('2026-10-18'),
      );

      final invalid = <String, CreateSharedHabitParams>{
        'blank name': params(name: '  '),
        'name over 60': params(name: 'x' * 61),
        'description over 200': params(description: 'x' * 201),
        'points 0': params(points: 0),
        'points 1001': params(points: 1001),
        'no weekdays': params(weekdays: const {}),
        'weekday 9': params(weekdays: const {9}),
      };
      invalid.forEach((label, input) {
        test('rejects $label', () async {
          final result = await CreateSharedHabit(repository)(input);

          expect(result.getLeft().toNullable(), isA<ValidationFailure>());
          verifyNever(() => repository.create(any()));
        });
      });

      test('trims the input and links the personal habit', () async {
        await CreateSharedHabit(repository)(
          CreateSharedHabitParams(
            name: ' Read ',
            startDate: DateKey.parse('2026-10-18'),
            sourceHabitId: 'p1',
          ),
        );

        final sent =
            verify(() => repository.create(captureAny())).captured.single
                as NewSharedHabit;
        expect(sent.name, 'Read');
        expect(sent.sourceHabitId, 'p1');
      });
    });

    group('WatchSharedHabitDetail', () {
      final clock = FixedClock(DateTime(2026, 10, 18, 9));
      final today = DateKey.parse('2026-10-18');

      CycleSnapshot cycle(int completed) => CycleSnapshot(
        dateKey: today,
        eligibleUids: const ['a', 'b', 'c', 'd', 'e'],
        visibleCompletedUids: const [],
        completedCount: completed,
        rule: const CompletionRule.individual(),
        closed: false,
      );

      void stub({
        int completed = 3,
        Set<DateKey> done = const {},
        bool pending = false,
      }) {
        when(
          () => repository.watchHabit('s1'),
        ).thenAnswer((_) => Stream.value(right(_habit())));
        when(() => repository.watchParticipants('s1')).thenAnswer(
          (_) => Stream.value(
            right(const [
              SharedParticipant(uid: 'a', displayName: 'Ann', active: true),
            ]),
          ),
        );
        when(
          () => repository.watchCycle('s1', today),
        ).thenAnswer((_) => Stream.value(right(cycle(completed))));
        when(() => repository.watchMyCompletions('s1')).thenAnswer(
          (_) => Stream.value(
            right(MyCompletions(dates: done, hasPendingWrites: pending)),
          ),
        );
      }

      WatchSharedHabitDetail build() => WatchSharedHabitDetail(
        repository,
        clock,
        const StreakHistoryCalculator(),
      );

      test('3 of 5 is 60 percent and my own streak is separate', () async {
        stub(done: {DateKey.parse('2026-10-17'), today});

        final detail = (await build()('s1').first).getRight().toNullable()!;

        expect(detail.cycle!.completedCount, 3);
        expect(detail.cycle!.progress.percent, 60);
        expect(detail.doneToday, isTrue);
        expect(detail.personalStats.currentStreak, 2);
        expect(detail.participants, hasLength(1));
      });

      test('shows the pending flag while offline', () async {
        stub(pending: true);

        final detail = (await build()('s1').first).getRight().toNullable()!;

        expect(detail.pendingSync, isTrue);
      });

      test('turns a failure into a single Left', () async {
        stub();
        when(() => repository.watchHabit('s1')).thenAnswer(
          (_) => Stream.value(left(const Failure.unauthenticated())),
        );

        final result = await build()('s1').first;

        expect(result.getLeft().toNullable(), isA<UnauthenticatedFailure>());
      });
    });
  });
}

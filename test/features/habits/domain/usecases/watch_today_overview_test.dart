import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:habit_tracker/core/error/failure.dart';
import 'package:habit_tracker/core/time/date_key.dart';
import 'package:habit_tracker/core/usecase/usecase.dart';
import 'package:habit_tracker/features/habits/domain/entities/completion.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit_streak.dart';
import 'package:habit_tracker/features/habits/domain/entities/today_overview.dart';
import 'package:habit_tracker/features/habits/domain/repositories/habit_repository.dart';
import 'package:habit_tracker/features/habits/domain/services/streak_calculator.dart';
import 'package:habit_tracker/features/habits/domain/usecases/watch_today_overview.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/builders.dart';
import '../../../../helpers/fakes.dart';

class _MockHabitRepository extends Mock implements HabitRepository {}

void main() {
  late _MockHabitRepository repository;
  late WatchTodayOverview watchTodayOverview;
  const today = DateKey(2026, 10, 17);

  setUp(() {
    repository = _MockHabitRepository();
    watchTodayOverview = WatchTodayOverview(
      repository,
      FixedClock(DateTime(2026, 10, 17, 22)),
      const StreakCalculator(),
    );
  });

  void stubWatches({
    required Stream<Either<Failure, List<Habit>>> habits,
    required Stream<Either<Failure, List<Completion>>> completions,
  }) {
    when(() => repository.watchHabits()).thenAnswer((_) => habits);
    when(
      () => repository.watchCompletions(from: today.minusDays(6), to: today),
    ).thenAnswer((_) => completions);
  }

  test('marks habits done from today\'s completions and sums points', () async {
    stubWatches(
      habits: Stream.value(
        right([
          buildHabit(id: 'water', points: 10),
          buildHabit(id: 'read', points: 20),
          buildHabit(id: 'run', points: 15),
        ]),
      ),
      completions: Stream.value(
        right([const Completion(habitId: 'read', dateKey: today)]),
      ),
    );

    final result = await watchTodayOverview(const NoParams()).first;
    final overview = result.getOrElse(
      (_) => throw StateError('expected right'),
    );

    expect(overview.date, today);
    expect(overview.totalCount, 3);
    expect(overview.doneCount, 1);
    expect(overview.totalPoints, 45);
    expect(overview.earnedPoints, 20);
    expect(overview.progress, closeTo(20 / 45, 1e-9));
    expect(overview.items.map((i) => (i.habit.id, i.isDone)), [
      ('water', false),
      ('read', true),
      ('run', false),
    ]);
  });

  test('ignores completions for other days', () async {
    stubWatches(
      habits: Stream.value(right([buildHabit(id: 'water')])),
      completions: Stream.value(
        right([Completion(habitId: 'water', dateKey: today.minusDays(1))]),
      ),
    );

    final overview = (await watchTodayOverview(
      const NoParams(),
    ).first).getOrElse((_) => throw StateError('expected right'));

    expect(overview.doneCount, 0);
    expect(overview.earnedPoints, 0);
  });

  test('handles zero habits without dividing by zero', () async {
    stubWatches(
      habits: Stream.value(right(<Habit>[])),
      completions: Stream.value(right(<Completion>[])),
    );

    final overview = (await watchTodayOverview(
      const NoParams(),
    ).first).getOrElse((_) => throw StateError('expected right'));

    expect(overview.items, isEmpty);
    expect(overview.progress, 0);
    expect(overview.totalPoints, 0);
  });

  test('emits a new overview whenever either stream changes', () async {
    final habits = StreamController<Either<Failure, List<Habit>>>();
    final completions = StreamController<Either<Failure, List<Completion>>>();
    addTearDown(habits.close);
    addTearDown(completions.close);
    stubWatches(habits: habits.stream, completions: completions.stream);

    final emitted = <TodayOverview>[];
    final subscription = watchTodayOverview(
      const NoParams(),
    ).listen((result) => result.map(emitted.add));
    addTearDown(subscription.cancel);

    habits.add(right([buildHabit(id: 'water', points: 10)]));
    completions.add(right(<Completion>[]));
    await pumpEventQueue();
    completions.add(
      right([const Completion(habitId: 'water', dateKey: today)]),
    );
    await pumpEventQueue();

    expect(emitted.map((o) => o.earnedPoints), [0, 10]);
  });

  test('propagates a failure from either source', () async {
    stubWatches(
      habits: Stream.value(left(const Failure.network())),
      completions: Stream.value(right(<Completion>[])),
    );

    final result = await watchTodayOverview(const NoParams()).first;

    expect(result, left<Failure, TodayOverview>(const Failure.network()));
  });

  Future<TodayOverview> firstOverview() async => (await watchTodayOverview(
    const NoParams(),
  ).first).getOrElse((_) => throw StateError('expected right'));

  test('requests the 7-day completion window exactly once', () async {
    stubWatches(
      habits: Stream.value(right([buildHabit(id: 'water')])),
      completions: Stream.value(right(<Completion>[])),
    );

    await firstOverview();

    verify(
      () => repository.watchCompletions(from: today.minusDays(6), to: today),
    ).called(1);
    verifyNever(() => repository.watchCompletions(from: today, to: today));
  });

  test('attaches a 7-day streak, oldest first, ending today', () async {
    stubWatches(
      habits: Stream.value(right([buildHabit(id: 'water')])),
      completions: Stream.value(
        right([
          Completion(habitId: 'water', dateKey: today.minusDays(2)),
          const Completion(habitId: 'water', dateKey: today),
        ]),
      ),
    );

    final streak = (await firstOverview()).items.single.streak;

    expect(streak.days, hasLength(7));
    expect(streak.days.first.date, today.minusDays(6));
    expect(streak.days.last.date, today);
    expect(streak.days.last.isToday, isTrue);
    expect(streak.days.where((d) => d.isToday), hasLength(1));
    expect(
      streak.days.where((d) => d.status == DayStatus.done).map((d) => d.date),
      [today.minusDays(2), today],
    );
    expect(streak.currentStreak, 1);
  });

  test('counts a run ending yesterday while today is still open', () async {
    stubWatches(
      habits: Stream.value(right([buildHabit(id: 'water')])),
      completions: Stream.value(
        right([
          for (final offset in [1, 2, 3])
            Completion(habitId: 'water', dateKey: today.minusDays(offset)),
        ]),
      ),
    );

    final item = (await firstOverview()).items.single;

    expect(item.isDone, isFalse);
    expect(item.streak.isDoneToday, isFalse);
    expect(item.streak.currentStreak, 3);
  });

  test('ignores other habits\' completions when building a streak', () async {
    stubWatches(
      habits: Stream.value(
        right([buildHabit(id: 'water'), buildHabit(id: 'read')]),
      ),
      completions: Stream.value(
        right([
          const Completion(habitId: 'read', dateKey: today),
          Completion(habitId: 'read', dateKey: today.minusDays(1)),
        ]),
      ),
    );

    final items = (await firstOverview()).items;

    expect(items[0].habit.id, 'water');
    expect(items[0].streak.doneCount, 0);
    expect(items[0].streak.currentStreak, 0);
    expect(items[1].habit.id, 'read');
    expect(items[1].streak.doneCount, 2);
    expect(items[1].streak.currentStreak, 2);
  });

  test('ignores completions outside the 7-day window', () async {
    stubWatches(
      habits: Stream.value(right([buildHabit(id: 'water')])),
      completions: Stream.value(
        right([
          Completion(habitId: 'water', dateKey: today.minusDays(7)),
          Completion(habitId: 'water', dateKey: today.minusDays(10)),
          Completion(habitId: 'water', dateKey: today.plusDays(1)),
        ]),
      ),
    );

    final item = (await firstOverview()).items.single;

    expect(item.isDone, isFalse);
    expect(item.streak.doneCount, 0);
    expect(item.streak.currentStreak, 0);
  });

  test('marks days before the habit was created as not applicable', () async {
    stubWatches(
      habits: Stream.value(
        right([buildHabit(id: 'water', createdDateKey: today.minusDays(2))]),
      ),
      completions: Stream.value(right(<Completion>[])),
    );

    final days = (await firstOverview()).items.single.streak.days;

    expect(days.map((d) => d.status), [
      ...List.filled(4, DayStatus.notApplicable),
      ...List.filled(3, DayStatus.missed),
    ]);
  });

  test('isDone is true only for a completion dated today', () async {
    stubWatches(
      habits: Stream.value(
        right([buildHabit(id: 'water'), buildHabit(id: 'read')]),
      ),
      completions: Stream.value(
        right([
          Completion(habitId: 'water', dateKey: today.minusDays(1)),
          const Completion(habitId: 'read', dateKey: today),
        ]),
      ),
    );

    final items = (await firstOverview()).items;

    expect(items.map((i) => (i.habit.id, i.isDone)), [
      ('water', false),
      ('read', true),
    ]);
    expect(items.map((i) => i.streak.isDoneToday), [false, true]);
  });

  test('propagates a failure from the completions stream', () async {
    stubWatches(
      habits: Stream.value(right([buildHabit(id: 'water')])),
      completions: Stream.value(left(const Failure.network())),
    );

    final result = await watchTodayOverview(const NoParams()).first;

    expect(result, left<Failure, TodayOverview>(const Failure.network()));
  });
}

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:habit_tracker/core/error/failure.dart';
import 'package:habit_tracker/core/time/date_key.dart';
import 'package:habit_tracker/features/habits/domain/entities/completion.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit_detail.dart';
import 'package:habit_tracker/features/habits/domain/repositories/habit_repository.dart';
import 'package:habit_tracker/features/habits/domain/services/streak_calculator.dart';
import 'package:habit_tracker/features/habits/domain/usecases/watch_habit_detail.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/builders.dart';
import '../../../../helpers/fakes.dart';

class _MockHabitRepository extends Mock implements HabitRepository {}

void main() {
  late _MockHabitRepository repository;
  late WatchHabitDetail watchHabitDetail;
  const today = DateKey(2026, 10, 17);
  const params = WatchHabitDetailParams(habitId: 'h1');

  setUp(() {
    repository = _MockHabitRepository();
    watchHabitDetail = WatchHabitDetail(
      repository,
      FixedClock(DateTime(2026, 10, 17, 8)),
      const StreakCalculator(),
    );
  });

  void stubWatches({
    required Stream<Either<Failure, Habit>> habit,
    required Stream<Either<Failure, List<Completion>>> completions,
  }) {
    when(() => repository.watchHabit('h1')).thenAnswer((_) => habit);
    when(
      () => repository.watchCompletions(from: today.minusDays(6), to: today),
    ).thenAnswer((_) => completions);
  }

  test('combines the habit with a 7 day streak ending today', () async {
    stubWatches(
      habit: Stream.value(
        right(buildHabit(id: 'h1', createdDateKey: today.minusDays(20))),
      ),
      completions: Stream.value(
        right([
          const Completion(habitId: 'h1', dateKey: today),
          Completion(habitId: 'h1', dateKey: today.minusDays(1)),
        ]),
      ),
    );

    final detail = (await watchHabitDetail(
      params,
    ).first).getOrElse((_) => throw StateError('expected right'));

    expect(detail.habit.id, 'h1');
    expect(detail.today, today);
    expect(detail.streak.days, hasLength(7));
    expect(detail.streak.currentStreak, 2);
    expect(detail.streak.isDoneToday, isTrue);
  });

  test('updates when today is toggled', () async {
    final completions = StreamController<Either<Failure, List<Completion>>>();
    addTearDown(completions.close);
    stubWatches(
      habit: Stream.value(
        right(buildHabit(id: 'h1', createdDateKey: today.minusDays(20))),
      ),
      completions: completions.stream,
    );

    final doneFlags = <bool>[];
    final subscription = watchHabitDetail(params).listen(
      (r) => r.map((HabitDetail d) => doneFlags.add(d.streak.isDoneToday)),
    );
    addTearDown(subscription.cancel);

    completions.add(right(<Completion>[]));
    await pumpEventQueue();
    completions.add(right([const Completion(habitId: 'h1', dateKey: today)]));
    await pumpEventQueue();
    completions.add(right(<Completion>[]));
    await pumpEventQueue();

    expect(doneFlags, [false, true, false]);
  });

  test('propagates a not-found habit', () async {
    stubWatches(
      habit: Stream.value(left(const Failure.notFound())),
      completions: Stream.value(right(<Completion>[])),
    );

    final result = await watchHabitDetail(params).first;

    expect(result, left<Failure, HabitDetail>(const Failure.notFound()));
  });

  test('propagates a completions failure', () async {
    stubWatches(
      habit: Stream.value(right(buildHabit(id: 'h1'))),
      completions: Stream.value(left(const Failure.network())),
    );

    final result = await watchHabitDetail(params).first;

    expect(result, left<Failure, HabitDetail>(const Failure.network()));
  });
}

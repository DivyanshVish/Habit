import 'package:fpdart/fpdart.dart';
import 'package:habit_tracker/core/error/failure.dart';
import 'package:habit_tracker/core/time/clock.dart';
import 'package:habit_tracker/core/usecase/usecase.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit_with_status.dart';
import 'package:habit_tracker/features/habits/domain/entities/today_overview.dart';
import 'package:habit_tracker/features/habits/domain/repositories/habit_repository.dart';
import 'package:habit_tracker/features/habits/domain/services/streak_calculator.dart';
import 'package:rxdart/rxdart.dart';

/// Live view of today's habits, their done status, 7-day streak and progress
/// totals.
class WatchTodayOverview implements StreamUseCase<TodayOverview, NoParams> {
  WatchTodayOverview(this._repository, this._clock, this._calculator);

  final HabitRepository _repository;
  final Clock _clock;
  final StreakCalculator _calculator;

  @override
  Stream<Either<Failure, TodayOverview>> call(NoParams params) {
    final today = _clock.today();
    final windowStart = today.minusDays(StreakCalculator.defaultWindowDays - 1);

    return Rx.combineLatest2(
      _repository.watchHabits(),
      _repository.watchCompletions(from: windowStart, to: today),
      (habitsResult, completionsResult) => habitsResult.flatMap(
        (habits) => completionsResult.map((completions) {
          final doneIds = {
            for (final completion in completions)
              if (completion.dateKey == today) completion.habitId,
          };
          return TodayOverview(
            date: today,
            items: [
              for (final habit in habits)
                HabitWithStatus(
                  habit: habit,
                  isDone: doneIds.contains(habit.id),
                  streak: _calculator.calculate(
                    habit: habit,
                    completions: completions,
                    today: today,
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }
}

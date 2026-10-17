import 'package:fpdart/fpdart.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:habit_tracker/core/error/failure.dart';
import 'package:habit_tracker/core/time/clock.dart';
import 'package:habit_tracker/core/usecase/usecase.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit_detail.dart';
import 'package:habit_tracker/features/habits/domain/repositories/habit_repository.dart';
import 'package:habit_tracker/features/habits/domain/services/streak_calculator.dart';
import 'package:rxdart/rxdart.dart';

part 'watch_habit_detail.freezed.dart';

@freezed
abstract class WatchHabitDetailParams with _$WatchHabitDetailParams {
  const factory WatchHabitDetailParams({required String habitId}) =
      _WatchHabitDetailParams;
}

/// Live habit plus its 7-day streak.
class WatchHabitDetail
    implements StreamUseCase<HabitDetail, WatchHabitDetailParams> {
  WatchHabitDetail(this._repository, this._clock, this._calculator);

  final HabitRepository _repository;
  final Clock _clock;
  final StreakCalculator _calculator;

  @override
  Stream<Either<Failure, HabitDetail>> call(WatchHabitDetailParams params) {
    final today = _clock.today();
    final windowStart = today.minusDays(StreakCalculator.defaultWindowDays - 1);

    return Rx.combineLatest2(
      _repository.watchHabit(params.habitId),
      _repository.watchCompletions(from: windowStart, to: today),
      (habitResult, completionsResult) => habitResult.flatMap(
        (habit) => completionsResult.map(
          (completions) => HabitDetail(
            habit: habit,
            today: today,
            streak: _calculator.calculate(
              habit: habit,
              completions: completions,
              today: today,
            ),
          ),
        ),
      ),
    );
  }
}

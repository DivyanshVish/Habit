import 'package:fpdart/fpdart.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:habit_tracker/core/error/failure.dart';
import 'package:habit_tracker/core/time/date_key.dart';
import 'package:habit_tracker/core/usecase/usecase.dart';
import 'package:habit_tracker/features/habits/domain/repositories/habit_repository.dart';

part 'toggle_habit_completion.freezed.dart';

/// [dateKey] is the day the user is looking at (not "now"), so a screen left
/// open past midnight still toggles the day it displays.
@freezed
abstract class ToggleHabitCompletionParams with _$ToggleHabitCompletionParams {
  const factory ToggleHabitCompletionParams({
    required String habitId,
    required DateKey dateKey,
    required bool done,
  }) = _ToggleHabitCompletionParams;
}

class ToggleHabitCompletion
    implements UseCase<Unit, ToggleHabitCompletionParams> {
  ToggleHabitCompletion(this._repository);

  final HabitRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(ToggleHabitCompletionParams params) {
    return _repository.setCompletion(
      habitId: params.habitId,
      dateKey: params.dateKey,
      done: params.done,
    );
  }
}

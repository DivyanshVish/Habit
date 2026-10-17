import 'package:fpdart/fpdart.dart';
import 'package:habit_tracker/core/error/failure.dart';
import 'package:habit_tracker/core/time/date_key.dart';
import 'package:habit_tracker/features/habits/domain/entities/completion.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit.dart';
import 'package:habit_tracker/features/habits/domain/entities/new_habit.dart';

/// Contract implemented by the data layer. The interface grows slice by slice.
abstract interface class HabitRepository {
  /// Live list of all habits, oldest first.
  Stream<Either<Failure, List<Habit>>> watchHabits();

  /// Live view of one habit. Emits a `NotFoundFailure` (and ends) when the
  /// habit does not exist or is deleted while being watched.
  Stream<Either<Failure, Habit>> watchHabit(String habitId);

  /// Live completions whose date is within [from]..[to] (inclusive).
  Stream<Either<Failure, List<Completion>>> watchCompletions({
    required DateKey from,
    required DateKey to,
  });

  Future<Either<Failure, Unit>> addHabit(NewHabit habit);

  /// Deletes the habit together with all of its completions.
  Future<Either<Failure, Unit>> deleteHabit(String habitId);

  /// Idempotently marks [habitId] done or not done on [dateKey].
  Future<Either<Failure, Unit>> setCompletion({
    required String habitId,
    required DateKey dateKey,
    required bool done,
  });
}

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit_streak.dart';

part 'habit_with_status.freezed.dart';

/// A habit together with whether it is done for a particular day, and how its
/// last days went.
@freezed
abstract class HabitWithStatus with _$HabitWithStatus {
  const factory HabitWithStatus({
    required Habit habit,
    required bool isDone,
    required HabitStreak streak,
  }) = _HabitWithStatus;
}

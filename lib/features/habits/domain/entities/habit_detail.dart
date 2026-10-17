import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:habit_tracker/core/time/date_key.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit_streak.dart';

part 'habit_detail.freezed.dart';

/// Everything the Habit Detail screen shows.
@freezed
abstract class HabitDetail with _$HabitDetail {
  const factory HabitDetail({
    required Habit habit,
    required HabitStreak streak,

    /// The day the screen is showing as "today".
    required DateKey today,
  }) = _HabitDetail;
}

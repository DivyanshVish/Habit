import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:habit_tracker/core/time/date_key.dart';

part 'habit_streak.freezed.dart';

enum DayStatus {
  /// The habit was completed that day.
  done,

  /// The habit existed that day but was not completed.
  missed,

  /// The day is before the habit was created, so it cannot be missed.
  notApplicable,
}

@freezed
abstract class StreakDay with _$StreakDay {
  const factory StreakDay({
    required DateKey date,
    required DayStatus status,
    required bool isToday,
  }) = _StreakDay;
}

/// How a habit went over a window of days ending today (oldest first).
@freezed
abstract class HabitStreak with _$HabitStreak {
  const HabitStreak._();

  const factory HabitStreak({
    required List<StreakDay> days,

    /// Consecutive done days ending today, or ending yesterday while today is
    /// still open. Only looks inside [days].
    required int currentStreak,
  }) = _HabitStreak;

  int get doneCount => days.where((d) => d.status == DayStatus.done).length;

  bool get isDoneToday => days.isNotEmpty && days.last.status == DayStatus.done;
}

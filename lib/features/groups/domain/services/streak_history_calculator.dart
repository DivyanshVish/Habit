import 'package:habit_tracker/core/time/date_key.dart';
import 'package:habit_tracker/features/groups/domain/entities/streak_stats.dart';

/// Streaks over the whole history of a habit (the existing 7-day
/// `StreakCalculator` is untouched).
///
/// Only scheduled days count. Days the habit is not scheduled on neither
/// extend nor break a streak. A scheduled day that is still open today never
/// counts as missed.
class StreakHistoryCalculator {
  const StreakHistoryCalculator();

  static const Set<int> everyDay = {1, 2, 3, 4, 5, 6, 7};

  StreakStats calculate({
    required Set<DateKey> doneDates,
    required DateKey start,
    required DateKey today,
    Set<int> scheduledWeekdays = everyDay,
  }) {
    if (today.isBefore(start) || scheduledWeekdays.isEmpty) {
      return StreakStats.empty;
    }

    var completed = 0;
    var missed = 0;
    var run = 0;
    var best = 0;
    var current = 0;

    var date = start;
    while (!date.isAfter(today)) {
      if (scheduledWeekdays.contains(date.weekday)) {
        final done = doneDates.contains(date);
        if (done) {
          completed++;
          run++;
          if (run > best) best = run;
        } else if (date == today) {
          // Still open. It neither extends nor breaks the run yet.
        } else {
          missed++;
          run = 0;
        }
      }
      date = date.plusDays(1);
    }
    current = run;

    return StreakStats(
      currentStreak: current,
      bestStreak: best,
      completed: completed,
      missed: missed,
    );
  }
}

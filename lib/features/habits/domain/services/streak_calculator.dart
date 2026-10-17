import 'package:habit_tracker/core/time/date_key.dart';
import 'package:habit_tracker/features/habits/domain/entities/completion.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit_streak.dart';

/// Pure logic that turns a habit and its completions into a [HabitStreak].
class StreakCalculator {
  const StreakCalculator();

  static const int defaultWindowDays = 7;

  /// The window is the [windowDays] days ending on [today] (inclusive).
  HabitStreak calculate({
    required Habit habit,
    required Iterable<Completion> completions,
    required DateKey today,
    int windowDays = defaultWindowDays,
  }) {
    assert(windowDays > 0, 'windowDays must be positive');

    final doneDates = {
      for (final completion in completions)
        if (completion.habitId == habit.id) completion.dateKey,
    };

    final days = [
      for (var offset = windowDays - 1; offset >= 0; offset--)
        _dayFor(
          date: today.minusDays(offset),
          today: today,
          habit: habit,
          doneDates: doneDates,
        ),
    ];

    return HabitStreak(days: days, currentStreak: _currentStreak(days));
  }

  StreakDay _dayFor({
    required DateKey date,
    required DateKey today,
    required Habit habit,
    required Set<DateKey> doneDates,
  }) {
    final DayStatus status;
    if (date.isBefore(habit.createdDateKey)) {
      status = DayStatus.notApplicable;
    } else if (doneDates.contains(date)) {
      status = DayStatus.done;
    } else {
      status = DayStatus.missed;
    }
    return StreakDay(date: date, status: status, isToday: date == today);
  }

  /// Counts consecutive done days walking back from today. Today not being
  /// done yet does not break the streak; it only breaks once the day passes.
  int _currentStreak(List<StreakDay> days) {
    var index = days.length - 1;
    if (index >= 0 && days[index].status != DayStatus.done) {
      index--;
    }
    var streak = 0;
    while (index >= 0 && days[index].status == DayStatus.done) {
      streak++;
      index--;
    }
    return streak;
  }
}

import 'package:habit_tracker/core/time/date_key.dart';
import 'package:habit_tracker/features/habits/domain/entities/completion.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit_streak.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit_with_status.dart';
import 'package:habit_tracker/features/habits/domain/services/streak_calculator.dart';

/// Test data builder for domain habits (never used by app code).
Habit buildHabit({
  String id = 'h1',
  String name = 'Drink 2L water',
  String description = '',
  int points = 10,
  DateTime? createdAt,
  DateKey createdDateKey = const DateKey(2026, 10, 1),
}) {
  return Habit(
    id: id,
    name: name,
    description: description,
    points: points,
    createdAt: createdAt ?? createdDateKey.toDateTime(),
    createdDateKey: createdDateKey,
  );
}

/// Builds a [HabitStreak] through the real [StreakCalculator].
///
/// [doneOffsets] are days before [today] (0 = today). The habit was created
/// [createdDaysAgo] days before [today] unless [habit] is given.
HabitStreak buildStreak({
  List<int> doneOffsets = const [],
  int createdDaysAgo = 30,
  DateKey today = const DateKey(2026, 10, 17),
  Habit? habit,
}) {
  final subject =
      habit ??
      buildHabit(id: 'h1', createdDateKey: today.minusDays(createdDaysAgo));
  return const StreakCalculator().calculate(
    habit: subject,
    completions: [
      for (final offset in doneOffsets)
        Completion(habitId: subject.id, dateKey: today.minusDays(offset)),
    ],
    today: today,
  );
}

/// Builds a [HabitWithStatus]. When [streak] is omitted it is derived from
/// [isDone] (done today, or not done at all).
HabitWithStatus buildItem({
  Habit? habit,
  bool isDone = false,
  HabitStreak? streak,
}) {
  final subject = habit ?? buildHabit();
  return HabitWithStatus(
    habit: subject,
    isDone: isDone,
    streak:
        streak ??
        buildStreak(habit: subject, doneOffsets: isDone ? const [0] : const []),
  );
}

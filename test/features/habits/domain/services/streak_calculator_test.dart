import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/core/time/date_key.dart';
import 'package:habit_tracker/features/habits/domain/entities/completion.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit_streak.dart';
import 'package:habit_tracker/features/habits/domain/services/streak_calculator.dart';

import '../../../../helpers/builders.dart';

void main() {
  const calculator = StreakCalculator();
  const today = DateKey(2026, 10, 17);

  /// Completions for [habit] on the given day offsets back from [today].
  List<Completion> doneOn(
    List<int> offsets, {
    String habitId = 'h1',
    DateKey at = today,
  }) => [
    for (final offset in offsets)
      Completion(habitId: habitId, dateKey: at.minusDays(offset)),
  ];

  List<DayStatus> statuses(HabitStreak streak) =>
      streak.days.map((d) => d.status).toList();

  const done = DayStatus.done;
  const missed = DayStatus.missed;
  const na = DayStatus.notApplicable;

  group('window shape', () {
    test('has 7 consecutive days, oldest first, ending today', () {
      final streak = calculator.calculate(
        habit: buildHabit(createdDateKey: today.minusDays(30)),
        completions: const [],
        today: today,
      );

      expect(streak.days, hasLength(7));
      expect(streak.days.first.date, today.minusDays(6));
      expect(streak.days.last.date, today);
      expect(streak.days.where((d) => d.isToday), hasLength(1));
      expect(streak.days.last.isToday, isTrue);
    });

    test('window follows the calendar across a month boundary', () {
      const march = DateKey(2026, 3, 3);
      final streak = calculator.calculate(
        habit: buildHabit(createdDateKey: const DateKey(2026, 1, 1)),
        completions: const [],
        today: march,
      );

      expect(streak.days.map((d) => d.date.value), [
        '2026-02-25',
        '2026-02-26',
        '2026-02-27',
        '2026-02-28',
        '2026-03-01',
        '2026-03-02',
        '2026-03-03',
      ]);
    });

    test('supports other window sizes', () {
      final streak = calculator.calculate(
        habit: buildHabit(createdDateKey: today.minusDays(30)),
        completions: doneOn([0, 1]),
        today: today,
        windowDays: 3,
      );

      expect(streak.days, hasLength(3));
      expect(statuses(streak), [missed, done, done]);
      expect(streak.currentStreak, 2);
    });
  });

  group('statuses and streak', () {
    // offsets are days back from today (0 = today). Expected statuses are
    // oldest to newest (6 days ago ... today).
    final cases =
        <
          ({
            String label,
            int createdDaysAgo,
            List<int> doneOffsets,
            List<DayStatus> expected,
            int streak,
            int doneCount,
          })
        >[
          (
            label: 'brand new habit created today, nothing done yet',
            createdDaysAgo: 0,
            doneOffsets: [],
            expected: [na, na, na, na, na, na, missed],
            streak: 0,
            doneCount: 0,
          ),
          (
            label: 'created today and done today',
            createdDaysAgo: 0,
            doneOffsets: [0],
            expected: [na, na, na, na, na, na, done],
            streak: 1,
            doneCount: 1,
          ),
          (
            label: 'created 2 days ago, done every day',
            createdDaysAgo: 2,
            doneOffsets: [0, 1, 2],
            expected: [na, na, na, na, done, done, done],
            streak: 3,
            doneCount: 3,
          ),
          (
            label: 'all 7 days done',
            createdDaysAgo: 30,
            doneOffsets: [0, 1, 2, 3, 4, 5, 6],
            expected: [done, done, done, done, done, done, done],
            streak: 7,
            doneCount: 7,
          ),
          (
            label: 'nothing done in a long-lived habit',
            createdDaysAgo: 30,
            doneOffsets: [],
            expected: [missed, missed, missed, missed, missed, missed, missed],
            streak: 0,
            doneCount: 0,
          ),
          (
            label: 'today not done yet keeps the streak alive from yesterday',
            createdDaysAgo: 30,
            doneOffsets: [1, 2, 3],
            expected: [missed, missed, missed, done, done, done, missed],
            streak: 3,
            doneCount: 3,
          ),
          (
            label: 'a gap yesterday breaks the streak even if today is done',
            createdDaysAgo: 30,
            doneOffsets: [0, 2, 3],
            expected: [missed, missed, missed, done, done, missed, done],
            streak: 1,
            doneCount: 3,
          ),
          (
            label: 'a gap before yesterday ends the run',
            createdDaysAgo: 30,
            doneOffsets: [1, 2, 4, 5],
            expected: [missed, done, done, missed, done, done, missed],
            streak: 2,
            doneCount: 4,
          ),
          (
            label: 'missed yesterday and today means streak is 0',
            createdDaysAgo: 30,
            doneOffsets: [2, 3, 4],
            expected: [missed, missed, done, done, done, missed, missed],
            streak: 0,
            doneCount: 3,
          ),
          (
            label: 'only the oldest day in the window done',
            createdDaysAgo: 30,
            doneOffsets: [6],
            expected: [done, missed, missed, missed, missed, missed, missed],
            streak: 0,
            doneCount: 1,
          ),
          (
            label: 'run reaches the start of the window',
            createdDaysAgo: 30,
            doneOffsets: [0, 1, 2, 3, 4, 5, 6],
            expected: [done, done, done, done, done, done, done],
            streak: 7,
            doneCount: 7,
          ),
          (
            label: 'created yesterday, done only yesterday',
            createdDaysAgo: 1,
            doneOffsets: [1],
            expected: [na, na, na, na, na, done, missed],
            streak: 1,
            doneCount: 1,
          ),
        ];

    for (final c in cases) {
      test(c.label, () {
        final streak = calculator.calculate(
          habit: buildHabit(createdDateKey: today.minusDays(c.createdDaysAgo)),
          completions: doneOn(c.doneOffsets),
          today: today,
        );

        expect(statuses(streak), c.expected);
        expect(streak.currentStreak, c.streak);
        expect(streak.doneCount, c.doneCount);
      });
    }
  });

  group('isDoneToday', () {
    test('true only when today is done', () {
      final habit = buildHabit(createdDateKey: today.minusDays(30));

      expect(
        calculator
            .calculate(habit: habit, completions: doneOn([0]), today: today)
            .isDoneToday,
        isTrue,
      );
      expect(
        calculator
            .calculate(habit: habit, completions: doneOn([1]), today: today)
            .isDoneToday,
        isFalse,
      );
    });
  });

  group('input filtering', () {
    test('ignores completions that belong to other habits', () {
      final streak = calculator.calculate(
        habit: buildHabit(id: 'mine', createdDateKey: today.minusDays(30)),
        completions: [
          ...doneOn([0, 1], habitId: 'someone-else'),
          ...doneOn([0], habitId: 'mine'),
        ],
        today: today,
      );

      expect(streak.doneCount, 1);
      expect(streak.currentStreak, 1);
    });

    test('ignores completions outside the window', () {
      final streak = calculator.calculate(
        habit: buildHabit(createdDateKey: today.minusDays(30)),
        completions: doneOn([7, 8, 20]),
        today: today,
      );

      expect(streak.doneCount, 0);
      expect(streak.currentStreak, 0);
    });

    test('duplicate completions for a day count once', () {
      final streak = calculator.calculate(
        habit: buildHabit(createdDateKey: today.minusDays(30)),
        completions: doneOn([0, 0, 0]),
        today: today,
      );

      expect(streak.doneCount, 1);
    });
  });

  group('crossing calendar boundaries', () {
    test('streak continues across a month end', () {
      const march = DateKey(2026, 3, 2);
      final streak = calculator.calculate(
        habit: buildHabit(createdDateKey: const DateKey(2026, 1, 1)),
        completions: [
          const Completion(habitId: 'h1', dateKey: DateKey(2026, 2, 27)),
          const Completion(habitId: 'h1', dateKey: DateKey(2026, 2, 28)),
          const Completion(habitId: 'h1', dateKey: DateKey(2026, 3, 1)),
          const Completion(habitId: 'h1', dateKey: DateKey(2026, 3, 2)),
        ],
        today: march,
      );

      expect(streak.currentStreak, 4);
    });

    test('streak continues across a year end', () {
      const newYear = DateKey(2027, 1, 2);
      final streak = calculator.calculate(
        habit: buildHabit(createdDateKey: const DateKey(2026, 1, 1)),
        completions: [
          const Completion(habitId: 'h1', dateKey: DateKey(2026, 12, 31)),
          const Completion(habitId: 'h1', dateKey: DateKey(2027, 1, 1)),
          const Completion(habitId: 'h1', dateKey: DateKey(2027, 1, 2)),
        ],
        today: newYear,
      );

      expect(streak.currentStreak, 3);
    });

    test('streak continues across a leap day', () {
      const march = DateKey(2028, 3, 1);
      final streak = calculator.calculate(
        habit: buildHabit(createdDateKey: const DateKey(2028, 1, 1)),
        completions: [
          const Completion(habitId: 'h1', dateKey: DateKey(2028, 2, 28)),
          const Completion(habitId: 'h1', dateKey: DateKey(2028, 2, 29)),
          const Completion(habitId: 'h1', dateKey: DateKey(2028, 3, 1)),
        ],
        today: march,
      );

      expect(streak.currentStreak, 3);
    });
  });
}

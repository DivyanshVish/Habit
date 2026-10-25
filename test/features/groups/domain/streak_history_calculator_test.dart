import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/core/time/date_key.dart';
import 'package:habit_tracker/features/groups/domain/entities/streak_stats.dart';
import 'package:habit_tracker/features/groups/domain/services/streak_history_calculator.dart';

DateKey _d(String value) => DateKey.parse(value);

Set<DateKey> _range(String from, int days) {
  final start = _d(from);
  return {for (var i = 0; i < days; i++) start.plusDays(i)};
}

void main() {
  const calculator = StreakHistoryCalculator();

  group('shared fixtures (same file as the TypeScript calculator)', () {
    final fixtures =
        jsonDecode(
              File(
                'test/fixtures/streak_history_cases.json',
              ).readAsStringSync(),
            )
            as Map<String, dynamic>;
    for (final c in (fixtures['cases'] as List).cast<Map<String, dynamic>>()) {
      test(c['name'] as String, () {
        final expected = c['expect'] as Map<String, dynamic>;
        final weekdays = c['weekdays'] as List?;
        final actual = calculator.calculate(
          doneDates: {
            for (final value in (c['done'] as List).cast<String>())
              DateKey.parse(value),
          },
          start: DateKey.parse(c['start'] as String),
          today: DateKey.parse(c['today'] as String),
          scheduledWeekdays: weekdays == null
              ? StreakHistoryCalculator.everyDay
              : weekdays.cast<int>().toSet(),
        );
        expect(
          actual,
          StreakStats(
            currentStreak: expected['currentStreak'] as int,
            bestStreak: expected['bestStreak'] as int,
            completed: expected['completed'] as int,
            missed: expected['missed'] as int,
          ),
        );
      });
    }
  });

  StreakStats run({
    required Set<DateKey> done,
    required String start,
    required String today,
    Set<int> weekdays = StreakHistoryCalculator.everyDay,
  }) => calculator.calculate(
    doneDates: done,
    start: _d(start),
    today: _d(today),
    scheduledWeekdays: weekdays,
  );

  test('returns empty before the start date', () {
    expect(
      run(done: {}, start: '2026-10-10', today: '2026-10-09'),
      StreakStats.empty,
    );
  });

  test('a brand new habit with nothing done yet has no misses', () {
    final stats = run(done: {}, start: '2026-10-10', today: '2026-10-10');
    expect(stats.currentStreak, 0);
    expect(stats.missed, 0);
    expect(stats.completionRate, 0);
  });

  test('today done extends the streak', () {
    final stats = run(
      done: _range('2026-10-08', 3),
      start: '2026-10-08',
      today: '2026-10-10',
    );
    expect(stats.currentStreak, 3);
    expect(stats.bestStreak, 3);
    expect(stats.completed, 3);
    expect(stats.missed, 0);
    expect(stats.completionRate, 100);
  });

  test('today still open does not break the streak or count as missed', () {
    final stats = run(
      done: _range('2026-10-08', 2),
      start: '2026-10-08',
      today: '2026-10-10',
    );
    expect(stats.currentStreak, 2);
    expect(stats.missed, 0);
  });

  test('a missed past day resets the current streak but keeps the best', () {
    // done 1..5, missed 6, done 7..8, today = 9 (open)
    final done = {..._range('2026-10-01', 5), ..._range('2026-10-07', 2)};
    final stats = run(done: done, start: '2026-10-01', today: '2026-10-09');
    expect(stats.bestStreak, 5);
    expect(stats.currentStreak, 2);
    expect(stats.completed, 7);
    expect(stats.missed, 1);
    expect(stats.completionRate, 87);
  });

  test('best streak is kept when the current run is shorter', () {
    final stats = run(
      done: _range('2026-10-01', 4),
      start: '2026-10-01',
      today: '2026-10-10',
    );
    expect(stats.bestStreak, 4);
    expect(stats.currentStreak, 0);
    expect(stats.missed, 5);
  });

  test('works across a month boundary', () {
    final stats = run(
      done: _range('2026-10-29', 5),
      start: '2026-10-29',
      today: '2026-11-02',
    );
    expect(stats.currentStreak, 5);
  });

  test('works across a year boundary', () {
    final stats = run(
      done: _range('2026-12-30', 4),
      start: '2026-12-30',
      today: '2027-01-02',
    );
    expect(stats.currentStreak, 4);
  });

  test('works across a leap day', () {
    final stats = run(
      done: _range('2028-02-27', 4),
      start: '2028-02-27',
      today: '2028-03-01',
    );
    expect(stats.currentStreak, 4);
    expect(stats.completed, 4);
  });

  test('unscheduled days neither extend nor break a streak', () {
    // Scheduled Mon, Wed, Fri. 2026-10-05 is a Monday.
    final done = {_d('2026-10-05'), _d('2026-10-07'), _d('2026-10-09')};
    final stats = run(
      done: done,
      start: '2026-10-05',
      today: '2026-10-11',
      weekdays: const {1, 3, 5},
    );
    expect(stats.currentStreak, 3);
    expect(stats.missed, 0);
    expect(stats.completed, 3);
  });

  test('a missed scheduled day breaks a sparse schedule', () {
    final done = {_d('2026-10-05'), _d('2026-10-09')};
    final stats = run(
      done: done,
      start: '2026-10-05',
      today: '2026-10-11',
      weekdays: const {1, 3, 5},
    );
    expect(stats.currentStreak, 1);
    expect(stats.missed, 1);
  });

  test('completions outside the schedule are ignored', () {
    final stats = run(
      done: {_d('2026-10-06')}, // Tuesday, not scheduled
      start: '2026-10-05',
      today: '2026-10-06',
      weekdays: const {1, 3, 5},
    );
    expect(stats.completed, 0);
  });

  test('an empty schedule yields empty stats', () {
    expect(
      run(
        done: _range('2026-10-01', 3),
        start: '2026-10-01',
        today: '2026-10-03',
        weekdays: const {},
      ),
      StreakStats.empty,
    );
  });
}

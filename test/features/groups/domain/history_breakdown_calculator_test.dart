import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/core/time/date_key.dart';
import 'package:habit_tracker/features/groups/domain/entities/history_breakdown.dart';
import 'package:habit_tracker/features/groups/domain/services/history_breakdown_calculator.dart';

DateKey _d(String value) => DateKey.parse(value);

Set<DateKey> _range(String from, int days) {
  final start = _d(from);
  return {for (var i = 0; i < days; i++) start.plusDays(i)};
}

void main() {
  const calculator = HistoryBreakdownCalculator();

  HistoryBreakdown run({
    required Set<DateKey> done,
    required String start,
    required String today,
    Set<int> weekdays = HistoryBreakdownCalculator.everyDay,
    int weeks = 8,
    int months = 6,
  }) => calculator.calculate(
    doneDates: done,
    start: _d(start),
    today: _d(today),
    scheduledWeekdays: weekdays,
    weeks: weeks,
    months: months,
  );

  // 2026-10-18 is a Sunday. Its week runs Mon 2026-10-12 to Sun 2026-10-18.
  test('nothing before the habit starts', () {
    expect(
      run(done: {}, start: '2026-10-20', today: '2026-10-18').isEmpty,
      isTrue,
    );
  });

  test('an empty schedule has no history', () {
    expect(
      run(
        done: _range('2026-10-01', 3),
        start: '2026-10-01',
        today: '2026-10-18',
        weekdays: const {},
      ).isEmpty,
      isTrue,
    );
  });

  test('a full week done is 7 of 7', () {
    final result = run(
      done: _range('2026-10-12', 7),
      start: '2026-10-01',
      today: '2026-10-18',
    );

    final week = result.weeks.last;
    expect(week.start, _d('2026-10-12'));
    expect(week.done, 7);
    expect(week.scheduled, 7);
    expect(week.percent, 100);
  });

  test('today still open is not counted, today done is', () {
    final open = run(
      done: _range('2026-10-12', 6), // Mon to Sat; Sunday (today) not yet
      start: '2026-10-01',
      today: '2026-10-18',
    );
    expect(open.weeks.last.scheduled, 6);
    expect(open.weeks.last.done, 6);

    final doneToday = run(
      done: _range('2026-10-12', 7),
      start: '2026-10-01',
      today: '2026-10-18',
    );
    expect(doneToday.weeks.last.scheduled, 7);
  });

  test('missed days count against the week', () {
    final result = run(
      done: {_d('2026-10-12'), _d('2026-10-13'), _d('2026-10-14')},
      start: '2026-10-01',
      today: '2026-10-18',
    );

    final week = result.weeks.last;
    expect(week.done, 3);
    expect(week.scheduled, 6); // Mon to Sat finished; Sunday is today, open
    expect(week.percent, 50);
  });

  test('days before the habit existed are not counted', () {
    final result = run(
      done: _range('2026-10-14', 4), // Wed to Sat
      start: '2026-10-14', // Wednesday
      today: '2026-10-18',
    );

    final week = result.weeks.last;
    expect(week.scheduled, 4); // Wed to Sat; Sunday (today) is still open
    expect(week.done, 4);
  });

  test('only scheduled weekdays count', () {
    // Mon, Wed, Fri.
    final result = run(
      done: {_d('2026-10-12'), _d('2026-10-16')},
      start: '2026-10-01',
      today: '2026-10-18',
      weekdays: const {1, 3, 5},
    );

    final week = result.weeks.last;
    expect(week.scheduled, 3);
    expect(week.done, 2);
  });

  test('a completion on an unscheduled day is ignored', () {
    final result = run(
      done: {_d('2026-10-13')}, // Tuesday, not scheduled
      start: '2026-10-01',
      today: '2026-10-18',
      weekdays: const {1, 3, 5},
    );

    expect(result.weeks.last.done, 0);
  });

  test('weeks are oldest first and never include the future', () {
    final result = run(
      done: {},
      start: '2026-09-01',
      today: '2026-10-18',
      weeks: 3,
    );

    expect(result.weeks.map((w) => w.start.value), [
      '2026-09-28',
      '2026-10-05',
      '2026-10-12',
    ]);
    expect(result.weeks, hasLength(3));
    expect(result.weeks.last.start, _d('2026-10-12'));
  });

  test(
    'a week that began before the start date only counts from the start',
    () {
      final result = run(
        done: {},
        start: '2026-10-15', // Thursday of the current week
        today: '2026-10-18',
      );

      expect(result.weeks, hasLength(1));
      expect(result.weeks.single.scheduled, 3); // Thu, Fri, Sat; Sunday is open
    },
  );

  test('months cover whole calendar months, oldest first', () {
    final result = run(
      done: _range('2026-09-01', 30), // all of September
      start: '2026-08-01',
      today: '2026-10-18',
      months: 3,
    );

    expect(result.months.map((m) => m.start.value), [
      '2026-08-01',
      '2026-09-01',
      '2026-10-01',
    ]);
    final september = result.months[1];
    expect(september.scheduled, 30);
    expect(september.done, 30);
    expect(result.months[0].done, 0); // August, nothing done
    expect(result.months[0].scheduled, 31);
  });

  test('the current month only counts days that have passed', () {
    final result = run(
      done: _range('2026-10-01', 18),
      start: '2026-10-01',
      today: '2026-10-18',
    );

    final october = result.months.last;
    expect(october.scheduled, 18);
    expect(october.done, 18);
  });

  test('February in a leap year has 29 days', () {
    final result = run(
      done: {},
      start: '2028-02-01',
      today: '2028-03-05',
      months: 2,
    );

    expect(result.months.first.start, _d('2028-02-01'));
    expect(result.months.first.scheduled, 29);
  });

  test('months cross the year boundary', () {
    final result = run(
      done: _range('2026-12-01', 31),
      start: '2026-11-01',
      today: '2027-01-10',
      months: 3,
    );

    expect(result.months.map((m) => m.start.value), [
      '2026-11-01',
      '2026-12-01',
      '2027-01-01',
    ]);
    expect(result.months[1].done, 31);
  });

  test('a percent of an empty period is zero, not an error', () {
    const empty = PeriodCount(
      start: DateKey(2026, 10, 12),
      scheduled: 0,
      done: 0,
    );
    expect(empty.percent, 0);
  });
}

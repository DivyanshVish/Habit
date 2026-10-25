import 'package:habit_tracker/core/time/date_key.dart';
import 'package:habit_tracker/features/groups/domain/entities/history_breakdown.dart';

/// Turns a person's completions into weekly and monthly counts.
///
/// Uses the same rules as the streak calculator: only scheduled days count,
/// days before the habit started are ignored, and today is left out until it
/// is done (an open day is neither a miss nor a success yet).
class HistoryBreakdownCalculator {
  const HistoryBreakdownCalculator();

  static const Set<int> everyDay = {1, 2, 3, 4, 5, 6, 7};

  HistoryBreakdown calculate({
    required Set<DateKey> doneDates,
    required DateKey start,
    required DateKey today,
    Set<int> scheduledWeekdays = everyDay,
    int weeks = 8,
    int months = 6,
  }) {
    if (today.isBefore(start) || scheduledWeekdays.isEmpty) {
      return HistoryBreakdown.empty;
    }

    final weekStarts = <DateKey>[];
    var monday = today.minusDays(today.weekday - 1);
    for (var i = 0; i < weeks; i++) {
      weekStarts.add(monday);
      monday = monday.minusDays(7);
    }

    final monthStarts = <DateKey>[];
    var month = DateKey(today.year, today.month, 1);
    for (var i = 0; i < months; i++) {
      monthStarts.add(month);
      month = month.month == 1
          ? DateKey(month.year - 1, 12, 1)
          : DateKey(month.year, month.month - 1, 1);
    }

    PeriodCount count(DateKey from, DateKey toInclusive) {
      var scheduled = 0;
      var done = 0;
      var day = from.isBefore(start) ? start : from;
      final last = toInclusive.isAfter(today) ? today : toInclusive;
      while (!day.isAfter(last)) {
        if (scheduledWeekdays.contains(day.weekday)) {
          final isDone = doneDates.contains(day);
          if (isDone) {
            scheduled++;
            done++;
          } else if (day != today) {
            scheduled++;
          }
        }
        day = day.plusDays(1);
      }
      return PeriodCount(start: from, scheduled: scheduled, done: done);
    }

    // Periods that end before the habit started carry no information.
    bool relevant(DateKey periodEnd) => !periodEnd.isBefore(start);

    final weekCounts = [
      for (final from in weekStarts.reversed)
        if (relevant(from.plusDays(6))) count(from, from.plusDays(6)),
    ];
    final monthCounts = [
      for (final from in monthStarts.reversed)
        if (relevant(_endOfMonth(from))) count(from, _endOfMonth(from)),
    ];
    return HistoryBreakdown(weeks: weekCounts, months: monthCounts);
  }

  static DateKey _endOfMonth(DateKey firstOfMonth) {
    final next = firstOfMonth.month == 12
        ? DateKey(firstOfMonth.year + 1, 1, 1)
        : DateKey(firstOfMonth.year, firstOfMonth.month + 1, 1);
    return next.minusDays(1);
  }
}

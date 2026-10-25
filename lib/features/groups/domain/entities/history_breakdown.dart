import 'package:habit_tracker/core/time/date_key.dart';

/// How a habit went over one week or month: scheduled days that are over, and
/// how many of them were done.
final class PeriodCount {
  const PeriodCount({
    required this.start,
    required this.scheduled,
    required this.done,
  });

  /// First day of the week (a Monday) or of the month.
  final DateKey start;

  /// Scheduled days in the period that have finished. A day that is still open
  /// today is not counted either way.
  final int scheduled;

  final int done;

  int get percent => scheduled == 0 ? 0 : (done * 100) ~/ scheduled;

  @override
  bool operator ==(Object other) =>
      other is PeriodCount &&
      other.start == start &&
      other.scheduled == scheduled &&
      other.done == done;

  @override
  int get hashCode => Object.hash(start, scheduled, done);

  @override
  String toString() => 'PeriodCount($start, $done/$scheduled)';
}

/// Recent weeks and months, newest last.
final class HistoryBreakdown {
  const HistoryBreakdown({required this.weeks, required this.months});

  static const HistoryBreakdown empty = HistoryBreakdown(weeks: [], months: []);

  final List<PeriodCount> weeks;
  final List<PeriodCount> months;

  bool get isEmpty => weeks.isEmpty && months.isEmpty;
}

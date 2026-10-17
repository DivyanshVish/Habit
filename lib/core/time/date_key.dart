/// A calendar day in the device's local time zone, serialised as `yyyy-MM-dd`.
///
/// Used instead of timestamps so streaks do not shift with UTC offsets, and so
/// day arithmetic is immune to DST (it goes through the calendar, never
/// through `Duration(days: n)`).
final class DateKey implements Comparable<DateKey> {
  const DateKey(this.year, this.month, this.day);

  /// Takes the local calendar date of [dateTime], dropping the time of day.
  factory DateKey.fromDateTime(DateTime dateTime) =>
      DateKey(dateTime.year, dateTime.month, dateTime.day);

  /// Parses `yyyy-MM-dd`. Throws [FormatException] for anything else.
  factory DateKey.parse(String value) {
    final match = _pattern.firstMatch(value);
    if (match == null) {
      throw FormatException('Expected yyyy-MM-dd', value);
    }
    final year = int.parse(match.group(1)!);
    final month = int.parse(match.group(2)!);
    final day = int.parse(match.group(3)!);
    final normalized = DateTime(year, month, day);
    if (normalized.year != year ||
        normalized.month != month ||
        normalized.day != day) {
      throw FormatException('Not a real calendar date', value);
    }
    return DateKey(year, month, day);
  }

  static final RegExp _pattern = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$');

  final int year;
  final int month;
  final int day;

  /// The `yyyy-MM-dd` representation stored in Firestore.
  String get value =>
      '${year.toString().padLeft(4, '0')}-'
      '${month.toString().padLeft(2, '0')}-'
      '${day.toString().padLeft(2, '0')}';

  /// Midnight of this day in local time.
  DateTime toDateTime() => DateTime(year, month, day);

  /// 1 = Monday ... 7 = Sunday (same as [DateTime.weekday]).
  int get weekday => toDateTime().weekday;

  DateKey minusDays(int days) =>
      DateKey.fromDateTime(DateTime(year, month, day - days));

  DateKey plusDays(int days) => minusDays(-days);

  bool isBefore(DateKey other) => compareTo(other) < 0;

  bool isAfter(DateKey other) => compareTo(other) > 0;

  @override
  int compareTo(DateKey other) {
    if (year != other.year) return year.compareTo(other.year);
    if (month != other.month) return month.compareTo(other.month);
    return day.compareTo(other.day);
  }

  @override
  bool operator ==(Object other) =>
      other is DateKey &&
      other.year == year &&
      other.month == month &&
      other.day == day;

  @override
  int get hashCode => Object.hash(year, month, day);

  @override
  String toString() => value;
}

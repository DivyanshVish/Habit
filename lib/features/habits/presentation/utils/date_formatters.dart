import 'package:habit_tracker/core/time/date_key.dart';

const List<String> _weekdays = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];

const List<String> _monthNames = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

/// Single-letter weekday, e.g. "S" for Saturday.
String weekdayInitial(DateKey date) => _weekdays[date.weekday - 1][0];

/// Full weekday, e.g. "Saturday" (used for screen reader labels).
String weekdayName(DateKey date) => _weekdays[date.weekday - 1];

/// Upper case date line for headers, e.g. "SATURDAY \u00B7 17 OCTOBER".
String formatKicker(DateKey date) =>
    '${weekdayName(date)} \u00B7 ${date.day} ${_monthNames[date.month - 1]}'
        .toUpperCase();

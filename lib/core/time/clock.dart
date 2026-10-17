import 'package:habit_tracker/core/time/date_key.dart';

/// Source of "now". Injected so tests can pin the current day.
abstract class Clock {
  DateTime now();

  DateKey today() => DateKey.fromDateTime(now());
}

class SystemClock extends Clock {
  @override
  DateTime now() => DateTime.now();
}

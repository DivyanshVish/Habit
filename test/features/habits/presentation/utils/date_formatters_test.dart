import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/core/time/date_key.dart';
import 'package:habit_tracker/features/habits/presentation/utils/date_formatters.dart';

void main() {
  group('formatKicker', () {
    test('formats a Saturday in October', () {
      expect(
        formatKicker(const DateKey(2026, 10, 17)),
        'SATURDAY \u00B7 17 OCTOBER',
      );
    });

    test('keeps a single digit day without padding', () {
      expect(
        formatKicker(const DateKey(2026, 10, 5)),
        'MONDAY \u00B7 5 OCTOBER',
      );
    });

    test('handles 1 January', () {
      expect(
        formatKicker(const DateKey(2026, 1, 1)),
        'THURSDAY \u00B7 1 JANUARY',
      );
    });

    test('handles December', () {
      expect(
        formatKicker(const DateKey(2026, 12, 31)),
        'THURSDAY \u00B7 31 DECEMBER',
      );
    });

    test('covers every month name', () {
      const names = [
        'JANUARY',
        'FEBRUARY',
        'MARCH',
        'APRIL',
        'MAY',
        'JUNE',
        'JULY',
        'AUGUST',
        'SEPTEMBER',
        'OCTOBER',
        'NOVEMBER',
        'DECEMBER',
      ];
      for (var month = 1; month <= 12; month++) {
        expect(
          formatKicker(DateKey(2026, month, 10)),
          endsWith('10 ${names[month - 1]}'),
        );
      }
    });
  });

  test('weekdayName and weekdayInitial', () {
    const saturday = DateKey(2026, 10, 17);
    expect(weekdayName(saturday), 'Saturday');
    expect(weekdayInitial(saturday), 'S');
    expect(weekdayInitial(const DateKey(2026, 10, 19)), 'M');
  });
}

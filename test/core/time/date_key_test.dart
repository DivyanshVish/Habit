import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/core/time/date_key.dart';

void main() {
  group('formatting and parsing', () {
    test('pads month and day', () {
      expect(const DateKey(2026, 3, 5).value, '2026-03-05');
    });

    test('fromDateTime drops the time of day', () {
      expect(
        DateKey.fromDateTime(DateTime(2026, 10, 17, 23, 59, 59)).value,
        '2026-10-17',
      );
    });

    test('parse round-trips', () {
      expect(DateKey.parse('2026-02-28'), const DateKey(2026, 2, 28));
    });

    test('parse rejects bad formats and impossible dates', () {
      expect(() => DateKey.parse('2026-2-8'), throwsFormatException);
      expect(() => DateKey.parse('hello'), throwsFormatException);
      expect(() => DateKey.parse('2026-02-30'), throwsFormatException);
      expect(() => DateKey.parse('2026-13-01'), throwsFormatException);
    });
  });

  group('day arithmetic', () {
    test('crosses month boundaries', () {
      expect(
        const DateKey(2026, 3, 2).minusDays(3),
        const DateKey(2026, 2, 27),
      );
    });

    test('crosses year boundaries', () {
      expect(
        const DateKey(2026, 1, 2).minusDays(3),
        const DateKey(2025, 12, 30),
      );
    });

    test('handles leap years', () {
      expect(
        const DateKey(2024, 3, 1).minusDays(1),
        const DateKey(2024, 2, 29),
      );
      expect(
        const DateKey(2026, 3, 1).minusDays(1),
        const DateKey(2026, 2, 28),
      );
    });

    test('is not affected by DST transitions', () {
      // US spring-forward (2026-03-08) and fall-back (2026-11-01) days.
      expect(const DateKey(2026, 3, 9).minusDays(1), const DateKey(2026, 3, 8));
      expect(const DateKey(2026, 3, 8).minusDays(1), const DateKey(2026, 3, 7));
      expect(
        const DateKey(2026, 11, 2).minusDays(1),
        const DateKey(2026, 11, 1),
      );
      expect(
        const DateKey(2026, 11, 1).minusDays(1),
        const DateKey(2026, 10, 31),
      );
      // Europe spring-forward (2026-03-29).
      expect(
        const DateKey(2026, 3, 30).minusDays(1),
        const DateKey(2026, 3, 29),
      );
    });

    test('plusDays is the inverse of minusDays', () {
      const start = DateKey(2026, 12, 30);
      expect(start.plusDays(5), const DateKey(2027, 1, 4));
      expect(start.plusDays(5).minusDays(5), start);
    });

    test('a 7 day window yields 7 distinct consecutive days', () {
      const today = DateKey(2026, 3, 3);
      final days = [for (var i = 6; i >= 0; i--) today.minusDays(i)];
      expect(days.first, const DateKey(2026, 2, 25));
      expect(days.toSet(), hasLength(7));
      for (var i = 1; i < days.length; i++) {
        expect(days[i].isAfter(days[i - 1]), isTrue);
      }
    });
  });

  group('ordering and equality', () {
    test('compares by year, month, day', () {
      expect(
        const DateKey(2026, 1, 1).isBefore(const DateKey(2026, 1, 2)),
        isTrue,
      );
      expect(
        const DateKey(2026, 2, 1).isAfter(const DateKey(2026, 1, 31)),
        isTrue,
      );
      expect(
        const DateKey(2025, 12, 31).isBefore(const DateKey(2026, 1, 1)),
        isTrue,
      );
    });

    test('value equality and hashing', () {
      expect(const DateKey(2026, 5, 5), const DateKey(2026, 5, 5));
      expect(
        const DateKey(2026, 5, 5).hashCode,
        const DateKey(2026, 5, 5).hashCode,
      );
      expect(const DateKey(2026, 5, 5) == const DateKey(2026, 5, 6), isFalse);
    });

    test('weekday matches DateTime', () {
      // 2026-10-17 is a Saturday.
      expect(const DateKey(2026, 10, 17).weekday, DateTime.saturday);
    });
  });
}

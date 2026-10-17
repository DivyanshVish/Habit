import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:habit_tracker/core/error/failure.dart';
import 'package:habit_tracker/core/time/date_key.dart';
import 'package:habit_tracker/features/habits/domain/repositories/habit_repository.dart';
import 'package:habit_tracker/features/habits/domain/usecases/toggle_habit_completion.dart';
import 'package:mocktail/mocktail.dart';

class _MockHabitRepository extends Mock implements HabitRepository {}

void main() {
  late _MockHabitRepository repository;
  late ToggleHabitCompletion toggle;
  const day = DateKey(2026, 10, 17);

  setUpAll(() => registerFallbackValue(day));

  setUp(() {
    repository = _MockHabitRepository();
    toggle = ToggleHabitCompletion(repository);
  });

  for (final done in [true, false]) {
    test('forwards done=$done for the given day', () async {
      when(
        () => repository.setCompletion(
          habitId: 'water',
          dateKey: day,
          done: done,
        ),
      ).thenAnswer((_) async => right(unit));

      final result = await toggle(
        ToggleHabitCompletionParams(habitId: 'water', dateKey: day, done: done),
      );

      expect(result, right<Failure, Unit>(unit));
      verify(
        () => repository.setCompletion(
          habitId: 'water',
          dateKey: day,
          done: done,
        ),
      ).called(1);
    });
  }

  test('propagates repository failures', () async {
    when(
      () => repository.setCompletion(
        habitId: any(named: 'habitId'),
        dateKey: any(named: 'dateKey'),
        done: any(named: 'done'),
      ),
    ).thenAnswer((_) async => left(const Failure.network()));

    final result = await toggle(
      const ToggleHabitCompletionParams(
        habitId: 'water',
        dateKey: day,
        done: true,
      ),
    );

    expect(result, left<Failure, Unit>(const Failure.network()));
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:habit_tracker/core/error/failure.dart';
import 'package:habit_tracker/features/habits/domain/repositories/habit_repository.dart';
import 'package:habit_tracker/features/habits/domain/usecases/delete_habit.dart';
import 'package:mocktail/mocktail.dart';

class _MockHabitRepository extends Mock implements HabitRepository {}

void main() {
  late _MockHabitRepository repository;
  late DeleteHabit deleteHabit;

  setUp(() {
    repository = _MockHabitRepository();
    deleteHabit = DeleteHabit(repository);
  });

  test('deletes through the repository', () async {
    when(
      () => repository.deleteHabit('h1'),
    ).thenAnswer((_) async => right(unit));

    expect(await deleteHabit('h1'), right<Failure, Unit>(unit));
    verify(() => repository.deleteHabit('h1')).called(1);
  });

  test('rejects a blank id without calling the repository', () async {
    final result = await deleteHabit('  ');

    expect(result.isLeft(), isTrue);
    verifyNever(() => repository.deleteHabit(any()));
  });

  test('propagates repository failures', () async {
    when(
      () => repository.deleteHabit('h1'),
    ).thenAnswer((_) async => left(const Failure.network()));

    expect(
      await deleteHabit('h1'),
      left<Failure, Unit>(const Failure.network()),
    );
  });
}

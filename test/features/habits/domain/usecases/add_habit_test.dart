import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:habit_tracker/core/error/failure.dart';
import 'package:habit_tracker/features/habits/domain/entities/new_habit.dart';
import 'package:habit_tracker/features/habits/domain/repositories/habit_repository.dart';
import 'package:habit_tracker/features/habits/domain/usecases/add_habit.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/fakes.dart';

class _MockHabitRepository extends Mock implements HabitRepository {}

class _FakeNewHabit extends Fake implements NewHabit {}

void main() {
  late _MockHabitRepository repository;
  late AddHabit addHabit;
  final now = DateTime(2026, 10, 17, 9, 30);

  setUpAll(() => registerFallbackValue(_FakeNewHabit()));

  setUp(() {
    repository = _MockHabitRepository();
    addHabit = AddHabit(repository, FixedClock(now));
    when(() => repository.addHabit(any())).thenAnswer((_) async => right(unit));
  });

  test('trims input, stamps createdAt from the clock and saves', () async {
    final result = await addHabit(
      const AddHabitParams(
        name: '  Read 20 pages ',
        description: ' Before bed ',
        points: 20,
      ),
    );

    expect(result, right<Failure, Unit>(unit));
    final saved =
        verify(() => repository.addHabit(captureAny())).captured.single
            as NewHabit;
    expect(saved.name, 'Read 20 pages');
    expect(saved.description, 'Before bed');
    expect(saved.points, 20);
    expect(saved.createdAt, now);
  });

  test('accepts an empty description and boundary values', () async {
    expect(
      (await addHabit(
        AddHabitParams(
          name: 'a' * HabitRules.maxNameLength,
          description: '',
          points: HabitRules.maxPoints,
        ),
      )).isRight(),
      isTrue,
    );
    expect(
      (await addHabit(
        const AddHabitParams(name: 'x', description: '', points: 1),
      )).isRight(),
      isTrue,
    );
  });

  group('rejects invalid input without touching the repository', () {
    final cases = <String, AddHabitParams>{
      'empty name': const AddHabitParams(name: '', description: '', points: 10),
      'whitespace name': const AddHabitParams(
        name: '   ',
        description: '',
        points: 10,
      ),
      'name too long': AddHabitParams(
        name: 'a' * (HabitRules.maxNameLength + 1),
        description: '',
        points: 10,
      ),
      'description too long': AddHabitParams(
        name: 'ok',
        description: 'd' * (HabitRules.maxDescriptionLength + 1),
        points: 10,
      ),
      'zero points': const AddHabitParams(
        name: 'ok',
        description: '',
        points: 0,
      ),
      'negative points': const AddHabitParams(
        name: 'ok',
        description: '',
        points: -5,
      ),
      'too many points': const AddHabitParams(
        name: 'ok',
        description: '',
        points: 1001,
      ),
    };

    cases.forEach((label, params) {
      test(label, () async {
        final result = await addHabit(params);

        expect(result.isLeft(), isTrue);
        result.match(
          (failure) => expect(failure, isA<ValidationFailure>()),
          (_) => fail('expected a failure'),
        );
        verifyNever(() => repository.addHabit(any()));
      });
    });
  });

  test('propagates repository failures', () async {
    when(
      () => repository.addHabit(any()),
    ).thenAnswer((_) async => left(const Failure.network()));

    final result = await addHabit(
      const AddHabitParams(name: 'ok', description: '', points: 5),
    );

    expect(result, left<Failure, Unit>(const Failure.network()));
  });
}

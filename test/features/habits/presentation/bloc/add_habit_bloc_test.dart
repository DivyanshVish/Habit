import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:habit_tracker/core/error/failure.dart';
import 'package:habit_tracker/features/habits/domain/usecases/add_habit.dart';
import 'package:habit_tracker/features/habits/presentation/bloc/add_habit/add_habit_bloc.dart';
import 'package:mocktail/mocktail.dart';

class _MockAddHabit extends Mock implements AddHabit {}

void main() {
  late _MockAddHabit addHabit;
  const params = AddHabitParams(name: 'Water', description: '', points: 10);

  setUpAll(() => registerFallbackValue(params));

  setUp(() => addHabit = _MockAddHabit());

  blocTest<AddHabitBloc, AddHabitState>(
    'emits submitting then success',
    build: () {
      when(() => addHabit(any())).thenAnswer((_) async => right(unit));
      return AddHabitBloc(addHabit);
    },
    act: (bloc) => bloc.add(
      const AddHabitEvent.submitted(name: 'Water', description: '', points: 10),
    ),
    expect: () => [
      const AddHabitState.submitting(),
      const AddHabitState.success(),
    ],
    verify: (_) => verify(() => addHabit(params)).called(1),
  );

  blocTest<AddHabitBloc, AddHabitState>(
    'emits submitting then failure with the failure',
    build: () {
      when(() => addHabit(any())).thenAnswer(
        (_) async =>
            left(const Failure.validation(message: 'Name is required.')),
      );
      return AddHabitBloc(addHabit);
    },
    act: (bloc) => bloc.add(
      const AddHabitEvent.submitted(name: '', description: '', points: 10),
    ),
    expect: () => [
      const AddHabitState.submitting(),
      const AddHabitState.failure(
        Failure.validation(message: 'Name is required.'),
      ),
    ],
  );

  blocTest<AddHabitBloc, AddHabitState>(
    'can retry after a failure',
    build: () {
      var calls = 0;
      when(() => addHabit(any())).thenAnswer((_) async {
        calls++;
        return calls == 1 ? left(const Failure.network()) : right(unit);
      });
      return AddHabitBloc(addHabit);
    },
    act: (bloc) async {
      const event = AddHabitEvent.submitted(
        name: 'Water',
        description: '',
        points: 10,
      );
      bloc.add(event);
      await Future<void>.delayed(Duration.zero);
      bloc.add(event);
    },
    expect: () => [
      const AddHabitState.submitting(),
      const AddHabitState.failure(Failure.network()),
      const AddHabitState.submitting(),
      const AddHabitState.success(),
    ],
  );
}

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:habit_tracker/core/error/failure.dart';
import 'package:habit_tracker/features/habits/domain/usecases/add_habit.dart';

part 'add_habit_bloc.freezed.dart';
part 'add_habit_event.dart';
part 'add_habit_state.dart';

class AddHabitBloc extends Bloc<AddHabitEvent, AddHabitState> {
  AddHabitBloc(this._addHabit) : super(const AddHabitState.initial()) {
    on<AddHabitSubmitted>(_onSubmitted);
  }

  final AddHabit _addHabit;

  Future<void> _onSubmitted(
    AddHabitSubmitted event,
    Emitter<AddHabitState> emit,
  ) async {
    if (state is AddHabitSubmitting) return;
    emit(const AddHabitState.submitting());

    final result = await _addHabit(
      AddHabitParams(
        name: event.name,
        description: event.description,
        points: event.points,
      ),
    );

    emit(
      result.fold(AddHabitState.failure, (_) => const AddHabitState.success()),
    );
  }
}

part of 'add_habit_bloc.dart';

@freezed
sealed class AddHabitState with _$AddHabitState {
  const factory AddHabitState.initial() = AddHabitInitial;
  const factory AddHabitState.submitting() = AddHabitSubmitting;
  const factory AddHabitState.success() = AddHabitSuccess;
  const factory AddHabitState.failure(Failure failure) = AddHabitFailure;
}

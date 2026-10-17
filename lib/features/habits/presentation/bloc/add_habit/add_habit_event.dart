part of 'add_habit_bloc.dart';

@freezed
sealed class AddHabitEvent with _$AddHabitEvent {
  const factory AddHabitEvent.submitted({
    required String name,
    required String description,
    required int points,
  }) = AddHabitSubmitted;
}

part of 'habit_detail_bloc.dart';

@freezed
sealed class HabitDetailState with _$HabitDetailState {
  const factory HabitDetailState.loading() = HabitDetailLoading;

  /// [actionFailure] is a one-shot message, emitted once then cleared.
  const factory HabitDetailState.loaded(
    HabitDetail detail, {
    Failure? actionFailure,
  }) = HabitDetailLoaded;

  const factory HabitDetailState.failure(Failure failure) = HabitDetailFailure;
}

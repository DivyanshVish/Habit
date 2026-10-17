part of 'habit_detail_bloc.dart';

@freezed
sealed class HabitDetailEvent with _$HabitDetailEvent {
  const factory HabitDetailEvent.started() = HabitDetailStarted;

  /// Flip today's done status.
  const factory HabitDetailEvent.todayToggled() = HabitDetailTodayToggled;

  /// The app returned to the foreground; refresh if the day changed.
  const factory HabitDetailEvent.resumed() = HabitDetailResumed;
}

part of 'today_bloc.dart';

@freezed
sealed class TodayEvent with _$TodayEvent {
  /// Start (or restart) listening to today's habits.
  const factory TodayEvent.started() = TodayStarted;

  const factory TodayEvent.habitToggled(String habitId) = TodayHabitToggled;

  const factory TodayEvent.habitDeleted(String habitId) = TodayHabitDeleted;

  /// The app returned to the foreground. If the calendar day changed while it
  /// was away, re-subscribe so "today" is correct again.
  const factory TodayEvent.resumed() = TodayResumed;
}

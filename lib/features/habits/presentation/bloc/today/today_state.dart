part of 'today_bloc.dart';

@freezed
sealed class TodayState with _$TodayState {
  const factory TodayState.loading() = TodayLoading;

  /// [actionFailure] is a one-shot message (e.g. a toggle that failed). It is
  /// emitted once and immediately cleared again, so listeners react only once.
  const factory TodayState.loaded(
    TodayOverview overview, {
    Failure? actionFailure,
  }) = TodayLoaded;

  const factory TodayState.failure(Failure failure) = TodayFailure;
}

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:habit_tracker/core/error/failure.dart';
import 'package:habit_tracker/core/time/clock.dart';
import 'package:habit_tracker/core/usecase/usecase.dart';
import 'package:habit_tracker/features/habits/domain/entities/today_overview.dart';
import 'package:habit_tracker/features/habits/domain/usecases/delete_habit.dart';
import 'package:habit_tracker/features/habits/domain/usecases/toggle_habit_completion.dart';
import 'package:habit_tracker/features/habits/domain/usecases/watch_today_overview.dart';

part 'today_bloc.freezed.dart';
part 'today_event.dart';
part 'today_state.dart';

class TodayBloc extends Bloc<TodayEvent, TodayState> {
  TodayBloc({
    required WatchTodayOverview watchTodayOverview,
    required ToggleHabitCompletion toggleHabitCompletion,
    required DeleteHabit deleteHabit,
    required Clock clock,
  }) : _watchTodayOverview = watchTodayOverview,
       _toggleHabitCompletion = toggleHabitCompletion,
       _deleteHabit = deleteHabit,
       _clock = clock,
       super(const TodayState.loading()) {
    // restartable: a new `started` cancels the previous subscription.
    on<TodayStarted>(_onStarted, transformer: restartable());
    on<TodayHabitToggled>(_onToggled);
    on<TodayHabitDeleted>(_onDeleted);
    on<TodayResumed>(_onResumed);
  }

  final WatchTodayOverview _watchTodayOverview;
  final ToggleHabitCompletion _toggleHabitCompletion;
  final DeleteHabit _deleteHabit;
  final Clock _clock;

  Future<void> _onStarted(TodayStarted event, Emitter<TodayState> emit) async {
    // Keep showing the current data while re-subscribing (no flicker).
    if (state is! TodayLoaded) emit(const TodayState.loading());

    await emit.forEach(
      _watchTodayOverview(const NoParams()),
      onData: (result) => result.fold(TodayState.failure, TodayState.loaded),
    );
  }

  Future<void> _onToggled(
    TodayHabitToggled event,
    Emitter<TodayState> emit,
  ) async {
    final current = state;
    if (current is! TodayLoaded) return;

    final matches = current.overview.items.where(
      (item) => item.habit.id == event.habitId,
    );
    if (matches.isEmpty) return;

    final result = await _toggleHabitCompletion(
      ToggleHabitCompletionParams(
        habitId: event.habitId,
        dateKey: current.overview.date,
        done: !matches.first.isDone,
      ),
    );

    result.match((failure) => _emitActionFailure(emit, failure), (_) {});
  }

  Future<void> _onDeleted(
    TodayHabitDeleted event,
    Emitter<TodayState> emit,
  ) async {
    final result = await _deleteHabit(event.habitId);
    result.match((failure) => _emitActionFailure(emit, failure), (_) {});
  }

  void _onResumed(TodayResumed event, Emitter<TodayState> emit) {
    final current = state;
    if (current is TodayLoaded && current.overview.date != _clock.today()) {
      add(const TodayEvent.started());
    }
  }

  /// Emits the message once, then clears it so it is never replayed.
  void _emitActionFailure(Emitter<TodayState> emit, Failure failure) {
    final latest = state;
    if (latest is! TodayLoaded) return;
    emit(TodayState.loaded(latest.overview, actionFailure: failure));
    emit(TodayState.loaded(latest.overview));
  }
}

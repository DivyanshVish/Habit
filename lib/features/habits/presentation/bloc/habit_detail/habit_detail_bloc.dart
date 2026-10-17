import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:habit_tracker/core/error/failure.dart';
import 'package:habit_tracker/core/time/clock.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit_detail.dart';
import 'package:habit_tracker/features/habits/domain/usecases/toggle_habit_completion.dart';
import 'package:habit_tracker/features/habits/domain/usecases/watch_habit_detail.dart';

part 'habit_detail_bloc.freezed.dart';
part 'habit_detail_event.dart';
part 'habit_detail_state.dart';

class HabitDetailBloc extends Bloc<HabitDetailEvent, HabitDetailState> {
  HabitDetailBloc({
    required String habitId,
    required WatchHabitDetail watchHabitDetail,
    required ToggleHabitCompletion toggleHabitCompletion,
    required Clock clock,
  }) : _habitId = habitId,
       _watchHabitDetail = watchHabitDetail,
       _toggleHabitCompletion = toggleHabitCompletion,
       _clock = clock,
       super(const HabitDetailState.loading()) {
    on<HabitDetailStarted>(_onStarted, transformer: restartable());
    on<HabitDetailTodayToggled>(_onTodayToggled);
    on<HabitDetailResumed>(_onResumed);
  }

  final String _habitId;
  final WatchHabitDetail _watchHabitDetail;
  final ToggleHabitCompletion _toggleHabitCompletion;
  final Clock _clock;

  void _onResumed(HabitDetailResumed event, Emitter<HabitDetailState> emit) {
    final current = state;
    if (current is HabitDetailLoaded &&
        current.detail.today != _clock.today()) {
      add(const HabitDetailEvent.started());
    }
  }

  Future<void> _onStarted(
    HabitDetailStarted event,
    Emitter<HabitDetailState> emit,
  ) async {
    if (state is! HabitDetailLoaded) emit(const HabitDetailState.loading());

    await emit.forEach(
      _watchHabitDetail(WatchHabitDetailParams(habitId: _habitId)),
      onData: (result) =>
          result.fold(HabitDetailState.failure, HabitDetailState.loaded),
    );
  }

  Future<void> _onTodayToggled(
    HabitDetailTodayToggled event,
    Emitter<HabitDetailState> emit,
  ) async {
    final current = state;
    if (current is! HabitDetailLoaded) return;
    final detail = current.detail;

    final result = await _toggleHabitCompletion(
      ToggleHabitCompletionParams(
        habitId: detail.habit.id,
        dateKey: detail.today,
        done: !detail.streak.isDoneToday,
      ),
    );

    result.match((failure) {
      final latest = state;
      if (latest is! HabitDetailLoaded) return;
      emit(HabitDetailState.loaded(latest.detail, actionFailure: failure));
      emit(HabitDetailState.loaded(latest.detail));
    }, (_) {});
  }
}

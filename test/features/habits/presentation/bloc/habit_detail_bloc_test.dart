import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:habit_tracker/core/error/failure.dart';
import 'package:habit_tracker/core/time/date_key.dart';
import 'package:habit_tracker/features/habits/domain/entities/completion.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit_detail.dart';
import 'package:habit_tracker/features/habits/domain/services/streak_calculator.dart';
import 'package:habit_tracker/features/habits/domain/usecases/toggle_habit_completion.dart';
import 'package:habit_tracker/features/habits/domain/usecases/watch_habit_detail.dart';
import 'package:habit_tracker/features/habits/presentation/bloc/habit_detail/habit_detail_bloc.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/builders.dart';
import '../../../../helpers/fakes.dart';

class _MockWatchHabitDetail extends Mock implements WatchHabitDetail {}

class _MockToggle extends Mock implements ToggleHabitCompletion {}

void main() {
  late _MockWatchHabitDetail watch;
  late _MockToggle toggle;
  late FixedClock clock;
  const today = DateKey(2026, 10, 17);

  HabitDetail detail({required bool doneToday}) {
    final habit = buildHabit(id: 'h1', createdDateKey: today.minusDays(20));
    return HabitDetail(
      habit: habit,
      today: today,
      streak: const StreakCalculator().calculate(
        habit: habit,
        completions: [
          if (doneToday) const Completion(habitId: 'h1', dateKey: today),
        ],
        today: today,
      ),
    );
  }

  setUpAll(() {
    registerFallbackValue(const WatchHabitDetailParams(habitId: 'h1'));
    registerFallbackValue(
      const ToggleHabitCompletionParams(
        habitId: 'x',
        dateKey: today,
        done: true,
      ),
    );
  });

  setUp(() {
    watch = _MockWatchHabitDetail();
    toggle = _MockToggle();
    clock = FixedClock(DateTime(2026, 10, 17, 9));
  });

  HabitDetailBloc build() => HabitDetailBloc(
    habitId: 'h1',
    watchHabitDetail: watch,
    toggleHabitCompletion: toggle,
    clock: clock,
  );

  blocTest<HabitDetailBloc, HabitDetailState>(
    'watches the habit it was created for',
    build: () {
      when(() => watch(any())).thenAnswer(
        (_) => Stream.fromIterable([
          right(detail(doneToday: false)),
          right(detail(doneToday: true)),
        ]),
      );
      return build();
    },
    act: (bloc) => bloc.add(const HabitDetailEvent.started()),
    expect: () => [
      const HabitDetailState.loading(),
      HabitDetailState.loaded(detail(doneToday: false)),
      HabitDetailState.loaded(detail(doneToday: true)),
    ],
    verify: (_) => verify(
      () => watch(const WatchHabitDetailParams(habitId: 'h1')),
    ).called(1),
  );

  blocTest<HabitDetailBloc, HabitDetailState>(
    'emits failure when the habit cannot be loaded',
    build: () {
      when(
        () => watch(any()),
      ).thenAnswer((_) => Stream.value(left(const Failure.notFound())));
      return build();
    },
    act: (bloc) => bloc.add(const HabitDetailEvent.started()),
    expect: () => [
      const HabitDetailState.loading(),
      const HabitDetailState.failure(Failure.notFound()),
    ],
  );

  blocTest<HabitDetailBloc, HabitDetailState>(
    'toggling an undone day marks today done',
    build: () {
      when(
        () => watch(any()),
      ).thenAnswer((_) => Stream.value(right(detail(doneToday: false))));
      when(() => toggle(any())).thenAnswer((_) async => right(unit));
      return build();
    },
    act: (bloc) async {
      bloc.add(const HabitDetailEvent.started());
      await pumpEventQueue();
      bloc.add(const HabitDetailEvent.todayToggled());
    },
    verify: (_) => verify(
      () => toggle(
        const ToggleHabitCompletionParams(
          habitId: 'h1',
          dateKey: today,
          done: true,
        ),
      ),
    ).called(1),
  );

  blocTest<HabitDetailBloc, HabitDetailState>(
    'toggling a done day marks today not done',
    build: () {
      when(
        () => watch(any()),
      ).thenAnswer((_) => Stream.value(right(detail(doneToday: true))));
      when(() => toggle(any())).thenAnswer((_) async => right(unit));
      return build();
    },
    act: (bloc) async {
      bloc.add(const HabitDetailEvent.started());
      await pumpEventQueue();
      bloc.add(const HabitDetailEvent.todayToggled());
    },
    verify: (_) => verify(
      () => toggle(
        const ToggleHabitCompletionParams(
          habitId: 'h1',
          dateKey: today,
          done: false,
        ),
      ),
    ).called(1),
  );

  blocTest<HabitDetailBloc, HabitDetailState>(
    'a failed toggle emits the failure once, then clears it',
    build: () {
      when(
        () => watch(any()),
      ).thenAnswer((_) => Stream.value(right(detail(doneToday: false))));
      when(
        () => toggle(any()),
      ).thenAnswer((_) async => left(const Failure.network()));
      return build();
    },
    act: (bloc) async {
      bloc.add(const HabitDetailEvent.started());
      await pumpEventQueue();
      bloc.add(const HabitDetailEvent.todayToggled());
    },
    expect: () => [
      const HabitDetailState.loading(),
      HabitDetailState.loaded(detail(doneToday: false)),
      HabitDetailState.loaded(
        detail(doneToday: false),
        actionFailure: const Failure.network(),
      ),
      HabitDetailState.loaded(detail(doneToday: false)),
    ],
  );

  blocTest<HabitDetailBloc, HabitDetailState>(
    'toggling before the habit has loaded does nothing',
    build: build,
    act: (bloc) => bloc.add(const HabitDetailEvent.todayToggled()),
    expect: () => <HabitDetailState>[],
    verify: (_) => verifyNever(() => toggle(any())),
  );

  group('resuming', () {
    test('re-subscribes when the day changed while away', () async {
      when(
        () => watch(any()),
      ).thenAnswer((_) => Stream.value(right(detail(doneToday: false))));
      final bloc = build();
      addTearDown(bloc.close);

      bloc.add(const HabitDetailEvent.started());
      await pumpEventQueue();
      verify(() => watch(any())).called(1);

      clock.current = DateTime(2026, 10, 18, 7);
      bloc.add(const HabitDetailEvent.resumed());
      await pumpEventQueue();

      verify(() => watch(any())).called(1);
    });

    test('does nothing when it is still the same day', () async {
      when(
        () => watch(any()),
      ).thenAnswer((_) => Stream.value(right(detail(doneToday: false))));
      final bloc = build();
      addTearDown(bloc.close);

      bloc.add(const HabitDetailEvent.started());
      await pumpEventQueue();
      clearInteractions(watch);

      bloc.add(const HabitDetailEvent.resumed());
      await pumpEventQueue();

      verifyNever(() => watch(any()));
    });
  });
}

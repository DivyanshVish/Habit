import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:habit_tracker/core/error/failure.dart';
import 'package:habit_tracker/core/time/date_key.dart';
import 'package:habit_tracker/core/usecase/usecase.dart';
import 'package:habit_tracker/features/habits/domain/entities/today_overview.dart';
import 'package:habit_tracker/features/habits/domain/usecases/delete_habit.dart';
import 'package:habit_tracker/features/habits/domain/usecases/toggle_habit_completion.dart';
import 'package:habit_tracker/features/habits/domain/usecases/watch_today_overview.dart';
import 'package:habit_tracker/features/habits/presentation/bloc/today/today_bloc.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/builders.dart';
import '../../../../helpers/fakes.dart';

class _MockWatchTodayOverview extends Mock implements WatchTodayOverview {}

class _MockToggle extends Mock implements ToggleHabitCompletion {}

class _MockDeleteHabit extends Mock implements DeleteHabit {}

void main() {
  late _MockWatchTodayOverview watch;
  late _MockToggle toggle;
  late _MockDeleteHabit deleteHabit;
  late FixedClock clock;
  const today = DateKey(2026, 10, 17);

  TodayOverview overview({bool waterDone = false}) => TodayOverview(
    date: today,
    items: [
      buildItem(
        habit: buildHabit(id: 'water'),
        isDone: waterDone,
      ),
      buildItem(habit: buildHabit(id: 'read', points: 20), isDone: false),
    ],
  );

  setUpAll(() {
    registerFallbackValue(const NoParams());
    registerFallbackValue(
      const ToggleHabitCompletionParams(
        habitId: 'x',
        dateKey: today,
        done: true,
      ),
    );
  });

  setUp(() {
    watch = _MockWatchTodayOverview();
    toggle = _MockToggle();
    deleteHabit = _MockDeleteHabit();
    clock = FixedClock(DateTime(2026, 10, 17, 9));
  });

  TodayBloc build() => TodayBloc(
    watchTodayOverview: watch,
    toggleHabitCompletion: toggle,
    deleteHabit: deleteHabit,
    clock: clock,
  );

  blocTest<TodayBloc, TodayState>(
    'loading then loaded as the overview changes',
    build: () {
      when(() => watch(any())).thenAnswer(
        (_) => Stream.fromIterable([
          right(overview()),
          right(overview(waterDone: true)),
        ]),
      );
      return build();
    },
    act: (bloc) => bloc.add(const TodayEvent.started()),
    expect: () => [
      const TodayState.loading(),
      TodayState.loaded(overview()),
      TodayState.loaded(overview(waterDone: true)),
    ],
  );

  blocTest<TodayBloc, TodayState>(
    'emits failure when the stream reports one',
    build: () {
      when(
        () => watch(any()),
      ).thenAnswer((_) => Stream.value(left(const Failure.network())));
      return build();
    },
    act: (bloc) => bloc.add(const TodayEvent.started()),
    expect: () => [
      const TodayState.loading(),
      const TodayState.failure(Failure.network()),
    ],
  );

  blocTest<TodayBloc, TodayState>(
    'toggling an undone habit asks to mark it done for the displayed day',
    build: () {
      when(
        () => watch(any()),
      ).thenAnswer((_) => Stream.value(right(overview())));
      when(() => toggle(any())).thenAnswer((_) async => right(unit));
      return build();
    },
    act: (bloc) async {
      bloc.add(const TodayEvent.started());
      await pumpEventQueue();
      bloc.add(const TodayEvent.habitToggled('water'));
    },
    verify: (_) => verify(
      () => toggle(
        const ToggleHabitCompletionParams(
          habitId: 'water',
          dateKey: today,
          done: true,
        ),
      ),
    ).called(1),
  );

  blocTest<TodayBloc, TodayState>(
    'toggling a done habit asks to mark it not done',
    build: () {
      when(
        () => watch(any()),
      ).thenAnswer((_) => Stream.value(right(overview(waterDone: true))));
      when(() => toggle(any())).thenAnswer((_) async => right(unit));
      return build();
    },
    act: (bloc) async {
      bloc.add(const TodayEvent.started());
      await pumpEventQueue();
      bloc.add(const TodayEvent.habitToggled('water'));
    },
    verify: (_) => verify(
      () => toggle(
        const ToggleHabitCompletionParams(
          habitId: 'water',
          dateKey: today,
          done: false,
        ),
      ),
    ).called(1),
  );

  blocTest<TodayBloc, TodayState>(
    'a failed toggle emits the failure once, then clears it',
    build: () {
      when(
        () => watch(any()),
      ).thenAnswer((_) => Stream.value(right(overview())));
      when(
        () => toggle(any()),
      ).thenAnswer((_) async => left(const Failure.server()));
      return build();
    },
    act: (bloc) async {
      bloc.add(const TodayEvent.started());
      await pumpEventQueue();
      bloc.add(const TodayEvent.habitToggled('water'));
    },
    expect: () => [
      const TodayState.loading(),
      TodayState.loaded(overview()),
      TodayState.loaded(overview(), actionFailure: const Failure.server()),
      TodayState.loaded(overview()),
    ],
  );

  blocTest<TodayBloc, TodayState>(
    'toggling an unknown habit does nothing',
    build: () {
      when(
        () => watch(any()),
      ).thenAnswer((_) => Stream.value(right(overview())));
      return build();
    },
    act: (bloc) async {
      bloc.add(const TodayEvent.started());
      await pumpEventQueue();
      bloc.add(const TodayEvent.habitToggled('ghost'));
    },
    verify: (_) => verifyNever(() => toggle(any())),
  );

  blocTest<TodayBloc, TodayState>(
    'toggling before data has loaded does nothing',
    build: build,
    act: (bloc) => bloc.add(const TodayEvent.habitToggled('water')),
    expect: () => <TodayState>[],
    verify: (_) => verifyNever(() => toggle(any())),
  );

  test(
    'restarting keeps current data on screen and swaps the subscription',
    () async {
      final first = StreamController<Either<Failure, TodayOverview>>();
      final second = StreamController<Either<Failure, TodayOverview>>();
      addTearDown(first.close);
      addTearDown(second.close);
      var calls = 0;
      when(
        () => watch(any()),
      ).thenAnswer((_) => (calls++ == 0) ? first.stream : second.stream);

      final bloc = build();
      addTearDown(bloc.close);
      final states = <TodayState>[];
      bloc.stream.listen(states.add);

      bloc.add(const TodayEvent.started());
      await pumpEventQueue();
      first.add(right(overview()));
      await pumpEventQueue();

      bloc.add(const TodayEvent.started());
      await pumpEventQueue();
      first.add(right(overview(waterDone: true))); // old subscription: ignored
      second.add(right(overview(waterDone: true)));
      await pumpEventQueue();

      expect(states, [
        const TodayState.loading(),
        TodayState.loaded(overview()),
        TodayState.loaded(overview(waterDone: true)),
      ]);
    },
  );

  group('deleting', () {
    blocTest<TodayBloc, TodayState>(
      'asks the use case to delete the habit',
      build: () {
        when(
          () => watch(any()),
        ).thenAnswer((_) => Stream.value(right(overview())));
        when(() => deleteHabit(any())).thenAnswer((_) async => right(unit));
        return build();
      },
      act: (bloc) async {
        bloc.add(const TodayEvent.started());
        await pumpEventQueue();
        bloc.add(const TodayEvent.habitDeleted('water'));
      },
      verify: (_) => verify(() => deleteHabit('water')).called(1),
    );

    blocTest<TodayBloc, TodayState>(
      'a failed delete emits the failure once, then clears it',
      build: () {
        when(
          () => watch(any()),
        ).thenAnswer((_) => Stream.value(right(overview())));
        when(
          () => deleteHabit(any()),
        ).thenAnswer((_) async => left(const Failure.network()));
        return build();
      },
      act: (bloc) async {
        bloc.add(const TodayEvent.started());
        await pumpEventQueue();
        bloc.add(const TodayEvent.habitDeleted('water'));
      },
      expect: () => [
        const TodayState.loading(),
        TodayState.loaded(overview()),
        TodayState.loaded(overview(), actionFailure: const Failure.network()),
        TodayState.loaded(overview()),
      ],
    );
  });

  group('resuming', () {
    test('re-subscribes when the day changed while away', () async {
      when(
        () => watch(any()),
      ).thenAnswer((_) => Stream.value(right(overview())));
      final bloc = build();
      addTearDown(bloc.close);

      bloc.add(const TodayEvent.started());
      await pumpEventQueue();
      verify(() => watch(any())).called(1);

      clock.current = DateTime(2026, 10, 18, 7); // next morning
      bloc.add(const TodayEvent.resumed());
      await pumpEventQueue();

      verify(() => watch(any())).called(1);
    });

    test('does nothing when it is still the same day', () async {
      when(
        () => watch(any()),
      ).thenAnswer((_) => Stream.value(right(overview())));
      final bloc = build();
      addTearDown(bloc.close);

      bloc.add(const TodayEvent.started());
      await pumpEventQueue();
      clearInteractions(watch);

      clock.current = DateTime(2026, 10, 17, 23, 59);
      bloc.add(const TodayEvent.resumed());
      await pumpEventQueue();

      verifyNever(() => watch(any()));
    });

    test('does nothing before data has loaded', () async {
      final bloc = build();
      addTearDown(bloc.close);

      bloc.add(const TodayEvent.resumed());
      await pumpEventQueue();

      verifyNever(() => watch(any()));
    });
  });
}

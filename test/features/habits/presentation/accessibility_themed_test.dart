import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/core/error/failure.dart';
import 'package:habit_tracker/core/time/date_key.dart';
import 'package:habit_tracker/features/habits/domain/entities/completion.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit_detail.dart';
import 'package:habit_tracker/features/habits/domain/entities/today_overview.dart';
import 'package:habit_tracker/features/habits/domain/services/streak_calculator.dart';
import 'package:habit_tracker/features/habits/presentation/bloc/add_habit/add_habit_bloc.dart';
import 'package:habit_tracker/features/habits/presentation/bloc/habit_detail/habit_detail_bloc.dart';
import 'package:habit_tracker/features/habits/presentation/bloc/today/today_bloc.dart';
import 'package:habit_tracker/features/habits/presentation/pages/add_habit_page.dart';
import 'package:habit_tracker/features/habits/presentation/pages/habit_detail_page.dart';
import 'package:habit_tracker/features/habits/presentation/pages/today_page.dart';
import 'package:habit_tracker/features/habits/presentation/widgets/confirm_delete_dialog.dart';
import 'package:habit_tracker/features/habits/presentation/widgets/habit_tile.dart';
import 'package:habit_tracker/features/habits/presentation/widgets/state_views.dart';

import '../../../helpers/builders.dart';
import '../../../helpers/pump_app.dart';

class _TodayBloc extends MockBloc<TodayEvent, TodayState>
    implements TodayBloc {}

class _DetailBloc extends MockBloc<HabitDetailEvent, HabitDetailState>
    implements HabitDetailBloc {}

class _AddBloc extends MockBloc<AddHabitEvent, AddHabitState>
    implements AddHabitBloc {}

/// Overflow guards for the redesigned screens with the real (light only) theme,
/// on a 320dp wide phone at 1.0x, 1.5x and 2.0x text.
void main() {
  const today = DateKey(2026, 10, 17);
  const longName = 'Drink two litres of water every single day without fail';
  const longDescription =
      'Keep a bottle on the desk and refill it often during the work day';

  Future<void> pumpToday(
    WidgetTester tester,
    TodayState state, {
    required double scale,
  }) async {
    useSmallPhone(tester);
    final bloc = _TodayBloc();
    whenListen(bloc, const Stream<TodayState>.empty(), initialState: state);
    await tester.pumpWidget(
      themedApp(
        textScale: scale,
        BlocProvider<TodayBloc>.value(value: bloc, child: const TodayPage()),
      ),
    );
    await tester.pumpAndSettle();
  }

  HabitDetail detailFor(List<int> doneOffsets) {
    final habit = buildHabit(
      id: 'a',
      name: longName,
      description: longDescription,
      points: 1000,
      createdDateKey: today.minusDays(30),
    );
    return HabitDetail(
      habit: habit,
      today: today,
      streak: const StreakCalculator().calculate(
        habit: habit,
        completions: [
          for (final offset in doneOffsets)
            Completion(habitId: 'a', dateKey: today.minusDays(offset)),
        ],
        today: today,
      ),
    );
  }

  for (final scale in [1.0, 1.5, 2.0]) {
    final label = '${scale}x';

    testWidgets('Today with long habits has no overflow ($label)', (
      tester,
    ) async {
      await pumpToday(
        tester,
        TodayState.loaded(
          TodayOverview(
            date: today,
            items: [
              buildItem(
                habit: buildHabit(
                  id: 'a',
                  name: longName,
                  description: longDescription,
                  points: 1000,
                ),
                isDone: true,
              ),
              buildItem(
                habit: buildHabit(id: 'b', name: 'Read 20 pages'),
                isDone: false,
              ),
            ],
          ),
        ),
        scale: scale,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('Today empty state has no overflow ($label)', (tester) async {
      await pumpToday(
        tester,
        const TodayState.loaded(TodayOverview(date: today, items: [])),
        scale: scale,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('Today loading skeleton has no overflow ($label)', (
      tester,
    ) async {
      await pumpToday(tester, const TodayState.loading(), scale: scale);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Today error state has no overflow ($label)', (tester) async {
      await pumpToday(
        tester,
        const TodayState.failure(Failure.network()),
        scale: scale,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('ErrorView with a very long message ($label)', (tester) async {
      useSmallPhone(tester);
      await tester.pumpWidget(
        themedApp(
          textScale: scale,
          Scaffold(
            body: ErrorView(message: 'Something failed. ' * 20, onRetry: () {}),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });

    for (final doneOffsets in [
      <int>[],
      [0],
      [0, 1, 2, 3, 4, 5, 6],
    ]) {
      testWidgets('Detail with ${doneOffsets.length} done days ($label)', (
        tester,
      ) async {
        useSmallPhone(tester);
        final bloc = _DetailBloc();
        whenListen(
          bloc,
          const Stream<HabitDetailState>.empty(),
          initialState: HabitDetailState.loaded(detailFor(doneOffsets)),
        );
        await tester.pumpWidget(
          themedApp(
            textScale: scale,
            BlocProvider<HabitDetailBloc>.value(
              value: bloc,
              child: const HabitDetailPage(),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('Detail loading skeleton has no overflow ($label)', (
      tester,
    ) async {
      useSmallPhone(tester);
      final bloc = _DetailBloc();
      whenListen(
        bloc,
        const Stream<HabitDetailState>.empty(),
        initialState: const HabitDetailState.loading(),
      );
      await tester.pumpWidget(
        themedApp(
          textScale: scale,
          BlocProvider<HabitDetailBloc>.value(
            value: bloc,
            child: const HabitDetailPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('Add habit with long text and errors ($label)', (tester) async {
      useSmallPhone(tester);
      final bloc = _AddBloc();
      whenListen(
        bloc,
        const Stream<AddHabitState>.empty(),
        initialState: const AddHabitState.initial(),
      );
      await tester.pumpWidget(
        themedApp(
          textScale: scale,
          BlocProvider<AddHabitBloc>.value(
            value: bloc,
            child: const AddHabitPage(),
          ),
        ),
      );
      await tester.enterText(
        find.byKey(const Key('description-field')),
        longDescription * 3,
      );
      await tester.enterText(find.byKey(const Key('points-field')), '');
      await tester.tap(find.text('Save habit'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a name'), findsOneWidget);
      expect(find.text('Enter a number of points'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.enterText(find.byKey(const Key('name-field')), longName);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('saving state on a small phone shows one spinner', (
    tester,
  ) async {
    useSmallPhone(tester);
    final bloc = _AddBloc();
    whenListen(
      bloc,
      const Stream<AddHabitState>.empty(),
      initialState: const AddHabitState.submitting(),
    );
    await tester.pumpWidget(
      themedApp(
        textScale: 2,
        BlocProvider<AddHabitBloc>.value(
          value: bloc,
          child: const AddHabitPage(),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  group('touch targets', () {
    void expectAtLeast48(WidgetTester tester, Finder finder, String reason) {
      expect(finder, findsWidgets, reason: reason);
      for (final element in finder.evaluate()) {
        final size = tester.getSize(
          find.byElementPredicate((e) => e == element),
        );
        expect(size.width, greaterThanOrEqualTo(48), reason: '$reason width');
        expect(size.height, greaterThanOrEqualTo(48), reason: '$reason height');
      }
    }

    testWidgets('Today: checks, rows and the New habit button', (tester) async {
      await pumpToday(
        tester,
        TodayState.loaded(
          TodayOverview(
            date: today,
            items: [
              buildItem(
                habit: buildHabit(id: 'a', name: 'Read'),
              ),
              buildItem(
                habit: buildHabit(id: 'b', name: 'Run'),
                isDone: true,
              ),
            ],
          ),
        ),
        scale: 1,
      );

      expectAtLeast48(tester, find.byTooltip('Mark as done'), 'open check');
      expectAtLeast48(tester, find.byTooltip('Mark as not done'), 'done check');
      expectAtLeast48(tester, find.byType(HabitTile), 'row');
      expectAtLeast48(tester, find.byType(OutlinedButton), 'New habit');
    });

    testWidgets('Add: close, stepper, quick picks and save', (tester) async {
      useSmallPhone(tester);
      final bloc = _AddBloc();
      whenListen(
        bloc,
        const Stream<AddHabitState>.empty(),
        initialState: const AddHabitState.initial(),
      );
      await tester.pumpWidget(
        themedApp(
          BlocProvider<AddHabitBloc>.value(
            value: bloc,
            child: const AddHabitPage(),
          ),
        ),
      );

      expectAtLeast48(tester, find.byTooltip('Close'), 'close');
      expectAtLeast48(tester, find.byTooltip('Decrease points'), 'minus');
      expectAtLeast48(tester, find.byTooltip('Increase points'), 'plus');
      expectAtLeast48(
        tester,
        find.byWidgetPredicate(
          (w) => w.key.toString().contains('points-chip-'),
        ),
        'quick pick',
      );
      expectAtLeast48(tester, find.byType(OutlinedButton), 'Save habit');
    });

    testWidgets('Detail: back and the today action', (tester) async {
      useSmallPhone(tester);
      final bloc = _DetailBloc();
      whenListen(
        bloc,
        const Stream<HabitDetailState>.empty(),
        initialState: HabitDetailState.loaded(detailFor(const [])),
      );
      await tester.pumpWidget(
        themedApp(
          BlocProvider<HabitDetailBloc>.value(
            value: bloc,
            child: const HabitDetailPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expectAtLeast48(tester, find.byTooltip('Back'), 'back');
      expectAtLeast48(tester, find.byType(OutlinedButton), 'today action');
    });

    testWidgets('the delete dialog buttons', (tester) async {
      await tester.pumpWidget(
        themedApp(
          Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => confirmDeleteHabit(context, 'Read'),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expectAtLeast48(tester, find.byType(TextButton).last, 'Cancel');
      expectAtLeast48(tester, find.byType(OutlinedButton), 'Delete');
    });
  });

  for (final scale in [1.0, 1.5, 2.0]) {
    testWidgets('delete dialog has no overflow (${scale}x)', (tester) async {
      useSmallPhone(tester);
      await tester.pumpWidget(
        themedApp(
          textScale: scale,
          Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => confirmDeleteHabit(context, longName),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.text('Delete habit?'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Today header with big numbers has no overflow (${scale}x)', (
      tester,
    ) async {
      await pumpToday(
        tester,
        TodayState.loaded(
          TodayOverview(
            date: today,
            items: [
              for (var i = 0; i < 4; i++)
                buildItem(
                  habit: buildHabit(id: 'h$i', name: 'Habit $i', points: 1000),
                  isDone: i.isEven,
                ),
            ],
          ),
        ),
        scale: scale,
      );
      expect(find.text('2000'), findsOneWidget);
      expect(find.text('/ 4000 points'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}

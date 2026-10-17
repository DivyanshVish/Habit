import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/core/time/date_key.dart';
import 'package:habit_tracker/features/habits/domain/entities/completion.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit_detail.dart';
import 'package:habit_tracker/features/habits/domain/entities/today_overview.dart';
import 'package:habit_tracker/features/habits/domain/services/streak_calculator.dart';
import 'package:habit_tracker/features/habits/presentation/bloc/habit_detail/habit_detail_bloc.dart';
import 'package:habit_tracker/features/habits/presentation/bloc/today/today_bloc.dart';
import 'package:habit_tracker/features/habits/presentation/pages/habit_detail_page.dart';
import 'package:habit_tracker/features/habits/presentation/pages/today_page.dart';

import '../../../helpers/builders.dart';

class _FakeTodayBloc extends MockBloc<TodayEvent, TodayState>
    implements TodayBloc {}

class _FakeDetailBloc extends MockBloc<HabitDetailEvent, HabitDetailState>
    implements HabitDetailBloc {}

/// Guards against RenderFlex overflow at large text sizes on a small phone.
void main() {
  const today = DateKey(2026, 10, 17);

  Future<void> setSmallPhone(WidgetTester tester) async {
    tester.view.physicalSize = const Size(320 * 3, 568 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
  }

  Widget app(Widget home, {required double textScale}) {
    return MaterialApp(
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(textScale)),
        child: child!,
      ),
      home: home,
    );
  }

  for (final scale in [1.0, 1.5, 2.0]) {
    testWidgets('Today screen has no overflow at ${scale}x text', (
      tester,
    ) async {
      await setSmallPhone(tester);
      final bloc = _FakeTodayBloc();
      whenListen(
        bloc,
        const Stream<TodayState>.empty(),
        initialState: TodayState.loaded(
          TodayOverview(
            date: today,
            items: [
              buildItem(
                habit: buildHabit(
                  id: 'a',
                  name: 'Drink two litres of water every single day',
                  description: 'Keep a bottle on the desk and refill it often',
                  points: 1000,
                ),
                isDone: true,
              ),
              buildItem(
                habit: buildHabit(id: 'b', name: 'Read 20 pages', points: 20),
                isDone: false,
              ),
            ],
          ),
        ),
      );

      await tester.pumpWidget(
        app(
          BlocProvider<TodayBloc>.value(value: bloc, child: const TodayPage()),
          textScale: scale,
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('Detail screen has no overflow at ${scale}x text', (
      tester,
    ) async {
      await setSmallPhone(tester);
      final bloc = _FakeDetailBloc();
      final habit = buildHabit(
        id: 'a',
        name: 'Drink two litres of water every single day',
        description:
            'Keep a bottle on the desk and refill it often during work',
        points: 1000,
        createdDateKey: today.minusDays(30),
      );
      whenListen(
        bloc,
        const Stream<HabitDetailState>.empty(),
        initialState: HabitDetailState.loaded(
          HabitDetail(
            habit: habit,
            today: today,
            streak: const StreakCalculator().calculate(
              habit: habit,
              completions: [
                for (var i = 0; i < 4; i++)
                  Completion(habitId: 'a', dateKey: today.minusDays(i)),
              ],
              today: today,
            ),
          ),
        ),
      );

      await tester.pumpWidget(
        app(
          BlocProvider<HabitDetailBloc>.value(
            value: bloc,
            child: const HabitDetailPage(),
          ),
          textScale: scale,
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  }
}

import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:habit_tracker/core/error/failure.dart';
import 'package:habit_tracker/core/time/date_key.dart';
import 'package:habit_tracker/features/habits/domain/entities/completion.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit_detail.dart';
import 'package:habit_tracker/features/habits/domain/services/streak_calculator.dart';
import 'package:habit_tracker/features/habits/presentation/bloc/habit_detail/habit_detail_bloc.dart';
import 'package:habit_tracker/features/habits/presentation/pages/habit_detail_page.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/builders.dart';

class _MockHabitDetailBloc extends MockBloc<HabitDetailEvent, HabitDetailState>
    implements HabitDetailBloc {}

/// The visible pill inside the snack bar (the SnackBar widget itself spans the
/// whole width).
final Finder _pill = find
    .descendant(of: find.byType(SnackBar), matching: find.byType(Material))
    .first;

void main() {
  late _MockHabitDetailBloc bloc;
  const today = DateKey(2026, 10, 17); // Saturday

  HabitDetail detail({
    List<int> doneOffsets = const [],
    int createdDaysAgo = 30,
    String description = 'Stay hydrated',
  }) {
    final habit = buildHabit(
      id: 'h1',
      name: 'Drink 2L water',
      description: description,
      points: 15,
      createdDateKey: today.minusDays(createdDaysAgo),
    );
    return HabitDetail(
      habit: habit,
      today: today,
      streak: const StreakCalculator().calculate(
        habit: habit,
        completions: [
          for (final offset in doneOffsets)
            Completion(habitId: 'h1', dateKey: today.minusDays(offset)),
        ],
        today: today,
      ),
    );
  }

  setUpAll(() => registerFallbackValue(const HabitDetailEvent.started()));

  setUp(() => bloc = _MockHabitDetailBloc());

  Future<void> pumpPage(
    WidgetTester tester,
    HabitDetailState state, {
    Stream<HabitDetailState> updates = const Stream<HabitDetailState>.empty(),
  }) async {
    whenListen(bloc, updates, initialState: state);
    final router = GoRouter(
      initialLocation: '/detail',
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const Scaffold(body: Text('home')),
        ),
        GoRoute(
          path: '/detail',
          builder: (_, _) => BlocProvider<HabitDetailBloc>.value(
            value: bloc,
            child: const HabitDetailPage(),
          ),
        ),
      ],
    );
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
  }

  testWidgets('shows kicker, name, description and point value', (
    tester,
  ) async {
    await pumpPage(tester, HabitDetailState.loaded(detail()));

    expect(find.text('HABIT'), findsOneWidget);
    expect(find.text('Drink 2L water'), findsOneWidget);
    expect(find.text('Stay hydrated'), findsOneWidget);
    expect(find.text('15 points'), findsOneWidget);
    expect(find.text('per completion'), findsOneWidget);
  });

  testWidgets('shows a placeholder for an empty description', (tester) async {
    await pumpPage(tester, HabitDetailState.loaded(detail(description: '')));

    expect(find.text('No description'), findsOneWidget);
  });

  testWidgets('renders 7 day chips with weekday initials ending today', (
    tester,
  ) async {
    await pumpPage(
      tester,
      HabitDetailState.loaded(detail(doneOffsets: [0, 1])),
    );

    expect(find.text('LAST 7 DAYS'), findsOneWidget);
    // 2026-10-11 (Sun) ... 2026-10-17 (Sat)
    for (final day in ['11', '12', '13', '14', '15', '16', '17']) {
      expect(find.text(day), findsOneWidget, reason: 'day $day');
    }
    // Two done pills; the button shows undo, not a check, once today is done.
    expect(find.byIcon(Icons.check), findsNWidgets(2));
    expect(find.byIcon(Icons.undo), findsOne);
  });

  testWidgets('the action shows a check while today is still open', (
    tester,
  ) async {
    await pumpPage(tester, HabitDetailState.loaded(detail()));

    expect(find.byIcon(Icons.check), findsOneWidget);
  });

  testWidgets('chips expose accessible labels', (tester) async {
    final semantics = tester.ensureSemantics();
    await pumpPage(
      tester,
      HabitDetailState.loaded(detail(doneOffsets: [0, 2], createdDaysAgo: 3)),
    );

    expect(find.bySemanticsLabel('Today, done'), findsOneWidget);
    expect(find.bySemanticsLabel('Thursday, done'), findsOneWidget);
    expect(find.bySemanticsLabel('Friday, missed'), findsOneWidget);
    expect(
      find.bySemanticsLabel('Monday, before this habit was created'),
      findsOneWidget,
    );
    semantics.dispose();
  });

  testWidgets('an open day today reads as not done yet, not missed', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await pumpPage(tester, HabitDetailState.loaded(detail(doneOffsets: [1])));

    expect(find.bySemanticsLabel('Today, not done yet'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('shows the current streak and done count', (tester) async {
    await pumpPage(
      tester,
      HabitDetailState.loaded(detail(doneOffsets: [0, 1, 2, 4])),
    );

    final semantics = tester.ensureSemantics();
    expect(find.bySemanticsLabel('Current streak: 3 days'), findsOneWidget);
    expect(find.text('4 of 7 days'), findsOneWidget);
    // 4 done days at 15 points each.
    expect(find.text('60 points this week'), findsOneWidget);
    expect(
      tester.widget<Text>(find.byKey(const Key('streak-count'))).data,
      '3',
    );
    expect(find.text('day streak'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('uses singular for a one day streak', (tester) async {
    await pumpPage(tester, HabitDetailState.loaded(detail(doneOffsets: [0])));

    final semantics = tester.ensureSemantics();
    expect(find.bySemanticsLabel('Current streak: 1 day'), findsOneWidget);
    expect(find.text('day streak'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('offers to mark today done and dispatches the toggle', (
    tester,
  ) async {
    await pumpPage(tester, HabitDetailState.loaded(detail()));

    expect(find.text('Mark today done'), findsOneWidget);
    await tester.tap(find.text('Mark today done'));
    await tester.pump();

    verify(() => bloc.add(const HabitDetailEvent.todayToggled())).called(1);
  });

  testWidgets('offers to mark today not done when it is done', (tester) async {
    await pumpPage(tester, HabitDetailState.loaded(detail(doneOffsets: [0])));

    expect(find.text('Mark today not done'), findsOneWidget);
    expect(find.text('Mark today done'), findsNothing);
    await tester.tap(find.text('Mark today not done'));
    await tester.pump();

    verify(() => bloc.add(const HabitDetailEvent.todayToggled())).called(1);
  });

  group('toast', () {
    testWidgets('shows +N points for an open habit, 190dp wide, above the '
        'action', (tester) async {
      await pumpPage(tester, HabitDetailState.loaded(detail()));

      await tester.tap(find.text('Mark today done'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('+15 points'), findsOneWidget);
      expect(tester.getSize(_pill).width, 190);
      expect(
        tester.getBottomLeft(_pill).dy,
        lessThanOrEqualTo(tester.getTopLeft(find.byType(OutlinedButton)).dy),
      );

      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
      expect(find.text('+15 points'), findsNothing);
    });

    testWidgets('shows -N points for a done habit', (tester) async {
      await pumpPage(tester, HabitDetailState.loaded(detail(doneOffsets: [0])));

      await tester.tap(find.text('Mark today not done'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('-15 points'), findsOneWidget);
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
    });

    testWidgets('is replaced by the error snackbar when the toggle fails', (
      tester,
    ) async {
      final updates = StreamController<HabitDetailState>();
      addTearDown(updates.close);
      await pumpPage(
        tester,
        HabitDetailState.loaded(detail()),
        updates: updates.stream,
      );

      await tester.tap(find.text('Mark today done'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('+15 points'), findsOneWidget);

      updates.add(
        HabitDetailState.loaded(
          detail(),
          actionFailure: const Failure.network(),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.text('+15 points'), findsNothing);
      expect(find.text(const Failure.network().message), findsOneWidget);
      await tester.pump(const Duration(seconds: 6));
      await tester.pumpAndSettle();
    });
  });

  testWidgets('has an outlined action and no filled button or FAB', (
    tester,
  ) async {
    await pumpPage(tester, HabitDetailState.loaded(detail()));

    expect(find.byType(OutlinedButton), findsOneWidget);
    expect(find.byType(FilledButton), findsNothing);
    expect(find.byType(FloatingActionButton), findsNothing);
    expect(
      tester.getSize(find.byType(OutlinedButton)).height,
      greaterThanOrEqualTo(48),
    );
  });

  testWidgets('shows a skeleton while loading, not a spinner', (tester) async {
    await pumpPage(tester, const HabitDetailState.loading());

    expect(find.byKey(const Key('detail-skeleton')), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('the back button leaves the screen', (tester) async {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, _) => Scaffold(
            body: TextButton(
              onPressed: () => context.push('/detail'),
              child: const Text('open'),
            ),
          ),
        ),
        GoRoute(
          path: '/detail',
          builder: (_, _) => BlocProvider<HabitDetailBloc>.value(
            value: bloc,
            child: const HabitDetailPage(),
          ),
        ),
      ],
    );
    whenListen(
      bloc,
      const Stream<HabitDetailState>.empty(),
      initialState: HabitDetailState.loaded(detail()),
    );
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('Mark today done'), findsOneWidget);

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    expect(find.text('open'), findsOneWidget);
  });

  testWidgets('shows an error with retry', (tester) async {
    await pumpPage(tester, const HabitDetailState.failure(Failure.network()));

    await tester.tap(find.text('Try again'));
    await tester.pump();

    verify(() => bloc.add(const HabitDetailEvent.started())).called(1);
  });

  testWidgets('shows a snackbar when a toggle fails', (tester) async {
    whenListen(
      bloc,
      Stream<HabitDetailState>.fromIterable([
        HabitDetailState.loaded(
          detail(),
          actionFailure: const Failure.network(),
        ),
      ]),
      initialState: HabitDetailState.loaded(detail()),
    );
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => BlocProvider<HabitDetailBloc>.value(
            value: bloc,
            child: const HabitDetailPage(),
          ),
        ),
      ],
    );
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pump();

    expect(find.text(const Failure.network().message), findsOneWidget);
  });

  testWidgets('leaves the screen when the habit is deleted', (tester) async {
    whenListen(
      bloc,
      Stream<HabitDetailState>.fromIterable([
        const HabitDetailState.failure(
          Failure.notFound(message: 'This habit no longer exists.'),
        ),
      ]),
      initialState: HabitDetailState.loaded(detail()),
    );
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, _) => Scaffold(
            body: TextButton(
              onPressed: () => context.push('/detail'),
              child: const Text('open'),
            ),
          ),
        ),
        GoRoute(
          path: '/detail',
          builder: (_, _) => BlocProvider<HabitDetailBloc>.value(
            value: bloc,
            child: const HabitDetailPage(),
          ),
        ),
      ],
    );
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.tap(find.text('open'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('This habit no longer exists.'), findsOneWidget);
    expect(find.text('open'), findsOneWidget);
    expect(find.text('Mark today done'), findsNothing);
  });
}

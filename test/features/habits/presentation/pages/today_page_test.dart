import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart' show CustomSemanticsAction;
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:habit_tracker/core/error/failure.dart';
import 'package:habit_tracker/core/theme/app_tokens.dart';
import 'package:habit_tracker/core/time/date_key.dart';
import 'package:habit_tracker/features/habits/domain/entities/today_overview.dart';
import 'package:habit_tracker/features/habits/presentation/bloc/today/today_bloc.dart';
import 'package:habit_tracker/features/habits/presentation/pages/today_page.dart';
import 'package:habit_tracker/features/habits/presentation/widgets/habit_tile.dart';
import 'package:habit_tracker/features/habits/presentation/widgets/hairline.dart';
import 'package:habit_tracker/features/habits/presentation/widgets/progress_header.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/builders.dart';

class _MockTodayBloc extends MockBloc<TodayEvent, TodayState>
    implements TodayBloc {}

/// The visible pill inside the snack bar (the SnackBar widget itself spans the
/// whole width).
final Finder _pill = find
    .descendant(of: find.byType(SnackBar), matching: find.byType(Material))
    .first;

void main() {
  late _MockTodayBloc bloc;

  final overview = TodayOverview(
    date: const DateKey(2026, 10, 17),
    items: [
      buildItem(
        habit: buildHabit(id: 'water', name: 'Drink 2L water', points: 10),
        isDone: true,
      ),
      buildItem(
        habit: buildHabit(
          id: 'read',
          name: 'Read 20 pages',
          description: 'Before bed',
          points: 20,
        ),
        isDone: false,
      ),
      buildItem(
        habit: buildHabit(id: 'run', name: 'Exercise 30 min', points: 15),
        isDone: false,
      ),
    ],
  );

  setUpAll(() => registerFallbackValue(const TodayEvent.started()));

  setUp(() => bloc = _MockTodayBloc());

  Future<GoRouter> pumpPage(WidgetTester tester, TodayState state) async {
    whenListen(bloc, const Stream<TodayState>.empty(), initialState: state);
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => BlocProvider<TodayBloc>.value(
            value: bloc,
            child: const TodayPage(),
          ),
        ),
        GoRoute(
          path: '/habits/new',
          builder: (_, _) => const Scaffold(body: Text('add screen')),
        ),
        GoRoute(
          path: '/habits/:id',
          builder: (_, state) =>
              Scaffold(body: Text('detail ${state.pathParameters['id']}')),
        ),
      ],
    );
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    return router;
  }

  Finder inHeader(Finder finder) =>
      find.descendant(of: find.byType(ProgressHeader), matching: finder);

  testWidgets('shows the progress header with points and completion count', (
    tester,
  ) async {
    await pumpPage(tester, TodayState.loaded(overview));

    expect(find.text('SATURDAY \u00B7 17 OCTOBER'), findsOneWidget);
    expect(find.text('Today'), findsOneWidget);
    expect(inHeader(find.text('10')), findsOneWidget); // earned points
    expect(find.text('/ 45 points'), findsOneWidget);
    expect(find.text('1 of 3 done'), findsOneWidget);
    expect(find.byKey(const Key('progress-bar')), findsOneWidget);
  });

  testWidgets('the header reads as one summary for screen readers', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await pumpPage(tester, TodayState.loaded(overview));

    expect(
      find.bySemanticsLabel('Today: 10 of 45 points, 1 of 3 habits done'),
      findsOneWidget,
    );
    semantics.dispose();
  });

  testWidgets('lists every habit with its points over PTS', (tester) async {
    await pumpPage(tester, TodayState.loaded(overview));

    expect(find.text('Drink 2L water'), findsOneWidget);
    expect(find.text('Read 20 pages'), findsOneWidget);
    expect(find.text('Exercise 30 min'), findsOneWidget);
    // The description is not part of the row any more (it lives on Detail).
    expect(find.text('Before bed'), findsNothing);
    expect(find.text('20'), findsOneWidget);
    expect(find.text('15'), findsOneWidget);
    // Earned points in the header and the 10 point row.
    expect(find.text('10'), findsNWidgets(2));
    expect(find.text('PTS'), findsNWidgets(3));
  });

  testWidgets('each row shows seven streak segments and the streak text', (
    tester,
  ) async {
    final streaky = TodayOverview(
      date: const DateKey(2026, 10, 17),
      items: [
        buildItem(
          habit: buildHabit(id: 'a', name: 'Streaky'),
          streak: buildStreak(doneOffsets: [1, 2, 3]),
        ),
        buildItem(
          habit: buildHabit(id: 'b', name: 'Fresh'),
        ),
        buildItem(
          habit: buildHabit(id: 'c', name: 'Done'),
          isDone: true,
        ),
      ],
    );
    await pumpPage(tester, TodayState.loaded(streaky));

    expect(find.text('3-day streak'), findsOneWidget);
    expect(find.text('No streak'), findsOneWidget);
    expect(find.text('1-day streak'), findsOneWidget);
    expect(find.byKey(const Key('streak-segment-0')), findsNWidgets(3));
    expect(find.byKey(const Key('streak-segment-6')), findsNWidgets(3));

    // First row: days 3, 2 and 1 ago are done (segments 3 to 5), today open.
    final first = find.ancestor(
      of: find.text('3-day streak'),
      matching: find.byType(HabitTile),
    );
    Color? segment(int i) => tester
        .widget<Container>(
          find.descendant(
            of: first,
            matching: find.byKey(Key('streak-segment-$i')),
          ),
        )
        .color;
    const tokens = AppTokens.light;
    expect(segment(0), tokens.track);
    expect(segment(3), tokens.accent);
    expect(segment(4), tokens.accent);
    expect(segment(5), tokens.accent);
    expect(segment(6), tokens.track);
  });

  testWidgets('rows are separated by hairlines and there is no FAB', (
    tester,
  ) async {
    await pumpPage(tester, TodayState.loaded(overview));

    expect(find.byType(FloatingActionButton), findsNothing);
    // header divider + 2 separators between 3 rows
    expect(find.byType(Hairline), findsNWidgets(3));
  });

  testWidgets('shows done and not-done states with accessible labels', (
    tester,
  ) async {
    await pumpPage(tester, TodayState.loaded(overview));

    expect(find.byTooltip('Mark as not done'), findsOneWidget);
    expect(find.byTooltip('Mark as done'), findsNWidgets(2));
  });

  testWidgets('tapping the status toggle dispatches habitToggled', (
    tester,
  ) async {
    await pumpPage(tester, TodayState.loaded(overview));

    await tester.tap(find.byTooltip('Mark as done').first);
    await tester.pump();

    verify(() => bloc.add(const TodayEvent.habitToggled('read'))).called(1);
  });

  testWidgets('toggling gives light haptic feedback and dispatches', (
    tester,
  ) async {
    final haptics = <String?>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'HapticFeedback.vibrate') {
          haptics.add(call.arguments as String?);
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    await pumpPage(tester, TodayState.loaded(overview));

    await tester.tap(find.byTooltip('Mark as done').first);
    await tester.pump();

    expect(haptics, ['HapticFeedbackType.lightImpact']);
    verify(() => bloc.add(const TodayEvent.habitToggled('read'))).called(1);
  });

  group('toast', () {
    testWidgets('an open habit shows +N points in a 190dp pill', (
      tester,
    ) async {
      await pumpPage(tester, TodayState.loaded(overview));

      await tester.tap(find.byTooltip('Mark as done').first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('+20 points'), findsOneWidget);
      expect(tester.getSize(_pill).width, 190);
      // It floats above the bottom bar, not over the New habit button.
      expect(
        tester.getBottomLeft(_pill).dy,
        lessThanOrEqualTo(tester.getTopLeft(find.byType(OutlinedButton)).dy),
      );
      verify(() => bloc.add(const TodayEvent.habitToggled('read'))).called(1);

      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
      expect(find.text('+20 points'), findsNothing);
    });

    testWidgets('a done habit shows -N points', (tester) async {
      await pumpPage(tester, TodayState.loaded(overview));

      await tester.tap(find.byTooltip('Mark as not done'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('-10 points'), findsOneWidget);
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
    });

    testWidgets('is replaced by the error snackbar when the toggle fails', (
      tester,
    ) async {
      final updates = StreamController<TodayState>();
      addTearDown(updates.close);
      whenListen(
        bloc,
        updates.stream,
        initialState: TodayState.loaded(overview),
      );
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (_, _) => BlocProvider<TodayBloc>.value(
              value: bloc,
              child: const TodayPage(),
            ),
          ),
        ],
      );
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      await tester.tap(find.byTooltip('Mark as done').first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('+20 points'), findsOneWidget);

      updates.add(
        TodayState.loaded(overview, actionFailure: const Failure.network()),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.text('+20 points'), findsNothing);
      expect(find.text(const Failure.network().message), findsOneWidget);
      await tester.pump(const Duration(seconds: 6));
      await tester.pumpAndSettle();
    });
  });

  testWidgets('a done habit is dimmed and struck through', (tester) async {
    await pumpPage(tester, TodayState.loaded(overview));
    await tester.pumpAndSettle();

    final done = tester.widget<Text>(find.text('Drink 2L water'));
    final open = tester.widget<Text>(find.text('Read 20 pages'));
    expect(done.style?.decoration, TextDecoration.lineThrough);
    expect(open.style?.decoration, isNull);
    expect(done.style?.color, isNot(open.style?.color));
  });

  group('deleting', () {
    testWidgets('swipe asks for confirmation, then dispatches habitDeleted', (
      tester,
    ) async {
      await pumpPage(tester, TodayState.loaded(overview));

      await tester.drag(find.text('Read 20 pages'), const Offset(-600, 0));
      await tester.pumpAndSettle();

      expect(find.text('Delete habit?'), findsOneWidget);
      verifyNever(() => bloc.add(any(that: isA<TodayHabitDeleted>())));

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      verify(() => bloc.add(const TodayEvent.habitDeleted('read'))).called(1);
      // The row stays until the live stream removes it.
      expect(find.text('Read 20 pages'), findsOneWidget);
    });

    testWidgets('cancelling the dialog deletes nothing', (tester) async {
      await pumpPage(tester, TodayState.loaded(overview));

      await tester.drag(find.text('Read 20 pages'), const Offset(-600, 0));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      verifyNever(() => bloc.add(any(that: isA<TodayHabitDeleted>())));
      expect(find.text('Read 20 pages'), findsOneWidget);
    });

    testWidgets('screen readers get a delete action', (tester) async {
      final semantics = tester.ensureSemantics();
      await pumpPage(tester, TodayState.loaded(overview));

      final tileSemantics = find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.customSemanticsActions != null,
      );
      expect(tileSemantics, findsNWidgets(3));
      final node = tester.getSemantics(tileSemantics.at(1));
      final actions = node.getSemanticsData().customSemanticsActionIds ?? [];
      final labels = actions
          .map((id) => CustomSemanticsAction.getAction(id)?.label)
          .toList();

      expect(labels, contains('Delete habit'));
      semantics.dispose();
    });
  });

  testWidgets('tapping a habit opens its detail screen', (tester) async {
    await pumpPage(tester, TodayState.loaded(overview));

    await tester.tap(find.text('Read 20 pages'));
    await tester.pumpAndSettle();

    expect(find.text('detail read'), findsOneWidget);
  });

  testWidgets('the add button opens the add screen', (tester) async {
    await pumpPage(tester, TodayState.loaded(overview));

    await tester.tap(find.text('New habit'));
    await tester.pumpAndSettle();

    expect(find.text('add screen'), findsOneWidget);
  });

  testWidgets('shows an italic empty state without habits', (tester) async {
    await pumpPage(
      tester,
      const TodayState.loaded(
        TodayOverview(date: DateKey(2026, 10, 17), items: []),
      ),
    );

    expect(find.text('No habits yet. Begin with one.'), findsOneWidget);
    final style = tester
        .widget<Text>(find.text('No habits yet. Begin with one.'))
        .style;
    expect(style?.fontStyle, FontStyle.italic);
    // The date stays visible and the single action is always there.
    expect(find.text('SATURDAY \u00B7 17 OCTOBER'), findsOneWidget);
    expect(find.text('Today'), findsOneWidget);
    expect(find.text('New habit'), findsOneWidget);
    expect(find.byKey(const Key('progress-bar')), findsNothing);
    expect(find.byType(FloatingActionButton), findsNothing);
  });

  testWidgets('shows a skeleton while loading, not a spinner', (tester) async {
    await pumpPage(tester, const TodayState.loading());

    expect(find.byKey(const Key('today-skeleton')), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('shows the error with a retry that restarts the stream', (
    tester,
  ) async {
    await pumpPage(tester, const TodayState.failure(Failure.network()));

    expect(find.text(const Failure.network().message), findsOneWidget);
    await tester.tap(find.text('Try again'));
    await tester.pump();

    verify(() => bloc.add(const TodayEvent.started())).called(1);
  });

  testWidgets('shows a snackbar for a failed toggle', (tester) async {
    whenListen(
      bloc,
      Stream<TodayState>.fromIterable([
        TodayState.loaded(overview, actionFailure: const Failure.network()),
      ]),
      initialState: TodayState.loaded(overview),
    );
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => BlocProvider<TodayBloc>.value(
            value: bloc,
            child: const TodayPage(),
          ),
        ),
      ],
    );
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pump();

    expect(find.text(const Failure.network().message), findsOneWidget);
  });
}

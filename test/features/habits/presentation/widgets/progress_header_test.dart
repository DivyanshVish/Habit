import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/core/theme/app_tokens.dart';
import 'package:habit_tracker/core/time/date_key.dart';
import 'package:habit_tracker/features/habits/domain/entities/today_overview.dart';
import 'package:habit_tracker/features/habits/presentation/widgets/progress_header.dart';

import '../../../../helpers/builders.dart';
import '../../../../helpers/pump_app.dart';

void main() {
  final overview = TodayOverview(
    date: const DateKey(2026, 10, 17),
    items: [
      buildItem(habit: buildHabit(id: 'a', points: 10), isDone: true),
      buildItem(habit: buildHabit(id: 'b', points: 20), isDone: false),
      buildItem(habit: buildHabit(id: 'c', points: 15), isDone: false),
    ],
  );

  Future<void> pump(WidgetTester tester, TodayOverview value) {
    return tester.pumpWidget(
      themedApp(Scaffold(body: ProgressHeader(overview: value))),
    );
  }

  testWidgets('shows kicker, title, points and count', (tester) async {
    await pump(tester, overview);

    expect(find.text('SATURDAY \u00B7 17 OCTOBER'), findsOneWidget);
    expect(find.text('Today'), findsOneWidget);
    expect(find.text('10'), findsOneWidget);
    expect(find.text('/ 45 points'), findsOneWidget);
    expect(find.text('1 of 3 done'), findsOneWidget);
  });

  testWidgets('the earned numeral is large serif and the bar is gold', (
    tester,
  ) async {
    await pump(tester, overview);
    await tester.pumpAndSettle();

    final numeral = tester.widget<Text>(find.text('10'));
    expect(numeral.style?.fontSize, 64);
    expect(numeral.style?.fontFamily, AppTextTokens.headingFamily);
    final fill = tester.widget<ColoredBox>(
      find.descendant(
        of: find.byKey(const Key('progress-bar')),
        matching: find.byType(ColoredBox),
      ),
    );
    expect(fill.color, AppTokens.light.accent);
  });

  testWidgets('reads as one summary for screen readers', (tester) async {
    final semantics = tester.ensureSemantics();
    await pump(tester, overview);

    expect(
      find.bySemanticsLabel('Today: 10 of 45 points, 1 of 3 habits done'),
      findsOneWidget,
    );
    semantics.dispose();
  });

  testWidgets('the progress bar settles on the overview progress', (
    tester,
  ) async {
    await pump(tester, overview);
    await tester.pumpAndSettle();

    final bar = tester.widget<FractionallySizedBox>(
      find.byKey(const Key('progress-bar')),
    );
    expect(bar.widthFactor, closeTo(overview.progress, 0.0001));
  });

  testWidgets('the progress bar animates up from empty', (tester) async {
    await pump(tester, overview);
    await tester.pump(const Duration(milliseconds: 100));

    final bar = tester.widget<FractionallySizedBox>(
      find.byKey(const Key('progress-bar')),
    );
    expect(bar.widthFactor, greaterThan(0));
    expect(bar.widthFactor, lessThan(overview.progress));
    await tester.pumpAndSettle();
  });

  testWidgets('the empty variant shows only the kicker and title', (
    tester,
  ) async {
    await pump(
      tester,
      const TodayOverview(date: DateKey(2026, 10, 17), items: []),
    );

    expect(find.text('SATURDAY \u00B7 17 OCTOBER'), findsOneWidget);
    expect(find.text('Today'), findsOneWidget);
    expect(find.textContaining('points'), findsNothing);
    expect(find.textContaining('done'), findsNothing);
    expect(find.byKey(const Key('progress-bar')), findsNothing);
  });

  for (final scale in [1.0, 1.5, 2.0]) {
    testWidgets('has no overflow at ${scale}x on 320dp', (tester) async {
      useSmallPhone(tester);
      await tester.pumpWidget(
        themedApp(
          textScale: scale,
          Scaffold(
            body: SingleChildScrollView(
              child: ProgressHeader(overview: overview),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  }
}

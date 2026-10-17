import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/core/theme/app_tokens.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit_streak.dart';
import 'package:habit_tracker/features/habits/presentation/widgets/day_chip.dart';
import 'package:habit_tracker/features/habits/presentation/widgets/streak_row.dart';

import '../../../../helpers/builders.dart';
import '../../../../helpers/pump_app.dart';

void main() {
  // Streaks are built for Saturday 17 October 2026 (see buildStreak).
  Future<void> pump(
    WidgetTester tester,
    HabitStreak value, {
    double textScale = 1,
  }) {
    return tester.pumpWidget(
      themedApp(
        textScale: textScale,
        Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: StreakRow(streak: value),
          ),
        ),
      ),
    );
  }

  testWidgets('renders seven cells with each day number once', (tester) async {
    await pump(tester, buildStreak(doneOffsets: [0]));

    expect(find.byType(DayChip), findsNWidgets(7));
    for (final day in ['11', '12', '13', '14', '15', '16', '17']) {
      expect(find.text(day), findsOneWidget, reason: 'day $day');
    }
  });

  testWidgets('each status has the right semantics label', (tester) async {
    final semantics = tester.ensureSemantics();
    await pump(tester, buildStreak(doneOffsets: [2], createdDaysAgo: 3));

    expect(find.bySemanticsLabel('Today, not done yet'), findsOneWidget);
    expect(find.bySemanticsLabel('Friday, missed'), findsOneWidget);
    expect(find.bySemanticsLabel('Thursday, done'), findsOneWidget);
    expect(
      find.bySemanticsLabel('Monday, before this habit was created'),
      findsOneWidget,
    );
    semantics.dispose();
  });

  testWidgets('only today carries the emphasis ring', (tester) async {
    await pump(tester, buildStreak(doneOffsets: [0, 1]));

    expect(find.byKey(const Key('today-ring')), findsOneWidget);
    expect(find.byKey(const Key('today-ring-outline')), findsOneWidget);
  });

  testWidgets('the ring is also shown while today is still open', (
    tester,
  ) async {
    await pump(tester, buildStreak(doneOffsets: [1]));

    expect(find.byKey(const Key('today-ring')), findsOneWidget);
    expect(find.byIcon(Icons.check), findsOneWidget);
  });

  testWidgets('today not done is a hollow cell inside a gold outline ring, '
      'never a solid gold block', (tester) async {
    await pump(tester, buildStreak(doneOffsets: [1]));

    final cell =
        tester
                .widget<AnimatedContainer>(find.byKey(const Key('today-ring')))
                .decoration!
            as BoxDecoration;
    expect(cell.color, Colors.transparent);
    expect((cell.border! as Border).top.color, AppTokens.light.outline);
    expect(cell.boxShadow, isNull);

    final ring =
        tester
                .widget<DecoratedBox>(
                  find.byKey(const Key('today-ring-outline')),
                )
                .decoration
            as BoxDecoration;
    expect(ring.color, isNull);
    expect((ring.border! as Border).top.color, AppTokens.light.accent);
    // The ring sits outside the cell and the cell keeps its size.
    final cellRect = tester.getRect(find.byKey(const Key('today-ring')));
    final ringRect = tester.getRect(
      find.byKey(const Key('today-ring-outline')),
    );
    expect(ringRect.inflate(-4.5), cellRect);
  });

  testWidgets('done days show a check and gold cell, missed days are empty', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await pump(tester, buildStreak(doneOffsets: [0, 3]));

    expect(find.byIcon(Icons.check), findsNWidgets(2));
    // No X marks any more, the semantics labels carry the missed state.
    expect(find.byIcon(Icons.close), findsNothing);
    // Offsets 1, 2, 4, 5 and 6 are missed.
    expect(find.bySemanticsLabel(RegExp(r', missed$')), findsNWidgets(5));
    expect(find.bySemanticsLabel('Today, done'), findsOneWidget);

    final done = tester.widget<AnimatedContainer>(
      find.byKey(const Key('today-ring')),
    );
    final decoration = done.decoration! as BoxDecoration;
    expect(decoration.color, AppTokens.light.accentTint);
    expect((decoration.border! as Border).top.color, AppTokens.light.accent);
    semantics.dispose();
  });

  testWidgets('cells are 38 by 52 with a 20dp radius when there is room', (
    tester,
  ) async {
    await pump(tester, buildStreak(doneOffsets: [0]));

    final size = tester.getSize(find.byKey(const Key('today-ring')));
    expect(size, const Size(38, 52));
    final decoration =
        tester
                .widget<AnimatedContainer>(find.byKey(const Key('today-ring')))
                .decoration!
            as BoxDecoration;
    expect(decoration.borderRadius, BorderRadius.circular(20));
    // No box shadow: it would bleed through a hollow cell as solid gold.
    expect(decoration.boxShadow, isNull);
  });

  testWidgets('days before the habit existed render no cell', (tester) async {
    await pump(tester, buildStreak(doneOffsets: [], createdDaysAgo: 0));

    expect(find.byIcon(Icons.check), findsNothing);
    expect(find.byIcon(Icons.close), findsNothing);
    expect(find.byType(DayChip), findsNWidgets(7));
  });

  for (final scale in [1.0, 1.5, 2.0]) {
    testWidgets('has no overflow at ${scale}x on 320dp', (tester) async {
      useSmallPhone(tester);
      await pump(tester, buildStreak(doneOffsets: [0, 1, 2]), textScale: scale);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  }
}

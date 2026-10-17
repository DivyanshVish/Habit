import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/core/theme/app_tokens.dart';
import 'package:habit_tracker/features/habits/presentation/widgets/streak_bar.dart';

import '../../../../helpers/builders.dart';
import '../../../../helpers/pump_app.dart';

void main() {
  Future<void> pump(WidgetTester tester, Widget bar, {double scale = 1}) =>
      tester.pumpWidget(
        themedApp(
          textScale: scale,
          Scaffold(body: Center(child: bar)),
        ),
      );

  Color? segment(WidgetTester tester, int i) =>
      tester.widget<Container>(find.byKey(Key('streak-segment-$i'))).color;

  testWidgets('seven 14 by 3 segments, gold for done days', (tester) async {
    await pump(tester, MiniStreakBar(streak: buildStreak(doneOffsets: [0, 1])));

    for (var i = 0; i < 7; i++) {
      expect(
        tester.getSize(find.byKey(Key('streak-segment-$i'))),
        const Size(14, 3),
      );
    }
    expect(segment(tester, 6), AppTokens.light.accent);
    expect(segment(tester, 5), AppTokens.light.accent);
    for (var i = 0; i < 5; i++) {
      expect(segment(tester, i), AppTokens.light.track);
    }
  });

  testWidgets('says "N-day streak" for a running streak', (tester) async {
    await pump(tester, MiniStreakBar(streak: buildStreak(doneOffsets: [1, 2])));

    expect(find.text('2-day streak'), findsOneWidget);
  });

  testWidgets('says "No streak" without one', (tester) async {
    await pump(tester, MiniStreakBar(streak: buildStreak()));

    expect(find.text('No streak'), findsOneWidget);
  });

  testWidgets('reads as a single label for screen readers', (tester) async {
    final semantics = tester.ensureSemantics();
    await pump(
      tester,
      MiniStreakBar(streak: buildStreak(doneOffsets: [0, 1, 2])),
    );

    expect(find.bySemanticsLabel('3-day streak'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('the text drops below the segments at 2.0x on 320dp', (
    tester,
  ) async {
    useSmallPhone(tester);
    await pump(
      tester,
      SizedBox(
        width: 200,
        child: MiniStreakBar(streak: buildStreak(doneOffsets: [0, 1, 2])),
      ),
      scale: 2,
    );

    expect(tester.takeException(), isNull);
    expect(
      tester.getTopLeft(find.text('3-day streak')).dy,
      greaterThan(
        tester.getBottomLeft(find.byKey(const Key('streak-segment-0'))).dy,
      ),
    );
  });
}

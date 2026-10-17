import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/core/theme/app_tokens.dart';
import 'package:habit_tracker/features/habits/presentation/widgets/animated_count.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  Widget host(ValueNotifier<int> value, {bool disableAnimations = false}) {
    return themedApp(
      disableAnimations: disableAnimations,
      Scaffold(
        body: ValueListenableBuilder<int>(
          valueListenable: value,
          builder: (context, v, _) => AnimatedCount(
            value: v,
            style: const AppTextTokens().displayNumeral,
          ),
        ),
      ),
    );
  }

  int shown(WidgetTester tester) =>
      int.parse(tester.widget<Text>(find.byType(Text)).data!);

  testWidgets('the first frame shows the final value', (tester) async {
    final value = ValueNotifier(40);
    addTearDown(value.dispose);
    await tester.pumpWidget(host(value));

    expect(shown(tester), 40);
  });

  testWidgets('a later change counts through intermediate values', (
    tester,
  ) async {
    final value = ValueNotifier(0);
    addTearDown(value.dispose);
    await tester.pumpWidget(host(value));

    value.value = 100;
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    final mid = shown(tester);
    expect(mid, greaterThan(0));
    expect(mid, lessThan(100));

    await tester.pumpAndSettle();
    expect(shown(tester), 100);
  });

  testWidgets('reduced motion jumps straight to the value', (tester) async {
    final value = ValueNotifier(0);
    addTearDown(value.dispose);
    await tester.pumpWidget(host(value, disableAnimations: true));

    value.value = 100;
    await tester.pump();
    await tester.pump();

    expect(shown(tester), 100);
  });

  testWidgets('uses tabular figures so digits do not jitter', (tester) async {
    final value = ValueNotifier(7);
    addTearDown(value.dispose);
    await tester.pumpWidget(host(value));

    final style = tester.widget<Text>(find.byType(Text)).style!;
    expect(style.fontFeatures, contains(const FontFeature.tabularFigures()));
  });

  testWidgets('uses lining figures so 10 does not read as IO', (tester) async {
    final value = ValueNotifier(10);
    addTearDown(value.dispose);
    await tester.pumpWidget(host(value));

    final style = tester.widget<Text>(find.byType(Text)).style!;
    expect(style.fontFeatures, contains(const FontFeature.liningFigures()));
  });
}

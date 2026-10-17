import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/core/theme/app_tokens.dart';
import 'package:habit_tracker/features/habits/presentation/widgets/check_toggle.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  Widget host(
    ValueNotifier<bool> checked, {
    VoidCallback? onPressed,
    bool disableAnimations = false,
  }) {
    return themedApp(
      disableAnimations: disableAnimations,
      Scaffold(
        body: Center(
          child: ValueListenableBuilder<bool>(
            valueListenable: checked,
            builder: (context, value, _) => CheckToggle(
              done: value,
              tooltip: value ? 'Mark as not done' : 'Mark as done',
              onPressed: onPressed ?? () {},
            ),
          ),
        ),
      ),
    );
  }

  double iconOpacity(WidgetTester tester) =>
      tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity)).opacity;

  double iconScale(WidgetTester tester) =>
      tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale;

  testWidgets('unchecked hides the check, checked shows it', (tester) async {
    final checked = ValueNotifier(false);
    addTearDown(checked.dispose);
    await tester.pumpWidget(host(checked));

    expect(iconOpacity(tester), 0);
    expect(iconScale(tester), lessThan(1));
    expect(find.byTooltip('Mark as done'), findsOneWidget);

    checked.value = true;
    await tester.pumpAndSettle();

    expect(iconOpacity(tester), 1);
    expect(iconScale(tester), 1);
    expect(find.byTooltip('Mark as not done'), findsOneWidget);
  });

  testWidgets('fills with the accent tint when checked', (tester) async {
    final checked = ValueNotifier(true);
    addTearDown(checked.dispose);
    await tester.pumpWidget(host(checked));
    await tester.pumpAndSettle();

    final container = tester.widget<AnimatedContainer>(
      find.byType(AnimatedContainer),
    );
    final decoration = container.decoration! as BoxDecoration;
    expect(decoration.color, AppTokens.light.accentTint);
  });

  testWidgets('has a 48dp touch target', (tester) async {
    final checked = ValueNotifier(false);
    addTearDown(checked.dispose);
    await tester.pumpWidget(host(checked));

    final size = tester.getSize(find.byTooltip('Mark as done'));
    expect(size.width, greaterThanOrEqualTo(48));
    expect(size.height, greaterThanOrEqualTo(48));
  });

  testWidgets('tapping fires onPressed once', (tester) async {
    final checked = ValueNotifier(false);
    addTearDown(checked.dispose);
    var taps = 0;
    await tester.pumpWidget(host(checked, onPressed: () => taps++));

    await tester.tap(find.byTooltip('Mark as done'));
    await tester.pump();

    expect(taps, 1);
  });

  testWidgets('exposes button and checked semantics', (tester) async {
    final semantics = tester.ensureSemantics();
    final checked = ValueNotifier(true);
    addTearDown(checked.dispose);
    await tester.pumpWidget(host(checked));

    expect(find.bySemanticsLabel('Mark as not done'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('reduced motion applies the final state in one frame', (
    tester,
  ) async {
    final checked = ValueNotifier(false);
    addTearDown(checked.dispose);
    await tester.pumpWidget(host(checked, disableAnimations: true));

    checked.value = true;
    await tester.pump();
    await tester.pump();

    expect(tester.hasRunningAnimations, isFalse);
    expect(iconOpacity(tester), 1);
    final container = tester.widget<AnimatedContainer>(
      find.byType(AnimatedContainer),
    );
    expect(container.duration, Duration.zero);
  });

  testWidgets('with motion enabled the change animates', (tester) async {
    final checked = ValueNotifier(false);
    addTearDown(checked.dispose);
    await tester.pumpWidget(host(checked));

    checked.value = true;
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(tester.hasRunningAnimations, isTrue);
  });

  testWidgets('draws a 34dp circle with an outline when open', (tester) async {
    final checked = ValueNotifier(false);
    addTearDown(checked.dispose);
    await tester.pumpWidget(host(checked));

    expect(tester.getSize(find.byType(AnimatedContainer)), const Size(34, 34));
    final decoration =
        tester
                .widget<AnimatedContainer>(find.byType(AnimatedContainer))
                .decoration!
            as BoxDecoration;
    expect(decoration.color, Colors.transparent);
    expect((decoration.border! as Border).top.color, AppTokens.light.outline);
  });

  testWidgets('a done toggle has a gold border and an ink check', (
    tester,
  ) async {
    final checked = ValueNotifier(true);
    addTearDown(checked.dispose);
    await tester.pumpWidget(host(checked));
    await tester.pumpAndSettle();

    final decoration =
        tester
                .widget<AnimatedContainer>(find.byType(AnimatedContainer))
                .decoration!
            as BoxDecoration;
    expect((decoration.border! as Border).top.color, AppTokens.light.accent);
    final icon = tester.widget<Icon>(find.byIcon(Icons.check));
    expect(icon.color, AppTokens.light.accentInk);
    expect(icon.size, 18);
  });
}

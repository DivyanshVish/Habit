import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/core/theme/app_tokens.dart';
import 'package:habit_tracker/features/habits/presentation/widgets/points_picker.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  late TextEditingController controller;
  final formKey = GlobalKey<FormState>();

  setUp(() => controller = TextEditingController(text: '10'));
  tearDown(() => controller.dispose());

  Future<void> pump(
    WidgetTester tester, {
    bool enabled = true,
    double textScale = 1,
  }) {
    return tester.pumpWidget(
      themedApp(
        textScale: textScale,
        Scaffold(
          body: Form(
            key: formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: PointsPicker(controller: controller, enabled: enabled),
            ),
          ),
        ),
      ),
    );
  }

  Color? chipFill(WidgetTester tester, int points) {
    final container = tester.widget<AnimatedContainer>(
      find.descendant(
        of: find.byKey(Key('points-chip-$points')),
        matching: find.byType(AnimatedContainer),
      ),
    );
    return (container.decoration! as BoxDecoration).color;
  }

  testWidgets('offers the five quick picks', (tester) async {
    await pump(tester);

    for (final n in [5, 10, 15, 20, 25]) {
      expect(find.byKey(Key('points-chip-$n')), findsOneWidget);
    }
  });

  testWidgets('tapping a quick pick writes the value and selects it', (
    tester,
  ) async {
    await pump(tester);
    expect(chipFill(tester, 10), AppTokens.light.accentTint);
    expect(chipFill(tester, 15), Colors.transparent);

    await tester.tap(find.byKey(const Key('points-chip-15')));
    await tester.pumpAndSettle();

    expect(controller.text, '15');
    expect(chipFill(tester, 15), AppTokens.light.accentTint);
    expect(chipFill(tester, 10), Colors.transparent);
  });

  testWidgets('selection follows typed values', (tester) async {
    await pump(tester);

    await tester.enterText(find.byKey(const Key('points-field')), '25');
    await tester.pumpAndSettle();

    expect(chipFill(tester, 25), AppTokens.light.accentTint);
    expect(chipFill(tester, 10), Colors.transparent);
  });

  testWidgets('quick picks expose selected semantics', (tester) async {
    final semantics = tester.ensureSemantics();
    await pump(tester);

    final selected = tester.getSemantics(find.bySemanticsLabel('10 points'));
    final other = tester.getSemantics(find.bySemanticsLabel('15 points'));
    expect(selected.flagsCollection.isSelected, Tristate.isTrue);
    expect(other.flagsCollection.isSelected, Tristate.isFalse);
    semantics.dispose();
  });

  testWidgets('plus and minus change the value by one', (tester) async {
    await pump(tester);

    await tester.tap(find.byTooltip('Increase points'));
    await tester.pump();
    expect(controller.text, '11');

    await tester.tap(find.byTooltip('Decrease points'));
    await tester.tap(find.byTooltip('Decrease points'));
    await tester.pump();
    expect(controller.text, '9');
  });

  testWidgets('the stepper stops at 1 and 1000', (tester) async {
    await pump(tester);

    controller.text = '1';
    await tester.tap(find.byTooltip('Decrease points'));
    await tester.pump();
    expect(controller.text, '1');

    controller.text = '1000';
    await tester.tap(find.byTooltip('Increase points'));
    await tester.pump();
    expect(controller.text, '1000');
  });

  testWidgets('empty or invalid text steps from 10', (tester) async {
    await pump(tester);

    controller.text = '';
    await tester.tap(find.byTooltip('Increase points'));
    await tester.pump();
    expect(controller.text, '11');

    controller.text = '';
    await tester.tap(find.byTooltip('Decrease points'));
    await tester.pump();
    expect(controller.text, '9');
  });

  testWidgets('validator accepts 1 and 1000 and rejects the rest', (
    tester,
  ) async {
    await pump(tester);

    Future<bool> valid(String text) async {
      controller.text = text;
      await tester.pump();
      return formKey.currentState!.validate();
    }

    expect(await valid('1'), isTrue);
    expect(await valid('1000'), isTrue);
    expect(await valid('0'), isFalse);
    await tester.pump();
    expect(find.text('Use 1 to 1000'), findsOneWidget);
    expect(await valid('1001'), isFalse);
    expect(await valid(''), isFalse);
    await tester.pump();
    expect(find.text('Enter a number of points'), findsOneWidget);
  });

  testWidgets('a disabled picker ignores taps', (tester) async {
    await pump(tester, enabled: false);

    await tester.tap(find.byTooltip('Increase points'), warnIfMissed: false);
    await tester.tap(
      find.byKey(const Key('points-chip-25')),
      warnIfMissed: false,
    );
    await tester.pump();

    expect(controller.text, '10');
  });

  testWidgets('quick picks are at least 48dp', (tester) async {
    await pump(tester);

    final size = tester.getSize(find.byKey(const Key('points-chip-5')));
    expect(size.width, greaterThanOrEqualTo(48));
    expect(size.height, greaterThanOrEqualTo(48));
  });

  testWidgets('the selected quick pick has a gold bottom border', (
    tester,
  ) async {
    await pump(tester);

    BorderSide bottom(int points) {
      final container = tester.widget<AnimatedContainer>(
        find.descendant(
          of: find.byKey(Key('points-chip-$points')),
          matching: find.byType(AnimatedContainer),
        ),
      );
      return ((container.decoration! as BoxDecoration).border! as Border)
          .bottom;
    }

    expect(bottom(10).color, AppTokens.light.accent);
    expect(bottom(10).width, 2);
    expect(bottom(15).color, Colors.transparent);
  });

  testWidgets('the stepper buttons are at least 48dp', (tester) async {
    await pump(tester);

    for (final tooltip in ['Decrease points', 'Increase points']) {
      final size = tester.getSize(find.byTooltip(tooltip));
      expect(size.width, greaterThanOrEqualTo(48), reason: tooltip);
      expect(size.height, greaterThanOrEqualTo(48), reason: tooltip);
    }
  });

  testWidgets('has no overflow at 2.0x text on a small phone', (tester) async {
    useSmallPhone(tester);
    await pump(tester, textScale: 2);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}

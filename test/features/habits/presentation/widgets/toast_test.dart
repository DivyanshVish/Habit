import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/core/theme/app_tokens.dart';
import 'package:habit_tracker/features/habits/presentation/widgets/toast.dart';

import '../../../../helpers/pump_app.dart';

/// The visible pill inside the snack bar (the SnackBar widget itself spans the
/// whole width).
final Finder _pill = find
    .descendant(of: find.byType(SnackBar), matching: find.byType(Material))
    .first;

void main() {
  Future<void> pump(
    WidgetTester tester, {
    bool disableAnimations = false,
    double scale = 1,
  }) {
    return tester.pumpWidget(
      themedApp(
        disableAnimations: disableAnimations,
        textScale: scale,
        Scaffold(
          body: Builder(
            builder: (context) => Column(
              children: [
                TextButton(
                  onPressed: () => showToast(context, '+20 points'),
                  child: const Text('toast'),
                ),
                TextButton(
                  onPressed: () => showErrorSnackBar(context, 'It failed.'),
                  child: const Text('error'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('the toast is a 190dp dark pill with centred text', (
    tester,
  ) async {
    await pump(tester);

    await tester.tap(find.text('toast'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('+20 points'), findsOneWidget);
    expect(tester.getSize(_pill).width, 190);
    final material = tester.widget<Material>(
      find.descendant(
        of: find.byType(SnackBar),
        matching: find.byType(Material),
      ),
    );
    expect(material.color, AppTokens.light.inkStrong);
    expect(
      (material.shape! as RoundedRectangleBorder).borderRadius,
      BorderRadius.circular(30),
    );
    final text = tester.widget<Text>(find.text('+20 points'));
    expect(text.textAlign, TextAlign.center);
    final style = DefaultTextStyle.of(tester.element(find.text('+20 points')));
    expect(style.style.color, AppTokens.light.paper);

    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(find.text('+20 points'), findsNothing);
  });

  testWidgets('a new toast replaces the one showing', (tester) async {
    await pump(tester);

    await tester.tap(find.text('toast'));
    await tester.pump();
    await tester.tap(find.text('error'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('+20 points'), findsNothing);
    expect(find.text('It failed.'), findsOneWidget);
    await tester.pump(const Duration(seconds: 6));
    await tester.pumpAndSettle();
  });

  testWidgets('the error snackbar has a 4dp radius and no fixed width', (
    tester,
  ) async {
    await pump(tester);

    await tester.tap(find.text('error'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    final bar = tester.widget<SnackBar>(find.byType(SnackBar));
    expect(
      (bar.shape! as RoundedRectangleBorder).borderRadius,
      BorderRadius.circular(4),
    );
    expect(bar.width, isNull);
    await tester.pump(const Duration(seconds: 6));
    await tester.pumpAndSettle();
  });

  testWidgets('reduced motion shows and hides the toast without animation', (
    tester,
  ) async {
    await pump(tester, disableAnimations: true);

    await tester.tap(find.text('toast'));
    await tester.pump();
    await tester.pump();

    // Fully visible after a single frame.
    expect(find.text('+20 points'), findsOneWidget);
    final bar = tester.widget<SnackBar>(find.byType(SnackBar));
    expect(bar.animation!.value, 1);

    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pump();
    expect(find.text('+20 points'), findsNothing);
  });

  testWidgets('wraps to two lines at 2.0x text without overflow', (
    tester,
  ) async {
    useSmallPhone(tester);
    await pump(tester, scale: 2);

    await tester.tap(find.text('toast'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(tester.takeException(), isNull);
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
  });
}

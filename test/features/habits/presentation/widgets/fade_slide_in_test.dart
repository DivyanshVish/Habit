import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/features/habits/presentation/widgets/fade_slide_in.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  Widget host({int index = 0, bool disableAnimations = false}) {
    return themedApp(
      disableAnimations: disableAnimations,
      Scaffold(
        body: FadeSlideIn(index: index, child: const Text('row')),
      ),
    );
  }

  double opacity(WidgetTester tester) =>
      tester.widget<Opacity>(find.byType(Opacity).last).opacity;

  testWidgets('starts transparent and ends fully visible in place', (
    tester,
  ) async {
    await tester.pumpWidget(host(index: 3));
    expect(opacity(tester), 0);

    await tester.pumpAndSettle();

    expect(opacity(tester), 1);
    final transform = tester.widget<Transform>(
      find
          .ancestor(of: find.text('row'), matching: find.byType(Transform))
          .first,
    );
    expect(transform.transform.getTranslation().y, 0);
  });

  testWidgets('later items start later', (tester) async {
    await tester.pumpWidget(
      themedApp(
        const Scaffold(
          body: Column(
            children: [
              FadeSlideIn(index: 0, child: Text('first')),
              FadeSlideIn(index: 6, child: Text('seventh')),
            ],
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 120));

    final opacities = tester
        .widgetList<Opacity>(find.byType(Opacity))
        .map((o) => o.opacity)
        .toList();
    expect(opacities.first, greaterThan(opacities.last));
    await tester.pumpAndSettle();
  });

  testWidgets('reduced motion shows the row immediately', (tester) async {
    await tester.pumpWidget(host(index: 5, disableAnimations: true));
    await tester.pump();

    expect(opacity(tester), 1);
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('settles without leaving pending timers', (tester) async {
    await tester.pumpWidget(host(index: 20));
    await tester.pumpAndSettle();

    expect(find.text('row'), findsOneWidget);
  });
}

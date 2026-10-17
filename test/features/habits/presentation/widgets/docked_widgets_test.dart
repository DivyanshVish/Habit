import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/core/theme/app_tokens.dart';
import 'package:habit_tracker/features/habits/presentation/widgets/bottom_action.dart';
import 'package:habit_tracker/features/habits/presentation/widgets/hairline.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  testWidgets('Hairline is a 1dp divider in the hairline colour', (
    tester,
  ) async {
    await tester.pumpWidget(themedApp(const Scaffold(body: Hairline())));

    final divider = tester.widget<Divider>(find.byType(Divider));
    expect(divider.thickness, 1);
    expect(divider.height, 1);
    expect(divider.color, AppTokens.light.hairline);
  });

  testWidgets('BottomAction has a paper ground, a top hairline and padding', (
    tester,
  ) async {
    await tester.pumpWidget(
      themedApp(
        const Scaffold(
          bottomNavigationBar: BottomAction(child: SizedBox(height: 52)),
        ),
      ),
    );

    final box = tester.widget<DecoratedBox>(
      find
          .descendant(
            of: find.byType(BottomAction),
            matching: find.byType(DecoratedBox),
          )
          .first,
    );
    final decoration = box.decoration as BoxDecoration;
    expect(decoration.color, AppTokens.light.paper);
    expect((decoration.border! as Border).top.color, AppTokens.light.hairline);
    final size = tester.getSize(find.byType(BottomAction));
    // 16 above, 12 below, 52 content, 1 border (no safe area in tests).
    expect(size.height, greaterThanOrEqualTo(16 + 52 + 12));
    expect(
      tester.getTopLeft(find.byType(SizedBox).last).dx,
      AppTokens.light.space.screenMargin,
    );
  });
}

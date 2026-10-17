import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/core/theme/app_theme.dart';

/// Wraps [home] in a `MaterialApp` using the real [AppTheme], with optional
/// text scale and reduced motion.
Widget themedApp(
  Widget home, {
  double textScale = 1,
  bool disableAnimations = false,
  bool accessibleNavigation = false,
}) {
  return MaterialApp(
    theme: AppTheme.light(),
    themeMode: ThemeMode.light,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.linear(textScale),
        disableAnimations: disableAnimations,
        accessibleNavigation: accessibleNavigation,
      ),
      child: child!,
    ),
    home: home,
  );
}

/// Makes the test surface a small 320 x 568 phone.
void useSmallPhone(WidgetTester tester) {
  tester.view.physicalSize = const Size(320 * 3, 568 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

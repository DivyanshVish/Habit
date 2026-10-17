import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/core/theme/app_theme.dart';
import 'package:habit_tracker/core/theme/app_tokens.dart';

void main() {
  final theme = AppTheme.light();
  const tokens = AppTokens.light;

  group('light theme', () {
    test('registers the design tokens and Material 3', () {
      expect(theme.extension<AppTokens>(), isNotNull);
      expect(theme.useMaterial3, isTrue);
      expect(theme.brightness, Brightness.light);
    });

    test('uses the paper background and Lora body text', () {
      expect(theme.scaffoldBackgroundColor, tokens.paper);
      expect(theme.textTheme.bodyLarge?.fontFamily, 'Lora');
      expect(theme.textTheme.displayMedium?.fontFamily, 'CormorantGaramond');
    });

    test('has no filled button style, only outlined buttons', () {
      expect(theme.filledButtonTheme.style, isNull);
      final style = theme.outlinedButtonTheme.style!;
      expect(style.minimumSize!.resolve({})!.height, greaterThanOrEqualTo(48));
      expect(style.minimumSize!.resolve({})!.height, 52);
      final shape = style.shape!.resolve({}) as RoundedRectangleBorder;
      expect(shape.borderRadius, BorderRadius.circular(4));
      expect(style.side!.resolve({})!.color, tokens.accent);
      expect(style.foregroundColor!.resolve({}), tokens.accentInk);
    });

    test('text buttons keep a 48dp target', () {
      final style = theme.textButtonTheme.style!;
      expect(style.minimumSize!.resolve({}), const Size(64, 48));
    });

    test('icon buttons keep a 48dp target', () {
      final style = theme.iconButtonTheme.style!;
      expect(style.minimumSize!.resolve({}), const Size(48, 48));
    });

    test('inputs use 4dp outline borders', () {
      final border = theme.inputDecorationTheme.enabledBorder;
      expect(border, isA<OutlineInputBorder>());
      expect(
        (border! as OutlineInputBorder).borderRadius,
        BorderRadius.circular(4),
      );
      expect(border.borderSide.color, tokens.outline);
      expect(
        theme.inputDecorationTheme.focusedBorder!.borderSide.color,
        tokens.accent,
      );
      expect(
        theme.inputDecorationTheme.errorBorder!.borderSide.color,
        tokens.danger,
      );
      expect(theme.inputDecorationTheme.filled, isNot(true));
    });

    test('validation and helper text wrap instead of ellipsizing', () {
      expect(theme.inputDecorationTheme.errorMaxLines, greaterThan(1));
      expect(theme.inputDecorationTheme.helperMaxLines, greaterThan(1));
    });

    test('snackbar is dark and floating', () {
      final bar = theme.snackBarTheme;
      expect(bar.behavior, SnackBarBehavior.floating);
      expect(bar.backgroundColor, tokens.inkStrong);
      expect(bar.contentTextStyle?.color, tokens.paper);
    });

    test('dialog is paper with a hairline 4dp border', () {
      final dialog = theme.dialogTheme;
      expect(dialog.backgroundColor, tokens.paper);
      final shape = dialog.shape! as RoundedRectangleBorder;
      expect(shape.borderRadius, BorderRadius.circular(4));
      expect(shape.side.color, tokens.hairline);
    });

    test('progress indicator is gold and 2dp', () {
      expect(theme.progressIndicatorTheme.color, tokens.accent);
      expect(theme.progressIndicatorTheme.strokeWidth, 2);
    });
  });

  test('overlay style is transparent with dark icons only', () {
    final style = AppTheme.overlayStyle();
    expect(style.statusBarIconBrightness, Brightness.dark);
    expect(style.systemNavigationBarIconBrightness, Brightness.dark);
    expect(style.statusBarColor, Colors.transparent);
    expect(style.systemNavigationBarColor, Colors.transparent);
  });
}

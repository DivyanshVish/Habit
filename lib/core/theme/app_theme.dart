import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:habit_tracker/core/theme/app_tokens.dart';

/// The single, light-only theme.
class AppTheme {
  const AppTheme._();

  static ThemeData light() => _build(AppTokens.light);

  /// Transparent system bars with dark icons.
  static SystemUiOverlayStyle overlayStyle() {
    return const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarIconBrightness: Brightness.dark,
    );
  }

  static ThemeData _build(AppTokens t) {
    final text = t.text;
    final scheme = ColorScheme.light(
      primary: t.accent,
      onPrimary: t.paper,
      secondary: t.accentInk,
      onSecondary: t.paper,
      error: t.danger,
      onError: t.paper,
      surface: t.paper,
      onSurface: t.ink,
      onSurfaceVariant: t.inkMuted,
      outline: t.outline,
      outlineVariant: t.hairline,
      surfaceContainerLowest: t.paper,
      surfaceContainerLow: t.paper,
      surfaceContainer: t.paper,
      surfaceContainerHigh: t.paper,
      surfaceContainerHighest: t.paper,
      primaryContainer: t.accentTint,
      onPrimaryContainer: t.accentInk,
      inverseSurface: t.inkStrong,
      onInverseSurface: t.paper,
      surfaceTint: Colors.transparent,
    );

    TextStyle ink(TextStyle s) => s.copyWith(color: t.ink);
    TextStyle muted(TextStyle s) => s.copyWith(color: t.inkMuted);

    final textTheme = TextTheme(
      displayLarge: ink(text.displayNumeral),
      displayMedium: ink(text.displayTitle),
      headlineMedium: ink(text.headline),
      titleMedium: ink(text.rowTitle),
      bodyLarge: ink(text.body),
      bodyMedium: ink(text.body),
      bodySmall: muted(text.bodySmall),
      labelLarge: text.button.copyWith(color: t.accentInk),
      labelMedium: muted(text.kicker),
      labelSmall: muted(text.caption),
    );

    final control = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(t.radii.control),
    );
    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(t.radii.control),
          borderSide: BorderSide(color: color, width: width),
        );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: AppTextTokens.bodyFamily,
      colorScheme: scheme,
      scaffoldBackgroundColor: t.paper,
      canvasColor: t.paper,
      extensions: [t],
      textTheme: textTheme,
      splashFactory: InkRipple.splashFactory,
      splashColor: t.accent.withValues(alpha: 0.10),
      highlightColor: Colors.transparent,
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(64, 48),
          shape: control,
          foregroundColor: t.inkMuted,
          textStyle: text.button,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: control,
          foregroundColor: t.accentInk,
          side: BorderSide(color: t.accent, width: 1.5),
          textStyle: text.button,
          overlayColor: t.accent,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size(48, 48),
          foregroundColor: t.ink,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        floatingLabelBehavior: FloatingLabelBehavior.always,
        contentPadding: const EdgeInsets.all(14),
        enabledBorder: border(t.outline),
        disabledBorder: border(t.hairline),
        focusedBorder: border(t.accent, 2),
        errorBorder: border(t.danger),
        focusedErrorBorder: border(t.danger, 2),
        labelStyle: muted(text.kicker),
        floatingLabelStyle: muted(text.kicker),
        hintStyle: muted(text.body),
        errorStyle: text.bodySmall.copyWith(color: t.danger),
        helperStyle: muted(text.bodySmall),
        // Validation and helper text must wrap, not ellipsize, at large
        // text scales (seen as "Please enter a na..." at 2.0x on 320dp).
        errorMaxLines: 3,
        helperMaxLines: 3,
        counterStyle: muted(text.bodySmall),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: t.inkStrong,
        contentTextStyle: text.body.copyWith(fontSize: 14, color: t.paper),
        elevation: 0,
        insetPadding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: t.paper,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(t.radii.control),
          side: BorderSide(color: t.hairline),
        ),
        titleTextStyle: ink(text.dialogTitle),
        contentTextStyle: muted(text.body),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      ),
      dividerTheme: DividerThemeData(color: t.hairline, thickness: 1, space: 1),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: t.inkStrong,
          borderRadius: BorderRadius.circular(t.radii.control),
        ),
        textStyle: text.bodySmall.copyWith(color: t.paper),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: t.ink,
        selectionColor: t.accent.withValues(alpha: 0.3),
        selectionHandleColor: t.ink,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: t.accent,
        strokeWidth: 2,
        circularTrackColor: Colors.transparent,
      ),
    );
  }
}

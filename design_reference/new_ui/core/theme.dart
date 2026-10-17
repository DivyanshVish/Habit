import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Classical design tokens: near-white ground, one gold accent used as stroke.
class C {
  static const bg = Color(0xFFF3F2F2);
  static const text = Color(0xFF201F1D);
  static const accent = Color(0xFFB68235);
  static const accent100 = Color(0xFFFFF3E4);
  static const accent700 = Color(0xFF7D5411);
  static const n300 = Color(0xFFD7D3D3);
  static const n500 = Color(0xFF9B9797);
  static const n700 = Color(0xFF605D5D);
  static const n900 = Color(0xFF2D2B2B);
  static const divider = Color(0x29201F1D); // 16% ink
  static const danger = Color(0xFF9A3B2C);
}

TextStyle heading(
  double size, {
  FontWeight w = FontWeight.w400,
  Color color = C.text,
}) => GoogleFonts.cormorantGaramond(
  fontSize: size,
  fontWeight: w,
  color: color,
  height: 1.05,
  fontFeatures: const [FontFeature.tabularFigures()],
);

TextStyle body(
  double size, {
  FontWeight w = FontWeight.w400,
  Color color = C.text,
  double h = 1.5,
}) => GoogleFonts.lora(fontSize: size, fontWeight: w, color: color, height: h);

TextStyle kicker([Color color = C.accent700]) =>
    body(11, w: FontWeight.w500, color: color).copyWith(letterSpacing: 1.8);

ThemeData buildClassicalTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: C.accent,
    brightness: Brightness.light,
  ).copyWith(primary: C.accent, surface: C.bg, onSurface: C.text);
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: C.bg,
    dividerColor: C.divider,
    textTheme: GoogleFonts.loraTextTheme(),
    appBarTheme: const AppBarTheme(
      backgroundColor: C.bg,
      elevation: 0,
      scrolledUnderElevation: 0,
      foregroundColor: C.text,
    ),
    // Outlined, never filled.
    outlinedButtonTheme: OutlinedButtonThemeData(
      style:
          OutlinedButton.styleFrom(
            foregroundColor: C.accent700,
            side: const BorderSide(color: C.accent),
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            textStyle: body(16, w: FontWeight.w500),
          ).copyWith(
            overlayColor: WidgetStatePropertyAll(C.accent.withOpacity(.10)),
          ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: C.n500),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: C.n500),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: C.accent, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: C.danger),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: C.danger, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: C.n900,
      behavior: SnackBarBehavior.floating,
      contentTextStyle: body(14, color: C.bg),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
    ),
  );
}

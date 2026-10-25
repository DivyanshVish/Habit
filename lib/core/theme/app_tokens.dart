import 'package:flutter/material.dart';

/// Design tokens for the whole app, exposed as a [ThemeExtension].
///
/// Classical, light-only look: warm grey paper, near-black ink, one gold
/// accent and two serif families (Cormorant Garamond for headings and
/// numerals, Lora for body copy).
///
/// Rules baked into the tokens:
/// * [accent] is for strokes and bars only (check outline, progress fill,
///   focus ring, button border). Never use it for text, use [accentInk].
/// * Buttons are outlined, never filled.
/// * Colours here are the only place hex values may live.
@immutable
class AppTokens extends ThemeExtension<AppTokens> {
  const AppTokens({
    required this.paper,
    required this.ink,
    required this.inkMuted,
    required this.inkStrong,
    required this.track,
    required this.outline,
    required this.hairline,
    required this.accent,
    required this.accentTint,
    required this.accentInk,
    required this.danger,
    this.space = const AppSpacing(),
    this.radii = const AppRadii(),
    this.text = const AppTextTokens(),
  });

  /// Ground: scaffold, dialogs, bottom bar.
  final Color paper;

  /// Primary text.
  final Color ink;

  /// Secondary text (at least 4.5:1 on [paper]).
  final Color inkMuted;

  /// Toast and tooltip background (text on it is [paper]).
  final Color inkStrong;

  /// Progress track and empty streak segments. Decorative only.
  final Color track;

  /// Non-text strokes: unchecked circle, input and picker borders (3:1).
  final Color outline;

  /// Decorative dividers only.
  final Color hairline;

  /// Gold. Strokes and bars only, never text.
  final Color accent;

  /// Done fill of the check and selected picker option.
  final Color accentTint;

  /// Accent for text and glyphs (at least 4.5:1).
  final Color accentInk;

  /// Delete, errors and validation (at least 4.5:1).
  final Color danger;

  final AppSpacing space;
  final AppRadii radii;
  final AppTextTokens text;

  /// Calm tones for group pictures (see the emblem widgets). The icon on top
  /// is always [emblemOn]. Like every colour here, they live only in this file.
  static const List<Color> emblemPalette = [
    Color(0xFFE9D9B8),
    Color(0xFFD8E2D0),
    Color(0xFFCFDDE6),
    Color(0xFFE6D0D0),
    Color(0xFFDDD3E6),
    Color(0xFFE3DDC8),
    Color(0xFFCFE3DF),
    Color(0xFFE8D6C4),
  ];

  /// Icon colour on top of any [emblemPalette] colour.
  static const Color emblemOn = Color(0xFF201F1D);

  static const AppTokens light = AppTokens(
    paper: Color(0xFFF3F2F2),
    ink: Color(0xFF201F1D),
    inkMuted: Color(0xFF605D5D),
    inkStrong: Color(0xFF2D2B2B),
    track: Color(0xFFD7D3D3),
    outline: Color(0xFF8A8686),
    hairline: Color(0x29201F1D),
    accent: Color(0xFFB68235),
    accentTint: Color(0xFFFFF3E4),
    accentInk: Color(0xFF7D5411),
    danger: Color(0xFF9A3B2C),
  );

  @override
  AppTokens copyWith({
    Color? paper,
    Color? ink,
    Color? inkMuted,
    Color? inkStrong,
    Color? track,
    Color? outline,
    Color? hairline,
    Color? accent,
    Color? accentTint,
    Color? accentInk,
    Color? danger,
    AppSpacing? space,
    AppRadii? radii,
    AppTextTokens? text,
  }) {
    return AppTokens(
      paper: paper ?? this.paper,
      ink: ink ?? this.ink,
      inkMuted: inkMuted ?? this.inkMuted,
      inkStrong: inkStrong ?? this.inkStrong,
      track: track ?? this.track,
      outline: outline ?? this.outline,
      hairline: hairline ?? this.hairline,
      accent: accent ?? this.accent,
      accentTint: accentTint ?? this.accentTint,
      accentInk: accentInk ?? this.accentInk,
      danger: danger ?? this.danger,
      space: space ?? this.space,
      radii: radii ?? this.radii,
      text: text ?? this.text,
    );
  }

  @override
  AppTokens lerp(ThemeExtension<AppTokens>? other, double t) {
    if (other is! AppTokens) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppTokens(
      paper: mix(paper, other.paper),
      ink: mix(ink, other.ink),
      inkMuted: mix(inkMuted, other.inkMuted),
      inkStrong: mix(inkStrong, other.inkStrong),
      track: mix(track, other.track),
      outline: mix(outline, other.outline),
      hairline: mix(hairline, other.hairline),
      accent: mix(accent, other.accent),
      accentTint: mix(accentTint, other.accentTint),
      accentInk: mix(accentInk, other.accentInk),
      danger: mix(danger, other.danger),
      space: space,
      radii: radii,
      text: text,
    );
  }
}

/// 4-based spacing scale.
@immutable
class AppSpacing {
  const AppSpacing();

  final double s4 = 4;
  final double s8 = 8;
  final double s12 = 12;
  final double s16 = 16;
  final double s24 = 24;
  final double s32 = 32;
  final double s48 = 48;

  /// Horizontal margin of every screen.
  final double screenMargin = 26;
}

/// Corner radii. Controls are nearly square, the week strip cell is rounder.
@immutable
class AppRadii {
  const AppRadii();

  /// Inputs, buttons, dialogs, picker and badge.
  final double control = 4;

  /// Week strip cell only.
  final double strip = 20;
}

/// Text styles. Colours are not baked in: text inherits ink from the theme and
/// widgets pass `copyWith(color: ...)` from the tokens for anything else.
/// Only weights 400, 500 and 600 and italic are bundled.
@immutable
class AppTextTokens {
  const AppTextTokens();

  /// Serif used for headings and numerals.
  static const String headingFamily = 'CormorantGaramond';

  /// Serif used for body copy.
  static const String bodyFamily = 'Lora';

  /// Cormorant Garamond defaults to old-style digits ('10' reads as 'IO'),
  /// so every heading and numeral asks for lining figures ('lnum'). The
  /// bundled Regular, SemiBold and Italic files all carry that GSUB feature.
  static const List<FontFeature> _tabular = [
    FontFeature.liningFigures(),
    FontFeature.tabularFigures(),
  ];

  TextStyle _heading(
    double size, {
    FontWeight weight = FontWeight.w400,
    double? height,
    FontStyle? style,
  }) => TextStyle(
    fontFamily: headingFamily,
    fontSize: size,
    fontWeight: weight,
    fontStyle: style,
    height: height,
    fontFeatures: _tabular,
  );

  TextStyle _body(
    double size, {
    FontWeight weight = FontWeight.w400,
    double? height,
    double? letterSpacing,
    FontStyle? style,
  }) => TextStyle(
    fontFamily: bodyFamily,
    fontSize: size,
    fontWeight: weight,
    fontStyle: style,
    height: height,
    letterSpacing: letterSpacing,
  );

  /// Small caps-style label. Colour `accentInk` by default, muted via copyWith.
  TextStyle get kicker => _body(
    11,
    weight: FontWeight.w500,
    letterSpacing: 1.8,
  ).copyWith(color: AppTokens.light.accentInk);

  /// "Today".
  TextStyle get displayTitle => _heading(46, height: 1.05);

  /// Earned points.
  TextStyle get displayNumeral => _heading(64, height: 1.05);

  /// Habit name on Detail ("New habit" uses 44 via copyWith).
  TextStyle get headline => _heading(42, height: 1.02);

  TextStyle get dialogTitle => _heading(26, weight: FontWeight.w600);

  /// Streak count on Detail.
  TextStyle get streakNumeral => _heading(48, height: 1.05);

  /// Habit row name.
  TextStyle get rowTitle => _heading(21, weight: FontWeight.w600);

  /// Row points; picker numbers use 20 via copyWith.
  TextStyle get numeral => _heading(24, weight: FontWeight.w600, height: 1.05);

  /// "X" in "X of Y done".
  TextStyle get numeralSmall =>
      _heading(26, weight: FontWeight.w600, height: 1.05);

  TextStyle get emptyState => _heading(22, style: FontStyle.italic);

  TextStyle get body => _body(15, height: 1.5);

  TextStyle get bodySmall => _body(13, height: 1.4);

  TextStyle get caption => _body(12);

  /// "PTS".
  TextStyle get tiny => _body(10, letterSpacing: 1.2);

  TextStyle get button => _body(16, weight: FontWeight.w500);

  /// "per completion".
  TextStyle get italicNote => _body(14, style: FontStyle.italic);
}

extension AppTokensContext on BuildContext {
  /// Tokens from the active theme. Falls back to the built-in set so widgets
  /// also work under a bare `MaterialApp`.
  AppTokens get tokens =>
      Theme.of(this).extension<AppTokens>() ?? AppTokens.light;
}

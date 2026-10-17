import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/core/theme/app_theme.dart';
import 'package:habit_tracker/core/theme/app_tokens.dart';

double _channel(double v) =>
    v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();

/// WCAG relative luminance contrast ratio.
double contrast(Color a, Color b) {
  double lum(Color c) =>
      0.2126 * _channel(c.r) + 0.7152 * _channel(c.g) + 0.0722 * _channel(c.b);
  final la = lum(a);
  final lb = lum(b);
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

void main() {
  const t = AppTokens.light;

  test('palette has the exact classical values', () {
    expect(t.paper, const Color(0xFFF3F2F2));
    expect(t.ink, const Color(0xFF201F1D));
    expect(t.inkMuted, const Color(0xFF605D5D));
    expect(t.inkStrong, const Color(0xFF2D2B2B));
    expect(t.track, const Color(0xFFD7D3D3));
    expect(t.outline, const Color(0xFF8A8686));
    expect(t.hairline, const Color(0x29201F1D));
    expect(t.accent, const Color(0xFFB68235));
    expect(t.accentTint, const Color(0xFFFFF3E4));
    expect(t.accentInk, const Color(0xFF7D5411));
    expect(t.danger, const Color(0xFF9A3B2C));
  });

  group('contrast', () {
    test('text on paper is at least 4.5:1', () {
      expect(contrast(t.ink, t.paper), greaterThanOrEqualTo(4.5));
      expect(contrast(t.inkMuted, t.paper), greaterThanOrEqualTo(4.5));
      expect(contrast(t.accentInk, t.paper), greaterThanOrEqualTo(4.5));
      expect(contrast(t.danger, t.paper), greaterThanOrEqualTo(4.5));
    });

    test('accentInk on the accent tint is at least 4.5:1', () {
      expect(contrast(t.accentInk, t.accentTint), greaterThanOrEqualTo(4.5));
    });

    test('toast and tooltip text (paper on inkStrong) is at least 4.5:1', () {
      expect(contrast(t.paper, t.inkStrong), greaterThanOrEqualTo(4.5));
    });

    test('strokes meet 3:1 on paper', () {
      expect(contrast(t.outline, t.paper), greaterThanOrEqualTo(3));
      expect(contrast(t.accent, t.paper), greaterThanOrEqualTo(3));
    });
  });

  test('copyWith replaces only the given values', () {
    final changed = t.copyWith(accent: const Color(0xFF000001));
    expect(changed.accent, const Color(0xFF000001));
    expect(changed.paper, t.paper);
    expect(changed.danger, t.danger);
  });

  test('lerp blends colours and returns this for foreign extensions', () {
    final other = t.copyWith(paper: const Color(0xFF000000));
    final mid = t.lerp(other, 0.5);
    expect(mid.paper, Color.lerp(t.paper, other.paper, 0.5));
    expect(t.lerp(null, 0.5), t);
    expect(t.lerp(t, 0).ink, t.ink);
  });

  test('spacing and radii follow the classical scale', () {
    expect(t.space.screenMargin, 26);
    expect(t.radii.control, 4);
    expect(t.radii.strip, 20);
  });

  test('text tokens use the two serif families and bundled weights', () {
    const text = AppTextTokens();
    expect(AppTextTokens.headingFamily, 'CormorantGaramond');
    expect(AppTextTokens.bodyFamily, 'Lora');

    final headings = [
      text.displayTitle,
      text.displayNumeral,
      text.headline,
      text.dialogTitle,
      text.streakNumeral,
      text.rowTitle,
      text.numeral,
      text.numeralSmall,
      text.emptyState,
    ];
    final bodies = [
      text.kicker,
      text.body,
      text.bodySmall,
      text.caption,
      text.tiny,
      text.button,
      text.italicNote,
    ];
    for (final style in headings) {
      expect(style.fontFamily, 'CormorantGaramond');
      expect(style.fontFeatures, contains(const FontFeature.tabularFigures()));
      // Cormorant's default digits are old-style ('10' reads as 'IO').
      expect(style.fontFeatures, contains(const FontFeature.liningFigures()));
    }
    for (final style in bodies) {
      expect(style.fontFamily, 'Lora');
    }
    for (final style in [...headings, ...bodies]) {
      final weight = style.fontWeight ?? FontWeight.w400;
      expect(weight.value, lessThanOrEqualTo(600));
      expect(style.fontSize, greaterThanOrEqualTo(10));
    }
    expect(text.emptyState.fontStyle, FontStyle.italic);
    expect(text.italicNote.fontStyle, FontStyle.italic);
    expect(text.kicker.letterSpacing, 1.8);
    expect(text.kicker.color, t.accentInk);
  });

  testWidgets('context.tokens falls back to light under a bare MaterialApp', (
    tester,
  ) async {
    late AppTokens tokens;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            tokens = context.tokens;
            return const SizedBox();
          },
        ),
      ),
    );
    expect(tokens.paper, t.paper);
  });

  testWidgets('context.tokens reads the extension from AppTheme', (
    tester,
  ) async {
    late AppTokens tokens;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Builder(
          builder: (context) {
            tokens = context.tokens;
            return const SizedBox();
          },
        ),
      ),
    );
    expect(tokens.paper, t.paper);
    expect(tokens.accent, t.accent);
  });
}

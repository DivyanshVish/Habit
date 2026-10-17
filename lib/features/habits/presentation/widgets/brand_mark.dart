import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:habit_tracker/core/theme/app_tokens.dart';

/// The app's own done-check: a gold ring around a check, with seven streak
/// segments underneath (four empty, three gold).
///
/// The geometry matches the native launch screen (a 560 x 620 box), so the
/// native-to-Flutter handover lines up. [progress] drives the intro: the ring
/// sweeps, the tint fades in, the check draws, then the segments appear one
/// after another. At `progress == 1` the paint is the static mark.
class BrandMark extends StatelessWidget {
  const BrandMark({
    this.progress = 1,
    this.width = defaultWidth,
    this.semanticLabel,
    super.key,
  });

  /// Logical width of the mark on the native splash.
  static const double defaultWidth = 112;

  /// 0 (nothing drawn) to 1 (static mark).
  final double progress;

  /// Width in logical px. The height follows the 560 x 620 box.
  final double width;

  /// Label for screen readers. The painted shapes are always hidden from
  /// semantics; without a label the mark is decorative.
  final String? semanticLabel;

  double get height =>
      width * BrandMarkPainter.boxHeight / BrandMarkPainter.boxWidth;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Semantics(
      label: semanticLabel,
      image: semanticLabel != null,
      excludeSemantics: true,
      child: CustomPaint(
        size: Size(width, height),
        painter: BrandMarkPainter(
          progress: progress,
          ring: tokens.accent,
          tint: tokens.accentTint,
          check: tokens.accentInk,
          empty: tokens.track,
          filled: tokens.accent,
        ),
      ),
    );
  }
}

/// Paints the mark in its 560 x 620 design box, scaled to the canvas width.
class BrandMarkPainter extends CustomPainter {
  const BrandMarkPainter({
    required this.progress,
    required this.ring,
    required this.tint,
    required this.check,
    required this.empty,
    required this.filled,
  });

  static const double boxWidth = 560;
  static const double boxHeight = 620;

  static const Offset ringCenter = Offset(280, 280);
  static const double ringRadius = 250;
  static const double ringStroke = 30;
  static const double checkStroke = 38;

  /// Streak segments: `x = 3 + i * 82`, `y = 590`, 62 x 18.
  static const int segmentCount = 7;

  /// Segments from this index on are gold.
  static const int firstFilledSegment = 4;

  static Rect segmentRect(int i) => Rect.fromLTWH(3 + i * 82, 590, 62, 18);

  // Phases of the intro, as fractions of [progress].
  static const double _ringEnd = 0.45;
  static const double _checkStart = 0.35;
  static const double _checkEnd = 0.75;
  static const double _segmentsStart = 0.7;
  static const double _segmentStagger = 0.03;
  static const double _segmentFade = 0.12;

  final double progress;
  final Color ring;
  final Color tint;
  final Color check;

  /// Colour of the empty (grey) streak segments.
  final Color empty;

  /// Colour of the gold streak segments.
  final Color filled;

  static double _phase(double p, double start, double end) =>
      ((p - start) / (end - start)).clamp(0.0, 1.0);

  @override
  void paint(Canvas canvas, Size size) {
    final p = progress.clamp(0.0, 1.0);
    canvas.save();
    canvas.scale(size.width / boxWidth, size.height / boxHeight);
    _paintRing(canvas, _phase(p, 0, _ringEnd));
    _paintCheck(canvas, _phase(p, _checkStart, _checkEnd));
    for (var i = 0; i < segmentCount; i++) {
      final start = _segmentsStart + i * _segmentStagger;
      _paintSegment(canvas, i, _phase(p, start, start + _segmentFade));
    }
    canvas.restore();
  }

  void _paintRing(Canvas canvas, double t) {
    if (t <= 0) return;
    final fill = Paint()
      ..style = PaintingStyle.fill
      ..color = t >= 1 ? tint : tint.withValues(alpha: tint.a * t);
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = ringStroke
      ..color = ring;
    canvas.drawCircle(ringCenter, ringRadius, fill);
    if (t >= 1) {
      canvas.drawCircle(ringCenter, ringRadius, stroke);
    } else {
      canvas.drawArc(
        Rect.fromCircle(center: ringCenter, radius: ringRadius),
        -math.pi / 2,
        2 * math.pi * t,
        false,
        stroke,
      );
    }
  }

  void _paintCheck(Canvas canvas, double t) {
    if (t <= 0) return;
    final path = Path()
      ..moveTo(146, 284)
      ..lineTo(236, 374)
      ..lineTo(414, 176);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = checkStroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = check;
    if (t >= 1) {
      canvas.drawPath(path, paint);
      return;
    }
    for (final metric in path.computeMetrics()) {
      canvas.drawPath(metric.extractPath(0, metric.length * t), paint);
    }
  }

  void _paintSegment(Canvas canvas, int i, double t) {
    if (t <= 0) return;
    final target = i >= firstFilledSegment ? filled : empty;
    // The gold segments turn from grey to gold as they appear.
    final base = i >= firstFilledSegment
        ? Color.lerp(empty, filled, t)!
        : target;
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = t >= 1 ? target : base.withValues(alpha: base.a * t);
    canvas.drawRect(segmentRect(i), paint);
  }

  @override
  bool shouldRepaint(BrandMarkPainter old) =>
      old.progress != progress ||
      old.ring != ring ||
      old.tint != tint ||
      old.check != check ||
      old.empty != empty ||
      old.filled != filled;
}

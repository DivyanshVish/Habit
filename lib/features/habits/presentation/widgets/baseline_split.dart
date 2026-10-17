import 'package:flutter/material.dart';

/// Width of [text] set in [style] on one line, at the current text scale.
double measureTextWidth(BuildContext context, String text, TextStyle style) {
  final painter = TextPainter(
    text: TextSpan(text: text, style: style),
    textDirection: Directionality.of(context),
    textScaler: MediaQuery.textScalerOf(context),
    maxLines: 1,
  )..layout();
  final width = painter.width;
  painter.dispose();
  return width;
}

/// [left] flush left and [right] flush right on one shared text baseline.
///
/// [naturalWidth] is the combined unwrapped width of both sides (measure it
/// with [measureTextWidth]). When it plus [gap] does not fit the available
/// width (large text scale, narrow screen) the sides stack instead, both left
/// aligned and [stackGap] apart, so nothing overflows.
class BaselineSplit extends StatelessWidget {
  const BaselineSplit({
    required this.left,
    required this.right,
    required this.naturalWidth,
    this.gap = 12,
    this.stackGap = 8,
    super.key,
  });

  final Widget left;
  final Widget right;
  final double naturalWidth;
  final double gap;
  final double stackGap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final fitsOnOneLine =
            constraints.maxWidth.isFinite &&
            naturalWidth + gap <= constraints.maxWidth;
        final shrinkingLeft = FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: left,
        );
        if (fitsOnOneLine) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(child: shrinkingLeft),
              SizedBox(width: gap),
              right,
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            shrinkingLeft,
            SizedBox(height: stackGap),
            right,
          ],
        );
      },
    );
  }
}

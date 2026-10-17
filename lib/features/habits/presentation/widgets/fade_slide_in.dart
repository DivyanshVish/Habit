import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:habit_tracker/core/theme/app_motion.dart';

/// Short staggered entrance: fades in and rises a few dp. The stagger delay is
/// baked into a single animation so no timers are involved.
class FadeSlideIn extends StatelessWidget {
  const FadeSlideIn({
    required this.index,
    required this.child,
    this.offset = 12,
    super.key,
  });

  /// Position in the list. The delay is capped after 8 items.
  final int index;
  final Widget child;

  /// Vertical travel in dp.
  final double offset;

  @override
  Widget build(BuildContext context) {
    final delay = math.min(index, 8) * 40;
    final total = AppMotion.base.inMilliseconds + delay;
    final duration = AppMotion.of(context, Duration(milliseconds: total));
    final curve = Interval(delay / total, 1, curve: AppMotion.standard);
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: duration,
      curve: curve,
      child: child,
      builder: (context, t, child) => Opacity(
        opacity: t.clamp(0.0, 1.0),
        alwaysIncludeSemantics: true,
        child: Transform.translate(
          offset: Offset(0, offset * (1 - t)),
          child: child,
        ),
      ),
    );
  }
}

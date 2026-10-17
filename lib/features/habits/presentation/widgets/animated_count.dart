import 'package:flutter/material.dart';
import 'package:habit_tracker/core/theme/app_motion.dart';

/// An integer that counts up or down when [value] changes. The first frame
/// shows [value] directly, only later changes animate.
class AnimatedCount extends StatelessWidget {
  const AnimatedCount({
    required this.value,
    required this.style,
    this.textKey,
    super.key,
  });

  final int value;
  final TextStyle style;

  /// Key applied to the inner [Text], handy for tests.
  final Key? textKey;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: value.toDouble()),
      duration: AppMotion.of(context, AppMotion.slow),
      curve: AppMotion.standard,
      builder: (context, current, _) =>
          Text('${current.round()}', key: textKey, style: style),
    );
  }
}

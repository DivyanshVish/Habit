import 'package:flutter/material.dart';
import 'package:habit_tracker/core/theme/app_motion.dart';
import 'package:habit_tracker/core/theme/app_tokens.dart';

/// Circular check. Outlined when open, gold outline with a tint and a check
/// mark when done (never a solid fill). The touch target is 48dp.
class CheckToggle extends StatelessWidget {
  const CheckToggle({
    required this.done,
    required this.onPressed,
    required this.tooltip,
    super.key,
  });

  final bool done;
  final VoidCallback onPressed;
  final String tooltip;

  /// Diameter of the visible circle (7dp inset inside the 48dp target).
  static const double diameter = 34;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final duration = AppMotion.of(context, const Duration(milliseconds: 200));
    return Tooltip(
      message: tooltip,
      excludeFromSemantics: true,
      child: Semantics(
        button: true,
        checked: done,
        label: tooltip,
        child: SizedBox.square(
          dimension: 48,
          child: InkResponse(
            onTap: onPressed,
            customBorder: const CircleBorder(),
            radius: 24,
            child: ExcludeSemantics(
              child: Center(
                child: AnimatedContainer(
                  duration: duration,
                  curve: AppMotion.standard,
                  width: diameter,
                  height: diameter,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: done ? tokens.accentTint : Colors.transparent,
                    border: Border.all(
                      color: done ? tokens.accent : tokens.outline,
                      width: 1.5,
                    ),
                  ),
                  child: AnimatedScale(
                    scale: done ? 1 : 0.6,
                    duration: duration,
                    curve: AppMotion.standard,
                    child: AnimatedOpacity(
                      opacity: done ? 1 : 0,
                      duration: duration,
                      child: Icon(
                        Icons.check,
                        size: 18,
                        color: tokens.accentInk,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

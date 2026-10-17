import 'package:flutter/material.dart';
import 'package:habit_tracker/core/theme/app_motion.dart';
import 'package:habit_tracker/core/theme/app_tokens.dart';

/// A short confirmation pill, e.g. "+20 points". It replaces any message that
/// is currently showing and disappears after 1.4 seconds.
void showToast(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Center(
          heightFactor: 1,
          child: Text(
            message,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 1400),
        width: 190,
      ),
      snackBarAnimationStyle: _animationStyle(context),
    );
}

/// A regular floating snackbar for failures. It replaces any toast.
void showErrorSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(context.tokens.radii.control),
        ),
      ),
      snackBarAnimationStyle: _animationStyle(context),
    );
}

AnimationStyle? _animationStyle(BuildContext context) =>
    reduceMotion(context) ? AnimationStyle.noAnimation : null;

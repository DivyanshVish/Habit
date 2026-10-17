import 'package:flutter/material.dart';

/// True when the user asked the system to reduce motion.
bool reduceMotion(BuildContext context) =>
    MediaQuery.disableAnimationsOf(context) ||
    MediaQuery.accessibleNavigationOf(context);

/// Durations and curves. Every animation in the app takes its duration from
/// [AppMotion.of] so reduced motion collapses it to zero.
class AppMotion {
  const AppMotion._();

  static const Duration fast = Duration(milliseconds: 160);
  static const Duration base = Duration(milliseconds: 240);
  static const Duration slow = Duration(milliseconds: 420);

  /// In-app splash intro, also the minimum time the splash stays up.
  static const Duration splash = Duration(milliseconds: 900);

  static const Curve standard = Curves.easeOutCubic;
  static const Curve emphasized = Curves.easeOutQuart;
  static const Curve spring = Curves.easeOutBack;

  /// [duration], or [Duration.zero] when motion should be reduced.
  static Duration of(BuildContext context, Duration duration) =>
      reduceMotion(context) ? Duration.zero : duration;
}

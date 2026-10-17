import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:habit_tracker/core/theme/app_motion.dart';
import 'package:habit_tracker/core/theme/app_tokens.dart';

enum AppTransitionKind {
  /// Fade-through with a small horizontal shift (Today to Detail).
  sharedAxis,

  /// Fade with a small rise from below (Add habit).
  riseUp,
}

/// Builds a go_router page with the app's fade-through transitions. When the
/// user asked for reduced motion the page simply appears.
Page<T> buildAppPage<T>({
  required GoRouterState state,
  required Widget child,
  AppTransitionKind kind = AppTransitionKind.sharedAxis,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 320),
    reverseTransitionDuration: const Duration(milliseconds: 260),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      // Opaque so the page below never shows through mid transition.
      final page = ColoredBox(color: context.tokens.paper, child: child);
      if (reduceMotion(context)) return page;

      final incomingFade = animation.drive(
        CurveTween(curve: const Interval(0.3, 1, curve: Curves.easeOut)),
      );
      final outgoingFade = secondaryAnimation
          .drive(
            CurveTween(curve: const Interval(0, 0.4, curve: Curves.easeIn)),
          )
          .drive(Tween<double>(begin: 1, end: 0));

      switch (kind) {
        case AppTransitionKind.sharedAxis:
          return SlideTransition(
            position: secondaryAnimation
                .drive(CurveTween(curve: AppMotion.standard))
                .drive(
                  Tween<Offset>(
                    begin: Offset.zero,
                    end: const Offset(-0.04, 0),
                  ),
                ),
            child: FadeTransition(
              opacity: outgoingFade,
              child: SlideTransition(
                position: animation
                    .drive(CurveTween(curve: AppMotion.standard))
                    .drive(
                      Tween<Offset>(
                        begin: const Offset(0.08, 0),
                        end: Offset.zero,
                      ),
                    ),
                child: FadeTransition(opacity: incomingFade, child: page),
              ),
            ),
          );
        case AppTransitionKind.riseUp:
          return FadeTransition(
            opacity: outgoingFade,
            child: SlideTransition(
              position: animation
                  .drive(CurveTween(curve: AppMotion.emphasized))
                  .drive(
                    Tween<Offset>(
                      begin: const Offset(0, 0.06),
                      end: Offset.zero,
                    ),
                  ),
              child: FadeTransition(opacity: incomingFade, child: page),
            ),
          );
      }
    },
  );
}

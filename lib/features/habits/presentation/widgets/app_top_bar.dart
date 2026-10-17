import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:habit_tracker/core/router/app_routes.dart';
import 'package:habit_tracker/core/theme/app_tokens.dart';

/// Minimal top bar: one 48dp leading button that goes back (or closes).
class AppTopBar extends StatelessWidget {
  const AppTopBar({this.close = false, super.key});

  /// Shows a close icon instead of a back arrow.
  final bool close;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return SizedBox(
      height: 56,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: EdgeInsets.only(left: tokens.space.s12),
          child: IconButton(
            tooltip: close ? 'Close' : 'Back',
            icon: Icon(close ? Icons.close : Icons.arrow_back, size: 24),
            onPressed: () =>
                context.canPop() ? context.pop() : context.go(AppRoutes.today),
          ),
        ),
      ),
    );
  }
}

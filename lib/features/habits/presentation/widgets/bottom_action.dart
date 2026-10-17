import 'package:flutter/material.dart';
import 'package:habit_tracker/core/theme/app_tokens.dart';

/// Bottom-docked action bar with a hairline above it.
class BottomAction extends StatelessWidget {
  const BottomAction({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: tokens.paper,
        border: Border(top: BorderSide(color: tokens.hairline)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            tokens.space.screenMargin,
            tokens.space.s16,
            tokens.space.screenMargin,
            tokens.space.s12,
          ),
          child: child,
        ),
      ),
    );
  }
}

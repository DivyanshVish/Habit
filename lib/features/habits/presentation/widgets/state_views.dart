import 'package:flutter/material.dart';
import 'package:habit_tracker/core/theme/app_motion.dart';
import 'package:habit_tracker/core/theme/app_tokens.dart';

enum LoadingVariant { list, detail }

/// Static skeleton shaped like the final layout. It fades in once and never
/// pulses, so there is no decoration-only motion.
class LoadingView extends StatelessWidget {
  const LoadingView({this.variant = LoadingVariant.list, super.key});

  final LoadingVariant variant;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final margin = tokens.space.screenMargin;
    final isList = variant == LoadingVariant.list;
    return Semantics(
      label: 'Loading',
      liveRegion: true,
      child: ExcludeSemantics(
        child: TweenAnimationBuilder<double>(
          key: Key(isList ? 'today-skeleton' : 'detail-skeleton'),
          tween: Tween<double>(begin: 0, end: 1),
          duration: AppMotion.of(context, AppMotion.slow),
          curve: AppMotion.standard,
          builder: (context, t, child) =>
              Opacity(opacity: t, alwaysIncludeSemantics: true, child: child),
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(margin, 0, margin, 0),
            child: isList ? const _ListSkeleton() : const _DetailSkeleton(),
          ),
        ),
      ),
    );
  }
}

class _Block extends StatelessWidget {
  const _Block({this.width, required this.height, this.circle = false});

  final double? width;
  final double height;
  final bool circle;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: tokens.track,
        shape: circle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: circle ? null : BorderRadius.circular(2),
      ),
    );
  }
}

class _ListSkeleton extends StatelessWidget {
  const _ListSkeleton();

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 18),
        const _Block(width: 150, height: 12),
        const SizedBox(height: 10),
        const _Block(width: 130, height: 40),
        const SizedBox(height: 18),
        const _Block(width: 120, height: 60),
        const SizedBox(height: 16),
        const _Block(height: 3),
        const SizedBox(height: 24),
        for (var i = 0; i < 4; i++) ...[
          Divider(color: tokens.hairline),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Row(
              children: [
                _Block(width: 34, height: 34, circle: true),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Block(width: 150, height: 16),
                      SizedBox(height: 8),
                      _Block(width: 110, height: 3),
                    ],
                  ),
                ),
                SizedBox(width: 12),
                _Block(width: 28, height: 20),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _DetailSkeleton extends StatelessWidget {
  const _DetailSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        const _Block(width: 60, height: 12),
        const SizedBox(height: 10),
        const _Block(width: 220, height: 36),
        const SizedBox(height: 16),
        const _Block(height: 12),
        const SizedBox(height: 8),
        const _Block(width: 200, height: 12),
        const SizedBox(height: 18),
        const _Block(width: 90, height: 26),
        const SizedBox(height: 28),
        const _Block(height: 1),
        const SizedBox(height: 24),
        const _Block(width: 110, height: 12),
        const SizedBox(height: 18),
        Row(
          children: [
            for (var i = 0; i < 7; i++) ...[
              if (i > 0) const SizedBox(width: 6),
              const Expanded(child: _Block(height: 52)),
            ],
          ],
        ),
      ],
    );
  }
}

/// Calm error state with a single outlined retry action.
class ErrorView extends StatelessWidget {
  const ErrorView({
    required this.message,
    required this.onRetry,
    this.title = "Couldn't load",
    this.kicker = 'SOMETHING WENT WRONG',
    this.actionLabel = 'Try again',
    this.icon,
    super.key,
  });

  final String message;
  final VoidCallback onRetry;
  final String title;

  /// Small label above the title.
  final String kicker;
  final String actionLabel;

  /// Defaults to an error circle.
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        tokens.space.screenMargin,
        tokens.space.s48,
        tokens.space.screenMargin,
        tokens.space.s32,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon ?? Icons.error_outline, size: 32, color: tokens.danger),
          SizedBox(height: tokens.space.s16),
          Text(kicker, style: tokens.text.kicker),
          SizedBox(height: tokens.space.s8),
          Semantics(
            header: true,
            child: Text(
              title,
              style: tokens.text.headline.copyWith(fontSize: 34, height: 1.1),
            ),
          ),
          SizedBox(height: tokens.space.s12),
          Text(
            message,
            style: tokens.text.body.copyWith(color: tokens.inkMuted),
          ),
          SizedBox(height: tokens.space.s24),
          OutlinedButton(onPressed: onRetry, child: Text(actionLabel)),
        ],
      ),
    );
  }
}

/// Quiet italic serif empty state. The single action lives in the persistent
/// "New habit" control.
class EmptyView extends StatelessWidget {
  const EmptyView({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.space.screenMargin,
        vertical: tokens.space.s32,
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: tokens.text.emptyState.copyWith(color: tokens.inkMuted),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:habit_tracker/core/theme/app_motion.dart';
import 'package:habit_tracker/core/theme/app_tokens.dart';
import 'package:habit_tracker/features/habits/domain/entities/today_overview.dart';
import 'package:habit_tracker/features/habits/presentation/utils/date_formatters.dart';
import 'package:habit_tracker/features/habits/presentation/widgets/animated_count.dart';
import 'package:habit_tracker/features/habits/presentation/widgets/baseline_split.dart';

/// Editorial header for Today: date kicker, "Today", the earned points
/// numeral and a thin progress line. Not a card.
class ProgressHeader extends StatelessWidget {
  const ProgressHeader({required this.overview, super.key});

  final TodayOverview overview;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final text = tokens.text;
    final isEmpty = overview.items.isEmpty;
    final summary =
        '${overview.earnedPoints} of ${overview.totalPoints} points, '
        '${overview.doneCount} of ${overview.totalCount} habits done';

    return Padding(
      padding: EdgeInsets.fromLTRB(
        tokens.space.screenMargin,
        18,
        tokens.space.screenMargin,
        18,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(formatKicker(overview.date), style: text.kicker),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text('Today', style: text.displayTitle),
          ),
          if (!isEmpty) ...[
            const SizedBox(height: 18),
            Semantics(
              container: true,
              label: 'Today: $summary',
              child: ExcludeSemantics(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Numbers(overview: overview),
                    SizedBox(height: tokens.space.s16),
                    _ProgressLine(progress: overview.progress),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// The big numeral with "/ N points" on the left and "X of Y done" flush right
/// on the same baseline. At large text sizes the right side stacks under the
/// left.
class _Numbers extends StatelessWidget {
  const _Numbers({required this.overview});

  final TodayOverview overview;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final text = tokens.text;
    final pointsLabel = '/ ${overview.totalPoints} points';
    final doneNumber = '${overview.doneCount}';
    final doneLabel = ' of ${overview.totalCount} done';
    final labelStyle = text.body.copyWith(color: tokens.inkMuted);
    final doneLabelStyle = text.bodySmall.copyWith(color: tokens.inkMuted);

    final naturalWidth =
        measureTextWidth(
          context,
          '${overview.earnedPoints}',
          text.displayNumeral,
        ) +
        tokens.space.s8 +
        measureTextWidth(context, pointsLabel, labelStyle) +
        measureTextWidth(context, doneNumber, text.numeralSmall) +
        measureTextWidth(context, doneLabel, doneLabelStyle);

    return BaselineSplit(
      naturalWidth: naturalWidth,
      left: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          AnimatedCount(
            value: overview.earnedPoints,
            style: text.displayNumeral,
          ),
          SizedBox(width: tokens.space.s8),
          Text(pointsLabel, style: labelStyle),
        ],
      ),
      right: Text.rich(
        TextSpan(
          children: [
            TextSpan(text: doneNumber, style: text.numeralSmall),
            TextSpan(text: doneLabel, style: doneLabelStyle),
          ],
        ),
      ),
    );
  }
}

/// 3dp track with a gold bar growing from the left.
class _ProgressLine extends StatelessWidget {
  const _ProgressLine({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return SizedBox(
      height: 3,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ColoredBox(color: tokens.track),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: progress),
            duration: AppMotion.of(context, AppMotion.slow),
            curve: Curves.easeOut,
            builder: (context, value, _) => FractionallySizedBox(
              key: const Key('progress-bar'),
              alignment: Alignment.centerLeft,
              widthFactor: value.clamp(0.0, 1.0),
              child: ColoredBox(color: tokens.accent),
            ),
          ),
        ],
      ),
    );
  }
}

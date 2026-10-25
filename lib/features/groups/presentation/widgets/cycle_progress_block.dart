import 'package:flutter/material.dart';
import 'package:habit_tracker/core/theme/app_tokens.dart';
import 'package:habit_tracker/features/groups/domain/entities/cycle_snapshot.dart';

/// Today's progress for everyone: "3 of 5 done", the percentage, the target
/// when there is one, and who has completed. Status is always written out, so
/// it never depends on colour.
class CycleProgressBlock extends StatelessWidget {
  const CycleProgressBlock({
    required this.cycle,
    required this.namesByUid,
    super.key,
  });

  /// Null when no cycle is open for today.
  final CycleSnapshot? cycle;

  /// Display names of the people who can be listed.
  final Map<String, String> namesByUid;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final cycle = this.cycle;
    if (cycle == null) {
      return Text(
        'Nothing is scheduled for today yet.',
        style: tokens.text.body.copyWith(color: tokens.inkMuted),
      );
    }

    final progress = cycle.progress;
    final names = [
      for (final uid in cycle.visibleCompletedUids) namesByUid[uid] ?? 'Member',
    ];
    final privateDone =
        cycle.completedCount - cycle.visibleCompletedUids.length;
    final summary =
        '${cycle.completedCount} of ${cycle.eligibleCount} done, '
        '${progress.percent} percent';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          label: summary,
          child: ExcludeSemantics(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Wraps instead of overflowing at large text sizes.
                Expanded(
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.end,
                    children: [
                      Text(
                        '${cycle.completedCount}',
                        style: tokens.text.displayNumeral.copyWith(
                          fontSize: 52,
                        ),
                      ),
                      Text(
                        ' of ${cycle.eligibleCount} done',
                        style: tokens.text.body.copyWith(
                          color: tokens.inkMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: tokens.space.s8),
                Text('${progress.percent}%', style: tokens.text.numeral),
              ],
            ),
          ),
        ),
        SizedBox(height: tokens.space.s8),
        ExcludeSemantics(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: progress.percent / 100,
              minHeight: 4,
              color: tokens.accent,
              backgroundColor: tokens.track,
            ),
          ),
        ),
        if (progress.hasTarget) ...[
          SizedBox(height: tokens.space.s12),
          Text(
            progress.reached
                ? 'Group target reached. Everyone can still complete.'
                : '${progress.remaining} more '
                      '${progress.remaining == 1 ? 'completion' : 'completions'} '
                      'needed (${progress.required} of ${cycle.eligibleCount}).',
            key: const Key('target-line'),
            style: tokens.text.body.copyWith(
              color: progress.reached ? tokens.accentInk : tokens.ink,
            ),
          ),
        ],
        SizedBox(height: tokens.space.s12),
        if (names.isNotEmpty)
          Text(
            'Done: ${names.join(', ')}'
            '${privateDone > 0 ? ' and $privateDone private' : ''}',
            style: tokens.text.bodySmall.copyWith(color: tokens.inkMuted),
          )
        else if (privateDone > 0)
          Text(
            '$privateDone done, names are private.',
            style: tokens.text.bodySmall.copyWith(color: tokens.inkMuted),
          ),
        Text(
          'Waiting: ${cycle.pendingCount}',
          style: tokens.text.bodySmall.copyWith(color: tokens.inkMuted),
        ),
      ],
    );
  }
}

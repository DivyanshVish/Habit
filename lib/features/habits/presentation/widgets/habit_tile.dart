import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart' show CustomSemanticsAction;
import 'package:flutter/services.dart';
import 'package:habit_tracker/core/theme/app_motion.dart';
import 'package:habit_tracker/core/theme/app_tokens.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit_with_status.dart';
import 'package:habit_tracker/features/habits/presentation/widgets/check_toggle.dart';
import 'package:habit_tracker/features/habits/presentation/widgets/confirm_delete_dialog.dart';
import 'package:habit_tracker/features/habits/presentation/widgets/streak_bar.dart';

/// A flat list row: check, name, seven day streak bar and the points value.
class HabitTile extends StatelessWidget {
  const HabitTile({
    required this.item,
    required this.onToggle,
    required this.onTap,
    required this.onDelete,
    super.key,
  });

  final HabitWithStatus item;
  final VoidCallback onToggle;
  final VoidCallback onTap;

  /// Called after the user confirmed deleting this habit.
  final VoidCallback onDelete;

  Future<void> _confirmAndDelete(BuildContext context) async {
    if (await confirmDeleteHabit(context, item.habit.name)) onDelete();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final text = tokens.text;
    final habit = item.habit;
    final done = item.isDone;

    final row = Material(
      color: tokens.paper,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 72),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: tokens.space.s12 - 1),
            child: Row(
              children: [
                CheckToggle(
                  done: done,
                  tooltip: done ? 'Mark as not done' : 'Mark as done',
                  onPressed: () {
                    unawaited(HapticFeedback.lightImpact());
                    onToggle();
                  },
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TweenAnimationBuilder<Color?>(
                        tween: ColorTween(
                          end: done ? tokens.inkMuted : tokens.ink,
                        ),
                        duration: AppMotion.of(context, AppMotion.base),
                        builder: (context, color, _) => Text(
                          habit.name,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: text.rowTitle.copyWith(
                            color: color,
                            decoration: done
                                ? TextDecoration.lineThrough
                                : null,
                            decorationColor: tokens.inkMuted,
                          ),
                        ),
                      ),
                      SizedBox(height: tokens.space.s8 - 1),
                      MiniStreakBar(streak: item.streak),
                    ],
                  ),
                ),
                SizedBox(width: tokens.space.s12),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 72),
                  child: Semantics(
                    label: '${habit.points} points',
                    child: ExcludeSemantics(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('${habit.points}', style: text.numeral),
                            Text(
                              'PTS',
                              style: text.tiny.copyWith(color: tokens.inkMuted),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    return Dismissible(
      key: ValueKey('dismiss-${habit.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        color: tokens.paper,
        child: Icon(Icons.delete_outline, size: 24, color: tokens.danger),
      ),
      // Ask first. The row is never removed by the swipe itself: it disappears
      // when the live Firestore stream no longer contains the habit, so a
      // failed delete just leaves the row where it was.
      confirmDismiss: (_) async {
        await _confirmAndDelete(context);
        return false;
      },
      // Swipe is not available to screen reader users, so offer an action.
      child: Semantics(
        container: true,
        customSemanticsActions: {
          const CustomSemanticsAction(label: 'Delete habit'): () =>
              _confirmAndDelete(context),
        },
        child: row,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:habit_tracker/core/theme/app_tokens.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit_streak.dart';

/// Seven thin segments (gold when done, oldest first) and the streak text.
/// The text repeats the state, so colour is never the only signal. Reads as a
/// single label for screen readers.
class MiniStreakBar extends StatelessWidget {
  const MiniStreakBar({required this.streak, super.key});

  final HabitStreak streak;

  /// "3-day streak" or "No streak".
  static String labelFor(HabitStreak streak) => streak.currentStreak > 0
      ? '${streak.currentStreak}-day streak'
      : 'No streak';

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final days = streak.days;
    final label = labelFor(streak);
    return Semantics(
      container: true,
      label: label,
      child: ExcludeSemantics(
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 7,
          runSpacing: 4,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < days.length; i++)
                  Padding(
                    padding: EdgeInsets.only(
                      right: i < days.length - 1 ? 3 : 0,
                    ),
                    child: Container(
                      key: Key('streak-segment-$i'),
                      width: 14,
                      height: 3,
                      color: days[i].status == DayStatus.done
                          ? tokens.accent
                          : tokens.track,
                    ),
                  ),
              ],
            ),
            Text(
              label,
              style: tokens.text.caption.copyWith(color: tokens.inkMuted),
            ),
          ],
        ),
      ),
    );
  }
}

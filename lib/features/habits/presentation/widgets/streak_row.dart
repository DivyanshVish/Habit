import 'package:flutter/material.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit_streak.dart';
import 'package:habit_tracker/features/habits/presentation/widgets/day_chip.dart';
import 'package:habit_tracker/features/habits/presentation/widgets/fade_slide_in.dart';

/// The week strip: the last 7 days, oldest on the left and today on the right.
class StreakRow extends StatelessWidget {
  const StreakRow({required this.streak, super.key});

  final HabitStreak streak;

  @override
  Widget build(BuildContext context) {
    final days = streak.days;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < days.length; i++) ...[
          if (i > 0) const SizedBox(width: 6),
          Expanded(
            child: FadeSlideIn(
              index: i,
              offset: 8,
              child: DayChip(day: days[i]),
            ),
          ),
        ],
      ],
    );
  }
}

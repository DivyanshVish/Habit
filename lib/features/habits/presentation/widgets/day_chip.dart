import 'package:flutter/material.dart';
import 'package:habit_tracker/core/theme/app_motion.dart';
import 'package:habit_tracker/core/theme/app_tokens.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit_streak.dart';
import 'package:habit_tracker/features/habits/presentation/utils/date_formatters.dart';

/// One cell of the week strip: weekday letter, a rounded cell showing the
/// status, and the day of the month. Today gets a gold outline ring around it.
class DayChip extends StatelessWidget {
  const DayChip({required this.day, super.key});

  final StreakDay day;

  static const double _cellWidth = 38;
  static const double _cellHeight = 52;

  /// Today's ring: 1.5dp gold line with a 3dp paper gap to the cell.
  static const double _ringWidth = 1.5;
  static const double _ringOffset = 3 + _ringWidth;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final text = tokens.text;
    final dayName = day.isToday ? 'Today' : weekdayName(day.date);
    final statusText = switch (day.status) {
      DayStatus.done => 'done',
      DayStatus.missed when day.isToday => 'not done yet',
      DayStatus.missed => 'missed',
      DayStatus.notApplicable => 'before this habit was created',
    };

    return Semantics(
      container: true,
      label: '$dayName, $statusText',
      child: ExcludeSemantics(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                weekdayInitial(day.date),
                style: text.kicker.copyWith(
                  color: day.isToday ? tokens.accentInk : tokens.inkMuted,
                  letterSpacing: 1,
                ),
              ),
            ),
            SizedBox(height: tokens.space.s8),
            SizedBox(
              height: _cellHeight,
              child: Center(child: _Cell(day: day)),
            ),
            SizedBox(height: tokens.space.s8),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '${day.date.day}',
                style: text.caption.copyWith(color: tokens.inkMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({required this.day});

  final StreakDay day;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final duration = AppMotion.of(context, AppMotion.base);

    if (day.status == DayStatus.notApplicable) {
      return Container(
        width: 4,
        height: 4,
        decoration: BoxDecoration(
          color: tokens.outline.withValues(alpha: 0.5),
          shape: BoxShape.circle,
        ),
      );
    }

    final done = day.status == DayStatus.done;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth.clamp(0.0, DayChip._cellWidth)
            : DayChip._cellWidth;
        final cell = AnimatedContainer(
          key: day.isToday ? const Key('today-ring') : null,
          duration: duration,
          curve: AppMotion.standard,
          width: width,
          height: DayChip._cellHeight,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: done ? tokens.accentTint : Colors.transparent,
            borderRadius: BorderRadius.circular(tokens.radii.strip),
            border: Border.all(color: done ? tokens.accent : tokens.outline),
          ),
          child: done
              ? Icon(Icons.check, size: 16, color: tokens.accentInk)
              : null,
        );
        if (!day.isToday) return cell;
        // Today: a separate gold outline ring with a paper gap, drawn around
        // the cell. A BoxShadow would bleed through a hollow cell and paint it
        // solid gold, so the ring is its own border-only box.
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: -DayChip._ringOffset,
              top: -DayChip._ringOffset,
              right: -DayChip._ringOffset,
              bottom: -DayChip._ringOffset,
              child: IgnorePointer(
                child: DecoratedBox(
                  key: const Key('today-ring-outline'),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      tokens.radii.strip + DayChip._ringOffset,
                    ),
                    border: Border.all(
                      color: tokens.accent,
                      width: DayChip._ringWidth,
                    ),
                  ),
                ),
              ),
            ),
            cell,
          ],
        );
      },
    );
  }
}

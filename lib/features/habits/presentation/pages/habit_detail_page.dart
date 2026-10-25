import 'dart:async';

import 'package:flutter/material.dart';
import 'package:habit_tracker/core/router/app_routes.dart';
import 'package:habit_tracker/features/notifications/domain/reminders_domain.dart';
import 'package:habit_tracker/features/notifications/presentation/reminder_tile.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:habit_tracker/core/error/failure.dart';
import 'package:habit_tracker/core/theme/app_motion.dart';
import 'package:habit_tracker/core/theme/app_tokens.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit_detail.dart';
import 'package:habit_tracker/features/habits/presentation/bloc/habit_detail/habit_detail_bloc.dart';
import 'package:habit_tracker/features/habits/presentation/widgets/animated_count.dart';
import 'package:habit_tracker/features/habits/presentation/widgets/app_top_bar.dart';
import 'package:habit_tracker/features/habits/presentation/widgets/baseline_split.dart';
import 'package:habit_tracker/features/habits/presentation/widgets/bottom_action.dart';
import 'package:habit_tracker/features/habits/presentation/widgets/hairline.dart';
import 'package:habit_tracker/features/habits/presentation/widgets/resume_observer.dart';
import 'package:habit_tracker/features/habits/presentation/widgets/state_views.dart';
import 'package:habit_tracker/features/habits/presentation/widgets/streak_row.dart';
import 'package:habit_tracker/features/habits/presentation/widgets/toast.dart';

class HabitDetailPage extends StatelessWidget {
  const HabitDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HabitDetailBloc, HabitDetailState>(
      listenWhen: (previous, current) =>
          current is HabitDetailFailure ||
          (current is HabitDetailLoaded && current.actionFailure != null),
      listener: (context, state) {
        switch (state) {
          case HabitDetailFailure(:final failure)
              when failure is NotFoundFailure:
            // The habit was deleted while this screen was open.
            showErrorSnackBar(context, failure.message);
            if (context.canPop()) context.pop();
          case HabitDetailLoaded(:final actionFailure?):
            // Replaces the toast of the failed toggle.
            showErrorSnackBar(context, actionFailure.message);
          case _:
            break;
        }
      },
      builder: (context, state) {
        return ResumeObserver(
          onResumed: () => context.read<HabitDetailBloc>().add(
            const HabitDetailEvent.resumed(),
          ),
          child: Scaffold(
            body: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  const AppTopBar(),
                  Expanded(
                    child: switch (state) {
                      HabitDetailLoading() => const LoadingView(
                        variant: LoadingVariant.detail,
                      ),
                      HabitDetailFailure(:final failure) => ErrorView(
                        message: failure.message,
                        onRetry: () => context.read<HabitDetailBloc>().add(
                          const HabitDetailEvent.started(),
                        ),
                      ),
                      HabitDetailLoaded(:final detail) => _DetailBody(
                        detail: detail,
                      ),
                    },
                  ),
                ],
              ),
            ),
            // In the bottom bar slot so toasts float above it, not over it.
            bottomNavigationBar: switch (state) {
              HabitDetailLoaded(:final detail) => BottomAction(
                child: _TodayAction(detail: detail),
              ),
              _ => null,
            },
          ),
        );
      },
    );
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({required this.detail});

  final HabitDetail detail;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final text = tokens.text;
    final space = tokens.space;
    final habit = detail.habit;
    final streak = detail.streak;
    final count = streak.currentStreak;
    final muted = tokens.inkMuted;

    final streakHeaderWidth =
        measureTextWidth(
          context,
          'LAST 7 DAYS',
          text.kicker.copyWith(color: muted),
        ) +
        measureTextWidth(context, '$count', text.streakNumeral) +
        6 +
        measureTextWidth(context, 'day streak', text.bodySmall);
    final footerLeft = '${streak.doneCount} of ${streak.days.length} days';
    final footerRight = '${streak.doneCount * habit.points} points this week';
    final footerStyle = text.bodySmall.copyWith(color: muted);
    final footerWidth =
        measureTextWidth(context, footerLeft, footerStyle) +
        measureTextWidth(context, footerRight, footerStyle);

    // Not a lazy list: every part stays reachable for screen readers.
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        space.screenMargin,
        0,
        space.screenMargin,
        24,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('HABIT', style: text.kicker),
            const SizedBox(height: 6),
            Semantics(
              header: true,
              child: Text(habit.name, style: text.headline),
            ),
            const SizedBox(height: 14),
            Text(
              habit.description.isEmpty ? 'No description' : habit.description,
              style: text.body.copyWith(color: muted),
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 10,
              runSpacing: space.s8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(color: tokens.accent),
                    borderRadius: BorderRadius.circular(tokens.radii.control),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    child: Text(
                      '${habit.points} points',
                      style: text.caption.copyWith(
                        fontWeight: FontWeight.w500,
                        color: tokens.accentInk,
                      ),
                    ),
                  ),
                ),
                Text(
                  'per completion',
                  style: text.italicNote.copyWith(color: muted),
                ),
              ],
            ),
            const SizedBox(height: 22),
            const Hairline(),
            const SizedBox(height: 20),
            BaselineSplit(
              naturalWidth: streakHeaderWidth,
              left: Semantics(
                header: true,
                child: Text(
                  'LAST 7 DAYS',
                  style: text.kicker.copyWith(color: muted),
                ),
              ),
              right: Semantics(
                container: true,
                label:
                    'Current streak: $count '
                    '${count == 1 ? 'day' : 'days'}',
                child: ExcludeSemantics(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      AnimatedCount(
                        value: count,
                        textKey: const Key('streak-count'),
                        style: text.streakNumeral,
                      ),
                      const SizedBox(width: 6),
                      // Flexible so the unit wraps when the stacked layout is
                      // narrower than numeral + unit (large text scales).
                      Flexible(
                        child: Text(
                          'day streak',
                          style: text.bodySmall.copyWith(color: muted),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            StreakRow(streak: streak),
            const SizedBox(height: 20),
            const Hairline(),
            Padding(
              padding: const EdgeInsets.only(top: 14),
              child: BaselineSplit(
                naturalWidth: footerWidth,
                stackGap: space.s4,
                left: Text(footerLeft, style: footerStyle),
                right: Text(footerRight, style: footerStyle),
              ),
            ),
            const SizedBox(height: 12),
            ReminderTile(target: PersonalReminderTarget(habit.id)),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => context.push(
                  AppRoutes.sharedNewFrom(
                    habitId: habit.id,
                    name: habit.name,
                    points: habit.points,
                  ),
                ),
                icon: const Icon(Icons.group_add_outlined, size: 18),
                label: const Text('Share with others'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Full width action that flips between "done" and "not done" styles.
class _TodayAction extends StatelessWidget {
  const _TodayAction({required this.detail});

  final HabitDetail detail;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final doneToday = detail.streak.isDoneToday;
    final style = doneToday
        ? OutlinedButton.styleFrom(
            foregroundColor: tokens.ink,
            side: BorderSide(color: tokens.outline, width: 1.5),
          )
        : null;
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        style: style,
        onPressed: () {
          unawaited(HapticFeedback.mediumImpact());
          // Toast text from the state BEFORE the toggle.
          showToast(
            context,
            '${doneToday ? '-' : '+'}${detail.habit.points} points',
          );
          context.read<HabitDetailBloc>().add(
            const HabitDetailEvent.todayToggled(),
          );
        },
        child: AnimatedSwitcher(
          duration: AppMotion.of(context, AppMotion.fast),
          child: Row(
            key: ValueKey(doneToday),
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(doneToday ? Icons.undo : Icons.check, size: 20),
              SizedBox(width: tokens.space.s8),
              Flexible(
                child: Text(
                  doneToday ? 'Mark today not done' : 'Mark today done',
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

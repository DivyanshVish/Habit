import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:habit_tracker/core/router/app_routes.dart';
import 'package:habit_tracker/core/theme/app_tokens.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit_with_status.dart';
import 'package:habit_tracker/features/habits/domain/entities/today_overview.dart';
import 'package:habit_tracker/features/habits/presentation/bloc/today/today_bloc.dart';
import 'package:habit_tracker/features/habits/presentation/widgets/bottom_action.dart';
import 'package:habit_tracker/features/habits/presentation/widgets/fade_slide_in.dart';
import 'package:habit_tracker/features/habits/presentation/widgets/habit_tile.dart';
import 'package:habit_tracker/features/habits/presentation/widgets/hairline.dart';
import 'package:habit_tracker/features/habits/presentation/widgets/progress_header.dart';
import 'package:habit_tracker/features/habits/presentation/widgets/resume_observer.dart';
import 'package:habit_tracker/features/habits/presentation/widgets/state_views.dart';
import 'package:habit_tracker/features/habits/presentation/widgets/toast.dart';

class TodayPage extends StatelessWidget {
  const TodayPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ResumeObserver(
      onResumed: () =>
          context.read<TodayBloc>().add(const TodayEvent.resumed()),
      child: Scaffold(
        body: SafeArea(
          bottom: false,
          child: BlocConsumer<TodayBloc, TodayState>(
            listenWhen: (previous, current) =>
                current is TodayLoaded && current.actionFailure != null,
            listener: (context, state) {
              if (state is TodayLoaded && state.actionFailure != null) {
                // Replaces the "+N points" toast of the failed toggle.
                showErrorSnackBar(context, state.actionFailure!.message);
              }
            },
            builder: (context, state) {
              return switch (state) {
                TodayLoading() => const LoadingView(),
                TodayFailure(:final failure) => ErrorView(
                  message: failure.message,
                  onRetry: () =>
                      context.read<TodayBloc>().add(const TodayEvent.started()),
                ),
                TodayLoaded(:final overview) => _TodayList(overview: overview),
              };
            },
          ),
        ),
        // In the bottom bar slot so toasts float above it, not over it.
        bottomNavigationBar: BottomAction(
          child: OutlinedButton.icon(
            onPressed: () => context.push(AppRoutes.addHabit),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('New habit'),
          ),
        ),
      ),
    );
  }
}

class _TodayList extends StatelessWidget {
  const _TodayList({required this.overview});

  final TodayOverview overview;

  /// Toast text from the state BEFORE the toggle.
  static String _toastFor(HabitWithStatus item) =>
      '${item.isDone ? '-' : '+'}${item.habit.points} points';

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final items = overview.items;

    // One scroll view for everything so very large text never overflows.
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: FadeSlideIn(
            index: 0,
            child: ProgressHeader(overview: overview),
          ),
        ),
        const SliverToBoxAdapter(child: Hairline()),
        if (items.isEmpty)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: FadeSlideIn(
                index: 1,
                child: EmptyView(message: 'No habits yet. Begin with one.'),
              ),
            ),
          )
        else
          SliverPadding(
            padding: EdgeInsets.symmetric(
              horizontal: tokens.space.screenMargin,
            ),
            sliver: SliverList.separated(
              itemCount: items.length,
              separatorBuilder: (_, _) => const Hairline(),
              itemBuilder: (context, i) {
                final item = items[i];
                return FadeSlideIn(
                  key: ValueKey('row-${item.habit.id}'),
                  index: i + 1,
                  child: HabitTile(
                    key: ValueKey(item.habit.id),
                    item: item,
                    onToggle: () {
                      showToast(context, _toastFor(item));
                      context.read<TodayBloc>().add(
                        TodayEvent.habitToggled(item.habit.id),
                      );
                    },
                    onTap: () =>
                        context.push(AppRoutes.habitDetail(item.habit.id)),
                    onDelete: () => context.read<TodayBloc>().add(
                      TodayEvent.habitDeleted(item.habit.id),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

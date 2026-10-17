import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme.dart';
import '../../domain/entities/habit.dart';
import '../providers/providers.dart';
import '../widgets/common.dart';
import 'add_habit_page.dart';
import 'habit_detail_page.dart';

class TodayPage extends ConsumerWidget {
  const TodayPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(habitsProvider);
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _Header(),
            const Hairline(),
            Expanded(
              child: habits.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(
                    color: C.accent,
                    strokeWidth: 2,
                  ),
                ),
                error: (e, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(26),
                    child: Text(
                      'Could not load habits.\n$e',
                      textAlign: TextAlign.center,
                      style: body(14, color: C.n700),
                    ),
                  ),
                ),
                data: (list) => list.isEmpty
                    ? Center(
                        child: Text(
                          'No habits yet. Begin with one.',
                          style: heading(
                            22,
                            color: C.n700,
                          ).copyWith(fontStyle: FontStyle.italic),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 26),
                        itemCount: list.length,
                        separatorBuilder: (_, __) => const Hairline(),
                        itemBuilder: (_, i) => _HabitRow(habit: list[i]),
                      ),
              ),
            ),
            BottomAction(
              child: OutlinedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddHabitPage()),
                ),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('New habit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends ConsumerWidget {
  const _Header();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = ref.watch(progressProvider);
    return Padding(
      padding: const EdgeInsets.fromLTRB(26, 18, 26, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DateFormat('EEEE · d MMMM').format(DateTime.now()).toUpperCase(),
            style: kicker(),
          ),
          const SizedBox(height: 6),
          Text('Today', style: heading(46)),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text('${p.earned}', style: heading(64)),
                  const SizedBox(width: 8),
                  Text('/ ${p.total} points', style: body(15, color: C.n700)),
                ],
              ),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '${p.done}',
                      style: heading(26, w: FontWeight.w600),
                    ),
                    TextSpan(
                      text: ' of ${p.count} done',
                      style: body(14, color: C.n700),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Hairline track, accent stroke.
          Stack(
            children: [
              Container(height: 3, color: C.n300),
              AnimatedFractionallySizedBox(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOut,
                widthFactor: p.fraction.clamp(0.0, 1.0),
                child: Container(height: 3, color: C.accent),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HabitRow extends ConsumerWidget {
  const _HabitRow({required this.habit});
  final Habit habit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = DateTime.now();
    final done = habit.isDoneOn(today);
    final streak = habit.currentStreak();

    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => HabitDetailPage(habitId: habit.id)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 11),
        child: Row(
          children: [
            CheckToggle(
              done: done,
              onTap: () async {
                await ref.read(setCompletionProvider)(habit, done: !done);
                if (context.mounted)
                  showToast(
                    context,
                    '${done ? '\u2212' : '+'}${habit.points} points',
                  );
              },
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    habit.name,
                    style:
                        heading(
                          21,
                          w: FontWeight.w600,
                          color: done ? C.n700 : C.text,
                        ).copyWith(
                          decoration: done ? TextDecoration.lineThrough : null,
                        ),
                  ),
                  const SizedBox(height: 7),
                  Row(
                    children: [
                      for (final d in habit.last7Days())
                        Container(
                          width: 14,
                          height: 3,
                          margin: const EdgeInsets.only(right: 3),
                          color: d.done ? C.accent : C.n300,
                        ),
                      const SizedBox(width: 7),
                      Text(
                        streak > 0 ? '$streak-day streak' : 'No streak',
                        style: body(12, color: C.n700),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${habit.points}', style: heading(24, w: FontWeight.w600)),
                Text(
                  'PTS',
                  style: body(10, color: C.n700).copyWith(letterSpacing: 1.2),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

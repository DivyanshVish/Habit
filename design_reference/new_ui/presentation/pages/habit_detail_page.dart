import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme.dart';
import '../../domain/entities/habit.dart';
import '../providers/providers.dart';
import '../widgets/common.dart';

class HabitDetailPage extends ConsumerWidget {
  const HabitDetailPage({super.key, required this.habitId});
  final String habitId;

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: C.bg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(7),
          side: const BorderSide(color: C.divider),
        ),
        title: Text(
          'Delete this habit?',
          style: heading(26, w: FontWeight.w600),
        ),
        content: Text(
          'Its history will be removed and cannot be restored.',
          style: body(14, color: C.n700),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: body(15, color: C.n700)),
          ),
          OutlinedButton(
            style: OutlinedButton.styleFrom(minimumSize: const Size(90, 44)),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      await ref.read(deleteHabitProvider)(habitId);
      if (context.mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habit = ref.watch(habitProvider(habitId));
    if (habit == null) return const Scaffold(); // deleted — page is popping

    final today = DateTime.now();
    final done = habit.isDoneOn(today);

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        actions: [
          IconButton(
            tooltip: 'Delete habit',
            icon: const Icon(Icons.delete_outline, size: 22),
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(26, 0, 26, 24),
              children: [
                Text('HABIT', style: kicker()),
                const SizedBox(height: 6),
                Text(habit.name, style: heading(42).copyWith(height: 1.02)),
                const SizedBox(height: 14),
                Text(
                  habit.description,
                  textAlign: TextAlign.justify,
                  style: body(15, color: const Color(0xFF444141), h: 1.6),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: C.accent),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${habit.points} points',
                        style: body(12, w: FontWeight.w500, color: C.accent700),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'per completion',
                      style: body(
                        14,
                        color: C.n700,
                      ).copyWith(fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                const Hairline(),
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('LAST 7 DAYS', style: kicker(C.n700)),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text('${habit.currentStreak()}', style: heading(48)),
                        const SizedBox(width: 6),
                        Text('day streak', style: body(14, color: C.n700)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _WeekStrip(days: habit.last7Days()),
                const SizedBox(height: 20),
                const Hairline(),
                Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${habit.doneDaysThisWeek} of 7 days',
                        style: body(14, color: C.n700),
                      ),
                      Text(
                        '${habit.weekPoints} points this week',
                        style: body(14, color: C.n700),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          BottomAction(
            child: OutlinedButton(
              style: done
                  ? OutlinedButton.styleFrom(
                      side: const BorderSide(color: C.n500),
                      foregroundColor: C.text,
                    )
                  : null,
              onPressed: () async {
                await ref.read(setCompletionProvider)(habit, done: !done);
                if (context.mounted)
                  showToast(
                    context,
                    '${done ? '\u2212' : '+'}${habit.points} points',
                  );
              },
              child: Text(done ? 'Undo today' : 'Mark today as done'),
            ),
          ),
        ],
      ),
    );
  }
}

class _WeekStrip extends StatelessWidget {
  const _WeekStrip({required this.days});
  final List<DayStatus> days;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      for (var i = 0; i < days.length; i++)
        Expanded(
          child: Column(
            children: [
              Text(
                DateFormat('E').format(days[i].date)[0],
                style: body(
                  11,
                  w: FontWeight.w500,
                  color: i == 6 ? C.accent700 : C.n700,
                ).copyWith(letterSpacing: 1),
              ),
              const SizedBox(height: 8),
              Container(
                width: 38,
                height: 52,
                decoration: BoxDecoration(
                  color: days[i].done ? C.accent100 : null,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: days[i].done ? C.accent : const Color(0xFFBAB6B6),
                  ),
                  boxShadow: i == 6
                      ? const [
                          BoxShadow(color: C.bg, spreadRadius: 3),
                          BoxShadow(
                            color: Color(0xFFE1AD66),
                            spreadRadius: 4,
                            blurRadius: 0,
                          ),
                        ]
                      : null,
                ),
                child: days[i].done
                    ? const Icon(Icons.check, size: 16, color: C.accent700)
                    : null,
              ),
              const SizedBox(height: 8),
              Text('${days[i].date.day}', style: body(12, color: C.n700)),
            ],
          ),
        ),
    ],
  );
}

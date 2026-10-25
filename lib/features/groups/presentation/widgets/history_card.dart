import 'package:flutter/material.dart';
import 'package:habit_tracker/core/theme/app_tokens.dart';
import 'package:habit_tracker/features/groups/domain/entities/history_breakdown.dart';
import 'package:habit_tracker/features/groups/presentation/widgets/date_field.dart';

/// Weekly and monthly history of one person's own completions. Every row says
/// "4 of 5" in words as well as showing a bar, so it never relies on the bar.
class HistoryCard extends StatefulWidget {
  const HistoryCard({required this.history, super.key});

  final HistoryBreakdown history;

  @override
  State<HistoryCard> createState() => _HistoryCardState();
}

class _HistoryCardState extends State<HistoryCard> {
  bool _weekly = true;

  static const List<String> _monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  String _label(PeriodCount period) {
    if (!_weekly) {
      return '${_monthNames[period.start.month - 1]} ${period.start.year}';
    }
    return 'Week of ${DateField.format(period.start)}';
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final history = widget.history;
    if (history.isEmpty) {
      return Text(
        'History appears after the first scheduled day.',
        style: tokens.text.body.copyWith(color: tokens.inkMuted),
      );
    }
    // Newest first reads better in a list.
    final periods = (_weekly ? history.weeks : history.months).reversed
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: tokens.space.s8,
          children: [
            ChoiceChip(
              label: const Text('Weekly'),
              selected: _weekly,
              onSelected: (_) => setState(() => _weekly = true),
            ),
            ChoiceChip(
              label: const Text('Monthly'),
              selected: !_weekly,
              onSelected: (_) => setState(() => _weekly = false),
            ),
          ],
        ),
        SizedBox(height: tokens.space.s8),
        for (final period in periods)
          _Row(
            key: ValueKey('${_weekly}_${period.start}'),
            label: _label(period),
            period: period,
          ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.period, super.key});

  final String label;
  final PeriodCount period;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final summary = period.scheduled == 0
        ? 'nothing scheduled yet'
        : '${period.done} of ${period.scheduled} (${period.percent}%)';
    return Semantics(
      label: '$label: $summary',
      child: ExcludeSemantics(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: tokens.space.s8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text(label, style: tokens.text.bodySmall)),
                  Text(summary, style: tokens.text.bodySmall),
                ],
              ),
              SizedBox(height: tokens.space.s4),
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: period.scheduled == 0
                      ? 0
                      : period.done / period.scheduled,
                  minHeight: 4,
                  color: tokens.accent,
                  backgroundColor: tokens.track,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:habit_tracker/core/theme/app_tokens.dart';
import 'package:habit_tracker/core/time/date_key.dart';

/// A tappable field that opens the date picker. Shows "None" for an optional
/// date that is not set, with a Clear button.
class DateField extends StatelessWidget {
  const DateField({
    required this.label,
    required this.value,
    required this.firstDate,
    required this.lastDate,
    required this.onChanged,
    this.optional = false,
    super.key,
  });

  final String label;
  final DateKey? value;
  final DateKey firstDate;
  final DateKey lastDate;
  final ValueChanged<DateKey?> onChanged;

  /// An optional date can be cleared.
  final bool optional;

  static const List<String> _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  static String format(DateKey date) =>
      '${date.day} ${_months[date.month - 1]} ${date.year}';

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final text = value == null ? 'None' : format(value!);
    return Semantics(
      button: true,
      label: '$label, $text',
      child: ExcludeSemantics(
        child: InkWell(
          onTap: () async {
            final initial = value ?? firstDate;
            final picked = await showDatePicker(
              context: context,
              initialDate: initial.toDateTime(),
              firstDate: firstDate.toDateTime(),
              lastDate: lastDate.toDateTime(),
            );
            if (picked != null) onChanged(DateKey.fromDateTime(picked));
          },
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 56),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        label,
                        style: tokens.text.bodySmall.copyWith(
                          color: tokens.inkMuted,
                        ),
                      ),
                      Text(text, style: tokens.text.rowTitle),
                    ],
                  ),
                ),
                if (optional && value != null)
                  TextButton(
                    onPressed: () => onChanged(null),
                    child: const Text('Clear'),
                  ),
                const Icon(Icons.calendar_today_outlined, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

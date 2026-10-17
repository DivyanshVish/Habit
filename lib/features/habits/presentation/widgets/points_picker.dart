import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:habit_tracker/core/theme/app_motion.dart';
import 'package:habit_tracker/core/theme/app_tokens.dart';
import 'package:habit_tracker/features/habits/domain/usecases/add_habit.dart';

/// Points input: a numeric field with a stepper and a segmented row of quick
/// picks.
class PointsPicker extends StatelessWidget {
  const PointsPicker({
    required this.controller,
    required this.enabled,
    this.onSubmitted,
    super.key,
  });

  static const List<int> quickPicks = [5, 10, 15, 20, 25];
  static const int _fallback = 10;

  final TextEditingController controller;
  final bool enabled;
  final VoidCallback? onSubmitted;

  int get _current => int.tryParse(controller.text.trim()) ?? _fallback;

  void _step(int delta) {
    final next = (_current + delta).clamp(
      HabitRules.minPoints,
      HabitRules.maxPoints,
    );
    controller.text = '$next';
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              tooltip: 'Decrease points',
              onPressed: enabled ? () => _step(-1) : null,
              icon: const Icon(Icons.remove),
            ),
            Expanded(
              child: TextFormField(
                key: const Key('points-field'),
                controller: controller,
                enabled: enabled,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                textAlign: TextAlign.center,
                style: tokens.text.numeral.copyWith(fontSize: 32, height: 1.1),
                decoration: const InputDecoration(
                  labelText: 'Points',
                  floatingLabelAlignment: FloatingLabelAlignment.center,
                ),
                validator: (value) {
                  final points = int.tryParse((value ?? '').trim());
                  if (points == null) return 'Enter a number of points';
                  if (points < HabitRules.minPoints ||
                      points > HabitRules.maxPoints) {
                    return 'Use ${HabitRules.minPoints} to ${HabitRules.maxPoints}';
                  }
                  return null;
                },
                onFieldSubmitted: (_) => onSubmitted?.call(),
              ),
            ),
            IconButton(
              tooltip: 'Increase points',
              onPressed: enabled ? () => _step(1) : null,
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        SizedBox(height: tokens.space.s12),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (context, value, _) {
            final selected = int.tryParse(value.text.trim());
            return DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: tokens.outline),
                borderRadius: BorderRadius.circular(tokens.radii.control),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(tokens.radii.control - 1),
                child: Row(
                  children: [
                    for (final n in quickPicks)
                      Expanded(
                        child: _QuickPick(
                          points: n,
                          selected: selected == n,
                          enabled: enabled,
                          onPressed: () {
                            unawaited(HapticFeedback.selectionClick());
                            controller.text = '$n';
                          },
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
        SizedBox(height: tokens.space.s8),
        Text(
          '${HabitRules.minPoints} to ${HabitRules.maxPoints} points',
          style: tokens.text.bodySmall.copyWith(color: tokens.inkMuted),
        ),
      ],
    );
  }
}

class _QuickPick extends StatelessWidget {
  const _QuickPick({
    required this.points,
    required this.selected,
    required this.enabled,
    required this.onPressed,
  });

  final int points;
  final bool selected;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final duration = AppMotion.of(context, AppMotion.fast);
    return Semantics(
      button: true,
      selected: selected,
      enabled: enabled,
      label: '$points points',
      child: ExcludeSemantics(
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            key: Key('points-chip-$points'),
            onTap: enabled ? onPressed : null,
            child: AnimatedContainer(
              duration: duration,
              curve: AppMotion.standard,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? tokens.accentTint : Colors.transparent,
                border: Border(
                  bottom: BorderSide(
                    color: selected ? tokens.accent : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: AnimatedDefaultTextStyle(
                  duration: duration,
                  style: tokens.text.numeral.copyWith(
                    fontSize: 20,
                    color: selected ? tokens.accentInk : tokens.ink,
                  ),
                  child: Text('$points'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

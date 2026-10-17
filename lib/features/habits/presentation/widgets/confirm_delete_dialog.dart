import 'package:flutter/material.dart';
import 'package:habit_tracker/core/theme/app_motion.dart';
import 'package:habit_tracker/core/theme/app_tokens.dart';

/// Asks the user to confirm deleting [habitName]. Resolves to true on confirm.
Future<bool> confirmDeleteHabit(BuildContext context, String habitName) async {
  final confirmed = await showDialog<bool>(
    context: context,
    animationStyle: reduceMotion(context) ? AnimationStyle.noAnimation : null,
    builder: (context) {
      final tokens = context.tokens;
      return AlertDialog(
        title: const Text('Delete habit?'),
        content: Text(
          '"$habitName" and its history will be removed. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(88, 48),
              foregroundColor: tokens.danger,
              side: BorderSide(color: tokens.danger, width: 1.5),
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      );
    },
  );
  return confirmed ?? false;
}

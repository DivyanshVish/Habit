import 'package:habit_tracker/core/platform/platform_services.dart';
import 'package:habit_tracker/core/time/date_key.dart';
import 'package:habit_tracker/features/shared_habits/domain/linked_toggle.dart';

class CallableLinkedCompletionSync implements LinkedCompletionSync {
  CallableLinkedCompletionSync(this._callable);

  final CallableClient _callable;

  @override
  Future<void> mirror({
    required String habitId,
    required DateKey dateKey,
    required bool done,
  }) async {
    try {
      await _callable.call('mirrorPersonalCompletion', {
        'habitId': habitId,
        'dateKey': dateKey.value,
        'done': done,
      });
    } on Exception {
      // Best effort. The personal completion is already saved.
    }
  }
}

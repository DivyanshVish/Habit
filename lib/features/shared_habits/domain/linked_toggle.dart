import 'dart:async';

import 'package:fpdart/fpdart.dart';
import 'package:habit_tracker/core/error/failure.dart';
import 'package:habit_tracker/core/time/date_key.dart';
import 'package:habit_tracker/features/habits/domain/usecases/toggle_habit_completion.dart';

/// Tells the server that a personal habit was ticked, so a linked shared habit
/// can count it too. Must never throw.
abstract interface class LinkedCompletionSync {
  Future<void> mirror({
    required String habitId,
    required DateKey dateKey,
    required bool done,
  });
}

/// The normal toggle, plus a best-effort notice to the server afterwards.
///
/// The personal completion is saved first and is what the user sees; the
/// mirror runs in the background and can fail (offline, habit not shared)
/// without any effect on it. Habits that are not shared are a no-op on the
/// server.
class LinkedToggleHabitCompletion extends ToggleHabitCompletion {
  LinkedToggleHabitCompletion(super.repository, this._sync);

  final LinkedCompletionSync _sync;

  @override
  Future<Either<Failure, Unit>> call(ToggleHabitCompletionParams params) async {
    final result = await super.call(params);
    if (result.isRight()) {
      unawaited(
        _sync
            .mirror(
              habitId: params.habitId,
              dateKey: params.dateKey,
              done: params.done,
            )
            .catchError((Object _) {}),
      );
    }
    return result;
  }
}

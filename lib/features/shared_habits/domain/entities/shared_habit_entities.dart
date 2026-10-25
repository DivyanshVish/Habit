import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:habit_tracker/core/time/date_key.dart';
import 'package:habit_tracker/features/groups/domain/entities/cycle_snapshot.dart';
import 'package:habit_tracker/features/groups/domain/entities/history_breakdown.dart';
import 'package:habit_tracker/features/groups/domain/entities/streak_stats.dart';

part 'shared_habit_entities.freezed.dart';

@freezed
abstract class SharedHabit with _$SharedHabit {
  const factory SharedHabit({
    required String id,
    required String name,
    required String description,
    required int points,
    required String ownerUid,
    required Set<int> weekdays,
    required DateKey startDate,
    required int participantCount,
    required bool archived,
  }) = _SharedHabit;
}

@freezed
abstract class SharedParticipant with _$SharedParticipant {
  const factory SharedParticipant({
    required String uid,
    required String displayName,
    required bool active,
  }) = _SharedParticipant;
}

/// Input for sharing a habit. [sourceHabitId] links an existing personal habit;
/// the original is left untouched.
@freezed
abstract class NewSharedHabit with _$NewSharedHabit {
  const factory NewSharedHabit({
    required String name,
    required String description,
    required int points,
    required Set<int> weekdays,
    required DateKey startDate,
    String? sourceHabitId,
  }) = _NewSharedHabit;
}

/// Everything the shared habit screen shows for one day.
@freezed
abstract class SharedHabitDetail with _$SharedHabitDetail {
  const factory SharedHabitDetail({
    required SharedHabit habit,
    required List<SharedParticipant> participants,
    required DateKey today,

    /// Null until the day's cycle is opened.
    required CycleSnapshot? cycle,
    required bool doneToday,
    required bool pendingSync,
    required StreakStats personalStats,
    required HistoryBreakdown history,
  }) = _SharedHabitDetail;
}

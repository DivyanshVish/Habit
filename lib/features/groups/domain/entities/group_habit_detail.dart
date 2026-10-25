import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:habit_tracker/core/time/date_key.dart';
import 'package:habit_tracker/features/groups/domain/entities/cycle_snapshot.dart';
import 'package:habit_tracker/features/groups/domain/entities/group_entities.dart';
import 'package:habit_tracker/features/groups/domain/entities/history_breakdown.dart';
import 'package:habit_tracker/features/groups/domain/entities/streak_stats.dart';

part 'group_habit_detail.freezed.dart';

/// Everything the Group Habit screen shows for one day.
@freezed
abstract class GroupHabitDetail with _$GroupHabitDetail {
  const GroupHabitDetail._();

  const factory GroupHabitDetail({
    required GroupHabit habit,
    required DateKey today,

    /// Null when no cycle is open for [today] (not scheduled, or not opened
    /// yet). The member can still tick the habit; it just does not count.
    required CycleSnapshot? cycle,
    required bool doneToday,

    /// True while a completion is waiting for the server (offline).
    required bool pendingSync,
    required StreakStats personalStats,

    /// Weekly and monthly counts of this person's own completions.
    required HistoryBreakdown history,
  }) = _GroupHabitDetail;

  /// Whether this member's completion counts toward today's group target.
  /// A member who joined after the day opened is not in the snapshot.
  bool isEligible(String uid) => cycle?.eligibleUids.contains(uid) ?? false;
}

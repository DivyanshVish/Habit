import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:habit_tracker/core/time/date_key.dart';
import 'package:habit_tracker/features/groups/domain/entities/completion_rule.dart';
import 'package:habit_tracker/features/groups/domain/entities/cycle_progress.dart';
import 'package:habit_tracker/features/groups/domain/services/completion_engine.dart';

part 'cycle_snapshot.freezed.dart';

/// What the server keeps for one habit on one day: who was eligible when the
/// day opened, how many of them completed, and whether the target was met.
///
/// Only members who share their activity appear in [visibleCompletedUids];
/// the counts always include everyone.
@freezed
abstract class CycleSnapshot with _$CycleSnapshot {
  const CycleSnapshot._();

  const factory CycleSnapshot({
    required DateKey dateKey,
    required List<String> eligibleUids,
    required List<String> visibleCompletedUids,
    required int completedCount,
    required CompletionRule rule,
    required bool closed,
  }) = _CycleSnapshot;

  int get eligibleCount => eligibleUids.length;

  /// Always recomputed from the counts with the same engine the server uses,
  /// so the screen never shows a number the rules would disagree with.
  CycleProgress get progress => const CompletionEngine().compute(
    rule: rule,
    eligible: eligibleCount,
    completed: completedCount,
  );

  /// Eligible members who have not completed and are not hidden.
  /// Hidden members cannot be told apart from pending ones by design.
  int get pendingCount => eligibleCount - completedCount;
}

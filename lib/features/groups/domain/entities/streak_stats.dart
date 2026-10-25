/// Long-history streak numbers for one habit and one person (or one group).
final class StreakStats {
  const StreakStats({
    required this.currentStreak,
    required this.bestStreak,
    required this.completed,
    required this.missed,
  });

  static const StreakStats empty = StreakStats(
    currentStreak: 0,
    bestStreak: 0,
    completed: 0,
    missed: 0,
  );

  /// Consecutive scheduled cycles done, ending today (or yesterday while
  /// today is still open).
  final int currentStreak;

  final int bestStreak;

  /// Scheduled cycles that were completed.
  final int completed;

  /// Scheduled cycles that have passed without a completion. A cycle that is
  /// still open today is not counted as missed.
  final int missed;

  /// Whole percent of finished scheduled cycles that were completed.
  int get completionRate {
    final total = completed + missed;
    return total == 0 ? 0 : (completed * 100) ~/ total;
  }

  @override
  bool operator ==(Object other) =>
      other is StreakStats &&
      other.currentStreak == currentStreak &&
      other.bestStreak == bestStreak &&
      other.completed == completed &&
      other.missed == missed;

  @override
  int get hashCode => Object.hash(currentStreak, bestStreak, completed, missed);

  @override
  String toString() =>
      'StreakStats(current: $currentStreak, best: $bestStreak, '
      'completed: $completed, missed: $missed)';
}

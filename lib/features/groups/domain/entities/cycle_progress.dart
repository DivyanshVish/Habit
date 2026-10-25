/// How far a group (or a shared habit) is toward its target for one cycle.
final class CycleProgress {
  const CycleProgress({
    required this.hasTarget,
    required this.required,
    required this.remaining,
    required this.percent,
    required this.reached,
  });

  /// False for the individual rule, which has no shared target.
  final bool hasTarget;

  /// Completions needed to reach the target.
  final int required;

  /// Completions still needed. Zero once the target is reached.
  final int remaining;

  /// Whole percent of eligible members who completed, rounded down.
  final int percent;

  final bool reached;

  @override
  bool operator ==(Object other) =>
      other is CycleProgress &&
      other.hasTarget == hasTarget &&
      other.required == required &&
      other.remaining == remaining &&
      other.percent == percent &&
      other.reached == reached;

  @override
  int get hashCode =>
      Object.hash(hasTarget, required, remaining, percent, reached);

  @override
  String toString() =>
      'CycleProgress(hasTarget: $hasTarget, required: $required, '
      'remaining: $remaining, percent: $percent, reached: $reached)';
}

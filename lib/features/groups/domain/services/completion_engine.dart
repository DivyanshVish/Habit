import 'dart:math' as math;

import 'package:habit_tracker/features/groups/domain/entities/completion_rule.dart';
import 'package:habit_tracker/features/groups/domain/entities/cycle_progress.dart';

/// Pure logic that turns a rule and two counts into a [CycleProgress].
///
/// Mirrors `functions/src/engine.ts`. Both are tested against
/// `test/fixtures/completion_engine_cases.json`.
class CompletionEngine {
  const CompletionEngine();

  CycleProgress compute({
    required CompletionRule rule,
    required int eligible,
    required int completed,
  }) {
    final n = math.max(0, eligible);
    final done = math.max(0, completed);
    final percent = n == 0 ? 0 : math.min(100, (done * 100) ~/ n);

    if (rule.type == CompletionRuleType.individual) {
      return CycleProgress(
        hasTarget: false,
        required: 0,
        remaining: 0,
        percent: percent,
        reached: false,
      );
    }

    final required = n == 0 ? 0 : _requiredFor(rule, n);
    return CycleProgress(
      hasTarget: true,
      required: required,
      remaining: math.max(0, required - done),
      percent: percent,
      reached: n > 0 && done >= required,
    );
  }

  int _requiredFor(CompletionRule rule, int n) {
    switch (rule.type) {
      case CompletionRuleType.individual:
        return 0;
      case CompletionRuleType.majority:
        return n ~/ 2 + 1;
      case CompletionRuleType.unanimous:
        return n;
      case CompletionRuleType.fixed:
        return (rule.value ?? 1).clamp(1, n);
      case CompletionRuleType.percentage:
        final pct = (rule.value ?? 100).clamp(1, 100);
        return (n * pct + 99) ~/ 100;
    }
  }
}

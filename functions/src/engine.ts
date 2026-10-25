// Group completion engine. Mirrors
// lib/features/groups/domain/services/completion_engine.dart.
// Both are tested against test/fixtures/completion_engine_cases.json.

export type RuleType =
  | "individual"
  | "majority"
  | "unanimous"
  | "fixed"
  | "percentage";

export interface CompletionRule {
  type: RuleType;
  value?: number;
}

export interface CycleProgress {
  hasTarget: boolean;
  required: number;
  remaining: number;
  percent: number;
  reached: boolean;
}

function clamp(value: number, min: number, max: number): number {
  return Math.min(max, Math.max(min, value));
}

export function computeProgress(
  rule: CompletionRule,
  eligible: number,
  completed: number,
): CycleProgress {
  const n = Math.max(0, Math.trunc(eligible));
  const done = Math.max(0, Math.trunc(completed));
  const percent = n === 0 ? 0 : Math.min(100, Math.floor((done * 100) / n));

  if (rule.type === "individual") {
    return { hasTarget: false, required: 0, remaining: 0, percent, reached: false };
  }

  let required = 0;
  if (n > 0) {
    switch (rule.type) {
      case "majority":
        required = Math.floor(n / 2) + 1;
        break;
      case "unanimous":
        required = n;
        break;
      case "fixed":
        required = clamp(Math.trunc(rule.value ?? 1), 1, n);
        break;
      case "percentage": {
        const pct = clamp(Math.trunc(rule.value ?? 100), 1, 100);
        required = Math.floor((n * pct + 99) / 100);
        break;
      }
    }
  }

  return {
    hasTarget: true,
    required,
    remaining: Math.max(0, required - done),
    percent,
    reached: n > 0 && done >= required,
  };
}

/** Whether a rule's value is acceptable when a habit is created or edited. */
export function isValidRule(rule: CompletionRule): boolean {
  switch (rule.type) {
    case "individual":
    case "majority":
    case "unanimous":
      return true;
    case "fixed":
      return Number.isInteger(rule.value) && (rule.value as number) >= 1;
    case "percentage":
      return (
        Number.isInteger(rule.value) &&
        (rule.value as number) >= 1 &&
        (rule.value as number) <= 100
      );
    default:
      return false;
  }
}

/// How a group decides that its shared target was reached.
enum CompletionRuleType {
  /// Everyone is tracked on their own. There is no shared target.
  individual,

  /// More than half of the eligible members.
  majority,

  /// Every eligible member.
  unanimous,

  /// A fixed number of members.
  fixed,

  /// A percentage of the eligible members.
  percentage;

  /// The name stored in Firestore.
  String get wireName => name;

  static CompletionRuleType fromWireName(String value) =>
      CompletionRuleType.values.firstWhere(
        (type) => type.name == value,
        orElse: () => CompletionRuleType.individual,
      );
}

/// A rule plus its optional value (the count for fixed, the percent for
/// percentage).
final class CompletionRule {
  const CompletionRule(this.type, {this.value});

  const CompletionRule.individual() : this(CompletionRuleType.individual);

  const CompletionRule.majority() : this(CompletionRuleType.majority);

  const CompletionRule.unanimous() : this(CompletionRuleType.unanimous);

  const CompletionRule.fixed(int count)
    : this(CompletionRuleType.fixed, value: count);

  const CompletionRule.percentage(int percent)
    : this(CompletionRuleType.percentage, value: percent);

  final CompletionRuleType type;
  final int? value;

  /// Whether the value is acceptable when a habit is created or edited.
  bool get isValid {
    switch (type) {
      case CompletionRuleType.individual:
      case CompletionRuleType.majority:
      case CompletionRuleType.unanimous:
        return true;
      case CompletionRuleType.fixed:
        return value != null && value! >= 1;
      case CompletionRuleType.percentage:
        return value != null && value! >= 1 && value! <= 100;
    }
  }

  @override
  bool operator ==(Object other) =>
      other is CompletionRule && other.type == type && other.value == value;

  @override
  int get hashCode => Object.hash(type, value);

  @override
  String toString() => 'CompletionRule(${type.name}, $value)';
}

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/features/groups/domain/entities/completion_rule.dart';
import 'package:habit_tracker/features/groups/domain/entities/cycle_progress.dart';
import 'package:habit_tracker/features/groups/domain/services/completion_engine.dart';

CompletionRule _ruleFrom(Map<String, dynamic> json) {
  final type = CompletionRuleType.fromWireName(json['type'] as String);
  return CompletionRule(type, value: json['value'] as int?);
}

void main() {
  const engine = CompletionEngine();

  final fixtures =
      jsonDecode(
            File(
              'test/fixtures/completion_engine_cases.json',
            ).readAsStringSync(),
          )
          as Map<String, dynamic>;
  final cases = (fixtures['progress'] as List).cast<Map<String, dynamic>>();

  group('shared fixtures (same file as the TypeScript engine)', () {
    for (final c in cases) {
      test(c['name'] as String, () {
        final expected = c['expect'] as Map<String, dynamic>;
        final actual = engine.compute(
          rule: _ruleFrom(c['rule'] as Map<String, dynamic>),
          eligible: c['eligible'] as int,
          completed: c['completed'] as int,
        );
        expect(
          actual,
          CycleProgress(
            hasTarget: expected['hasTarget'] as bool,
            required: expected['required'] as int,
            remaining: expected['remaining'] as int,
            percent: expected['percent'] as int,
            reached: expected['reached'] as bool,
          ),
        );
      });
    }
  });

  group('CompletionRule.isValid', () {
    test('accepts rules without a value', () {
      expect(const CompletionRule.individual().isValid, isTrue);
      expect(const CompletionRule.majority().isValid, isTrue);
      expect(const CompletionRule.unanimous().isValid, isTrue);
    });

    test('fixed needs a count of at least 1', () {
      expect(const CompletionRule.fixed(1).isValid, isTrue);
      expect(const CompletionRule.fixed(0).isValid, isFalse);
      expect(const CompletionRule(CompletionRuleType.fixed).isValid, isFalse);
    });

    test('percentage needs 1 to 100', () {
      expect(const CompletionRule.percentage(80).isValid, isTrue);
      expect(const CompletionRule.percentage(0).isValid, isFalse);
      expect(const CompletionRule.percentage(101).isValid, isFalse);
    });
  });

  test('an unknown wire name falls back to individual', () {
    expect(
      CompletionRuleType.fromWireName('nonsense'),
      CompletionRuleType.individual,
    );
  });
}

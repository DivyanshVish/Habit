import 'package:flutter/material.dart';
import 'package:habit_tracker/core/theme/app_tokens.dart';
import 'package:habit_tracker/features/groups/domain/entities/completion_rule.dart';

/// Plain words for each completion rule.
String ruleLabel(CompletionRuleType type) => switch (type) {
  CompletionRuleType.individual => 'Just track each person',
  CompletionRuleType.majority => 'More than half',
  CompletionRuleType.unanimous => 'Everyone',
  CompletionRuleType.fixed => 'A set number of people',
  CompletionRuleType.percentage => 'A percentage of people',
};

/// One sentence describing a rule, for the habit screen.
String ruleSentence(CompletionRule rule) => switch (rule.type) {
  CompletionRuleType.individual => 'Each person on their own',
  CompletionRuleType.majority => 'More than half of the group',
  CompletionRuleType.unanimous => 'Everyone in the group',
  CompletionRuleType.fixed => '${rule.value} people',
  CompletionRuleType.percentage => '${rule.value}% of the group',
};

/// Picks how the group succeeds: a rule, plus a number for the two rules that
/// need one. Reports a new [CompletionRule] on every change.
class RuleEditor extends StatefulWidget {
  const RuleEditor({required this.initial, required this.onChanged, super.key});

  final CompletionRule initial;
  final ValueChanged<CompletionRule> onChanged;

  @override
  State<RuleEditor> createState() => _RuleEditorState();
}

class _RuleEditorState extends State<RuleEditor> {
  late CompletionRuleType _type = widget.initial.type;
  late final TextEditingController _value = TextEditingController(
    text: '${widget.initial.value ?? 80}',
  );

  @override
  void dispose() {
    _value.dispose();
    super.dispose();
  }

  bool get _needsValue =>
      _type == CompletionRuleType.fixed ||
      _type == CompletionRuleType.percentage;

  void _report() {
    final value = int.tryParse(_value.text.trim());
    widget.onChanged(
      _needsValue
          ? CompletionRule(_type, value: value ?? 0)
          : CompletionRule(_type),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<CompletionRuleType>(
          initialValue: _type,
          isExpanded: true,
          items: [
            for (final type in CompletionRuleType.values)
              DropdownMenuItem(value: type, child: Text(ruleLabel(type))),
          ],
          onChanged: (value) {
            setState(() => _type = value ?? CompletionRuleType.majority);
            _report();
          },
        ),
        if (_needsValue)
          TextField(
            controller: _value,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: _type == CompletionRuleType.fixed
                  ? 'Number of people'
                  : 'Percent of people (1 to 100)',
            ),
            onChanged: (_) => _report(),
          ),
        SizedBox(height: tokens.space.s8),
      ],
    );
  }
}

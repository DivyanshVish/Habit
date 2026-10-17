import 'package:flutter/material.dart';
import 'package:habit_tracker/core/theme/app_tokens.dart';

/// A 1dp divider in the hairline colour.
class Hairline extends StatelessWidget {
  const Hairline({super.key});

  @override
  Widget build(BuildContext context) =>
      Divider(height: 1, thickness: 1, color: context.tokens.hairline);
}

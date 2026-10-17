import 'package:flutter/material.dart';

import '../../core/theme.dart';

/// Circular tap target; outlined in gold, tinted (never solid) when done.
class CheckToggle extends StatelessWidget {
  const CheckToggle({super.key, required this.done, required this.onTap});
  final bool done;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    checked: done,
    label: done ? 'Mark not done' : 'Mark done',
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(5), // 44pt hit area
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: done ? C.accent100 : Colors.transparent,
            border: Border.all(color: done ? C.accent : C.n500),
          ),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: done ? 1 : 0,
            child: const Icon(Icons.check, size: 18, color: C.accent700),
          ),
        ),
      ),
    ),
  );
}

class Hairline extends StatelessWidget {
  const Hairline({super.key});
  @override
  Widget build(BuildContext context) =>
      const Divider(height: 1, thickness: 1, color: C.divider);
}

/// Bottom-docked action bar with a hairline above it.
class BottomAction extends StatelessWidget {
  const BottomAction({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const BoxDecoration(
      color: C.bg,
      border: Border(top: BorderSide(color: C.divider)),
    ),
    child: SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(26, 16, 26, 12),
        child: child,
      ),
    ),
  );
}

void showToast(BuildContext context, String message) {
  final m = ScaffoldMessenger.of(context);
  m.hideCurrentSnackBar();
  m.showSnackBar(
    SnackBar(
      content: Center(heightFactor: 1, child: Text(message)),
      duration: const Duration(milliseconds: 1400),
      width: 190,
    ),
  );
}

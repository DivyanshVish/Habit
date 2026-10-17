import 'package:flutter/widgets.dart';

/// Calls [onResumed] whenever the app returns to the foreground.
class ResumeObserver extends StatefulWidget {
  const ResumeObserver({
    required this.onResumed,
    required this.child,
    super.key,
  });

  final VoidCallback onResumed;
  final Widget child;

  @override
  State<ResumeObserver> createState() => _ResumeObserverState();
}

class _ResumeObserverState extends State<ResumeObserver>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) widget.onResumed();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

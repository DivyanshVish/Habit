import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:habit_tracker/bootstrap_exception.dart';
import 'package:habit_tracker/core/brand.dart';
import 'package:habit_tracker/core/router/app_router.dart';
import 'package:habit_tracker/core/theme/app_motion.dart';
import 'package:habit_tracker/core/theme/app_theme.dart';
import 'package:habit_tracker/features/habits/presentation/widgets/splash_view.dart';
import 'package:habit_tracker/features/habits/presentation/widgets/state_views.dart';

enum _Phase { loading, ready, failed }

/// Runs [bootstrap] and shows the splash, a retry screen, or the app.
///
/// The splash stays up for at least [AppMotion.splash] on the first launch so
/// its intro is not cut off. Reduced motion, a failure and a retry never wait.
class BootstrapGate extends StatefulWidget {
  const BootstrapGate({required this.bootstrap, super.key});

  final Future<void> Function() bootstrap;

  @override
  State<BootstrapGate> createState() => _BootstrapGateState();
}

class _BootstrapGateState extends State<BootstrapGate> {
  _Phase _phase = _Phase.loading;
  Object? _error;
  int _attempt = 0;
  bool _minElapsed = false;
  bool _minStarted = false;
  Timer? _minTimer;
  GoRouter? _router;

  @override
  void initState() {
    super.initState();
    _run();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_minStarted) return;
    _minStarted = true;
    if (_reduceMotion(context)) {
      _minElapsed = true;
    } else {
      _minTimer = Timer(AppMotion.splash, () {
        if (mounted) setState(() => _minElapsed = true);
      });
    }
  }

  void _run() {
    final attempt = ++_attempt;
    Future<void>.sync(widget.bootstrap).then<void>(
      (_) {
        if (mounted && attempt == _attempt) {
          setState(() => _phase = _Phase.ready);
        }
      },
      onError: (Object error) {
        if (mounted && attempt == _attempt) {
          setState(() {
            _phase = _Phase.failed;
            _error = error;
          });
        }
      },
    );
  }

  void _retry() {
    _minTimer?.cancel();
    setState(() {
      _minElapsed = true;
      _phase = _Phase.loading;
      _error = null;
    });
    _run();
  }

  @override
  void dispose() {
    _minTimer?.cancel();
    _router?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Widget child;
    switch (_phase) {
      case _Phase.failed:
        child = _BootstrapShell(
          key: const ValueKey('error'),
          child: SafeArea(
            child: ErrorView(
              title: "Can't connect",
              kicker: 'OFFLINE',
              message: _describe(_error),
              actionLabel: 'Retry',
              icon: Icons.cloud_off_outlined,
              onRetry: _retry,
            ),
          ),
        );
      case _Phase.ready when _minElapsed:
        child = HabitTrackerApp(
          key: const ValueKey('app'),
          router: _router ??= createRouter(),
        );
      case _Phase.ready:
      case _Phase.loading:
        child = const _BootstrapShell(
          key: ValueKey('splash'),
          child: SplashView(),
        );
    }
    return AnimatedSwitcher(
      duration: _reduceMotion(context) ? Duration.zero : AppMotion.base,
      // This switcher sits above the MaterialApp, so there is no ambient
      // Directionality yet. A Stack needs one to resolve its alignment, which
      // is what threw "No Directionality widget found" on launch.
      layoutBuilder: (current, previous) => Stack(
        textDirection: TextDirection.ltr,
        fit: StackFit.expand,
        children: [...previous, ?current],
      ),
      child: child,
    );
  }

  String _describe(Object? error) {
    if (error is BootstrapException) return error.message;
    if (error is UnsupportedError && error.message != null) {
      return error.message!;
    }
    return 'Could not start the app. Check your connection and try again.';
  }
}

class HabitTrackerApp extends StatelessWidget {
  const HabitTrackerApp({required this.router, super.key});

  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: appName,
      theme: AppTheme.light(),
      themeMode: ThemeMode.light,
      builder: _withSystemBars,
      routerConfig: router,
    );
  }
}

class _BootstrapShell extends StatelessWidget {
  const _BootstrapShell({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appName,
      theme: AppTheme.light(),
      themeMode: ThemeMode.light,
      builder: _withSystemBars,
      home: Scaffold(body: child),
    );
  }
}

/// True when the user asked the system to reduce motion. The gate sits above
/// the MaterialApp, so without a MediaQuery it asks the platform directly.
bool _reduceMotion(BuildContext context) {
  final media = MediaQuery.maybeOf(context);
  if (media != null) {
    return media.disableAnimations || media.accessibleNavigation;
  }
  final features = View.of(context).platformDispatcher.accessibilityFeatures;
  return features.disableAnimations || features.accessibleNavigation;
}

/// Makes the system bars transparent with dark icons.
Widget _withSystemBars(BuildContext context, Widget? child) {
  return AnnotatedRegion<SystemUiOverlayStyle>(
    value: AppTheme.overlayStyle(),
    child: child ?? const SizedBox.shrink(),
  );
}

import 'package:flutter/material.dart';
import 'package:habit_tracker/core/brand.dart';
import 'package:habit_tracker/core/theme/app_motion.dart';
import 'package:habit_tracker/core/theme/app_tokens.dart';
import 'package:habit_tracker/features/habits/presentation/widgets/brand_mark.dart';

/// Branded splash shown while the app starts.
///
/// The mark is centred on the screen exactly where the native launch screen
/// draws it, and never moves. The wordmark fades in below it. The intro runs
/// once; with reduced motion the final state shows immediately.
///
/// Fill the whole screen with this (no SafeArea), so the centre matches the
/// native splash.
class SplashView extends StatefulWidget {
  const SplashView({super.key});

  /// Gap between the bottom of the mark box and the wordmark.
  static const double wordmarkGap = 28;

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppMotion.splash,
  );
  late final Animation<double> _mark = CurvedAnimation(
    parent: _controller,
    curve: AppMotion.standard,
  );
  late final Animation<double> _wordmark = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.45, 1, curve: AppMotion.standard),
  );
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (reduceMotion(context)) {
      _controller.value = 1;
    } else if (!_started) {
      _started = true;
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final text = tokens.text;
    const markHeight =
        BrandMark.defaultWidth *
        BrandMarkPainter.boxHeight /
        BrandMarkPainter.boxWidth;
    return Semantics(
      label: appName,
      container: true,
      excludeSemantics: true,
      child: ColoredBox(
        color: tokens.paper,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final centerY = constraints.maxHeight / 2;
            return Stack(
              children: [
                Positioned(
                  left: 0,
                  right: 0,
                  top: centerY - markHeight / 2,
                  height: markHeight,
                  child: Center(
                    child: AnimatedBuilder(
                      animation: _mark,
                      builder: (context, _) => BrandMark(progress: _mark.value),
                    ),
                  ),
                ),
                Positioned(
                  left: tokens.space.screenMargin,
                  right: tokens.space.screenMargin,
                  top: centerY + markHeight / 2 + SplashView.wordmarkGap,
                  child: FadeTransition(
                    opacity: _wordmark,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            appName,
                            maxLines: 1,
                            style: text.displayTitle.copyWith(
                              fontSize: 30,
                              height: 1.1,
                              color: tokens.ink,
                            ),
                          ),
                        ),
                        SizedBox(height: tokens.space.s8),
                        Text('DAILY HABITS', style: text.kicker),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

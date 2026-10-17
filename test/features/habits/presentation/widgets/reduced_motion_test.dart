import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/core/theme/app_motion.dart';
import 'package:habit_tracker/core/time/date_key.dart';
import 'package:habit_tracker/features/habits/domain/entities/today_overview.dart';
import 'package:habit_tracker/features/habits/presentation/widgets/check_toggle.dart';
import 'package:habit_tracker/features/habits/presentation/widgets/confirm_delete_dialog.dart';
import 'package:habit_tracker/features/habits/presentation/widgets/progress_header.dart';

import '../../../../helpers/builders.dart';
import '../../../../helpers/pump_app.dart';

void main() {
  Future<(bool, Duration)> probe(
    WidgetTester tester, {
    bool disableAnimations = false,
    bool accessibleNavigation = false,
  }) async {
    late bool reduced;
    late Duration duration;
    await tester.pumpWidget(
      themedApp(
        disableAnimations: disableAnimations,
        accessibleNavigation: accessibleNavigation,
        Builder(
          builder: (context) {
            reduced = reduceMotion(context);
            duration = AppMotion.of(context, AppMotion.slow);
            return const SizedBox();
          },
        ),
      ),
    );
    return (reduced, duration);
  }

  testWidgets('motion runs normally by default', (tester) async {
    final (reduced, duration) = await probe(tester);
    expect(reduced, isFalse);
    expect(duration, AppMotion.slow);
  });

  testWidgets('disableAnimations reduces motion', (tester) async {
    final (reduced, duration) = await probe(tester, disableAnimations: true);
    expect(reduced, isTrue);
    expect(duration, Duration.zero);
  });

  testWidgets('accessibleNavigation reduces motion', (tester) async {
    final (reduced, duration) = await probe(tester, accessibleNavigation: true);
    expect(reduced, isTrue);
    expect(duration, Duration.zero);
  });

  group('with reduced motion', () {
    testWidgets('the check toggle flips in one frame', (tester) async {
      final done = ValueNotifier(false);
      addTearDown(done.dispose);
      await tester.pumpWidget(
        themedApp(
          disableAnimations: true,
          Scaffold(
            body: Center(
              child: ValueListenableBuilder<bool>(
                valueListenable: done,
                builder: (context, value, _) => CheckToggle(
                  done: value,
                  tooltip: 'toggle',
                  onPressed: () {},
                ),
              ),
            ),
          ),
        ),
      );

      done.value = true;
      await tester.pump();
      await tester.pump();

      expect(tester.hasRunningAnimations, isFalse);
      final container = tester.widget<AnimatedContainer>(
        find.byType(AnimatedContainer),
      );
      expect(container.duration, Duration.zero);
    });

    testWidgets('the progress bar jumps straight to its value', (tester) async {
      final overview = TodayOverview(
        date: const DateKey(2026, 10, 17),
        items: [
          buildItem(habit: buildHabit(id: 'a', points: 10), isDone: true),
          buildItem(habit: buildHabit(id: 'b', points: 30)),
        ],
      );
      await tester.pumpWidget(
        themedApp(
          disableAnimations: true,
          Scaffold(body: ProgressHeader(overview: overview)),
        ),
      );
      await tester.pump();

      final bar = tester.widget<FractionallySizedBox>(
        find.byKey(const Key('progress-bar')),
      );
      expect(bar.widthFactor, closeTo(0.25, 0.0001));
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('the delete dialog opens without an animation', (tester) async {
      await tester.pumpWidget(
        themedApp(
          disableAnimations: true,
          Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => confirmDeleteHabit(context, 'Read'),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pump();
      await tester.pump();

      expect(find.text('Delete habit?'), findsOneWidget);
      final fade = tester.widget<FadeTransition>(
        find
            .ancestor(
              of: find.byType(AlertDialog),
              matching: find.byType(FadeTransition),
            )
            .first,
      );
      expect(fade.opacity.value, 1);
    });

    testWidgets('the delete dialog does animate with motion enabled', (
      tester,
    ) async {
      await tester.pumpWidget(
        themedApp(
          Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => confirmDeleteHabit(context, 'Read'),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(tester.hasRunningAnimations, isTrue);
      await tester.pumpAndSettle();
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:habit_tracker/app.dart';
import 'package:habit_tracker/core/router/app_transitions.dart';
import 'package:habit_tracker/core/theme/app_tokens.dart';

/// Page transitions fade the old and new page together, so for a moment
/// neither is fully opaque. These tests make sure the page colour is painted
/// behind them, otherwise the window background flashes on every navigation.
void main() {
  GoRouter buildRouter() => GoRouter(
    routes: [
      GoRoute(
        path: '/',
        pageBuilder: (context, state) => buildAppPage(
          state: state,
          child: Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () => context.push('/next'),
                child: const Text('go'),
              ),
            ),
          ),
        ),
      ),
      GoRoute(
        path: '/next',
        pageBuilder: (context, state) => buildAppPage(
          state: state,
          child: const Scaffold(body: Center(child: Text('next page'))),
        ),
      ),
    ],
  );

  testWidgets('the paper colour sits behind the navigator', (tester) async {
    await tester.pumpWidget(HabitTrackerApp(router: buildRouter()));
    await tester.pumpAndSettle();

    final behindNavigator = find.ancestor(
      of: find.byType(Navigator),
      matching: find.byWidgetPredicate(
        (w) => w is ColoredBox && w.color == AppTokens.light.paper,
      ),
    );
    expect(behindNavigator, findsWidgets);
  });

  testWidgets('mid transition nothing but paper shows through', (tester) async {
    await tester.pumpWidget(HabitTrackerApp(router: buildRouter()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('go'));
    // Part way through the fade, both pages are partly transparent.
    await tester.pump(const Duration(milliseconds: 120));

    final behindNavigator = find.ancestor(
      of: find.byType(Navigator),
      matching: find.byWidgetPredicate(
        (w) => w is ColoredBox && w.color == AppTokens.light.paper,
      ),
    );
    expect(behindNavigator, findsWidgets);

    await tester.pumpAndSettle();
    expect(find.text('next page'), findsOneWidget);
  });
}

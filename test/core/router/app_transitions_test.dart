import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:habit_tracker/core/router/app_transitions.dart';
import 'package:habit_tracker/core/theme/app_theme.dart';

void main() {
  GoRouter buildRouter(AppTransitionKind kind) {
    return GoRouter(
      routes: [
        GoRoute(
          path: '/',
          pageBuilder: (context, state) => buildAppPage(
            state: state,
            child: Scaffold(
              body: TextButton(
                onPressed: () => context.push('/next'),
                child: const Text('open'),
              ),
            ),
          ),
        ),
        GoRoute(
          path: '/next',
          pageBuilder: (context, state) => buildAppPage(
            state: state,
            kind: kind,
            child: const Scaffold(body: Text('next page')),
          ),
        ),
      ],
    );
  }

  Widget app(GoRouter router, {bool disableAnimations = false}) {
    return MaterialApp.router(
      theme: AppTheme.light(),
      routerConfig: router,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(disableAnimations: disableAnimations),
        child: child!,
      ),
    );
  }

  Finder pageTransitions() => find.descendant(
    of: find.byType(Navigator),
    matching: find.byType(SlideTransition),
  );

  for (final kind in AppTransitionKind.values) {
    testWidgets('$kind slides and fades the incoming page', (tester) async {
      await tester.pumpWidget(app(buildRouter(kind)));
      await tester.tap(find.text('open'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(pageTransitions(), findsWidgets);
      expect(find.text('next page'), findsOneWidget);

      await tester.pumpAndSettle();
      expect(find.text('next page'), findsOneWidget);
    });

    testWidgets('$kind has no slide with reduced motion', (tester) async {
      await tester.pumpWidget(app(buildRouter(kind), disableAnimations: true));
      await tester.tap(find.text('open'));
      await tester.pump();
      await tester.pump();

      // Present after the first frame of the push, with nothing sliding.
      expect(find.text('next page'), findsOneWidget);
      final next = find.ancestor(
        of: find.text('next page'),
        matching: find.byType(SlideTransition),
      );
      expect(next, findsNothing);
      final fade = find.ancestor(
        of: find.text('next page'),
        matching: find.byType(FadeTransition),
      );
      for (final element in fade.evaluate()) {
        final opacity = (element.widget as FadeTransition).opacity.value;
        expect(opacity, 1);
      }
    });
  }

  testWidgets('going back returns to the first page', (tester) async {
    final router = buildRouter(AppTransitionKind.sharedAxis);
    await tester.pumpWidget(app(router));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    router.pop();
    await tester.pumpAndSettle();

    expect(find.text('open'), findsOneWidget);
  });
}

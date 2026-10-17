import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/core/theme/app_tokens.dart';
import 'package:habit_tracker/features/habits/presentation/widgets/state_views.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  group('LoadingView', () {
    for (final variant in LoadingVariant.values) {
      testWidgets('${variant.name} renders a skeleton labelled Loading', (
        tester,
      ) async {
        final semantics = tester.ensureSemantics();
        await tester.pumpWidget(
          themedApp(Scaffold(body: LoadingView(variant: variant))),
        );
        await tester.pumpAndSettle();

        expect(find.bySemanticsLabel('Loading'), findsOneWidget);
        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(tester.takeException(), isNull);
        semantics.dispose();
      });

      testWidgets('${variant.name} fits a small phone at 2.0x text', (
        tester,
      ) async {
        useSmallPhone(tester);
        await tester.pumpWidget(
          themedApp(
            textScale: 2,
            Scaffold(body: LoadingView(variant: variant)),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('does not animate forever', (tester) async {
      await tester.pumpWidget(themedApp(const Scaffold(body: LoadingView())));
      await tester.pumpAndSettle();

      expect(tester.hasRunningAnimations, isFalse);
    });
  });

  group('ErrorView', () {
    testWidgets('shows title and message and retries on tap', (tester) async {
      var retries = 0;
      await tester.pumpWidget(
        themedApp(
          Scaffold(
            body: ErrorView(
              message: 'No connection.',
              onRetry: () => retries++,
            ),
          ),
        ),
      );

      expect(find.text("Couldn't load"), findsOneWidget);
      expect(find.text('No connection.'), findsOneWidget);
      await tester.tap(find.text('Try again'));
      expect(retries, 1);
    });

    testWidgets('supports a custom title, action and icon', (tester) async {
      await tester.pumpWidget(
        themedApp(
          Scaffold(
            body: ErrorView(
              title: "Can't connect",
              message: 'Offline.',
              actionLabel: 'Retry',
              icon: Icons.cloud_off_outlined,
              onRetry: () {},
            ),
          ),
        ),
      );

      expect(find.text("Can't connect"), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
      expect(find.byIcon(Icons.cloud_off_outlined), findsOneWidget);
    });

    testWidgets('shows a kicker, a danger icon and an outlined retry', (
      tester,
    ) async {
      await tester.pumpWidget(
        themedApp(
          Scaffold(
            body: ErrorView(message: 'Oops.', onRetry: () {}),
          ),
        ),
      );

      expect(find.text('SOMETHING WENT WRONG'), findsOneWidget);
      expect(find.byType(OutlinedButton), findsOneWidget);
      expect(find.byType(FilledButton), findsNothing);
      final icon = tester.widget<Icon>(find.byIcon(Icons.error_outline));
      expect(icon.color, AppTokens.light.danger);
      expect(
        tester.getSize(find.byType(OutlinedButton)).height,
        greaterThanOrEqualTo(48),
      );
    });

    testWidgets('scrolls instead of overflowing with a long message', (
      tester,
    ) async {
      useSmallPhone(tester);
      await tester.pumpWidget(
        themedApp(
          textScale: 2,
          Scaffold(
            body: ErrorView(
              message: 'Very long message. ' * 30,
              onRetry: () {},
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });
  });

  group('EmptyView', () {
    testWidgets('shows the message in italic serif and no icon', (
      tester,
    ) async {
      await tester.pumpWidget(
        themedApp(
          const Scaffold(body: EmptyView(message: 'No habits yet. Begin.')),
        ),
      );

      expect(find.text('No habits yet. Begin.'), findsOneWidget);
      final style = tester
          .widget<Text>(find.text('No habits yet. Begin.'))
          .style;
      expect(style?.fontStyle, FontStyle.italic);
      expect(style?.fontFamily, AppTextTokens.headingFamily);
      expect(find.byType(Icon), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });
}

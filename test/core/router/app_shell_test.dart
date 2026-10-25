import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go_router/go_router.dart';
import 'package:habit_tracker/core/di/injection.dart';
import 'package:habit_tracker/core/error/failure.dart';
import 'package:habit_tracker/core/router/app_shell.dart';
import 'package:habit_tracker/core/theme/app_theme.dart';
import 'package:habit_tracker/features/notifications/domain/notifications_domain.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/pump_app.dart';

class MockInboxRepository extends Mock implements InboxRepository {}

/// A router with the real shell and a page per tab that just says where it is.
GoRouter _router({String initial = '/'}) => GoRouter(
  initialLocation: initial,
  routes: [
    ShellRoute(
      builder: (context, state, child) =>
          AppShell(location: state.uri.path, child: child),
      routes: [
        for (final tab in AppTab.values)
          GoRoute(
            path: tab.route,
            pageBuilder: (context, state) => NoTransitionPage<void>(
              key: state.pageKey,
              child: Center(child: Text('page ${tab.name}')),
            ),
          ),
      ],
    ),
    GoRoute(
      path: '/detail',
      builder: (context, state) => const Scaffold(body: Text('a detail page')),
    ),
  ],
);

Widget _app(GoRouter router, {double textScale = 1}) => MaterialApp.router(
  theme: AppTheme.light(),
  routerConfig: router,
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(
      context,
    ).copyWith(textScaler: TextScaler.linear(textScale)),
    child: child!,
  ),
);

void main() {
  tearDown(() async => getIt.reset());

  group('AppTab.forLocation', () {
    test('maps every tab and its sub pages', () {
      expect(AppTab.forLocation('/'), AppTab.home);
      expect(AppTab.forLocation('/shared'), AppTab.shared);
      expect(AppTab.forLocation('/groups'), AppTab.groups);
      expect(AppTab.forLocation('/inbox'), AppTab.inbox);
      expect(AppTab.forLocation('/profile'), AppTab.profile);
    });

    test('a page opened from a tab is not a tab', () {
      expect(AppTab.forLocation('/groups/g1'), AppTab.groups);
      expect(AppTab.forLocation('/habits/h1'), isNull);
      expect(AppTab.forLocation('/join'), isNull);
    });

    test('Home is only the root, never a prefix of everything', () {
      expect(AppTab.forLocation('/shared/s1'), AppTab.shared);
      expect(AppTab.forLocation('/unknown'), isNull);
    });
  });

  group('AppShell', () {
    testWidgets('shows five tabs with words, not just icons', (tester) async {
      await tester.pumpWidget(_app(_router()));
      await tester.pumpAndSettle();

      for (final label in ['Home', 'Shared', 'Groups', 'Inbox', 'Profile']) {
        expect(find.text(label), findsOneWidget);
      }
      expect(find.text('page home'), findsOneWidget);
    });

    testWidgets('tapping a tab opens it and keeps the bar', (tester) async {
      await tester.pumpWidget(_app(_router()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Groups'));
      await tester.pumpAndSettle();
      expect(find.text('page groups'), findsOneWidget);
      expect(find.byType(NavigationBar), findsOneWidget);

      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();
      expect(find.text('page profile'), findsOneWidget);
      expect(find.text('page groups'), findsNothing);
    });

    testWidgets('the current tab is marked selected', (tester) async {
      await tester.pumpWidget(_app(_router(initial: '/inbox')));
      await tester.pumpAndSettle();

      final bar = tester.widget<NavigationBar>(find.byType(NavigationBar));
      expect(bar.selectedIndex, AppTab.values.indexOf(AppTab.inbox));
    });

    testWidgets('switching tabs does not animate (no flash)', (tester) async {
      await tester.pumpWidget(_app(_router()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Shared'));
      await tester.pump(); // one frame

      expect(find.text('page shared'), findsOneWidget);
      expect(find.text('page home'), findsNothing);
    });

    testWidgets('a page opened over the bar covers it', (tester) async {
      final router = _router();
      await tester.pumpWidget(_app(router));
      await tester.pumpAndSettle();

      unawaited(router.push('/detail'));
      await tester.pumpAndSettle();

      expect(find.text('a detail page'), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);

      router.pop();
      await tester.pumpAndSettle();
      expect(find.byType(NavigationBar), findsOneWidget);
    });

    testWidgets('without an inbox registered there is simply no badge', (
      tester,
    ) async {
      await tester.pumpWidget(_app(_router()));
      await tester.pumpAndSettle();

      expect(find.byType(Badge), findsNothing);
    });

    testWidgets('unread notifications show a count on Inbox', (tester) async {
      final repository = MockInboxRepository();
      when(
        () => repository.watchUnreadCount(),
      ).thenAnswer((_) => Stream.value(right(3)));
      getIt.registerSingleton<WatchUnreadCount>(WatchUnreadCount(repository));
      await tester.pumpWidget(_app(_router()));
      await tester.pumpAndSettle();

      expect(find.text('3'), findsOneWidget);
      expect(find.byType(Badge), findsOneWidget);
    });

    testWidgets('a large count reads 99+', (tester) async {
      final repository = MockInboxRepository();
      when(
        () => repository.watchUnreadCount(),
      ).thenAnswer((_) => Stream.value(right(100)));
      getIt.registerSingleton<WatchUnreadCount>(WatchUnreadCount(repository));
      await tester.pumpWidget(_app(_router()));
      await tester.pumpAndSettle();

      expect(find.text('99+'), findsOneWidget);
    });

    testWidgets('no unread means no badge', (tester) async {
      final repository = MockInboxRepository();
      when(
        () => repository.watchUnreadCount(),
      ).thenAnswer((_) => Stream.value(right(0)));
      getIt.registerSingleton<WatchUnreadCount>(WatchUnreadCount(repository));
      await tester.pumpWidget(_app(_router()));
      await tester.pumpAndSettle();

      expect(find.byType(Badge), findsNothing);
    });

    testWidgets('a failing unread count never breaks the bar', (tester) async {
      final repository = MockInboxRepository();
      when(
        () => repository.watchUnreadCount(),
      ).thenAnswer((_) => Stream.value(left(const Failure.network())));
      getIt.registerSingleton<WatchUnreadCount>(WatchUnreadCount(repository));
      await tester.pumpWidget(_app(_router()));
      await tester.pumpAndSettle();

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(Badge), findsNothing);
    });

    testWidgets('the Inbox tab announces how many are unread', (tester) async {
      final handle = tester.ensureSemantics();
      final repository = MockInboxRepository();
      when(
        () => repository.watchUnreadCount(),
      ).thenAnswer((_) => Stream.value(right(2)));
      getIt.registerSingleton<WatchUnreadCount>(WatchUnreadCount(repository));
      await tester.pumpWidget(_app(_router()));
      await tester.pumpAndSettle();

      expect(find.byTooltip('Inbox, 2 unread'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('does not overflow at 2x text on a small phone', (
      tester,
    ) async {
      useSmallPhone(tester);
      await tester.pumpWidget(_app(_router(), textScale: 2));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}

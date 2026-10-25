import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go_router/go_router.dart';
import 'package:habit_tracker/core/di/injection.dart';
import 'package:habit_tracker/core/error/failure.dart';
import 'package:habit_tracker/core/theme/app_theme.dart';
import 'package:habit_tracker/features/notifications/domain/notifications_domain.dart';
import 'package:habit_tracker/features/notifications/presentation/inbox_page.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/pump_app.dart';

class MockInboxRepository extends Mock implements InboxRepository {}

InboxItem _item(
  String id,
  String type, {
  bool read = false,
  Map<String, String> data = const {},
  DateTime? at,
}) => InboxItem(
  id: id,
  type: type,
  title: 'Title $id',
  body: 'Body $id',
  read: read,
  createdAt: at ?? DateTime.now().subtract(const Duration(minutes: 5)),
  data: data,
);

void main() {
  late MockInboxRepository repository;

  setUp(() {
    repository = MockInboxRepository();
    getIt
      ..registerSingleton<WatchInbox>(WatchInbox(repository))
      ..registerSingleton<MarkInboxRead>(MarkInboxRead(repository))
      ..registerSingleton<MarkAllInboxRead>(MarkAllInboxRead(repository));
    when(() => repository.markRead(any())).thenAnswer((_) async => right(unit));
    when(() => repository.markAllRead()).thenAnswer((_) async => right(unit));
  });

  tearDown(() async => getIt.reset());

  void stubItems(List<InboxItem> items) {
    when(
      () => repository.watch(limit: any(named: 'limit')),
    ).thenAnswer((_) => Stream.value(right(items)));
  }

  Future<GoRouter> pump(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 4800);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (c, s) => const InboxPage()),
        GoRoute(path: '/groups', builder: (c, s) => const Text('groups tab')),
        GoRoute(
          path: '/groups/:id',
          builder: (c, s) => Text('group ${s.pathParameters['id']}'),
        ),
      ],
    );
    await tester.pumpWidget(
      MaterialApp.router(theme: AppTheme.light(), routerConfig: router),
    );
    await tester.pumpAndSettle();
    return router;
  }

  testWidgets('an empty inbox says so', (tester) async {
    stubItems(const []);
    await pump(tester);

    expect(find.text('Nothing here yet.'), findsOneWidget);
    expect(find.text('ALL CAUGHT UP'), findsOneWidget);
    expect(find.text('Mark all as read'), findsNothing);
  });

  testWidgets('unread items say NEW in words and are counted', (tester) async {
    stubItems([
      _item('a', 'invitation.received'),
      _item('b', 'invitation.declined', read: true),
    ]);
    await pump(tester);

    expect(find.text('1 UNREAD'), findsOneWidget);
    expect(find.text('NEW'), findsOneWidget);
    expect(find.text('Title a'), findsOneWidget);
    expect(find.text('Body b'), findsOneWidget);
  });

  testWidgets('shows how long ago, in words', (tester) async {
    stubItems([
      _item('a', 'x', at: DateTime.now().subtract(const Duration(hours: 3))),
    ]);
    await pump(tester);

    expect(find.text('3 h ago'), findsOneWidget);
  });

  testWidgets('tapping an unread item marks it read and opens it', (
    tester,
  ) async {
    stubItems([
      _item('a', 'group.join_request', data: {'groupId': 'g1'}),
    ]);
    await pump(tester);

    await tester.tap(find.text('Title a'));
    await tester.pumpAndSettle();

    verify(() => repository.markRead('a')).called(1);
    expect(find.text('group g1'), findsOneWidget);
  });

  testWidgets('tapping a read item does not mark it again', (tester) async {
    stubItems([_item('a', 'invitation.received', read: true)]);
    await pump(tester);

    await tester.tap(find.text('Title a'));
    await tester.pumpAndSettle();

    verifyNever(() => repository.markRead(any()));
    expect(find.text('groups tab'), findsOneWidget);
  });

  testWidgets('an item with nowhere to go is marked read and stays put', (
    tester,
  ) async {
    stubItems([_item('a', 'invitation.declined')]);
    await pump(tester);

    await tester.tap(find.text('Title a'));
    await tester.pumpAndSettle();

    verify(() => repository.markRead('a')).called(1);
    expect(find.text('Title a'), findsOneWidget);
  });

  testWidgets('Mark all as read clears them', (tester) async {
    stubItems([_item('a', 'x'), _item('b', 'x')]);
    await pump(tester);

    await tester.tap(find.text('Mark all as read'));
    await tester.pumpAndSettle();

    verify(() => repository.markAllRead()).called(1);
  });

  testWidgets('a full page offers older notifications', (tester) async {
    when(() => repository.watch(limit: any(named: 'limit'))).thenAnswer((
      invocation,
    ) {
      final limit = invocation.namedArguments[#limit] as int;
      return Stream.value(
        right([for (var i = 0; i < limit; i++) _item('n$i', 'x', read: true)]),
      );
    });
    await pump(tester);

    await tester.ensureVisible(find.text('Show older'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Show older'));
    await tester.pumpAndSettle();

    verify(() => repository.watch(limit: 60)).called(greaterThan(0));
  });

  testWidgets('a short list has no Show older button', (tester) async {
    stubItems([_item('a', 'x')]);
    await pump(tester);

    expect(find.text('Show older'), findsNothing);
  });

  testWidgets('reading order and state are spoken as one sentence', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    stubItems([
      _item('a', 'x', at: DateTime.now().subtract(const Duration(minutes: 5))),
    ]);
    await pump(tester);

    expect(
      find.semantics.byLabel(RegExp(r'Unread\. Title a\. Body a\.')),
      findsOneWidget,
    );
    handle.dispose();
  });

  testWidgets('a failure to load offers a retry', (tester) async {
    when(
      () => repository.watch(limit: any(named: 'limit')),
    ).thenAnswer((_) => Stream.value(left(const Failure.network())));
    await pump(tester);

    expect(find.text('Try again'), findsOneWidget);
  });

  testWidgets('does not overflow at 2x text on a small phone', (tester) async {
    stubItems([_item('a', 'x'), _item('b', 'x', read: true)]);
    useSmallPhone(tester);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(2)),
          child: child!,
        ),
        home: const InboxPage(),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}

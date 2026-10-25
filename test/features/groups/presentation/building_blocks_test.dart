import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go_router/go_router.dart';
import 'package:habit_tracker/core/di/injection.dart';
import 'package:habit_tracker/core/error/failure.dart';
import 'package:habit_tracker/core/presentation/view_state.dart';
import 'package:habit_tracker/core/theme/app_tokens.dart';
import 'package:habit_tracker/core/time/date_key.dart';
import 'package:habit_tracker/features/groups/domain/entities/completion_rule.dart';
import 'package:habit_tracker/features/groups/domain/entities/group_entities.dart';
import 'package:habit_tracker/features/groups/domain/entities/history_breakdown.dart';
import 'package:habit_tracker/features/groups/presentation/widgets/collab_widgets.dart';
import 'package:habit_tracker/features/groups/presentation/widgets/date_field.dart';
import 'package:habit_tracker/features/groups/presentation/widgets/emblem_widgets.dart';
import 'package:habit_tracker/features/groups/presentation/widgets/history_card.dart';
import 'package:habit_tracker/features/groups/presentation/widgets/rule_editor.dart';
import 'package:habit_tracker/features/notifications/domain/reminders_domain.dart';
import 'package:habit_tracker/features/notifications/presentation/reminder_tile.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/pump_app.dart';

class MockReminderRepository extends Mock implements ReminderRepository {}

PeriodCount _p(String start, int done, int scheduled) =>
    PeriodCount(start: DateKey.parse(start), scheduled: scheduled, done: done);

void main() {
  group('EmblemPicker', () {
    testWidgets('shows a preview and reports icon and colour changes', (
      tester,
    ) async {
      var value = const GroupEmblem(icon: 'people', color: 0);
      await tester.pumpWidget(
        themedApp(
          StatefulBuilder(
            builder: (context, setState) => Scaffold(
              body: SingleChildScrollView(
                child: EmblemPicker(
                  value: value,
                  onChanged: (v) => setState(() => value = v),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byKey(const ValueKey('emblem-icon-run')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('emblem-color-3')));
      await tester.pump();

      expect(value, const GroupEmblem(icon: 'run', color: 3));
    });

    testWidgets('every icon and colour is a labelled button with its state', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        themedApp(
          Scaffold(
            body: SingleChildScrollView(
              child: EmblemPicker(
                value: const GroupEmblem(icon: 'book', color: 1),
                onChanged: (_) {},
              ),
            ),
          ),
        ),
      );

      expect(find.bySemanticsLabel('Reading, selected'), findsOneWidget);
      expect(find.bySemanticsLabel('Running'), findsOneWidget);
      expect(find.bySemanticsLabel('Colour 2, selected'), findsOneWidget);
      expect(find.bySemanticsLabel('Colour 1'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('touch targets are at least 48 by 48', (tester) async {
      await tester.pumpWidget(
        themedApp(
          Scaffold(
            body: SingleChildScrollView(
              child: EmblemPicker(
                value: GroupEmblem.fallback,
                onChanged: (_) {},
              ),
            ),
          ),
        ),
      );

      final size = tester.getSize(
        find.byKey(const ValueKey('emblem-icon-run')),
      );
      expect(size.width, greaterThanOrEqualTo(48));
      expect(size.height, greaterThanOrEqualTo(48));
    });

    testWidgets('does not overflow on a small phone at 2x text', (
      tester,
    ) async {
      useSmallPhone(tester);
      await tester.pumpWidget(
        themedApp(
          Scaffold(
            body: SingleChildScrollView(
              child: EmblemPicker(
                value: GroupEmblem.fallback,
                onChanged: (_) {},
              ),
            ),
          ),
          textScale: 2,
        ),
      );

      expect(tester.takeException(), isNull);
    });

    test('every icon the server accepts has a drawing and a name', () {
      for (final icon in GroupEmblem.icons) {
        expect(EmblemStyle.icons, contains(icon));
        expect(EmblemStyle.names, contains(icon));
      }
      expect(EmblemStyle.colors, hasLength(GroupEmblem.colorCount));
    });

    testWidgets('an unknown icon or colour still draws something', (
      tester,
    ) async {
      await tester.pumpWidget(
        themedApp(
          const Scaffold(
            body: EmblemAvatar(emblem: GroupEmblem(icon: 'nope', color: 99)),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.byType(Icon), findsOneWidget);
    });

    testWidgets('a group without a picture gets the default', (tester) async {
      await tester.pumpWidget(themedApp(const Scaffold(body: EmblemAvatar())));

      expect(find.byIcon(Icons.groups_outlined), findsOneWidget);
    });
  });

  group('HistoryCard', () {
    Future<void> pump(WidgetTester tester, HistoryBreakdown history) {
      return tester.pumpWidget(
        themedApp(
          Scaffold(
            body: SingleChildScrollView(child: HistoryCard(history: history)),
          ),
        ),
      );
    }

    final history = HistoryBreakdown(
      weeks: [_p('2026-10-05', 5, 7), _p('2026-10-12', 3, 6)],
      months: [_p('2026-09-01', 20, 30), _p('2026-10-01', 9, 18)],
    );

    testWidgets('shows weeks newest first, with counts in words', (
      tester,
    ) async {
      await pump(tester, history);

      expect(find.text('Week of 12 Oct 2026'), findsOneWidget);
      expect(find.text('3 of 6 (50%)'), findsOneWidget);
      expect(find.text('5 of 7 (71%)'), findsOneWidget);
      final newer = tester.getTopLeft(find.text('Week of 12 Oct 2026'));
      final older = tester.getTopLeft(find.text('Week of 5 Oct 2026'));
      expect(newer.dy, lessThan(older.dy));
    });

    testWidgets('switches to months', (tester) async {
      await pump(tester, history);

      await tester.tap(find.text('Monthly'));
      await tester.pump();

      expect(find.text('October 2026'), findsOneWidget);
      expect(find.text('9 of 18 (50%)'), findsOneWidget);
      expect(find.text('September 2026'), findsOneWidget);
      expect(find.textContaining('Week of'), findsNothing);
    });

    testWidgets('says so before there is any history', (tester) async {
      await pump(tester, HistoryBreakdown.empty);

      expect(find.textContaining('History appears after'), findsOneWidget);
    });

    testWidgets('a period with nothing scheduled does not show 0 of 0', (
      tester,
    ) async {
      await pump(
        tester,
        HistoryBreakdown(weeks: [_p('2026-10-12', 0, 0)], months: const []),
      );

      expect(find.text('nothing scheduled yet'), findsOneWidget);
      expect(find.textContaining('0 of 0'), findsNothing);
    });

    testWidgets('each row is spoken as one sentence', (tester) async {
      final handle = tester.ensureSemantics();
      await pump(tester, history);

      expect(
        find.bySemanticsLabel('Week of 12 Oct 2026: 3 of 6 (50%)'),
        findsOneWidget,
      );
      handle.dispose();
    });

    testWidgets('does not overflow at 2x text on a small phone', (
      tester,
    ) async {
      useSmallPhone(tester);
      await tester.pumpWidget(
        themedApp(
          Scaffold(
            body: SingleChildScrollView(child: HistoryCard(history: history)),
          ),
          textScale: 2,
        ),
      );

      expect(tester.takeException(), isNull);
    });
  });

  group('DateField', () {
    Future<void> pump(
      WidgetTester tester, {
      DateKey? value,
      bool optional = false,
      ValueChanged<DateKey?>? onChanged,
    }) {
      return tester.pumpWidget(
        themedApp(
          Scaffold(
            body: DateField(
              label: 'Ends',
              value: value,
              optional: optional,
              firstDate: DateKey.parse('2026-01-01'),
              lastDate: DateKey.parse('2027-12-31'),
              onChanged: onChanged ?? (_) {},
            ),
          ),
        ),
      );
    }

    test('formats a date for reading', () {
      expect(DateField.format(DateKey.parse('2026-10-05')), '5 Oct 2026');
      expect(DateField.format(DateKey.parse('2027-01-31')), '31 Jan 2027');
    });

    testWidgets('shows None for an empty optional date', (tester) async {
      await pump(tester, optional: true);

      expect(find.text('None'), findsOneWidget);
      expect(find.text('Clear'), findsNothing);
    });

    testWidgets('a set optional date can be cleared', (tester) async {
      DateKey? value = DateKey.parse('2026-10-18');
      await pump(
        tester,
        value: value,
        optional: true,
        onChanged: (v) => value = v,
      );

      expect(find.text('18 Oct 2026'), findsOneWidget);
      await tester.tap(find.text('Clear'));

      expect(value, isNull);
    });

    testWidgets('a required date has no Clear button', (tester) async {
      await pump(tester, value: DateKey.parse('2026-10-18'));

      expect(find.text('Clear'), findsNothing);
    });

    testWidgets('tapping opens the date picker and reports the pick', (
      tester,
    ) async {
      DateKey? picked;
      await pump(
        tester,
        value: DateKey.parse('2026-10-18'),
        onChanged: (v) => picked = v,
      );

      await tester.tap(find.text('18 Oct 2026'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('20'));
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(picked, DateKey.parse('2026-10-20'));
    });

    testWidgets('cancelling the picker changes nothing', (tester) async {
      var changes = 0;
      await pump(
        tester,
        value: DateKey.parse('2026-10-18'),
        onChanged: (_) => changes++,
      );

      await tester.tap(find.text('18 Oct 2026'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(changes, 0);
    });

    testWidgets('is read out with its label and value', (tester) async {
      final handle = tester.ensureSemantics();
      await pump(tester, value: DateKey.parse('2026-10-18'));

      expect(find.bySemanticsLabel('Ends, 18 Oct 2026'), findsOneWidget);
      handle.dispose();
    });
  });

  group('RuleEditor', () {
    testWidgets('reports a rule without a number for the simple rules', (
      tester,
    ) async {
      CompletionRule? latest;
      await tester.pumpWidget(
        themedApp(
          Scaffold(
            body: RuleEditor(
              initial: const CompletionRule.majority(),
              onChanged: (r) => latest = r,
            ),
          ),
        ),
      );

      await tester.tap(find.text('More than half'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Everyone').last);
      await tester.pumpAndSettle();

      expect(latest, const CompletionRule.unanimous());
    });

    testWidgets('percentage asks for a number and reports it', (tester) async {
      CompletionRule? latest;
      await tester.pumpWidget(
        themedApp(
          Scaffold(
            body: RuleEditor(
              initial: const CompletionRule.percentage(80),
              onChanged: (r) => latest = r,
            ),
          ),
        ),
      );

      expect(find.text('80'), findsOneWidget);
      await tester.enterText(find.byType(TextField), '60');

      expect(latest, const CompletionRule.percentage(60));
    });

    testWidgets('a non number is reported as 0 so validation rejects it', (
      tester,
    ) async {
      CompletionRule? latest;
      await tester.pumpWidget(
        themedApp(
          Scaffold(
            body: RuleEditor(
              initial: const CompletionRule.fixed(3),
              onChanged: (r) => latest = r,
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'abc');

      expect(latest, const CompletionRule.fixed(0));
      expect(latest!.isValid, isFalse);
    });

    test('plain words for every rule', () {
      for (final type in CompletionRuleType.values) {
        expect(ruleLabel(type), isNotEmpty);
      }
      expect(
        ruleSentence(const CompletionRule.percentage(80)),
        '80% of the group',
      );
      expect(ruleSentence(const CompletionRule.fixed(4)), '4 people');
      expect(
        ruleSentence(const CompletionRule.majority()),
        'More than half of the group',
      );
    });
  });

  group('ReminderTile', () {
    late MockReminderRepository repository;
    const target = PersonalReminderTarget('h1');

    setUpAll(() {
      registerFallbackValue(target);
      registerFallbackValue(
        const ReminderSetting(enabled: true, minutesOfDay: 0),
      );
    });

    setUp(() {
      repository = MockReminderRepository();
      getIt.registerSingleton<WatchReminder>(WatchReminder(repository));
      getIt.registerSingleton<SaveReminder>(SaveReminder(repository));
      when(
        () => repository.save(any(), any()),
      ).thenAnswer((_) async => right(unit));
    });

    tearDown(() async => getIt.reset());

    void stubWatch(ReminderSetting? setting) {
      when(
        () => repository.watch(any()),
      ).thenAnswer((_) => Stream.value(right(setting)));
    }

    Future<void> pump(WidgetTester tester) async {
      await tester.pumpWidget(
        themedApp(const Scaffold(body: ReminderTile(target: target))),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('off by default', (tester) async {
      stubWatch(null);
      await pump(tester);

      expect(find.text('Remind me'), findsOneWidget);
      expect(find.text('Off'), findsOneWidget);
      expect(find.textContaining('Change time'), findsNothing);
    });

    testWidgets('turning it on saves 18:00 as the first time', (tester) async {
      stubWatch(null);
      await pump(tester);

      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      final saved =
          verify(() => repository.save(any(), captureAny())).captured.single
              as ReminderSetting;
      expect(saved.enabled, isTrue);
      expect(saved.minutesOfDay, 18 * 60);
    });

    testWidgets('shows the time in words when on', (tester) async {
      stubWatch(const ReminderSetting(enabled: true, minutesOfDay: 7 * 60 + 5));
      await pump(tester);

      expect(find.textContaining('Every day at 07:05'), findsOneWidget);
      expect(find.text('Change time (07:05)'), findsOneWidget);
    });

    testWidgets('turning it off keeps the time for later', (tester) async {
      stubWatch(const ReminderSetting(enabled: true, minutesOfDay: 8 * 60));
      await pump(tester);

      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      final saved =
          verify(() => repository.save(any(), captureAny())).captured.single
              as ReminderSetting;
      expect(saved.enabled, isFalse);
      expect(saved.minutesOfDay, 8 * 60);
    });

    testWidgets('a failed save tells the person', (tester) async {
      stubWatch(null);
      when(
        () => repository.save(any(), any()),
      ).thenAnswer((_) async => left(const Failure.network()));
      await pump(tester);

      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      expect(find.textContaining('Network unavailable'), findsOneWidget);
    });

    testWidgets('shows nothing when reminders are not available', (
      tester,
    ) async {
      await getIt.reset();
      await tester.pumpWidget(
        themedApp(const Scaffold(body: ReminderTile(target: target))),
      );

      expect(find.text('Remind me'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('says reminders respect quiet hours', (tester) async {
      stubWatch(null);
      await pump(tester);

      expect(find.textContaining('quiet hours'), findsOneWidget);
    });
  });

  group('lost access', () {
    Future<void> pumpWith(WidgetTester tester, Failure failure) async {
      final cubit = WatchCubit<int>(() => Stream.value(left(failure)))..start();
      addTearDown(cubit.close);
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) =>
                const Scaffold(body: Text('home page')),
          ),
          GoRoute(
            path: '/group',
            builder: (context, state) => BlocProvider.value(
              value: cubit,
              child: ViewStateBuilder<int>(
                standalone: true,
                builder: (context, v) => Text('value $v'),
              ),
            ),
          ),
        ],
        initialLocation: '/group',
      );
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();
    }

    testWidgets('being removed reads as lost access, not a crash', (
      tester,
    ) async {
      await pumpWith(tester, const Failure.unauthenticated());

      expect(find.text('No access'), findsOneWidget);
      expect(find.textContaining('removed'), findsOneWidget);
      expect(find.text('Go back'), findsOneWidget);
      expect(find.text('Try again'), findsNothing);
    });

    testWidgets('something deleted reads as gone', (tester) async {
      await pumpWith(tester, const Failure.notFound());

      expect(find.text('Not found'), findsOneWidget);
      expect(find.textContaining('deleted'), findsOneWidget);
    });

    testWidgets('Go back leaves the screen', (tester) async {
      await pumpWith(tester, const Failure.unauthenticated());

      await tester.tap(find.text('Go back'));
      await tester.pumpAndSettle();

      expect(find.text('home page'), findsOneWidget);
    });

    testWidgets('a network problem still offers to retry', (tester) async {
      await pumpWith(tester, const Failure.network());

      expect(find.text('Try again'), findsOneWidget);
      expect(find.text('No access'), findsNothing);
    });
  });

  testWidgets(
    'the emblem colours are all distinct tones from the design tokens',
    (tester) async {
      expect(
        AppTokens.emblemPalette.toSet(),
        hasLength(AppTokens.emblemPalette.length),
      );
    },
  );
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart' show Either, Unit, left, right, unit;
import 'package:habit_tracker/core/error/failure.dart';
import 'package:habit_tracker/core/presentation/view_state.dart';
import 'package:habit_tracker/core/time/date_key.dart';
import 'package:habit_tracker/features/groups/domain/entities/completion_rule.dart';
import 'package:habit_tracker/features/groups/domain/entities/cycle_snapshot.dart';
import 'package:habit_tracker/features/groups/presentation/widgets/collab_widgets.dart';
import 'package:habit_tracker/features/groups/presentation/widgets/cycle_progress_block.dart';

import 'package:habit_tracker/features/habits/presentation/widgets/state_views.dart';

import '../../../helpers/pump_app.dart';

CycleSnapshot _cycle({
  required int eligible,
  required int completed,
  required CompletionRule rule,
  List<String> visible = const [],
}) => CycleSnapshot(
  dateKey: DateKey.parse('2026-10-18'),
  eligibleUids: [for (var i = 0; i < eligible; i++) 'u$i'],
  visibleCompletedUids: visible,
  completedCount: completed,
  rule: rule,
  closed: false,
);

void main() {
  group('CycleProgressBlock', () {
    Future<void> pump(
      WidgetTester tester,
      CycleSnapshot? cycle, {
      Map<String, String> names = const {},
    }) {
      return tester.pumpWidget(
        themedApp(
          Scaffold(
            body: SingleChildScrollView(
              child: CycleProgressBlock(cycle: cycle, namesByUid: names),
            ),
          ),
        ),
      );
    }

    testWidgets('shows 3 of 5 and 60 percent for a shared habit', (
      tester,
    ) async {
      await pump(
        tester,
        _cycle(
          eligible: 5,
          completed: 3,
          rule: const CompletionRule.individual(),
        ),
      );

      expect(find.textContaining('of 5 done'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('60%'), findsOneWidget);
      expect(find.byKey(const Key('target-line')), findsNothing);
      expect(find.text('Waiting: 2'), findsOneWidget);
    });

    testWidgets('the PRD example: 7 of 10 at 80 percent needs 1 more', (
      tester,
    ) async {
      await pump(
        tester,
        _cycle(
          eligible: 10,
          completed: 7,
          rule: const CompletionRule.percentage(80),
        ),
      );

      expect(find.text('70%'), findsOneWidget);
      expect(
        find.textContaining('1 more completion needed (8 of 10)'),
        findsOneWidget,
      );
    });

    testWidgets('says the target is reached, and others can still complete', (
      tester,
    ) async {
      await pump(
        tester,
        _cycle(
          eligible: 10,
          completed: 8,
          rule: const CompletionRule.percentage(80),
        ),
      );

      expect(
        find.textContaining(
          'Group target reached. Everyone can still complete.',
        ),
        findsOneWidget,
      );
      expect(find.text('Waiting: 2'), findsOneWidget);
    });

    testWidgets('lists names of members who share, and counts private ones', (
      tester,
    ) async {
      await pump(
        tester,
        _cycle(
          eligible: 4,
          completed: 3,
          rule: const CompletionRule.majority(),
          visible: const ['u0', 'u1'],
        ),
        names: {'u0': 'Ann', 'u1': 'Bob'},
      );

      expect(find.text('Done: Ann, Bob and 1 private'), findsOneWidget);
    });

    testWidgets('explains an empty day', (tester) async {
      await pump(tester, null);

      expect(find.textContaining('Nothing is scheduled'), findsOneWidget);
    });

    testWidgets('has a spoken summary instead of relying on the numbers', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pump(
        tester,
        _cycle(
          eligible: 5,
          completed: 3,
          rule: const CompletionRule.individual(),
        ),
      );

      expect(find.bySemanticsLabel('3 of 5 done, 60 percent'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('does not overflow at 2x text on a small phone', (
      tester,
    ) async {
      useSmallPhone(tester);
      await tester.pumpWidget(
        themedApp(
          Scaffold(
            body: SingleChildScrollView(
              child: CycleProgressBlock(
                cycle: _cycle(
                  eligible: 10,
                  completed: 7,
                  rule: const CompletionRule.percentage(80),
                  visible: const ['u0', 'u1', 'u2'],
                ),
                namesByUid: {
                  'u0': 'Alexandria',
                  'u1': 'Bartholomew',
                  'u2': 'Christopher',
                },
              ),
            ),
          ),
          textScale: 2,
        ),
      );

      expect(tester.takeException(), isNull);
    });
  });

  group('WeekdayPicker', () {
    testWidgets('toggles days and labels the state in words', (tester) async {
      var selected = <int>{1, 2};
      await tester.pumpWidget(
        themedApp(
          StatefulBuilder(
            builder: (context, setState) => Scaffold(
              body: WeekdayPicker(
                selected: selected,
                onChanged: (days) => setState(() => selected = days),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Mon ✓'), findsOneWidget);
      expect(find.text('Wed'), findsOneWidget);

      await tester.tap(find.text('Wed'));
      await tester.pump();
      await tester.tap(find.text('Mon ✓'));
      await tester.pump();

      expect(selected, {2, 3});
      expect(find.text('Wed ✓'), findsOneWidget);
      expect(find.text('Mon'), findsOneWidget);
    });

    testWidgets('each day is a labelled button with its state', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        themedApp(
          Scaffold(
            body: WeekdayPicker(selected: const {1}, onChanged: (_) {}),
          ),
        ),
      );

      expect(find.bySemanticsLabel('Mon, on'), findsOneWidget);
      expect(find.bySemanticsLabel('Tue, off'), findsOneWidget);
      handle.dispose();
    });
  });

  group('confirmAction', () {
    testWidgets('resolves true on confirm and false on cancel', (tester) async {
      bool? result;
      await tester.pumpWidget(
        themedApp(
          Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () async => result = await confirmAction(
                  context,
                  title: 'Remove Bob?',
                  message: 'They lose access.',
                  confirmLabel: 'Remove',
                ),
                child: const Text('go'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('go'));
      await tester.pumpAndSettle();
      expect(find.text('Remove Bob?'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(result, isFalse);

      await tester.tap(find.text('go'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Remove'));
      await tester.pumpAndSettle();
      expect(result, isTrue);
    });
  });

  group('ViewStateBuilder and SubmitListener', () {
    testWidgets('shows loading, then content', (tester) async {
      final cubit = WatchCubit<int>(() => Stream.value(right(5)));
      addTearDown(cubit.close);
      await tester.pumpWidget(
        themedApp(
          BlocProvider.value(
            value: cubit,
            child: Scaffold(
              body: ViewStateBuilder<int>(
                builder: (context, value) => Text('value $value'),
              ),
            ),
          ),
        ),
      );
      expect(find.byType(LoadingView), findsOneWidget);

      cubit.start();
      await tester.pumpAndSettle();

      expect(find.text('value 5'), findsOneWidget);
    });

    testWidgets('a failure shows a retry that reopens the stream', (
      tester,
    ) async {
      var attempt = 0;
      final cubit = WatchCubit<int>(() {
        attempt++;
        return Stream.value(
          attempt == 1 ? left(const Failure.network()) : right(9),
        );
      })..start();
      addTearDown(cubit.close);
      await tester.pumpWidget(
        themedApp(
          BlocProvider.value(
            value: cubit,
            child: Scaffold(
              body: ViewStateBuilder<int>(
                builder: (context, value) => Text('value $value'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('Network unavailable'), findsOneWidget);

      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();

      expect(find.text('value 9'), findsOneWidget);
    });

    testWidgets(
      'a standalone page keeps its frame while loading: no flash of an empty route',
      (tester) async {
        final controller = StreamController<Either<Failure, int>>();
        addTearDown(controller.close);
        final cubit = WatchCubit<int>(() => controller.stream)..start();
        addTearDown(cubit.close);
        await tester.pumpWidget(
          themedApp(
            BlocProvider.value(
              value: cubit,
              child: ViewStateBuilder<int>(
                standalone: true,
                builder: (context, value) =>
                    Scaffold(body: Text('value $value')),
              ),
            ),
          ),
        );

        // Right away: the page background and back button exist, the skeleton
        // does not (a one frame skeleton reads as a flicker).
        expect(find.byType(Scaffold), findsOneWidget);
        expect(find.byTooltip('Back'), findsOneWidget);
        expect(find.byType(LoadingView), findsNothing);

        // Slow loads still get a skeleton.
        await tester.pump(const Duration(milliseconds: 200));
        expect(find.byType(LoadingView), findsOneWidget);

        controller.add(right(3));
        await tester.pumpAndSettle();
        expect(find.text('value 3'), findsOneWidget);
        expect(find.byType(LoadingView), findsNothing);
      },
    );

    testWidgets('a fast load never shows the skeleton', (tester) async {
      final cubit = WatchCubit<int>(() => Stream.value(right(1)))..start();
      addTearDown(cubit.close);
      await tester.pumpWidget(
        themedApp(
          BlocProvider.value(
            value: cubit,
            child: ViewStateBuilder<int>(
              standalone: true,
              builder: (context, value) => Scaffold(body: Text('value $value')),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('value 1'), findsOneWidget);
      expect(find.byType(LoadingView), findsNothing);
      // Let the grace timer finish so the test ends cleanly.
      await tester.pump(const Duration(milliseconds: 200));
    });

    testWidgets('a standalone failure keeps the frame and can go back', (
      tester,
    ) async {
      final cubit = WatchCubit<int>(
        () => Stream.value(left(const Failure.network())),
      )..start();
      addTearDown(cubit.close);
      await tester.pumpWidget(
        themedApp(
          BlocProvider.value(
            value: cubit,
            child: ViewStateBuilder<int>(
              standalone: true,
              builder: (context, value) => Text('value $value'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byTooltip('Back'), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
    });

    testWidgets('a submit failure appears once as a snackbar', (tester) async {
      final cubit = SubmitCubit<Unit>();
      addTearDown(cubit.close);
      await tester.pumpWidget(
        themedApp(
          BlocProvider.value(
            value: cubit,
            child: const Scaffold(
              body: SubmitListener<Unit>(child: SizedBox()),
            ),
          ),
        ),
      );

      await cubit.submit(
        () async => left(const Failure.validation(message: 'Group is full.')),
      );
      await tester.pump();

      expect(find.text('Group is full.'), findsOneWidget);
      expect(cubit.state, isA<SubmitIdle<Unit>>());
    });

    testWidgets('success calls onSuccess', (tester) async {
      final cubit = SubmitCubit<Unit>();
      addTearDown(cubit.close);
      var called = 0;
      await tester.pumpWidget(
        themedApp(
          BlocProvider.value(
            value: cubit,
            child: Scaffold(
              body: SubmitListener<Unit>(
                onSuccess: (_, _) => called++,
                child: const SizedBox(),
              ),
            ),
          ),
        ),
      );

      await cubit.submit(() async => right(unit));
      await tester.pump();

      expect(called, 1);
    });
  });

  testWidgets('PendingSyncBadge says it in words', (tester) async {
    await tester.pumpWidget(
      themedApp(const Scaffold(body: PendingSyncBadge())),
    );

    expect(find.text('Waiting to sync'), findsOneWidget);
  });
}

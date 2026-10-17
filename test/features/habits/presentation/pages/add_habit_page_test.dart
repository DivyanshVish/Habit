import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:habit_tracker/core/error/failure.dart';
import 'package:habit_tracker/features/habits/presentation/bloc/add_habit/add_habit_bloc.dart';
import 'package:habit_tracker/features/habits/presentation/pages/add_habit_page.dart';
import 'package:mocktail/mocktail.dart';

class _MockAddHabitBloc extends MockBloc<AddHabitEvent, AddHabitState>
    implements AddHabitBloc {}

void main() {
  late _MockAddHabitBloc bloc;

  setUpAll(
    () => registerFallbackValue(
      const AddHabitEvent.submitted(name: '', description: '', points: 1),
    ),
  );

  setUp(() {
    bloc = _MockAddHabitBloc();
    whenListen(
      bloc,
      const Stream<AddHabitState>.empty(),
      initialState: const AddHabitState.initial(),
    );
  });

  Future<void> pumpPage(WidgetTester tester) {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const Scaffold(body: Text('home')),
        ),
        GoRoute(
          path: '/add',
          builder: (_, _) => BlocProvider<AddHabitBloc>.value(
            value: bloc,
            child: const AddHabitPage(),
          ),
        ),
      ],
      initialLocation: '/add',
    );
    return tester.pumpWidget(MaterialApp.router(routerConfig: router));
  }

  testWidgets('shows the heading, the labels and the quick picks', (
    tester,
  ) async {
    await pumpPage(tester);

    expect(find.text('ADD'), findsOneWidget);
    expect(find.text('New habit'), findsOneWidget);
    expect(find.text('NAME'), findsOneWidget);
    expect(find.text('DESCRIPTION'), findsOneWidget);
    expect(find.text('POINTS PER COMPLETION'), findsOneWidget);
    expect(find.text('Earned each time you mark it done.'), findsOneWidget);
    expect(find.text('Save habit'), findsOneWidget);
    expect(find.byKey(const Key('points-chip-15')), findsOneWidget);
  });

  testWidgets('uses an outlined save button of at least 48dp', (tester) async {
    await pumpPage(tester);

    expect(find.byType(FilledButton), findsNothing);
    expect(find.byType(OutlinedButton), findsOneWidget);
    expect(
      tester.getSize(find.byType(OutlinedButton)).height,
      greaterThanOrEqualTo(48),
    );
  });

  testWidgets('a quick pick sets the submitted points', (tester) async {
    await pumpPage(tester);

    await tester.enterText(find.byKey(const Key('name-field')), 'Read');
    // The form scrolls above the docked button on a short screen.
    await tester.ensureVisible(find.byKey(const Key('points-chip-15')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('points-chip-15')));
    await tester.pump();
    await tester.tap(find.text('Save habit'));
    await tester.pump();

    verify(
      () => bloc.add(
        const AddHabitEvent.submitted(
          name: 'Read',
          description: '',
          points: 15,
        ),
      ),
    ).called(1);
  });

  testWidgets('the close button leaves the screen', (tester) async {
    await pumpPage(tester);

    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();

    expect(find.text('home'), findsOneWidget);
  });

  testWidgets('shows validation errors and does not submit empty form', (
    tester,
  ) async {
    await pumpPage(tester);

    await tester.enterText(find.byKey(const Key('points-field')), '');
    await tester.tap(find.text('Save habit'));
    await tester.pump();

    expect(find.text('Please enter a name'), findsOneWidget);
    expect(find.text('Enter a number of points'), findsOneWidget);
    verifyNever(() => bloc.add(any()));
  });

  testWidgets('rejects points outside the allowed range', (tester) async {
    await pumpPage(tester);

    await tester.enterText(find.byKey(const Key('name-field')), 'Read');
    await tester.enterText(find.byKey(const Key('points-field')), '5000');
    await tester.tap(find.text('Save habit'));
    await tester.pump();

    expect(find.text('Use 1 to 1000'), findsOneWidget);
    verifyNever(() => bloc.add(any()));
  });

  testWidgets('submits the entered values', (tester) async {
    await pumpPage(tester);

    await tester.enterText(
      find.byKey(const Key('name-field')),
      'Read 20 pages',
    );
    await tester.enterText(
      find.byKey(const Key('description-field')),
      'Before bed',
    );
    await tester.enterText(find.byKey(const Key('points-field')), '20');
    await tester.tap(find.text('Save habit'));
    await tester.pump();

    verify(
      () => bloc.add(
        const AddHabitEvent.submitted(
          name: 'Read 20 pages',
          description: 'Before bed',
          points: 20,
        ),
      ),
    ).called(1);
  });

  testWidgets('the saving state is announced', (tester) async {
    final semantics = tester.ensureSemantics();
    whenListen(
      bloc,
      const Stream<AddHabitState>.empty(),
      initialState: const AddHabitState.submitting(),
    );
    await pumpPage(tester);
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.bySemanticsLabel('Saving'), findsOneWidget);
    expect(find.text('Save habit'), findsNothing);
    semantics.dispose();
  });

  testWidgets('disables the button while submitting', (tester) async {
    whenListen(
      bloc,
      const Stream<AddHabitState>.empty(),
      initialState: const AddHabitState.submitting(),
    );
    await pumpPage(tester);

    final button = tester.widget<OutlinedButton>(find.byType(OutlinedButton));
    expect(button.onPressed, isNull);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows the failure message in a snackbar', (tester) async {
    whenListen(
      bloc,
      Stream<AddHabitState>.fromIterable([
        const AddHabitState.failure(Failure.network()),
      ]),
      initialState: const AddHabitState.initial(),
    );
    await pumpPage(tester);
    await tester.pump();

    expect(find.text(const Failure.network().message), findsOneWidget);
  });

  testWidgets('pops the page on success', (tester) async {
    whenListen(
      bloc,
      Stream<AddHabitState>.fromIterable([const AddHabitState.success()]),
      initialState: const AddHabitState.initial(),
    );
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, _) => Scaffold(
            body: TextButton(
              onPressed: () => context.push('/add'),
              child: const Text('open'),
            ),
          ),
        ),
        GoRoute(
          path: '/add',
          builder: (_, _) => BlocProvider<AddHabitBloc>.value(
            value: bloc,
            child: const AddHabitPage(),
          ),
        ),
      ],
    );
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    // The success state was emitted on subscribe, so the form closed itself.
    expect(find.text('Save habit'), findsNothing);
    expect(find.text('open'), findsOneWidget);
  });

  testWidgets('shows a "Habit added" toast after closing on success', (
    tester,
  ) async {
    final updates = StreamController<AddHabitState>();
    addTearDown(updates.close);
    whenListen(
      bloc,
      updates.stream,
      initialState: const AddHabitState.initial(),
    );
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, _) => Scaffold(
            body: TextButton(
              onPressed: () => context.push('/add'),
              child: const Text('open'),
            ),
          ),
        ),
        GoRoute(
          path: '/add',
          builder: (_, _) => BlocProvider<AddHabitBloc>.value(
            value: bloc,
            child: const AddHabitPage(),
          ),
        ),
      ],
    );
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('Save habit'), findsOneWidget);

    updates.add(const AddHabitState.success());
    await tester.pump();
    // The snack bar hero-flies between the two scaffolds while the page pops.
    for (var i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 250));
    }

    expect(find.text('Habit added'), findsWidgets);
    expect(find.text('Save habit'), findsNothing);

    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(find.text('Habit added'), findsNothing);
  });
}

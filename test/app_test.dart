import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:habit_tracker/app.dart';
import 'package:habit_tracker/bootstrap_exception.dart';
import 'package:habit_tracker/core/brand.dart';
import 'package:habit_tracker/core/di/injection.dart';
import 'package:habit_tracker/core/theme/app_motion.dart';
import 'package:habit_tracker/core/time/date_key.dart';
import 'package:habit_tracker/core/usecase/usecase.dart';
import 'package:habit_tracker/features/habits/domain/entities/today_overview.dart';
import 'package:habit_tracker/features/habits/domain/usecases/add_habit.dart';
import 'package:habit_tracker/features/habits/domain/usecases/delete_habit.dart';
import 'package:habit_tracker/features/habits/domain/usecases/toggle_habit_completion.dart';
import 'package:habit_tracker/features/habits/domain/usecases/watch_today_overview.dart';
import 'package:habit_tracker/features/habits/presentation/bloc/add_habit/add_habit_bloc.dart';
import 'package:habit_tracker/features/habits/presentation/bloc/today/today_bloc.dart';
import 'package:habit_tracker/features/habits/presentation/widgets/brand_mark.dart';
import 'package:habit_tracker/features/habits/presentation/widgets/splash_view.dart';
import 'package:mocktail/mocktail.dart';

import 'helpers/fakes.dart';

class _MockAddHabit extends Mock implements AddHabit {}

class _MockWatchTodayOverview extends Mock implements WatchTodayOverview {}

class _MockToggle extends Mock implements ToggleHabitCompletion {}

class _MockDeleteHabit extends Mock implements DeleteHabit {}

void main() {
  setUpAll(() => registerFallbackValue(const NoParams()));

  setUp(() {
    getIt.registerFactory<AddHabitBloc>(() => AddHabitBloc(_MockAddHabit()));
    getIt.registerFactory<TodayBloc>(() {
      final watch = _MockWatchTodayOverview();
      when(() => watch(any())).thenAnswer(
        (_) => Stream.value(
          right(const TodayOverview(date: DateKey(2026, 10, 17), items: [])),
        ),
      );
      return TodayBloc(
        watchTodayOverview: watch,
        toggleHabitCompletion: _MockToggle(),
        deleteHabit: _MockDeleteHabit(),
        clock: FixedClock(DateTime(2026, 10, 17)),
      );
    });
  });

  tearDown(() => getIt.reset());

  testWidgets('shows the Today screen after a successful bootstrap', (
    tester,
  ) async {
    await tester.pumpWidget(BootstrapGate(bootstrap: () async {}));
    await tester.pumpAndSettle();

    expect(find.text('SATURDAY \u00B7 17 OCTOBER'), findsOneWidget);
    expect(find.text('Today'), findsOneWidget);
    expect(find.text('New habit'), findsOneWidget);
  });

  testWidgets('shows the splash until bootstrap completes', (tester) async {
    final semantics = tester.ensureSemantics();
    final completer = Completer<void>();
    await tester.pumpWidget(BootstrapGate(bootstrap: () => completer.future));
    await tester.pump();

    expect(find.byType(SplashView), findsOneWidget);
    expect(find.text(appName), findsOneWidget);
    expect(find.text('DAILY HABITS'), findsOneWidget);
    expect(find.bySemanticsLabel(appName), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Today'), findsNothing);

    completer.complete();
    await tester.pumpAndSettle();

    expect(find.text('Today'), findsOneWidget);
    expect(find.byType(SplashView), findsNothing);
    semantics.dispose();
  });

  group('splash timing', () {
    const minimum = AppMotion.splash;

    testWidgets('keeps the splash for the minimum even if bootstrap is fast', (
      tester,
    ) async {
      await tester.pumpWidget(BootstrapGate(bootstrap: () async {}));
      await tester.pump();
      expect(find.byType(SplashView), findsOneWidget);

      await tester.pump(minimum - const Duration(milliseconds: 100));
      expect(find.byType(SplashView), findsOneWidget);
      expect(find.text('Today'), findsNothing);

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();
      expect(find.text('Today'), findsOneWidget);
      expect(find.byType(SplashView), findsNothing);
    });

    testWidgets('waits for a slow bootstrap after the minimum', (tester) async {
      final completer = Completer<void>();
      await tester.pumpWidget(BootstrapGate(bootstrap: () => completer.future));
      await tester.pump(minimum + const Duration(seconds: 1));
      expect(find.byType(SplashView), findsOneWidget);

      completer.complete();
      await tester.pumpAndSettle();
      expect(find.text('Today'), findsOneWidget);
    });

    testWidgets('shows the error right away, without the minimum', (
      tester,
    ) async {
      await tester.pumpWidget(
        BootstrapGate(bootstrap: () async => throw Exception('offline')),
      );
      // Microtasks, the first frame of the switch, then the crossfade. Well
      // under the splash minimum.
      await tester.pump();
      await tester.pump();
      await tester.pump(AppMotion.base);
      // The error is already on screen (checked below). A ticker counts time
      // from its first frame, so the fade needs a second full duration before
      // AnimatedSwitcher drops the outgoing splash. Still ~500 ms in total,
      // well under the 900 ms minimum the error must not wait for.
      await tester.pump(AppMotion.base);

      expect(find.text('Retry'), findsOneWidget);
      expect(find.byType(SplashView), findsNothing);
    });

    testWidgets('retry shows the splash again with no extra minimum', (
      tester,
    ) async {
      var attempts = 0;
      final retry = Completer<void>();
      await tester.pumpWidget(
        BootstrapGate(
          bootstrap: () {
            attempts++;
            if (attempts == 1) return Future<void>.error(Exception('offline'));
            return retry.future;
          },
        ),
      );
      await tester.pump();
      await tester.pump();
      await tester.pump(AppMotion.base);
      await tester.tap(find.text('Retry'));
      await tester.pump();
      await tester.pump(AppMotion.base);
      expect(find.byType(SplashView), findsOneWidget);

      retry.complete();
      await tester.pumpAndSettle();
      expect(find.text('Today'), findsOneWidget);
    });

    testWidgets('reduced motion shows the final mark and never waits', (
      tester,
    ) async {
      final completer = Completer<void>();
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: BootstrapGate(bootstrap: () => completer.future),
        ),
      );
      await tester.pump();

      expect(tester.widget<BrandMark>(find.byType(BrandMark)).progress, 1);
      final wordmark = tester.widget<FadeTransition>(
        find
            .ancestor(
              of: find.text(appName),
              matching: find.byType(FadeTransition),
            )
            .first,
      );
      expect(wordmark.opacity.value, 1);

      completer.complete();
      await tester.pumpAndSettle();
      expect(find.text('Today'), findsOneWidget);
    });

    testWidgets('the intro animates the mark when motion is allowed', (
      tester,
    ) async {
      final completer = Completer<void>();
      await tester.pumpWidget(BootstrapGate(bootstrap: () => completer.future));
      await tester.pump();
      expect(
        tester.widget<BrandMark>(find.byType(BrandMark)).progress,
        lessThan(0.1),
      );

      await tester.pump(minimum);
      expect(tester.widget<BrandMark>(find.byType(BrandMark)).progress, 1);
    });
  });

  testWidgets('shows retry when bootstrap fails and recovers on retry', (
    tester,
  ) async {
    var attempts = 0;
    await tester.pumpWidget(
      BootstrapGate(
        bootstrap: () async {
          attempts++;
          if (attempts == 1) throw Exception('offline');
        },
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Retry'), findsOneWidget);
    expect(find.text("Can't connect"), findsOneWidget);

    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(attempts, 2);
    expect(find.text('Today'), findsOneWidget);
  });

  testWidgets('navigates to the Add habit form from the Today screen', (
    tester,
  ) async {
    await tester.pumpWidget(BootstrapGate(bootstrap: () async {}));
    await tester.pumpAndSettle();

    await tester.tap(find.text('New habit'));
    await tester.pumpAndSettle();

    expect(find.text('Save habit'), findsOneWidget);
    expect(find.text('NAME'), findsOneWidget);
  });

  testWidgets('shows the specific message from a BootstrapException', (
    tester,
  ) async {
    await tester.pumpWidget(
      BootstrapGate(
        bootstrap: () async =>
            throw const BootstrapException('Anonymous sign-in is not enabled.'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Anonymous sign-in is not enabled.'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });
}

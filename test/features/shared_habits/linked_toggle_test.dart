import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:habit_tracker/core/error/failure.dart';
import 'package:habit_tracker/core/platform/platform_services.dart';
import 'package:habit_tracker/core/time/date_key.dart';
import 'package:habit_tracker/features/habits/domain/repositories/habit_repository.dart';
import 'package:habit_tracker/features/habits/domain/usecases/toggle_habit_completion.dart';
import 'package:habit_tracker/features/shared_habits/data/callable_linked_sync.dart';
import 'package:habit_tracker/features/shared_habits/domain/linked_toggle.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fakes.dart';

class MockHabitRepository extends Mock implements HabitRepository {}

class RecordingSync implements LinkedCompletionSync {
  final List<({String habitId, String dateKey, bool done})> calls = [];

  @override
  Future<void> mirror({
    required String habitId,
    required DateKey dateKey,
    required bool done,
  }) async {
    calls.add((habitId: habitId, dateKey: dateKey.value, done: done));
  }
}

void main() {
  late MockHabitRepository repository;
  late RecordingSync sync;
  final day = DateKey.parse('2026-10-18');
  final params = ToggleHabitCompletionParams(
    habitId: 'h1',
    dateKey: day,
    done: true,
  );

  setUpAll(() => registerFallbackValue(DateKey.parse('2026-01-01')));

  setUp(() {
    repository = MockHabitRepository();
    sync = RecordingSync();
  });

  void stubToggle(Either<Failure, Unit> result) {
    when(
      () => repository.setCompletion(
        habitId: any(named: 'habitId'),
        dateKey: any(named: 'dateKey'),
        done: any(named: 'done'),
      ),
    ).thenAnswer((_) async => result);
  }

  test('saves the personal completion first, then tells the server', () async {
    stubToggle(right(unit));

    final result = await LinkedToggleHabitCompletion(repository, sync)(params);
    await Future<void>.delayed(Duration.zero);

    expect(result, right(unit));
    verify(
      () => repository.setCompletion(habitId: 'h1', dateKey: day, done: true),
    ).called(1);
    expect(sync.calls, [(habitId: 'h1', dateKey: '2026-10-18', done: true)]);
  });

  test('undoing is mirrored too', () async {
    stubToggle(right(unit));

    await LinkedToggleHabitCompletion(repository, sync)(
      ToggleHabitCompletionParams(habitId: 'h1', dateKey: day, done: false),
    );
    await Future<void>.delayed(Duration.zero);

    expect(sync.calls.single.done, isFalse);
  });

  test('a failed personal save is not mirrored', () async {
    stubToggle(left(const Failure.network()));

    final result = await LinkedToggleHabitCompletion(repository, sync)(params);
    await Future<void>.delayed(Duration.zero);

    expect(result.isLeft(), isTrue);
    expect(sync.calls, isEmpty);
  });

  test('a failing mirror never changes the result', () async {
    stubToggle(right(unit));
    final failing = _ThrowingSync();

    final result = await LinkedToggleHabitCompletion(repository, failing)(
      params,
    );
    await Future<void>.delayed(Duration.zero);

    expect(result, right(unit));
  });

  group('CallableLinkedCompletionSync', () {
    test('sends the habit, date and state', () async {
      final callable = FakeCallableClient();

      await CallableLinkedCompletionSync(
        callable,
      ).mirror(habitId: 'h1', dateKey: day, done: true);

      expect(callable.calls.single.name, 'mirrorPersonalCompletion');
      expect(callable.calls.single.data, {
        'habitId': 'h1',
        'dateKey': '2026-10-18',
        'done': true,
      });
    });

    test('swallows server errors', () async {
      final callable = FakeCallableClient()
        ..error = const CallableException('unavailable', 'offline');

      await expectLater(
        CallableLinkedCompletionSync(
          callable,
        ).mirror(habitId: 'h1', dateKey: day, done: true),
        completes,
      );
    });
  });
}

class _ThrowingSync implements LinkedCompletionSync {
  @override
  Future<void> mirror({
    required String habitId,
    required DateKey dateKey,
    required bool done,
  }) => Future.error(StateError('boom'));
}

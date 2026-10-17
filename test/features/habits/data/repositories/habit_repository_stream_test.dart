import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:habit_tracker/core/error/exceptions.dart';
import 'package:habit_tracker/core/error/failure.dart';
import 'package:habit_tracker/core/time/date_key.dart';
import 'package:habit_tracker/features/habits/data/datasources/habit_remote_data_source.dart';
import 'package:habit_tracker/features/habits/data/models/completion_model.dart';
import 'package:habit_tracker/features/habits/data/models/habit_model.dart';
import 'package:habit_tracker/features/habits/data/repositories/habit_repository_impl.dart';
import 'package:habit_tracker/features/habits/domain/entities/completion.dart';
import 'package:mocktail/mocktail.dart';

class _MockRemote extends Mock implements HabitRemoteDataSource {}

void main() {
  late _MockRemote remote;
  late HabitRepositoryImpl repository;
  const day = DateKey(2026, 10, 17);

  setUp(() {
    remote = _MockRemote();
    repository = HabitRepositoryImpl(remote);
  });

  HabitModel model(String id, {String createdDateKey = '2026-10-01'}) =>
      HabitModel(
        id: id,
        name: id,
        description: '',
        points: 5,
        createdAt: DateTime(2026, 10, 1),
        createdDateKey: createdDateKey,
      );

  group('watchHabits', () {
    test('maps models to entities', () async {
      when(
        () => remote.watchHabits(),
      ).thenAnswer((_) => Stream.value([model('a'), model('b')]));

      final result = await repository.watchHabits().first;

      final habits = result.getOrElse(
        (_) => throw StateError('expected right'),
      );
      expect(habits.map((h) => h.id), ['a', 'b']);
      expect(habits.first.createdDateKey, const DateKey(2026, 10, 1));
    });

    test('turns a stream error into a single Left and ends', () async {
      when(() => remote.watchHabits()).thenAnswer(
        (_) => Stream.error(
          FirebaseException(plugin: 'cloud_firestore', code: 'unavailable'),
        ),
      );

      final results = await repository.watchHabits().toList();

      expect(results, [left<Failure, Never>(const Failure.network())]);
    });

    test('turns a synchronous throw while opening into a Left', () async {
      when(
        () => remote.watchHabits(),
      ).thenThrow(const UnauthenticatedException());

      final results = await repository.watchHabits().toList();

      expect(results, [left<Failure, Never>(const Failure.unauthenticated())]);
    });

    test(
      'a malformed document becomes a server failure, not a crash',
      () async {
        when(() => remote.watchHabits()).thenAnswer(
          (_) => Stream.value([model('a', createdDateKey: 'not-a-date')]),
        );

        final results = await repository.watchHabits().toList();

        expect(results, [
          left<Failure, Never>(
            const Failure.server(message: 'Received unexpected data.'),
          ),
        ]);
      },
    );

    test('keeps emitting values as they arrive', () async {
      final controller = StreamController<List<HabitModel>>();
      addTearDown(controller.close);
      when(() => remote.watchHabits()).thenAnswer((_) => controller.stream);

      final counts = <int>[];
      final subscription = repository.watchHabits().listen(
        (r) => r.map((habits) => counts.add(habits.length)),
      );
      addTearDown(subscription.cancel);

      controller.add([model('a')]);
      controller.add([model('a'), model('b')]);
      await pumpEventQueue();

      expect(counts, [1, 2]);
    });
  });

  group('watchHabit', () {
    test('maps the model to an entity', () async {
      when(
        () => remote.watchHabit('a'),
      ).thenAnswer((_) => Stream.value(model('a')));

      final result = await repository.watchHabit('a').first;

      expect(
        result.getOrElse((_) => throw StateError('expected right')).id,
        'a',
      );
    });

    test(
      'a missing habit becomes a notFound failure and the stream ends',
      () async {
        when(
          () => remote.watchHabit('a'),
        ).thenAnswer((_) => Stream.error(const NotFoundException()));

        final results = await repository.watchHabit('a').toList();

        expect(results, [
          left<Failure, Never>(
            const Failure.notFound(message: 'This habit no longer exists.'),
          ),
        ]);
      },
    );
  });

  group('watchCompletions', () {
    test('maps models to entities', () async {
      when(() => remote.watchCompletions(from: day, to: day)).thenAnswer(
        (_) => Stream.value([
          const CompletionModel(habitId: 'a', dateKey: '2026-10-17'),
        ]),
      );

      final result = await repository
          .watchCompletions(from: day, to: day)
          .first;

      expect(result.getOrElse((_) => throw StateError('expected right')), [
        const Completion(habitId: 'a', dateKey: day),
      ]);
    });

    test('maps stream errors to failures', () async {
      when(() => remote.watchCompletions(from: day, to: day)).thenAnswer(
        (_) => Stream.error(
          FirebaseException(
            plugin: 'cloud_firestore',
            code: 'permission-denied',
          ),
        ),
      );

      final results = await repository
          .watchCompletions(from: day, to: day)
          .toList();

      expect(results.single.isLeft(), isTrue);
    });
  });

  group('deleteHabit', () {
    test('returns unit on success', () async {
      when(() => remote.deleteHabit('a')).thenAnswer((_) async {});

      expect(await repository.deleteHabit('a'), right<Failure, Unit>(unit));
    });

    test('maps exceptions to failures', () async {
      when(() => remote.deleteHabit('a')).thenThrow(
        FirebaseException(plugin: 'cloud_firestore', code: 'permission-denied'),
      );

      final result = await repository.deleteHabit('a');

      expect(result.isLeft(), isTrue);
    });
  });

  group('setCompletion', () {
    test('returns unit on success', () async {
      when(
        () => remote.setCompletion(habitId: 'a', dateKey: day, done: true),
      ).thenAnswer((_) async {});

      expect(
        await repository.setCompletion(habitId: 'a', dateKey: day, done: true),
        right<Failure, Unit>(unit),
      );
    });

    test('maps exceptions to failures', () async {
      when(
        () => remote.setCompletion(habitId: 'a', dateKey: day, done: false),
      ).thenThrow(
        FirebaseException(plugin: 'cloud_firestore', code: 'unavailable'),
      );

      expect(
        await repository.setCompletion(habitId: 'a', dateKey: day, done: false),
        left<Failure, Unit>(const Failure.network()),
      );
    });
  });
}

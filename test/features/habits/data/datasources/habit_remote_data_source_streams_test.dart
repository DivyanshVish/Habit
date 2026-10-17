import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/core/error/exceptions.dart';
import 'package:habit_tracker/core/time/date_key.dart';
import 'package:habit_tracker/features/habits/data/datasources/habit_remote_data_source.dart';
import 'package:habit_tracker/features/habits/data/models/completion_model.dart';
import 'package:habit_tracker/features/habits/domain/entities/new_habit.dart';

import '../../../../helpers/fakes.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late HabitRemoteDataSourceImpl dataSource;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    dataSource = HabitRemoteDataSourceImpl(
      firestore: firestore,
      userIdProvider: FakeUserIdProvider('alice'),
    );
  });

  NewHabit habit(String name, DateTime createdAt) =>
      NewHabit(name: name, description: '', points: 10, createdAt: createdAt);

  CollectionReference<Map<String, dynamic>> completions(String uid) =>
      firestore.collection('users').doc(uid).collection('completions');

  group('watchHabits', () {
    test('emits habits oldest first and updates live', () async {
      await dataSource.addHabit(habit('second', DateTime(2026, 10, 2)));
      await dataSource.addHabit(habit('first', DateTime(2026, 10, 1)));

      final emissions = <List<String>>[];
      final subscription = dataSource.watchHabits().listen(
        (models) => emissions.add(models.map((m) => m.name).toList()),
      );
      addTearDown(subscription.cancel);
      await pumpEventQueue();

      await dataSource.addHabit(habit('third', DateTime(2026, 10, 3)));
      await pumpEventQueue();

      expect(emissions.first, ['first', 'second']);
      expect(emissions.last, ['first', 'second', 'third']);
    });

    test('only sees the signed-in user\'s habits', () async {
      await dataSource.addHabit(habit('alice habit', DateTime(2026, 10, 1)));
      final bob = HabitRemoteDataSourceImpl(
        firestore: firestore,
        userIdProvider: FakeUserIdProvider('bob'),
      );

      expect(await bob.watchHabits().first, isEmpty);
      expect(await dataSource.watchHabits().first, hasLength(1));
    });
  });

  group('watchHabit', () {
    CollectionReference<Map<String, dynamic>> habits(String uid) =>
        firestore.collection('users').doc(uid).collection('habits');

    test('emits the habit and its updates', () async {
      await dataSource.addHabit(habit('Water', DateTime(2026, 10, 1)));
      final id = (await habits('alice').get()).docs.single.id;

      final names = <String>[];
      final subscription = dataSource
          .watchHabit(id)
          .listen((model) => names.add(model.name));
      addTearDown(subscription.cancel);
      await pumpEventQueue();

      await habits('alice').doc(id).update({'name': 'Water 2L'});
      await pumpEventQueue();

      expect(names, ['Water', 'Water 2L']);
    });

    test('errors with NotFoundException for a missing habit', () async {
      expect(
        dataSource.watchHabit('missing').first,
        throwsA(isA<NotFoundException>()),
      );
    });

    test('errors with NotFoundException when deleted while watching', () async {
      await dataSource.addHabit(habit('Water', DateTime(2026, 10, 1)));
      final id = (await habits('alice').get()).docs.single.id;

      final errors = <Object>[];
      final subscription = dataSource
          .watchHabit(id)
          .listen((_) {}, onError: errors.add);
      addTearDown(subscription.cancel);
      await pumpEventQueue();

      await habits('alice').doc(id).delete();
      await pumpEventQueue();

      expect(errors.single, isA<NotFoundException>());
    });

    test('cannot read another user\'s habit', () async {
      await dataSource.addHabit(habit('Water', DateTime(2026, 10, 1)));
      final id = (await habits('alice').get()).docs.single.id;
      final bob = HabitRemoteDataSourceImpl(
        firestore: firestore,
        userIdProvider: FakeUserIdProvider('bob'),
      );

      expect(bob.watchHabit(id).first, throwsA(isA<NotFoundException>()));
    });
  });

  group('setCompletion', () {
    const day = DateKey(2026, 10, 17);

    test('done writes a deterministic document', () async {
      await dataSource.setCompletion(
        habitId: 'water',
        dateKey: day,
        done: true,
      );

      final doc = await completions('alice').doc('water_2026-10-17').get();
      expect(doc.exists, isTrue);
      expect(doc.data()!['habitId'], 'water');
      expect(doc.data()!['dateKey'], '2026-10-17');
      expect(doc.data()!.containsKey('completedAt'), isTrue);
    });

    test('marking done twice stays a single document', () async {
      await dataSource.setCompletion(
        habitId: 'water',
        dateKey: day,
        done: true,
      );
      await dataSource.setCompletion(
        habitId: 'water',
        dateKey: day,
        done: true,
      );

      expect((await completions('alice').get()).docs, hasLength(1));
    });

    test(
      'undone deletes the document, and deleting twice is harmless',
      () async {
        await dataSource.setCompletion(
          habitId: 'water',
          dateKey: day,
          done: true,
        );
        await dataSource.setCompletion(
          habitId: 'water',
          dateKey: day,
          done: false,
        );
        await dataSource.setCompletion(
          habitId: 'water',
          dateKey: day,
          done: false,
        );

        expect((await completions('alice').get()).docs, isEmpty);
      },
    );

    test('different habits and days do not collide', () async {
      await dataSource.setCompletion(
        habitId: 'water',
        dateKey: day,
        done: true,
      );
      await dataSource.setCompletion(habitId: 'read', dateKey: day, done: true);
      await dataSource.setCompletion(
        habitId: 'water',
        dateKey: day.minusDays(1),
        done: true,
      );

      expect((await completions('alice').get()).docs, hasLength(3));
    });
  });

  group('watchCompletions', () {
    const day = DateKey(2026, 10, 17);

    test('returns only completions inside the inclusive date range', () async {
      for (final offset in [0, 1, 6, 7, 8]) {
        await dataSource.setCompletion(
          habitId: 'water',
          dateKey: day.minusDays(offset),
          done: true,
        );
      }

      final models = await dataSource
          .watchCompletions(from: day.minusDays(6), to: day)
          .first;

      expect(models.map((m) => m.dateKey).toSet(), {
        day.value,
        day.minusDays(1).value,
        day.minusDays(6).value,
      });
    });

    test('works across a month boundary', () async {
      const march = DateKey(2026, 3, 2);
      await dataSource.setCompletion(
        habitId: 'water',
        dateKey: const DateKey(2026, 2, 28),
        done: true,
      );

      final models = await dataSource
          .watchCompletions(from: march.minusDays(6), to: march)
          .first;

      expect(models.single.dateKey, '2026-02-28');
    });

    test('updates live when a completion is toggled', () async {
      final counts = <int>[];
      final subscription = dataSource
          .watchCompletions(from: day, to: day)
          .listen((models) => counts.add(models.length));
      addTearDown(subscription.cancel);
      await pumpEventQueue();

      await dataSource.setCompletion(
        habitId: 'water',
        dateKey: day,
        done: true,
      );
      await pumpEventQueue();
      await dataSource.setCompletion(
        habitId: 'water',
        dateKey: day,
        done: false,
      );
      await pumpEventQueue();

      expect(counts, [0, 1, 0]);
    });

    test('does not see another user\'s completions', () async {
      await HabitRemoteDataSourceImpl(
        firestore: firestore,
        userIdProvider: FakeUserIdProvider('bob'),
      ).setCompletion(habitId: 'water', dateKey: day, done: true);

      expect(
        await dataSource.watchCompletions(from: day, to: day).first,
        isEmpty,
      );
    });
  });

  group('deleteHabit', () {
    const day = DateKey(2026, 10, 17);

    Future<String> addAndGetId(String name) async {
      await dataSource.addHabit(habit(name, DateTime(2026, 10, 1)));
      final docs = await firestore
          .collection('users')
          .doc('alice')
          .collection('habits')
          .where('name', isEqualTo: name)
          .get();
      return docs.docs.single.id;
    }

    test('removes the habit and all of its completions', () async {
      final water = await addAndGetId('Water');
      for (var i = 0; i < 5; i++) {
        await dataSource.setCompletion(
          habitId: water,
          dateKey: day.minusDays(i),
          done: true,
        );
      }

      await dataSource.deleteHabit(water);

      final habits = await firestore
          .collection('users')
          .doc('alice')
          .collection('habits')
          .get();
      expect(habits.docs, isEmpty);
      expect((await completions('alice').get()).docs, isEmpty);
    });

    test('leaves other habits and their completions alone', () async {
      final water = await addAndGetId('Water');
      final read = await addAndGetId('Read');
      await dataSource.setCompletion(habitId: water, dateKey: day, done: true);
      await dataSource.setCompletion(habitId: read, dateKey: day, done: true);

      await dataSource.deleteHabit(water);

      final remaining = await completions('alice').get();
      expect(remaining.docs.single.data()['habitId'], read);
      final habits = await firestore
          .collection('users')
          .doc('alice')
          .collection('habits')
          .get();
      expect(habits.docs.single.id, read);
    });

    test(
      'does not touch another user\'s data with the same habit id',
      () async {
        final water = await addAndGetId('Water');
        final bob = HabitRemoteDataSourceImpl(
          firestore: firestore,
          userIdProvider: FakeUserIdProvider('bob'),
        );
        await bob.setCompletion(habitId: water, dateKey: day, done: true);

        await dataSource.deleteHabit(water);

        expect((await completions('bob').get()).docs, hasLength(1));
      },
    );

    test('splits very long histories across several batches', () async {
      final water = await addAndGetId('Water');
      final batchWrites = <Future<void>>[];
      for (var i = 0; i < 450; i++) {
        batchWrites.add(
          dataSource.setCompletion(
            habitId: water,
            dateKey: day.minusDays(i),
            done: true,
          ),
        );
      }
      await Future.wait(batchWrites);
      expect((await completions('alice').get()).docs, hasLength(450));

      await dataSource.deleteHabit(water);

      expect((await completions('alice').get()).docs, isEmpty);
    });

    test('deleting a habit that does not exist is harmless', () async {
      await expectLater(dataSource.deleteHabit('ghost'), completes);
    });
  });

  group('CompletionModel', () {
    test('docId combines habit id and date key', () {
      expect(
        CompletionModel.docId('abc', const DateKey(2026, 1, 5)),
        'abc_2026-01-05',
      );
    });

    test('rejects malformed documents', () async {
      await completions('alice').doc('bad').set({'habitId': 'x'});
      final snapshot = await completions('alice').doc('bad').get();

      expect(
        () => CompletionModel.fromFirestore(snapshot),
        throwsFormatException,
      );
    });
  });
}

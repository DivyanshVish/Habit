import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/core/error/exceptions.dart';
import 'package:habit_tracker/features/habits/data/datasources/habit_remote_data_source.dart';
import 'package:habit_tracker/features/habits/domain/entities/new_habit.dart';

import '../../../../helpers/fakes.dart';

void main() {
  final habit = NewHabit(
    name: 'Drink 2L water',
    description: 'Stay hydrated',
    points: 10,
    createdAt: DateTime(2026, 10, 17, 8),
  );

  test('writes the habit under users/{uid}/habits', () async {
    final firestore = FakeFirebaseFirestore();
    final dataSource = HabitRemoteDataSourceImpl(
      firestore: firestore,
      userIdProvider: FakeUserIdProvider('alice'),
    );

    await dataSource.addHabit(habit);

    final docs = await firestore
        .collection('users')
        .doc('alice')
        .collection('habits')
        .get();
    expect(docs.docs, hasLength(1));
    final data = docs.docs.single.data();
    expect(data['name'], 'Drink 2L water');
    expect(data['description'], 'Stay hydrated');
    expect(data['points'], 10);
    expect(data['createdDateKey'], '2026-10-17');
    expect(data['createdAt'], isA<Timestamp>());
  });

  test('scopes data per user', () async {
    final firestore = FakeFirebaseFirestore();
    await HabitRemoteDataSourceImpl(
      firestore: firestore,
      userIdProvider: FakeUserIdProvider('alice'),
    ).addHabit(habit);

    final bobs = await firestore
        .collection('users')
        .doc('bob')
        .collection('habits')
        .get();
    expect(bobs.docs, isEmpty);
  });

  test('throws UnauthenticatedException when nobody is signed in', () {
    final dataSource = HabitRemoteDataSourceImpl(
      firestore: FakeFirebaseFirestore(),
      userIdProvider: FakeUserIdProvider(null),
    );

    expect(
      dataSource.addHabit(habit),
      throwsA(isA<UnauthenticatedException>()),
    );
  });

  group('awaitWriteAck', () {
    test(
      'treats a write that never acks (offline) as queued, not an error',
      () async {
        final neverAcked = Completer<void>().future;

        await expectLater(
          awaitWriteAck(neverAcked, const Duration(milliseconds: 20)),
          completes,
        );
      },
    );

    test('completes as soon as the write acks', () async {
      await expectLater(
        awaitWriteAck(Future<void>.value(), const Duration(seconds: 5)),
        completes,
      );
    });

    test('still surfaces real errors such as permission denied', () async {
      final failing = Future<void>.error(
        FirebaseException(plugin: 'cloud_firestore', code: 'permission-denied'),
      );

      await expectLater(
        awaitWriteAck(failing, const Duration(seconds: 5)),
        throwsA(isA<FirebaseException>()),
      );
    });
  });
}

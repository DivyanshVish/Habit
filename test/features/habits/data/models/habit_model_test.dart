import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/core/time/date_key.dart';
import 'package:habit_tracker/features/habits/data/models/habit_model.dart';
import 'package:habit_tracker/features/habits/domain/entities/new_habit.dart';

void main() {
  final createdAt = DateTime(2026, 10, 17, 9, 30);

  test('fromNewHabit derives the local date key', () {
    final model = HabitModel.fromNewHabit(
      'h1',
      NewHabit(
        name: 'Exercise 30 min',
        description: 'Any workout',
        points: 15,
        createdAt: createdAt,
      ),
    );

    expect(model.id, 'h1');
    expect(model.createdDateKey, '2026-10-17');
  });

  test('round-trips through Firestore', () async {
    final firestore = FakeFirebaseFirestore();
    final model = HabitModel.fromNewHabit(
      'h1',
      NewHabit(
        name: 'Read 20 pages',
        description: '',
        points: 20,
        createdAt: createdAt,
      ),
    );
    await firestore.collection('habits').doc('h1').set(model.toFirestore());

    final snapshot = await firestore.collection('habits').doc('h1').get();
    final parsed = HabitModel.fromFirestore(snapshot);

    expect(parsed, model);
    final entity = parsed.toEntity();
    expect(entity.createdDateKey, const DateKey(2026, 10, 17));
    expect(entity.points, 20);
  });

  test('tolerates a missing description', () async {
    final firestore = FakeFirebaseFirestore();
    await firestore.collection('habits').doc('h1').set({
      'name': 'Water',
      'points': 10,
      'createdAt': Timestamp.fromDate(createdAt),
      'createdDateKey': '2026-10-17',
    });

    final snapshot = await firestore.collection('habits').doc('h1').get();

    expect(HabitModel.fromFirestore(snapshot).description, '');
  });

  test('throws FormatException for malformed documents', () async {
    final firestore = FakeFirebaseFirestore();
    await firestore.collection('habits').doc('bad').set({'name': 'No points'});
    final snapshot = await firestore.collection('habits').doc('bad').get();

    expect(() => HabitModel.fromFirestore(snapshot), throwsFormatException);
  });

  test('throws FormatException for a missing document', () async {
    final firestore = FakeFirebaseFirestore();
    final snapshot = await firestore.collection('habits').doc('nope').get();

    expect(() => HabitModel.fromFirestore(snapshot), throwsFormatException);
  });
}

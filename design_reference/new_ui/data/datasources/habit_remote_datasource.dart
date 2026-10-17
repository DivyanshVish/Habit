import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/habit.dart';
import '../models/habit_model.dart';

/// Firestore layout:  users/{uid}/habits/{habitId}
///   { name, description, points, createdAt, completedDates: ['2026-10-17', …] }
/// Completions live on the habit doc, so one listener drives every screen and
/// toggling is a single atomic arrayUnion / arrayRemove.
class HabitRemoteDataSource {
  HabitRemoteDataSource(this._db, this._uid);
  final FirebaseFirestore _db;
  final String _uid;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('users').doc(_uid).collection('habits');

  Stream<List<Habit>> watchHabits() => _col
      .orderBy('createdAt')
      .snapshots()
      .map((s) => s.docs.map(HabitModel.fromDoc).toList());

  Future<void> add(String name, String description, int points) =>
      _col.add(HabitModel.toNewDoc(name, description, points));

  Future<void> setCompletion(String id, DateTime day, bool done) {
    final key = Habit.keyFor(day);
    return _col.doc(id).update({
      'completedDates': done
          ? FieldValue.arrayUnion([key])
          : FieldValue.arrayRemove([key]),
    });
  }

  Future<void> delete(String id) => _col.doc(id).delete();
}

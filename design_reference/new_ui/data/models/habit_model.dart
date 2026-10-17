import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/habit.dart';

class HabitModel {
  static Habit fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final m = doc.data() ?? {};
    return Habit(
      id: doc.id,
      name: (m['name'] as String?) ?? '',
      description: (m['description'] as String?) ?? '',
      points: (m['points'] as num?)?.toInt() ?? 0,
      // serverTimestamp is null on the local write before the server confirms.
      createdAt: (m['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      completedDates: ((m['completedDates'] as List?) ?? const [])
          .cast<String>()
          .toSet(),
    );
  }

  static Map<String, dynamic> toNewDoc(
    String name,
    String description,
    int points,
  ) => {
    'name': name,
    'description': description,
    'points': points,
    'createdAt': FieldValue.serverTimestamp(),
    'completedDates': <String>[],
  };
}

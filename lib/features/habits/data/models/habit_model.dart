import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:habit_tracker/core/time/date_key.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit.dart';
import 'package:habit_tracker/features/habits/domain/entities/new_habit.dart';

part 'habit_model.freezed.dart';

/// Firestore representation of a habit: `users/{uid}/habits/{habitId}`.
@freezed
abstract class HabitModel with _$HabitModel {
  const HabitModel._();

  const factory HabitModel({
    required String id,
    required String name,
    required String description,
    required int points,
    required DateTime createdAt,
    required String createdDateKey,
  }) = _HabitModel;

  factory HabitModel.fromNewHabit(String id, NewHabit habit) => HabitModel(
    id: id,
    name: habit.name,
    description: habit.description,
    points: habit.points,
    createdAt: habit.createdAt,
    createdDateKey: DateKey.fromDateTime(habit.createdAt).value,
  );

  /// Throws [FormatException] when the document is missing or malformed.
  factory HabitModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) {
      throw FormatException('Habit ${doc.id} has no data');
    }
    final name = data[fieldName];
    final points = data[fieldPoints];
    final createdAt = data[fieldCreatedAt];
    final createdDateKey = data[fieldCreatedDateKey];
    if (name is! String ||
        points is! num ||
        createdAt is! Timestamp ||
        createdDateKey is! String) {
      throw FormatException('Habit ${doc.id} is malformed');
    }
    return HabitModel(
      id: doc.id,
      name: name,
      description: (data[fieldDescription] as String?) ?? '',
      points: points.toInt(),
      createdAt: createdAt.toDate(),
      createdDateKey: createdDateKey,
    );
  }

  static const String fieldName = 'name';
  static const String fieldDescription = 'description';
  static const String fieldPoints = 'points';
  static const String fieldCreatedAt = 'createdAt';
  static const String fieldCreatedDateKey = 'createdDateKey';

  Map<String, dynamic> toFirestore() => {
    fieldName: name,
    fieldDescription: description,
    fieldPoints: points,
    fieldCreatedAt: Timestamp.fromDate(createdAt),
    fieldCreatedDateKey: createdDateKey,
  };

  /// Throws [FormatException] when [createdDateKey] is not `yyyy-MM-dd`.
  Habit toEntity() => Habit(
    id: id,
    name: name,
    description: description,
    points: points,
    createdAt: createdAt,
    createdDateKey: DateKey.parse(createdDateKey),
  );
}

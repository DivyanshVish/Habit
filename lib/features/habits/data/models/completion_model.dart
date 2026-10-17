import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:habit_tracker/core/time/date_key.dart';
import 'package:habit_tracker/features/habits/domain/entities/completion.dart';

part 'completion_model.freezed.dart';

/// Firestore representation of a completion:
/// `users/{uid}/completions/{habitId}_{yyyy-MM-dd}`.
@freezed
abstract class CompletionModel with _$CompletionModel {
  const CompletionModel._();

  const factory CompletionModel({
    required String habitId,
    required String dateKey,
  }) = _CompletionModel;

  static const String fieldHabitId = 'habitId';
  static const String fieldDateKey = 'dateKey';
  static const String fieldCompletedAt = 'completedAt';

  /// Deterministic id, so marking done twice is the same write and undoing it
  /// is a plain delete (no read needed).
  static String docId(String habitId, DateKey dateKey) =>
      '${habitId}_${dateKey.value}';

  /// Throws [FormatException] when the document is missing or malformed.
  factory CompletionModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    final habitId = data?[fieldHabitId];
    final dateKey = data?[fieldDateKey];
    if (habitId is! String || dateKey is! String) {
      throw FormatException('Completion ${doc.id} is malformed');
    }
    return CompletionModel(habitId: habitId, dateKey: dateKey);
  }

  Map<String, dynamic> toFirestore() => {
    fieldHabitId: habitId,
    fieldDateKey: dateKey,
    // Write-only audit field, so the server timestamp's local null is harmless.
    fieldCompletedAt: FieldValue.serverTimestamp(),
  };

  /// Throws [FormatException] when [dateKey] is not `yyyy-MM-dd`.
  Completion toEntity() =>
      Completion(habitId: habitId, dateKey: DateKey.parse(dateKey));
}

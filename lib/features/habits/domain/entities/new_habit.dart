import 'package:freezed_annotation/freezed_annotation.dart';

part 'new_habit.freezed.dart';

/// A habit that has not been persisted yet (no id).
@freezed
abstract class NewHabit with _$NewHabit {
  const factory NewHabit({
    required String name,
    required String description,
    required int points,
    required DateTime createdAt,
  }) = _NewHabit;
}

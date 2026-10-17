import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:habit_tracker/core/time/date_key.dart';

part 'habit.freezed.dart';

@freezed
abstract class Habit with _$Habit {
  const factory Habit({
    required String id,
    required String name,
    required String description,
    required int points,
    required DateTime createdAt,
    required DateKey createdDateKey,
  }) = _Habit;
}

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:habit_tracker/core/time/date_key.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit_with_status.dart';

part 'today_overview.freezed.dart';

/// Everything the Today screen shows for one day.
@freezed
abstract class TodayOverview with _$TodayOverview {
  const TodayOverview._();

  const factory TodayOverview({
    required DateKey date,
    required List<HabitWithStatus> items,
  }) = _TodayOverview;

  int get totalCount => items.length;

  int get doneCount => items.where((item) => item.isDone).length;

  int get totalPoints => items.fold(0, (sum, item) => sum + item.habit.points);

  int get earnedPoints => items
      .where((item) => item.isDone)
      .fold(0, (sum, item) => sum + item.habit.points);

  /// Share of today's points earned, 0.0 to 1.0.
  double get progress => totalPoints == 0 ? 0 : earnedPoints / totalPoints;
}

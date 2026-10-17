import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:habit_tracker/core/time/date_key.dart';

part 'completion.freezed.dart';

/// Records that [habitId] was done on [dateKey].
@freezed
abstract class Completion with _$Completion {
  const factory Completion({
    required String habitId,
    required DateKey dateKey,
  }) = _Completion;
}

import 'package:fpdart/fpdart.dart';
import 'package:habit_tracker/core/error/failure.dart';
import 'package:habit_tracker/core/usecase/usecase.dart';

/// Which habit a reminder is for.
sealed class ReminderTarget {
  const ReminderTarget();

  /// Stable id of the reminder document, so setting a reminder twice for the
  /// same habit edits it instead of adding another.
  String get docId;
}

final class PersonalReminderTarget extends ReminderTarget {
  const PersonalReminderTarget(this.habitId);

  final String habitId;

  @override
  String get docId => 'personal_$habitId';
}

final class SharedReminderTarget extends ReminderTarget {
  const SharedReminderTarget(this.sharedId);

  final String sharedId;

  @override
  String get docId => 'shared_$sharedId';
}

final class GroupReminderTarget extends ReminderTarget {
  const GroupReminderTarget(this.groupId, this.habitId);

  final String groupId;
  final String habitId;

  @override
  String get docId => 'group_${groupId}_$habitId';
}

class ReminderSetting {
  const ReminderSetting({
    required this.enabled,
    required this.minutesOfDay,
    this.onlyIfIncomplete = true,
  });

  final bool enabled;

  /// Minutes after local midnight.
  final int minutesOfDay;

  /// Skip the reminder when the habit is already done today.
  final bool onlyIfIncomplete;

  @override
  bool operator ==(Object other) =>
      other is ReminderSetting &&
      other.enabled == enabled &&
      other.minutesOfDay == minutesOfDay &&
      other.onlyIfIncomplete == onlyIfIncomplete;

  @override
  int get hashCode => Object.hash(enabled, minutesOfDay, onlyIfIncomplete);
}

abstract interface class ReminderRepository {
  /// Null when no reminder is set for the habit.
  Stream<Either<Failure, ReminderSetting?>> watch(ReminderTarget target);

  Future<Either<Failure, Unit>> save(
    ReminderTarget target,
    ReminderSetting setting,
  );

  Future<Either<Failure, Unit>> remove(ReminderTarget target);
}

class WatchReminder implements StreamUseCase<ReminderSetting?, ReminderTarget> {
  WatchReminder(this._repository);

  final ReminderRepository _repository;

  @override
  Stream<Either<Failure, ReminderSetting?>> call(ReminderTarget params) =>
      _repository.watch(params);
}

class SaveReminderParams {
  const SaveReminderParams(this.target, this.setting);

  final ReminderTarget target;
  final ReminderSetting setting;
}

class SaveReminder implements UseCase<Unit, SaveReminderParams> {
  SaveReminder(this._repository);

  final ReminderRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(SaveReminderParams params) {
    final minutes = params.setting.minutesOfDay;
    if (minutes < 0 || minutes >= 24 * 60) {
      return Future.value(
        left(const Failure.validation(message: 'Pick a time of day.')),
      );
    }
    return _repository.save(params.target, params.setting);
  }
}

class RemoveReminder implements UseCase<Unit, ReminderTarget> {
  RemoveReminder(this._repository);

  final ReminderRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(ReminderTarget params) =>
      _repository.remove(params);
}

import 'package:fpdart/fpdart.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:habit_tracker/core/error/failure.dart';
import 'package:habit_tracker/core/time/clock.dart';
import 'package:habit_tracker/core/usecase/usecase.dart';
import 'package:habit_tracker/features/habits/domain/entities/new_habit.dart';
import 'package:habit_tracker/features/habits/domain/repositories/habit_repository.dart';

part 'add_habit.freezed.dart';

/// Input rules shared by the use case and the form validators.
class HabitRules {
  const HabitRules._();

  static const int maxNameLength = 60;
  static const int maxDescriptionLength = 200;
  static const int minPoints = 1;
  static const int maxPoints = 1000;
}

@freezed
abstract class AddHabitParams with _$AddHabitParams {
  const factory AddHabitParams({
    required String name,
    required String description,
    required int points,
  }) = _AddHabitParams;
}

class AddHabit implements UseCase<Unit, AddHabitParams> {
  AddHabit(this._repository, this._clock);

  final HabitRepository _repository;
  final Clock _clock;

  @override
  Future<Either<Failure, Unit>> call(AddHabitParams params) async {
    final name = params.name.trim();
    final description = params.description.trim();

    if (name.isEmpty) {
      return left(const Failure.validation(message: 'Name is required.'));
    }
    if (name.length > HabitRules.maxNameLength) {
      return left(
        const Failure.validation(
          message:
              'Name must be ${HabitRules.maxNameLength} characters or fewer.',
        ),
      );
    }
    if (description.length > HabitRules.maxDescriptionLength) {
      return left(
        const Failure.validation(
          message:
              'Description must be ${HabitRules.maxDescriptionLength} characters or fewer.',
        ),
      );
    }
    if (params.points < HabitRules.minPoints ||
        params.points > HabitRules.maxPoints) {
      return left(
        const Failure.validation(
          message:
              'Points must be between ${HabitRules.minPoints} and ${HabitRules.maxPoints}.',
        ),
      );
    }

    return _repository.addHabit(
      NewHabit(
        name: name,
        description: description,
        points: params.points,
        createdAt: _clock.now(),
      ),
    );
  }
}

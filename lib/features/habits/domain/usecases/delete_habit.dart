import 'package:fpdart/fpdart.dart';
import 'package:habit_tracker/core/error/failure.dart';
import 'package:habit_tracker/core/usecase/usecase.dart';
import 'package:habit_tracker/features/habits/domain/repositories/habit_repository.dart';

/// Deletes a habit and its completion history.
class DeleteHabit implements UseCase<Unit, String> {
  DeleteHabit(this._repository);

  final HabitRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(String habitId) {
    if (habitId.trim().isEmpty) {
      return Future.value(
        left(const Failure.validation(message: 'Missing habit id.')),
      );
    }
    return _repository.deleteHabit(habitId);
  }
}

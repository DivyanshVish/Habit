import 'package:fpdart/fpdart.dart';
import 'package:habit_tracker/core/data/exception_mapper.dart';
import 'package:habit_tracker/core/error/failure.dart';
import 'package:habit_tracker/core/time/date_key.dart';
import 'package:habit_tracker/features/habits/data/datasources/habit_remote_data_source.dart';
import 'package:habit_tracker/features/habits/domain/entities/completion.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit.dart';
import 'package:habit_tracker/features/habits/domain/entities/new_habit.dart';
import 'package:habit_tracker/features/habits/domain/repositories/habit_repository.dart';
import 'package:rxdart/rxdart.dart';

class HabitRepositoryImpl implements HabitRepository {
  HabitRepositoryImpl(this._remote);

  final HabitRemoteDataSource _remote;

  @override
  Stream<Either<Failure, List<Habit>>> watchHabits() {
    return _guardStream(
      _remote.watchHabits,
      (models) => [for (final model in models) model.toEntity()],
    );
  }

  @override
  Stream<Either<Failure, Habit>> watchHabit(String habitId) {
    return _guardStream(
      () => _remote.watchHabit(habitId),
      (model) => model.toEntity(),
    );
  }

  @override
  Stream<Either<Failure, List<Completion>>> watchCompletions({
    required DateKey from,
    required DateKey to,
  }) {
    return _guardStream(
      () => _remote.watchCompletions(from: from, to: to),
      (models) => [for (final model in models) model.toEntity()],
    );
  }

  @override
  Future<Either<Failure, Unit>> addHabit(NewHabit habit) {
    return _guard(() => _remote.addHabit(habit));
  }

  @override
  Future<Either<Failure, Unit>> setCompletion({
    required String habitId,
    required DateKey dateKey,
    required bool done,
  }) {
    return _guard(
      () =>
          _remote.setCompletion(habitId: habitId, dateKey: dateKey, done: done),
    );
  }

  @override
  Future<Either<Failure, Unit>> deleteHabit(String habitId) {
    return _guard(() => _remote.deleteHabit(habitId));
  }

  Future<Either<Failure, Unit>> _guard(Future<void> Function() action) async {
    try {
      await action();
      return right(unit);
    } on Exception catch (error) {
      return left(mapExceptionToFailure(error));
    }
  }

  /// Maps each emission and turns any exception (including one thrown while
  /// opening the stream or mapping a malformed document) into a single
  /// `Left`, after which the stream ends.
  ///
  /// Deliberately not an `async*` generator: those only notice a cancelled
  /// subscription at their next `yield`, which would keep the Firestore
  /// listener alive until the next snapshot.
  Stream<Either<Failure, R>> _guardStream<T, R>(
    Stream<T> Function() open,
    R Function(T value) map,
  ) {
    final Stream<T> source;
    try {
      source = open();
    } on Exception catch (error) {
      return Stream.value(left(mapExceptionToFailure(error)));
    }
    return source
        .map<Either<Failure, R>>((value) => right(map(value)))
        .onErrorReturnWith((error, _) => left(mapExceptionToFailure(error)));
  }
}

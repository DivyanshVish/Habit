import 'package:fpdart/fpdart.dart';
import 'package:habit_tracker/core/data/exception_mapper.dart';
import 'package:habit_tracker/core/error/failure.dart';
import 'package:habit_tracker/core/time/date_key.dart';
import 'package:habit_tracker/features/groups/domain/entities/cycle_snapshot.dart';
import 'package:habit_tracker/features/groups/domain/entities/group_entities.dart';
import 'package:habit_tracker/features/shared_habits/data/datasources/shared_habit_remote_data_source.dart';
import 'package:habit_tracker/features/shared_habits/domain/entities/shared_habit_entities.dart';
import 'package:habit_tracker/features/shared_habits/domain/repositories/shared_habit_repository.dart';
import 'package:rxdart/rxdart.dart';

class SharedHabitRepositoryImpl implements SharedHabitRepository {
  SharedHabitRepositoryImpl(this._remote);

  final SharedHabitRemoteDataSource _remote;

  @override
  Stream<Either<Failure, List<SharedHabit>>> watchMine() =>
      _guardStream(_remote.watchMine);

  @override
  Stream<Either<Failure, SharedHabit>> watchHabit(String sharedId) =>
      _guardStream(() => _remote.watchHabit(sharedId));

  @override
  Stream<Either<Failure, List<SharedParticipant>>> watchParticipants(
    String sharedId,
  ) => _guardStream(() => _remote.watchParticipants(sharedId));

  @override
  Stream<Either<Failure, CycleSnapshot?>> watchCycle(
    String sharedId,
    DateKey dateKey,
  ) => _guardStream(() => _remote.watchCycle(sharedId, dateKey));

  @override
  Stream<Either<Failure, MyCompletions>> watchMyCompletions(String sharedId) =>
      _guardStream(() => _remote.watchMyCompletions(sharedId));

  @override
  Future<Either<Failure, Unit>> setCompletion({
    required String sharedId,
    required DateKey dateKey,
    required bool done,
  }) => _guard(
    () =>
        _remote.setCompletion(sharedId: sharedId, dateKey: dateKey, done: done),
  );

  @override
  Future<Either<Failure, String>> create(NewSharedHabit habit) async {
    try {
      return right(await _remote.create(habit));
    } on Exception catch (error) {
      return left(mapExceptionToFailure(error));
    }
  }

  @override
  Future<Either<Failure, Unit>> leave(String sharedId) =>
      _guard(() => _remote.leave(sharedId));

  Future<Either<Failure, Unit>> _guard(Future<void> Function() action) async {
    try {
      await action();
      return right(unit);
    } on Exception catch (error) {
      return left(mapExceptionToFailure(error));
    }
  }

  Stream<Either<Failure, T>> _guardStream<T>(Stream<T> Function() open) {
    final Stream<T> source;
    try {
      source = open();
    } on Exception catch (error) {
      return Stream.value(left(mapExceptionToFailure(error)));
    }
    return source
        .map<Either<Failure, T>>(right)
        .onErrorReturnWith((error, _) => left(mapExceptionToFailure(error)));
  }
}

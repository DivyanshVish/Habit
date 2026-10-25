import 'package:fpdart/fpdart.dart';
import 'package:habit_tracker/core/error/failure.dart';
import 'package:habit_tracker/core/time/date_key.dart';
import 'package:habit_tracker/features/groups/domain/entities/cycle_snapshot.dart';
import 'package:habit_tracker/features/groups/domain/entities/group_entities.dart';
import 'package:habit_tracker/features/shared_habits/domain/entities/shared_habit_entities.dart';

abstract interface class SharedHabitRepository {
  /// Shared habits I take part in.
  Stream<Either<Failure, List<SharedHabit>>> watchMine();

  Stream<Either<Failure, SharedHabit>> watchHabit(String sharedId);

  Stream<Either<Failure, List<SharedParticipant>>> watchParticipants(
    String sharedId,
  );

  Stream<Either<Failure, CycleSnapshot?>> watchCycle(
    String sharedId,
    DateKey dateKey,
  );

  Stream<Either<Failure, MyCompletions>> watchMyCompletions(String sharedId);

  Future<Either<Failure, Unit>> setCompletion({
    required String sharedId,
    required DateKey dateKey,
    required bool done,
  });

  Future<Either<Failure, String>> create(NewSharedHabit habit);

  Future<Either<Failure, Unit>> leave(String sharedId);
}

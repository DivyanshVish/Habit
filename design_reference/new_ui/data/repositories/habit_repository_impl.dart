import '../../domain/entities/habit.dart';
import '../../domain/repositories/habit_repository.dart';
import '../datasources/habit_remote_datasource.dart';

class HabitRepositoryImpl implements HabitRepository {
  HabitRepositoryImpl(this._remote);
  final HabitRemoteDataSource _remote;

  @override
  Stream<List<Habit>> watchHabits() => _remote.watchHabits();

  @override
  Future<void> addHabit({
    required String name,
    required String description,
    required int points,
  }) => _remote.add(name, description, points);

  @override
  Future<void> setCompletion({
    required String habitId,
    required DateTime day,
    required bool done,
  }) => _remote.setCompletion(habitId, day, done);

  @override
  Future<void> deleteHabit(String habitId) => _remote.delete(habitId);
}

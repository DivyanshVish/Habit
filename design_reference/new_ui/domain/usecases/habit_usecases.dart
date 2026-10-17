import '../entities/habit.dart';
import '../repositories/habit_repository.dart';

class WatchHabits {
  const WatchHabits(this._repo);
  final HabitRepository _repo;
  Stream<List<Habit>> call() => _repo.watchHabits();
}

class AddHabit {
  const AddHabit(this._repo);
  final HabitRepository _repo;

  Future<void> call({
    required String name,
    required String description,
    required int points,
  }) {
    final n = name.trim();
    if (n.isEmpty) throw ArgumentError('Habit name is required');
    if (points <= 0) throw ArgumentError('Points must be positive');
    return _repo.addHabit(
      name: n,
      description: description.trim(),
      points: points,
    );
  }
}

class SetHabitCompletion {
  const SetHabitCompletion(this._repo);
  final HabitRepository _repo;

  Future<void> call(Habit habit, {DateTime? day, required bool done}) => _repo
      .setCompletion(habitId: habit.id, day: day ?? DateTime.now(), done: done);
}

class DeleteHabit {
  const DeleteHabit(this._repo);
  final HabitRepository _repo;
  Future<void> call(String id) => _repo.deleteHabit(id);
}

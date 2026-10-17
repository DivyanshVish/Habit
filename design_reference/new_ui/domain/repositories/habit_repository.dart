import '../entities/habit.dart';

abstract interface class HabitRepository {
  Stream<List<Habit>> watchHabits();

  Future<void> addHabit({
    required String name,
    required String description,
    required int points,
  });

  Future<void> setCompletion({
    required String habitId,
    required DateTime day,
    required bool done,
  });

  Future<void> deleteHabit(String habitId);
}

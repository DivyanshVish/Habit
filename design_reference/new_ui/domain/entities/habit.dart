/// Pure Dart. No Flutter or Firebase imports.
class Habit {
  const Habit({
    required this.id,
    required this.name,
    required this.description,
    required this.points,
    required this.createdAt,
    this.completedDates = const {},
  });

  final String id;
  final String name;
  final String description;
  final int points;
  final DateTime createdAt;

  /// Day keys (`yyyy-MM-dd`) on which the habit was completed.
  final Set<String> completedDates;

  static String keyFor(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  bool isDoneOn(DateTime day) => completedDates.contains(keyFor(day));

  /// Oldest → newest; the last entry is [today].
  List<DayStatus> last7Days([DateTime? today]) {
    final t = today ?? DateTime.now();
    return List.generate(7, (i) {
      final d = DateTime(t.year, t.month, t.day - (6 - i));
      return DayStatus(d, isDoneOn(d));
    });
  }

  int get doneDaysThisWeek => last7Days().where((d) => d.done).length;
  int get weekPoints => doneDaysThisWeek * points;

  /// Consecutive done days ending today — or yesterday if today is still open.
  int currentStreak([DateTime? today]) {
    final days = last7Days(today);
    var i = days.last.done ? 6 : 5;
    var n = 0;
    while (i >= 0 && days[i].done) {
      n++;
      i--;
    }
    return n;
  }
}

class DayStatus {
  const DayStatus(this.date, this.done);
  final DateTime date;
  final bool done;
}

/// Aggregate used by the Today header.
class DailyProgress {
  const DailyProgress(this.earned, this.total, this.done, this.count);
  final int earned, total, done, count;

  factory DailyProgress.from(List<Habit> habits, [DateTime? today]) {
    final t = today ?? DateTime.now();
    final done = habits.where((h) => h.isDoneOn(t)).toList();
    return DailyProgress(
      done.fold(0, (a, h) => a + h.points),
      habits.fold(0, (a, h) => a + h.points),
      done.length,
      habits.length,
    );
  }

  double get fraction => total == 0 ? 0 : earned / total;
}

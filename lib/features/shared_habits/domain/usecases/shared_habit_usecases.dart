import 'package:fpdart/fpdart.dart';
import 'package:habit_tracker/core/error/failure.dart';
import 'package:habit_tracker/core/time/clock.dart';
import 'package:habit_tracker/core/time/date_key.dart';
import 'package:habit_tracker/core/usecase/usecase.dart';
import 'package:habit_tracker/features/groups/domain/services/history_breakdown_calculator.dart';
import 'package:habit_tracker/features/groups/domain/services/streak_history_calculator.dart';
import 'package:habit_tracker/features/habits/domain/usecases/add_habit.dart';
import 'package:habit_tracker/features/shared_habits/domain/entities/shared_habit_entities.dart';
import 'package:habit_tracker/features/shared_habits/domain/repositories/shared_habit_repository.dart';
import 'package:rxdart/rxdart.dart';

class WatchSharedHabits implements StreamUseCase<List<SharedHabit>, NoParams> {
  WatchSharedHabits(this._repository);

  final SharedHabitRepository _repository;

  /// Active habits first, archived ones last; each group alphabetical.
  @override
  Stream<Either<Failure, List<SharedHabit>>> call(NoParams params) {
    return _repository.watchMine().map(
      (result) => result.map((items) {
        final sorted = [...items];
        sorted.sort((a, b) {
          if (a.archived != b.archived) return a.archived ? 1 : -1;
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });
        return sorted;
      }),
    );
  }
}

class WatchSharedHabitDetail
    implements StreamUseCase<SharedHabitDetail, String> {
  WatchSharedHabitDetail(
    this._repository,
    this._clock,
    this._calculator, [
    this._history = const HistoryBreakdownCalculator(),
  ]);

  final SharedHabitRepository _repository;
  final Clock _clock;
  final StreakHistoryCalculator _calculator;
  final HistoryBreakdownCalculator _history;

  @override
  Stream<Either<Failure, SharedHabitDetail>> call(String sharedId) {
    final today = DateKey.fromDateTime(_clock.now());
    return Rx.combineLatest4(
      _repository.watchHabit(sharedId),
      _repository.watchParticipants(sharedId),
      _repository.watchCycle(sharedId, today),
      _repository.watchMyCompletions(sharedId),
      (habit, participants, cycle, mine) {
        final failure = [habit, participants, cycle, mine]
            .map((r) => r.getLeft().toNullable())
            .firstWhere((f) => f != null, orElse: () => null);
        if (failure != null) return left<Failure, SharedHabitDetail>(failure);

        final h = habit.getRight().toNullable()!;
        final completions = mine.getRight().toNullable()!;
        return right<Failure, SharedHabitDetail>(
          SharedHabitDetail(
            habit: h,
            participants: participants.getRight().toNullable()!,
            today: today,
            cycle: cycle.getRight().toNullable(),
            doneToday: completions.dates.contains(today),
            pendingSync: completions.hasPendingWrites,
            personalStats: _calculator.calculate(
              doneDates: completions.dates,
              start: h.startDate,
              today: today,
              scheduledWeekdays: h.weekdays,
            ),
            history: _history.calculate(
              doneDates: completions.dates,
              start: h.startDate,
              today: today,
              scheduledWeekdays: h.weekdays,
            ),
          ),
        );
      },
    );
  }
}

class SetSharedCompletionParams {
  const SetSharedCompletionParams({
    required this.sharedId,
    required this.dateKey,
    required this.done,
  });

  final String sharedId;
  final DateKey dateKey;
  final bool done;
}

class SetSharedCompletion implements UseCase<Unit, SetSharedCompletionParams> {
  SetSharedCompletion(this._repository);

  final SharedHabitRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(SetSharedCompletionParams params) {
    return _repository.setCompletion(
      sharedId: params.sharedId,
      dateKey: params.dateKey,
      done: params.done,
    );
  }
}

class CreateSharedHabitParams {
  const CreateSharedHabitParams({
    required this.name,
    this.description = '',
    this.points = 10,
    this.weekdays = const {1, 2, 3, 4, 5, 6, 7},
    required this.startDate,
    this.sourceHabitId,
  });

  final String name;
  final String description;
  final int points;
  final Set<int> weekdays;
  final DateKey startDate;
  final String? sourceHabitId;
}

class CreateSharedHabit implements UseCase<String, CreateSharedHabitParams> {
  CreateSharedHabit(this._repository);

  final SharedHabitRepository _repository;

  @override
  Future<Either<Failure, String>> call(CreateSharedHabitParams params) async {
    final name = params.name.trim();
    final description = params.description.trim();
    if (name.isEmpty || name.length > HabitRules.maxNameLength) {
      return left(
        const Failure.validation(
          message: 'Name must be 1 to ${HabitRules.maxNameLength} characters.',
        ),
      );
    }
    if (description.length > HabitRules.maxDescriptionLength) {
      return left(
        const Failure.validation(
          message:
              'Description can be up to ${HabitRules.maxDescriptionLength} '
              'characters.',
        ),
      );
    }
    if (params.points < HabitRules.minPoints ||
        params.points > HabitRules.maxPoints) {
      return left(
        const Failure.validation(
          message:
              'Points must be ${HabitRules.minPoints} to '
              '${HabitRules.maxPoints}.',
        ),
      );
    }
    if (params.weekdays.isEmpty ||
        params.weekdays.any((day) => day < 1 || day > 7)) {
      return left(
        const Failure.validation(message: 'Pick at least one day of the week.'),
      );
    }
    return _repository.create(
      NewSharedHabit(
        name: name,
        description: description,
        points: params.points,
        weekdays: params.weekdays,
        startDate: params.startDate,
        sourceHabitId: params.sourceHabitId,
      ),
    );
  }
}

class LeaveSharedHabit implements UseCase<Unit, String> {
  LeaveSharedHabit(this._repository);

  final SharedHabitRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(String sharedId) =>
      _repository.leave(sharedId);
}

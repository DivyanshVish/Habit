import 'package:fpdart/fpdart.dart';
import 'package:habit_tracker/core/data/exception_mapper.dart';
import 'package:habit_tracker/core/error/failure.dart';
import 'package:habit_tracker/core/time/date_key.dart';
import 'package:habit_tracker/features/groups/data/datasources/group_remote_data_source.dart';
import 'package:habit_tracker/features/groups/domain/entities/completion_rule.dart';
import 'package:habit_tracker/features/groups/domain/entities/cycle_snapshot.dart';
import 'package:habit_tracker/features/groups/domain/entities/group_entities.dart';
import 'package:habit_tracker/features/groups/domain/repositories/group_repository.dart';
import 'package:rxdart/rxdart.dart';

class GroupRepositoryImpl implements GroupRepository {
  GroupRepositoryImpl(this._remote);

  final GroupRemoteDataSource _remote;

  @override
  Stream<Either<Failure, List<GroupMembership>>> watchMemberships() =>
      _guardStream(_remote.watchMemberships);

  @override
  Stream<Either<Failure, HabitGroup>> watchGroup(String groupId) =>
      _guardStream(() => _remote.watchGroup(groupId));

  @override
  Stream<Either<Failure, List<GroupMember>>> watchMembers(
    String groupId, {
    int limit = 50,
  }) => _guardStream(() => _remote.watchMembers(groupId, limit: limit));

  @override
  Stream<Either<Failure, List<GroupHabit>>> watchHabits(String groupId) =>
      _guardStream(() => _remote.watchHabits(groupId));

  @override
  Stream<Either<Failure, GroupHabit>> watchHabit(
    String groupId,
    String habitId,
  ) => _guardStream(() => _remote.watchHabit(groupId, habitId));

  @override
  Stream<Either<Failure, CycleSnapshot?>> watchCycle(
    String groupId,
    String habitId,
    DateKey dateKey,
  ) => _guardStream(() => _remote.watchCycle(groupId, habitId, dateKey));

  @override
  Stream<Either<Failure, MyCompletions>> watchMyCompletions(
    String groupId,
    String habitId,
  ) => _guardStream(() => _remote.watchMyCompletions(groupId, habitId));

  @override
  Future<Either<Failure, Unit>> setCompletion({
    required String groupId,
    required String habitId,
    required DateKey dateKey,
    required bool done,
  }) => _guard(
    () => _remote.setCompletion(
      groupId: groupId,
      habitId: habitId,
      dateKey: dateKey,
      done: done,
    ),
  );

  @override
  Stream<Either<Failure, List<JoinRequest>>> watchJoinRequests(
    String groupId,
  ) => _guardStream(() => _remote.watchJoinRequests(groupId));

  @override
  Stream<Either<Failure, List<AuditEntry>>> watchAudit(
    String groupId, {
    int limit = 30,
  }) => _guardStream(() => _remote.watchAudit(groupId, limit: limit));

  @override
  Future<Either<Failure, Unit>> reviewJoinRequest({
    required String groupId,
    required String uid,
    required bool approve,
  }) => _guard(
    () =>
        _remote.reviewJoinRequest(groupId: groupId, uid: uid, approve: approve),
  );

  @override
  Future<Either<Failure, String>> createGroup({
    required String name,
    required String description,
    required bool membersCanInvite,
    bool requireApproval = false,
    GroupEmblem? emblem,
  }) => _guardValue(
    () => _remote.createGroup(
      name: name,
      description: description,
      membersCanInvite: membersCanInvite,
      requireApproval: requireApproval,
      emblem: emblem,
    ),
  );

  @override
  Future<Either<Failure, Unit>> updateSettings({
    required String groupId,
    String? name,
    String? description,
    bool? membersCanInvite,
    bool? requireApproval,
    GroupEmblem? emblem,
  }) => _guard(
    () => _remote.updateSettings(
      groupId: groupId,
      name: name,
      description: description,
      membersCanInvite: membersCanInvite,
      requireApproval: requireApproval,
      emblem: emblem,
    ),
  );

  @override
  Future<Either<Failure, Unit>> leave(String groupId) =>
      _guard(() => _remote.leave(groupId));

  @override
  Future<Either<Failure, Unit>> removeMember(String groupId, String uid) =>
      _guard(() => _remote.removeMember(groupId, uid));

  @override
  Future<Either<Failure, Unit>> setRole(
    String groupId,
    String uid,
    MemberRole role,
  ) => _guard(() => _remote.setRole(groupId, uid, role));

  @override
  Future<Either<Failure, Unit>> transferOwnership(String groupId, String uid) =>
      _guard(() => _remote.transferOwnership(groupId, uid));

  @override
  Future<Either<Failure, Unit>> archive(String groupId) =>
      _guard(() => _remote.archive(groupId));

  @override
  Future<Either<Failure, String>> createHabit(
    String groupId,
    NewGroupHabit habit,
  ) => _guardValue(() => _remote.createHabit(groupId, habit));

  @override
  Future<Either<Failure, Unit>> updateHabit({
    required String groupId,
    required String habitId,
    String? name,
    String? description,
    Set<int>? weekdays,
    CompletionRule? target,
    DateKey? endDate,
    bool clearEndDate = false,
  }) => _guard(
    () => _remote.updateHabit(
      groupId: groupId,
      habitId: habitId,
      name: name,
      description: description,
      weekdays: weekdays,
      target: target,
      endDate: endDate,
      clearEndDate: clearEndDate,
    ),
  );

  @override
  Future<Either<Failure, Unit>> archiveHabit(String groupId, String habitId) =>
      _guard(() => _remote.archiveHabit(groupId, habitId));

  Future<Either<Failure, Unit>> _guard(Future<void> Function() action) async {
    try {
      await action();
      return right(unit);
    } on Exception catch (error) {
      return left(mapExceptionToFailure(error));
    }
  }

  Future<Either<Failure, T>> _guardValue<T>(Future<T> Function() action) async {
    try {
      return right(await action());
    } on Exception catch (error) {
      return left(mapExceptionToFailure(error));
    }
  }

  /// Same approach as the habits repository: not an `async*` generator, so a
  /// cancelled subscription closes the Firestore listener immediately.
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

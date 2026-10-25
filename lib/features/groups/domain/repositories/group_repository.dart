import 'package:fpdart/fpdart.dart';
import 'package:habit_tracker/core/error/failure.dart';
import 'package:habit_tracker/core/time/date_key.dart';
import 'package:habit_tracker/features/groups/domain/entities/completion_rule.dart';
import 'package:habit_tracker/features/groups/domain/entities/cycle_snapshot.dart';
import 'package:habit_tracker/features/groups/domain/entities/group_entities.dart';

/// Reads come straight from Firestore, protected by security rules. Anything
/// that changes who can see what goes through a Cloud Function, which checks
/// roles on the server.
abstract interface class GroupRepository {
  Stream<Either<Failure, List<GroupMembership>>> watchMemberships();

  Stream<Either<Failure, HabitGroup>> watchGroup(String groupId);

  /// Newest [limit] members. HabitGroup size is capped on the server.
  Stream<Either<Failure, List<GroupMember>>> watchMembers(
    String groupId, {
    int limit = 50,
  });

  Stream<Either<Failure, List<GroupHabit>>> watchHabits(String groupId);

  Stream<Either<Failure, GroupHabit>> watchHabit(
    String groupId,
    String habitId,
  );

  /// Emits null when no cycle has been opened for that day (for example a day
  /// the habit is not scheduled).
  Stream<Either<Failure, CycleSnapshot?>> watchCycle(
    String groupId,
    String habitId,
    DateKey dateKey,
  );

  Stream<Either<Failure, MyCompletions>> watchMyCompletions(
    String groupId,
    String habitId,
  );

  Future<Either<Failure, Unit>> setCompletion({
    required String groupId,
    required String habitId,
    required DateKey dateKey,
    required bool done,
  });

  /// Admins only (the rules refuse everyone else).
  Stream<Either<Failure, List<JoinRequest>>> watchJoinRequests(String groupId);

  /// Admins only. Newest first, [limit] entries.
  Stream<Either<Failure, List<AuditEntry>>> watchAudit(
    String groupId, {
    int limit = 30,
  });

  Future<Either<Failure, Unit>> reviewJoinRequest({
    required String groupId,
    required String uid,
    required bool approve,
  });

  Future<Either<Failure, String>> createGroup({
    required String name,
    required String description,
    required bool membersCanInvite,
    bool requireApproval = false,
    GroupEmblem? emblem,
  });

  Future<Either<Failure, Unit>> updateSettings({
    required String groupId,
    String? name,
    String? description,
    bool? membersCanInvite,
    bool? requireApproval,
    GroupEmblem? emblem,
  });

  Future<Either<Failure, Unit>> leave(String groupId);

  Future<Either<Failure, Unit>> removeMember(String groupId, String uid);

  Future<Either<Failure, Unit>> setRole(
    String groupId,
    String uid,
    MemberRole role,
  );

  Future<Either<Failure, Unit>> transferOwnership(String groupId, String uid);

  Future<Either<Failure, Unit>> archive(String groupId);

  Future<Either<Failure, String>> createHabit(
    String groupId,
    NewGroupHabit habit,
  );

  Future<Either<Failure, Unit>> updateHabit({
    required String groupId,
    required String habitId,
    String? name,
    String? description,
    Set<int>? weekdays,
    CompletionRule? target,
    DateKey? endDate,
    bool clearEndDate = false,
  });

  Future<Either<Failure, Unit>> archiveHabit(String groupId, String habitId);
}

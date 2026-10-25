import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:habit_tracker/core/time/date_key.dart';
import 'package:habit_tracker/features/groups/domain/entities/completion_rule.dart';

part 'group_entities.freezed.dart';

enum MemberRole {
  owner,
  admin,
  member;

  bool get isAdmin => this != MemberRole.member;

  static MemberRole fromWireName(String? value) => MemberRole.values.firstWhere(
    (role) => role.name == value,
    orElse: () => MemberRole.member,
  );
}

enum MembershipStatus {
  active,
  left,
  removed;

  static MembershipStatus fromWireName(String? value) =>
      MembershipStatus.values.firstWhere(
        (status) => status.name == value,
        orElse: () => MembershipStatus.left,
      );
}

/// A group's picture: a preset icon and colour instead of an uploaded image.
/// [icon] is one of [GroupEmblem.icons]; [color] is an index below
/// [GroupEmblem.colorCount].
@freezed
abstract class GroupEmblem with _$GroupEmblem {
  const factory GroupEmblem({required String icon, required int color}) =
      _GroupEmblem;

  static const List<String> icons = [
    'fitness',
    'book',
    'run',
    'heart',
    'star',
    'leaf',
    'coffee',
    'music',
    'study',
    'water',
    'sleep',
    'people',
  ];

  static const int colorCount = 8;

  /// Used when a group has not picked one.
  static const GroupEmblem fallback = GroupEmblem(icon: 'people', color: 0);
}

/// One row in "my groups". Kept per user by the server.
@freezed
abstract class GroupMembership with _$GroupMembership {
  const factory GroupMembership({
    required String groupId,
    required String groupName,
    required MemberRole role,
    required MembershipStatus status,
    required bool groupArchived,
    GroupEmblem? emblem,
  }) = _GroupMembership;
}

@freezed
abstract class HabitGroup with _$HabitGroup {
  const factory HabitGroup({
    required String id,
    required String name,
    required String description,
    required String ownerUid,
    required int memberCount,
    required bool membersCanInvite,
    required bool archived,
    GroupEmblem? emblem,

    /// When true, joining with a code only files a request that an admin
    /// approves or rejects.
    @Default(false) bool requireApproval,
  }) = _HabitGroup;
}

@freezed
abstract class GroupMember with _$GroupMember {
  const factory GroupMember({
    required String uid,
    required String displayName,
    required MemberRole role,
    required bool active,
  }) = _GroupMember;
}

@freezed
abstract class GroupStreak with _$GroupStreak {
  const factory GroupStreak({required int current, required int best}) =
      _GroupStreak;
}

@freezed
abstract class GroupHabit with _$GroupHabit {
  const factory GroupHabit({
    required String id,
    required String name,
    required String description,
    required Set<int> weekdays,
    required CompletionRule target,
    required DateKey startDate,
    required DateKey? endDate,
    required bool archived,
    required GroupStreak groupStreak,

    /// When a queued schedule or target change starts, if there is one.
    required DateKey? pendingFrom,
  }) = _GroupHabit;
}

/// Input for creating a group habit.
@freezed
abstract class NewGroupHabit with _$NewGroupHabit {
  const factory NewGroupHabit({
    required String name,
    required String description,
    required Set<int> weekdays,
    required CompletionRule target,
    required DateKey startDate,
    DateKey? endDate,
  }) = _NewGroupHabit;
}

/// The signed-in user's own completions of one habit, plus whether any of them
/// is still waiting for the server (offline or in flight).
@freezed
abstract class MyCompletions with _$MyCompletions {
  const factory MyCompletions({
    required Set<DateKey> dates,
    required bool hasPendingWrites,
  }) = _MyCompletions;
}

/// Somebody who used a code on a group that wants approval.
@freezed
abstract class JoinRequest with _$JoinRequest {
  const factory JoinRequest({
    required String uid,
    required String displayName,
  }) = _JoinRequest;
}

/// One line of a group's activity log. Only admins can read it.
@freezed
abstract class AuditEntry with _$AuditEntry {
  const factory AuditEntry({
    required String id,
    required String action,
    required String actorUid,
    required DateTime? at,
    required Map<String, Object?> details,
  }) = _AuditEntry;
}

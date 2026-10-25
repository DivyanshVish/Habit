import 'package:fpdart/fpdart.dart';
import 'package:habit_tracker/core/error/failure.dart';
import 'package:habit_tracker/core/time/clock.dart';
import 'package:habit_tracker/core/time/date_key.dart';
import 'package:habit_tracker/core/usecase/usecase.dart';
import 'package:habit_tracker/features/groups/domain/entities/completion_rule.dart';
import 'package:habit_tracker/features/groups/domain/entities/group_entities.dart';
import 'package:habit_tracker/features/groups/domain/entities/group_habit_detail.dart';
import 'package:habit_tracker/features/groups/domain/repositories/group_repository.dart';
import 'package:habit_tracker/features/groups/domain/services/history_breakdown_calculator.dart';
import 'package:habit_tracker/features/groups/domain/services/streak_history_calculator.dart';
import 'package:rxdart/rxdart.dart';

/// Input limits. Shared with the form validators and mirrored on the server.
class GroupRules {
  const GroupRules._();

  static const int nameMax = 60;
  static const int descriptionMax = 300;
  static const int habitDescriptionMax = 200;
}

Failure _invalid(String message) => Failure.validation(message: message);

// ---------------------------------------------------------------------------
// Groups
// ---------------------------------------------------------------------------

class CreateGroupParams {
  const CreateGroupParams({
    required this.name,
    this.description = '',
    this.membersCanInvite = false,
    this.requireApproval = false,
    this.emblem,
  });

  final String name;
  final String description;
  final bool membersCanInvite;
  final bool requireApproval;
  final GroupEmblem? emblem;
}

class CreateGroup implements UseCase<String, CreateGroupParams> {
  CreateGroup(this._repository);

  final GroupRepository _repository;

  @override
  Future<Either<Failure, String>> call(CreateGroupParams params) async {
    final name = params.name.trim();
    final description = params.description.trim();
    if (name.isEmpty) return left(_invalid('Give the group a name.'));
    if (name.length > GroupRules.nameMax) {
      return left(
        _invalid('Keep the name under ${GroupRules.nameMax} characters.'),
      );
    }
    if (description.length > GroupRules.descriptionMax) {
      return left(
        _invalid(
          'Keep the description under ${GroupRules.descriptionMax} characters.',
        ),
      );
    }
    return _repository.createGroup(
      name: name,
      description: description,
      membersCanInvite: params.membersCanInvite,
      requireApproval: params.requireApproval,
      emblem: params.emblem,
    );
  }
}

class UpdateGroupSettingsParams {
  const UpdateGroupSettingsParams({
    required this.groupId,
    this.name,
    this.description,
    this.membersCanInvite,
    this.requireApproval,
    this.emblem,
  });

  final String groupId;
  final String? name;
  final String? description;
  final bool? membersCanInvite;
  final bool? requireApproval;
  final GroupEmblem? emblem;
}

/// Admins rename the group, change who may invite, whether joining needs
/// approval, and the emblem. Only the fields given are sent.
class UpdateGroupSettings implements UseCase<Unit, UpdateGroupSettingsParams> {
  UpdateGroupSettings(this._repository);

  final GroupRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(UpdateGroupSettingsParams params) {
    final name = params.name?.trim();
    final description = params.description?.trim();
    if (name != null && name.isEmpty) {
      return Future.value(left(_invalid('Give the group a name.')));
    }
    if (name != null && name.length > GroupRules.nameMax) {
      return Future.value(
        left(_invalid('Keep the name under ${GroupRules.nameMax} characters.')),
      );
    }
    if (description != null && description.length > GroupRules.descriptionMax) {
      return Future.value(
        left(
          _invalid(
            'Keep the description under '
            '${GroupRules.descriptionMax} characters.',
          ),
        ),
      );
    }
    return _repository.updateSettings(
      groupId: params.groupId,
      name: name,
      description: description,
      membersCanInvite: params.membersCanInvite,
      requireApproval: params.requireApproval,
      emblem: params.emblem,
    );
  }
}

class WatchJoinRequests implements StreamUseCase<List<JoinRequest>, String> {
  WatchJoinRequests(this._repository);

  final GroupRepository _repository;

  @override
  Stream<Either<Failure, List<JoinRequest>>> call(String groupId) =>
      _repository.watchJoinRequests(groupId);
}

class ReviewJoinRequestParams {
  const ReviewJoinRequestParams({
    required this.groupId,
    required this.uid,
    required this.approve,
  });

  final String groupId;
  final String uid;
  final bool approve;
}

class ReviewJoinRequest implements UseCase<Unit, ReviewJoinRequestParams> {
  ReviewJoinRequest(this._repository);

  final GroupRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(ReviewJoinRequestParams params) =>
      _repository.reviewJoinRequest(
        groupId: params.groupId,
        uid: params.uid,
        approve: params.approve,
      );
}

class WatchAuditParams {
  const WatchAuditParams({required this.groupId, this.limit = 30});

  final String groupId;
  final int limit;
}

class WatchGroupAudit
    implements StreamUseCase<List<AuditEntry>, WatchAuditParams> {
  WatchGroupAudit(this._repository);

  final GroupRepository _repository;

  @override
  Stream<Either<Failure, List<AuditEntry>>> call(WatchAuditParams params) =>
      _repository.watchAudit(params.groupId, limit: params.limit);
}

class WatchMemberships
    implements StreamUseCase<List<GroupMembership>, NoParams> {
  WatchMemberships(this._repository);

  final GroupRepository _repository;

  /// Active memberships first, then the rest; archived groups sink.
  @override
  Stream<Either<Failure, List<GroupMembership>>> call(NoParams params) {
    return _repository.watchMemberships().map(
      (result) => result.map((items) {
        final visible = items
            .where((m) => m.status == MembershipStatus.active)
            .toList();
        visible.sort((a, b) {
          if (a.groupArchived != b.groupArchived) {
            return a.groupArchived ? 1 : -1;
          }
          return a.groupName.toLowerCase().compareTo(b.groupName.toLowerCase());
        });
        return visible;
      }),
    );
  }
}

class GroupOverview {
  const GroupOverview({
    required this.group,
    required this.members,
    required this.habits,
    required this.myRole,
  });

  final HabitGroup group;
  final List<GroupMember> members;
  final List<GroupHabit> habits;
  final MemberRole myRole;
}

class WatchGroupOverviewParams {
  const WatchGroupOverviewParams({required this.groupId, required this.myUid});

  final String groupId;
  final String myUid;
}

class WatchGroupOverview
    implements StreamUseCase<GroupOverview, WatchGroupOverviewParams> {
  WatchGroupOverview(this._repository);

  final GroupRepository _repository;

  @override
  Stream<Either<Failure, GroupOverview>> call(WatchGroupOverviewParams params) {
    return Rx.combineLatest3(
      _repository.watchGroup(params.groupId),
      _repository.watchMembers(params.groupId),
      _repository.watchHabits(params.groupId),
      (group, members, habits) {
        final failure = [group, members, habits]
            .map((r) => r.getLeft().toNullable())
            .firstWhere((f) => f != null, orElse: () => null);
        if (failure != null) return left<Failure, GroupOverview>(failure);

        final memberList = members.getRight().toNullable()!;
        final me = memberList.where((m) => m.uid == params.myUid);
        return right<Failure, GroupOverview>(
          GroupOverview(
            group: group.getRight().toNullable()!,
            members: memberList.where((m) => m.active).toList(),
            habits: habits.getRight().toNullable()!,
            myRole: me.isEmpty ? MemberRole.member : me.first.role,
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// HabitGroup habits
// ---------------------------------------------------------------------------

class CreateGroupHabitParams {
  const CreateGroupHabitParams({
    required this.groupId,
    required this.name,
    required this.description,
    required this.weekdays,
    required this.target,
    required this.startDate,
    this.endDate,
  });

  final String groupId;
  final String name;
  final String description;
  final Set<int> weekdays;
  final CompletionRule target;
  final DateKey startDate;
  final DateKey? endDate;
}

class CreateGroupHabit implements UseCase<String, CreateGroupHabitParams> {
  CreateGroupHabit(this._repository);

  final GroupRepository _repository;

  @override
  Future<Either<Failure, String>> call(CreateGroupHabitParams params) async {
    final name = params.name.trim();
    final description = params.description.trim();
    if (name.isEmpty) return left(_invalid('Give the habit a name.'));
    if (name.length > GroupRules.nameMax) {
      return left(
        _invalid('Keep the name under ${GroupRules.nameMax} characters.'),
      );
    }
    if (description.length > GroupRules.habitDescriptionMax) {
      return left(
        _invalid(
          'Keep the description under '
          '${GroupRules.habitDescriptionMax} characters.',
        ),
      );
    }
    if (params.weekdays.isEmpty ||
        params.weekdays.any((day) => day < 1 || day > 7)) {
      return left(_invalid('Pick at least one day of the week.'));
    }
    if (!params.target.isValid) {
      return left(_invalid('That target is not valid.'));
    }
    final end = params.endDate;
    if (end != null && end.isBefore(params.startDate)) {
      return left(_invalid('The end date must not be before the start.'));
    }
    return _repository.createHabit(
      params.groupId,
      NewGroupHabit(
        name: name,
        description: description,
        weekdays: params.weekdays,
        target: params.target,
        startDate: params.startDate,
        endDate: end,
      ),
    );
  }
}

class UpdateGroupHabitParams {
  const UpdateGroupHabitParams({
    required this.groupId,
    required this.habitId,
    this.name,
    this.description,
    this.weekdays,
    this.target,
    this.endDate,
    this.clearEndDate = false,
    this.startDate,
  });

  final String groupId;
  final String habitId;
  final String? name;
  final String? description;
  final Set<int>? weekdays;
  final CompletionRule? target;
  final DateKey? endDate;
  final bool clearEndDate;

  /// The habit's start date, used only to check the new end date.
  final DateKey? startDate;
}

/// Edits an existing group habit. A new schedule or target starts two days
/// from now (the server decides), so days already open are never rewritten.
class UpdateGroupHabit implements UseCase<Unit, UpdateGroupHabitParams> {
  UpdateGroupHabit(this._repository);

  final GroupRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(UpdateGroupHabitParams params) {
    final name = params.name?.trim();
    final description = params.description?.trim();
    if (name != null && name.isEmpty) {
      return Future.value(left(_invalid('Give the habit a name.')));
    }
    if (name != null && name.length > GroupRules.nameMax) {
      return Future.value(
        left(_invalid('Keep the name under ${GroupRules.nameMax} characters.')),
      );
    }
    if (description != null &&
        description.length > GroupRules.habitDescriptionMax) {
      return Future.value(
        left(
          _invalid(
            'Keep the description under '
            '${GroupRules.habitDescriptionMax} characters.',
          ),
        ),
      );
    }
    final weekdays = params.weekdays;
    if (weekdays != null &&
        (weekdays.isEmpty || weekdays.any((day) => day < 1 || day > 7))) {
      return Future.value(left(_invalid('Pick at least one day of the week.')));
    }
    final target = params.target;
    if (target != null && !target.isValid) {
      return Future.value(left(_invalid('That target is not valid.')));
    }
    final end = params.endDate;
    final start = params.startDate;
    if (end != null && start != null && end.isBefore(start)) {
      return Future.value(
        left(_invalid('The end date must not be before the start.')),
      );
    }
    return _repository.updateHabit(
      groupId: params.groupId,
      habitId: params.habitId,
      name: name,
      description: description,
      weekdays: weekdays,
      target: target,
      endDate: end,
      clearEndDate: params.clearEndDate,
    );
  }
}

class SetGroupCompletionParams {
  const SetGroupCompletionParams({
    required this.groupId,
    required this.habitId,
    required this.dateKey,
    required this.done,
  });

  final String groupId;
  final String habitId;
  final DateKey dateKey;
  final bool done;
}

/// Records the signed-in member's own completion. Nobody can complete on
/// behalf of someone else; the rules enforce it too.
class SetGroupCompletion implements UseCase<Unit, SetGroupCompletionParams> {
  SetGroupCompletion(this._repository);

  final GroupRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(SetGroupCompletionParams params) {
    return _repository.setCompletion(
      groupId: params.groupId,
      habitId: params.habitId,
      dateKey: params.dateKey,
      done: params.done,
    );
  }
}

class GroupHabitRef {
  const GroupHabitRef({required this.groupId, required this.habitId});

  final String groupId;
  final String habitId;
}

class WatchGroupHabitDetail
    implements StreamUseCase<GroupHabitDetail, GroupHabitRef> {
  WatchGroupHabitDetail(
    this._repository,
    this._clock,
    this._calculator, [
    this._history = const HistoryBreakdownCalculator(),
  ]);

  final GroupRepository _repository;
  final Clock _clock;
  final StreakHistoryCalculator _calculator;
  final HistoryBreakdownCalculator _history;

  @override
  Stream<Either<Failure, GroupHabitDetail>> call(GroupHabitRef params) {
    final today = DateKey.fromDateTime(_clock.now());
    return Rx.combineLatest3(
      _repository.watchHabit(params.groupId, params.habitId),
      _repository.watchCycle(params.groupId, params.habitId, today),
      _repository.watchMyCompletions(params.groupId, params.habitId),
      (habit, cycle, mine) {
        final failure = [habit, cycle, mine]
            .map((r) => r.getLeft().toNullable())
            .firstWhere((f) => f != null, orElse: () => null);
        if (failure != null) return left<Failure, GroupHabitDetail>(failure);

        final h = habit.getRight().toNullable()!;
        final completions = mine.getRight().toNullable()!;
        final stats = _calculator.calculate(
          doneDates: completions.dates,
          start: h.startDate,
          today: today,
          scheduledWeekdays: h.weekdays,
        );
        return right<Failure, GroupHabitDetail>(
          GroupHabitDetail(
            habit: h,
            today: today,
            cycle: cycle.getRight().toNullable(),
            doneToday: completions.dates.contains(today),
            pendingSync: completions.hasPendingWrites,
            personalStats: stats,
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

// ---------------------------------------------------------------------------
// Admin and membership actions. Thin on purpose: the server enforces the rules.
// ---------------------------------------------------------------------------

class LeaveGroup implements UseCase<Unit, String> {
  LeaveGroup(this._repository);

  final GroupRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(String groupId) =>
      _repository.leave(groupId);
}

class ArchiveGroup implements UseCase<Unit, String> {
  ArchiveGroup(this._repository);

  final GroupRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(String groupId) =>
      _repository.archive(groupId);
}

class MemberTarget {
  const MemberTarget(this.groupId, this.uid);

  final String groupId;
  final String uid;
}

class RemoveGroupMember implements UseCase<Unit, MemberTarget> {
  RemoveGroupMember(this._repository);

  final GroupRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(MemberTarget params) =>
      _repository.removeMember(params.groupId, params.uid);
}

class TransferGroupOwnership implements UseCase<Unit, MemberTarget> {
  TransferGroupOwnership(this._repository);

  final GroupRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(MemberTarget params) =>
      _repository.transferOwnership(params.groupId, params.uid);
}

class SetMemberRoleParams {
  const SetMemberRoleParams(this.groupId, this.uid, this.role);

  final String groupId;
  final String uid;
  final MemberRole role;
}

class SetMemberRole implements UseCase<Unit, SetMemberRoleParams> {
  SetMemberRole(this._repository);

  final GroupRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(SetMemberRoleParams params) {
    // Ownership has its own flow, so it cannot be set here.
    if (params.role == MemberRole.owner) {
      return Future.value(
        left(_invalid('Use transfer ownership to change the owner.')),
      );
    }
    return _repository.setRole(params.groupId, params.uid, params.role);
  }
}

class ArchiveGroupHabit implements UseCase<Unit, GroupHabitRef> {
  ArchiveGroupHabit(this._repository);

  final GroupRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(GroupHabitRef params) =>
      _repository.archiveHabit(params.groupId, params.habitId);
}

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:habit_tracker/core/auth/user_id_provider.dart';
import 'package:habit_tracker/core/error/exceptions.dart';
import 'package:habit_tracker/core/platform/platform_services.dart';
import 'package:habit_tracker/core/time/date_key.dart';
import 'package:habit_tracker/features/groups/data/models/group_mappers.dart';
import 'package:habit_tracker/features/groups/domain/entities/completion_rule.dart';
import 'package:habit_tracker/features/groups/domain/entities/cycle_snapshot.dart';
import 'package:habit_tracker/features/groups/domain/entities/group_entities.dart';
import 'package:habit_tracker/features/habits/data/datasources/habit_remote_data_source.dart'
    show awaitWriteAck;

/// Reads groups from Firestore and sends every membership or admin change to
/// a Cloud Function. Throws exceptions; the repository maps them to failures.
abstract interface class GroupRemoteDataSource {
  Stream<List<GroupMembership>> watchMemberships();
  Stream<HabitGroup> watchGroup(String groupId);
  Stream<List<GroupMember>> watchMembers(String groupId, {int limit = 50});
  Stream<List<GroupHabit>> watchHabits(String groupId);
  Stream<GroupHabit> watchHabit(String groupId, String habitId);
  Stream<CycleSnapshot?> watchCycle(
    String groupId,
    String habitId,
    DateKey dateKey,
  );
  Stream<MyCompletions> watchMyCompletions(String groupId, String habitId);

  Future<void> setCompletion({
    required String groupId,
    required String habitId,
    required DateKey dateKey,
    required bool done,
  });

  Stream<List<JoinRequest>> watchJoinRequests(String groupId);
  Stream<List<AuditEntry>> watchAudit(String groupId, {int limit = 30});
  Future<void> reviewJoinRequest({
    required String groupId,
    required String uid,
    required bool approve,
  });

  Future<String> createGroup({
    required String name,
    required String description,
    required bool membersCanInvite,
    bool requireApproval = false,
    GroupEmblem? emblem,
  });
  Future<void> updateSettings({
    required String groupId,
    String? name,
    String? description,
    bool? membersCanInvite,
    bool? requireApproval,
    GroupEmblem? emblem,
  });
  Future<void> leave(String groupId);
  Future<void> removeMember(String groupId, String uid);
  Future<void> setRole(String groupId, String uid, MemberRole role);
  Future<void> transferOwnership(String groupId, String uid);
  Future<void> archive(String groupId);
  Future<String> createHabit(String groupId, NewGroupHabit habit);
  Future<void> updateHabit({
    required String groupId,
    required String habitId,
    String? name,
    String? description,
    Set<int>? weekdays,
    CompletionRule? target,
    DateKey? endDate,
    bool clearEndDate = false,
  });
  Future<void> archiveHabit(String groupId, String habitId);
}

class GroupRemoteDataSourceImpl implements GroupRemoteDataSource {
  GroupRemoteDataSourceImpl({
    required FirebaseFirestore firestore,
    required UserIdProvider userIdProvider,
    required CallableClient callable,
    this.writeAckTimeout = const Duration(seconds: 3),
  }) : _firestore = firestore,
       _userIdProvider = userIdProvider,
       _callable = callable;

  final FirebaseFirestore _firestore;
  final UserIdProvider _userIdProvider;
  final CallableClient _callable;
  final Duration writeAckTimeout;

  String _uid() {
    final uid = _userIdProvider.currentUserId;
    if (uid == null) throw const UnauthenticatedException();
    return uid;
  }

  /// Asks the server to open today's cycle (first request of the day) and
  /// recompute it from the completions. Best effort: when it fails (offline),
  /// the numbers catch up the next time any member opens the screen or
  /// completes. It never changes what this member has recorded.
  void _refreshCycle(String groupId, String habitId, DateKey dateKey) {
    unawaited(
      _callable
          .call('refreshCycle', {
            'kind': 'group',
            'groupId': groupId,
            'habitId': habitId,
            'dateKey': dateKey.value,
          })
          .then<void>((_) {}, onError: (Object _) {}),
    );
  }

  DocumentReference<Map<String, dynamic>> _group(String id) =>
      _firestore.collection('groups').doc(id);

  DocumentReference<Map<String, dynamic>> _habit(String groupId, String id) =>
      _group(groupId).collection('habits').doc(id);

  @override
  Stream<List<GroupMembership>> watchMemberships() {
    return _firestore
        .collection('users')
        .doc(_uid())
        .collection('memberships')
        .snapshots()
        .map((s) => s.docs.map(GroupMappers.membership).toList());
  }

  @override
  Stream<HabitGroup> watchGroup(String groupId) {
    return _group(groupId).snapshots().map((doc) {
      if (!doc.exists) throw const NotFoundException();
      return GroupMappers.group(doc);
    });
  }

  @override
  Stream<List<GroupMember>> watchMembers(String groupId, {int limit = 50}) {
    return _group(groupId)
        .collection('members')
        .orderBy('joinedAt')
        .limit(limit)
        .snapshots()
        .map((s) => s.docs.map(GroupMappers.member).toList());
  }

  @override
  Stream<List<GroupHabit>> watchHabits(String groupId) {
    return _group(groupId)
        .collection('habits')
        .snapshots()
        .map((s) => s.docs.map(GroupMappers.habit).toList());
  }

  @override
  Stream<GroupHabit> watchHabit(String groupId, String habitId) {
    return _habit(groupId, habitId).snapshots().map((doc) {
      if (!doc.exists) throw const NotFoundException();
      return GroupMappers.habit(doc);
    });
  }

  @override
  Stream<CycleSnapshot?> watchCycle(
    String groupId,
    String habitId,
    DateKey dateKey,
  ) {
    _refreshCycle(groupId, habitId, dateKey);
    return _habit(groupId, habitId)
        .collection('cycles')
        .doc(dateKey.value)
        .snapshots()
        .map((doc) => doc.exists ? GroupMappers.cycle(doc) : null);
  }

  /// Own completions only: the rules let a member read nobody else's. Metadata
  /// changes are included so the screen can show "waiting to sync".
  @override
  Stream<MyCompletions> watchMyCompletions(String groupId, String habitId) {
    return _habit(groupId, habitId)
        .collection('completions')
        .where('uid', isEqualTo: _uid())
        .snapshots(includeMetadataChanges: true)
        .map(
          (snapshot) => MyCompletions(
            dates: {
              for (final doc in snapshot.docs)
                DateKey.parse(doc.data()['dateKey'] as String),
            },
            hasPendingWrites: snapshot.docs.any(
              (doc) => doc.metadata.hasPendingWrites,
            ),
          ),
        );
  }

  /// The id is {uid}_{dateKey}, so repeating the request targets the same
  /// document and can never create a second record.
  @override
  Future<void> setCompletion({
    required String groupId,
    required String habitId,
    required DateKey dateKey,
    required bool done,
  }) async {
    final uid = _uid();
    final doc = _habit(
      groupId,
      habitId,
    ).collection('completions').doc('${uid}_${dateKey.value}');
    final write = done
        ? doc.set({
            'uid': uid,
            'dateKey': dateKey.value,
            'completedAt': FieldValue.serverTimestamp(),
          })
        : doc.delete();
    await awaitWriteAck(write, writeAckTimeout);
    _refreshCycle(groupId, habitId, dateKey);
  }

  @override
  Stream<List<JoinRequest>> watchJoinRequests(String groupId) {
    return _group(groupId)
        .collection('joinRequests')
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((s) => s.docs.map(GroupMappers.joinRequest).toList());
  }

  @override
  Stream<List<AuditEntry>> watchAudit(String groupId, {int limit = 30}) {
    return _group(groupId)
        .collection('auditLog')
        .orderBy('at', descending: true)
        .limit(limit)
        .snapshots()
        .map((s) => s.docs.map(GroupMappers.audit).toList());
  }

  @override
  Future<void> reviewJoinRequest({
    required String groupId,
    required String uid,
    required bool approve,
  }) async {
    await _callable.call('reviewJoinRequest', {
      'groupId': groupId,
      'uid': uid,
      'approve': approve,
    });
  }

  @override
  Future<String> createGroup({
    required String name,
    required String description,
    required bool membersCanInvite,
    bool requireApproval = false,
    GroupEmblem? emblem,
  }) async {
    final result = await _callable.call('createGroup', {
      'name': name,
      'description': description,
      'membersCanInvite': membersCanInvite,
      'requireApproval': requireApproval,
      if (emblem != null) 'emblem': GroupMappers.emblemToWire(emblem),
    });
    return result['groupId'] as String;
  }

  @override
  Future<void> updateSettings({
    required String groupId,
    String? name,
    String? description,
    bool? membersCanInvite,
    bool? requireApproval,
    GroupEmblem? emblem,
  }) async {
    await _callable.call('updateGroupSettings', {
      'groupId': groupId,
      'name': ?name,
      'description': ?description,
      'membersCanInvite': ?membersCanInvite,
      'requireApproval': ?requireApproval,
      if (emblem != null) 'emblem': GroupMappers.emblemToWire(emblem),
    });
  }

  @override
  Future<void> leave(String groupId) async {
    await _callable.call('leaveGroup', {'groupId': groupId});
  }

  @override
  Future<void> removeMember(String groupId, String uid) async {
    await _callable.call('removeMember', {'groupId': groupId, 'uid': uid});
  }

  @override
  Future<void> setRole(String groupId, String uid, MemberRole role) async {
    await _callable.call('setMemberRole', {
      'groupId': groupId,
      'uid': uid,
      'role': role.name,
    });
  }

  @override
  Future<void> transferOwnership(String groupId, String uid) async {
    await _callable.call('transferOwnership', {'groupId': groupId, 'uid': uid});
  }

  @override
  Future<void> archive(String groupId) async {
    await _callable.call('archiveGroup', {'groupId': groupId});
  }

  @override
  Future<String> createHabit(String groupId, NewGroupHabit habit) async {
    final result = await _callable.call('createGroupHabit', {
      'groupId': groupId,
      'name': habit.name,
      'description': habit.description,
      'weekdays': (habit.weekdays.toList()..sort()),
      'target': GroupMappers.ruleToWire(habit.target),
      'startDate': habit.startDate.value,
      'endDate': habit.endDate?.value,
    });
    return result['habitId'] as String;
  }

  @override
  Future<void> updateHabit({
    required String groupId,
    required String habitId,
    String? name,
    String? description,
    Set<int>? weekdays,
    CompletionRule? target,
    DateKey? endDate,
    bool clearEndDate = false,
  }) async {
    await _callable.call('updateGroupHabit', {
      'groupId': groupId,
      'habitId': habitId,
      'name': ?name,
      'description': ?description,
      if (weekdays != null) 'weekdays': (weekdays.toList()..sort()),
      if (target != null) 'target': GroupMappers.ruleToWire(target),
      if (endDate != null) 'endDate': endDate.value,
      if (clearEndDate) 'endDate': null,
    });
  }

  @override
  Future<void> archiveHabit(String groupId, String habitId) async {
    await _callable.call('archiveGroupHabit', {
      'groupId': groupId,
      'habitId': habitId,
    });
  }
}

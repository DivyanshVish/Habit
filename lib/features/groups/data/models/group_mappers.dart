import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:habit_tracker/core/time/date_key.dart';
import 'package:habit_tracker/features/groups/domain/entities/completion_rule.dart';
import 'package:habit_tracker/features/groups/domain/entities/cycle_snapshot.dart';
import 'package:habit_tracker/features/groups/domain/entities/group_entities.dart';

/// Turns Firestore documents into domain entities. A document that is missing
/// a required field throws [FormatException], which the repository reports as
/// a server failure rather than showing half-parsed data.
class GroupMappers {
  const GroupMappers._();

  static T _require<T>(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value is! T) {
      throw FormatException('Missing or invalid "$key"', data);
    }
    return value;
  }

  static GroupEmblem? emblem(Object? raw) {
    if (raw is! Map) return null;
    final icon = raw['icon'];
    final color = raw['color'];
    if (icon is! String || color is! num) return null;
    return GroupEmblem(icon: icon, color: color.toInt());
  }

  static Map<String, dynamic> emblemToWire(GroupEmblem emblem) => {
    'icon': emblem.icon,
    'color': emblem.color,
  };

  static JoinRequest joinRequest(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const <String, dynamic>{};
    return JoinRequest(
      uid: doc.id,
      displayName: (data['displayName'] as String?) ?? 'Habitry user',
    );
  }

  static AuditEntry audit(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const <String, dynamic>{};
    final at = data['at'];
    final details = data['details'];
    return AuditEntry(
      id: doc.id,
      action: (data['action'] as String?) ?? '',
      actorUid: (data['actorUid'] as String?) ?? '',
      at: at is Timestamp ? at.toDate() : null,
      details: details is Map ? Map<String, Object?>.from(details) : const {},
    );
  }

  static GroupMembership membership(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? const <String, dynamic>{};
    return GroupMembership(
      groupId: doc.id,
      groupName: _require<String>(data, 'groupName'),
      role: MemberRole.fromWireName(data['role'] as String?),
      status: MembershipStatus.fromWireName(data['status'] as String?),
      groupArchived: data['groupStatus'] == 'archived',
      emblem: emblem(data['emblem']),
    );
  }

  static HabitGroup group(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const <String, dynamic>{};
    return HabitGroup(
      id: doc.id,
      name: _require<String>(data, 'name'),
      description: (data['description'] as String?) ?? '',
      ownerUid: _require<String>(data, 'ownerUid'),
      memberCount: (data['memberCount'] as num?)?.toInt() ?? 0,
      membersCanInvite: data['membersCanInvite'] == true,
      archived: data['status'] == 'archived',
      emblem: emblem(data['emblem']),
      requireApproval: data['requireApproval'] == true,
    );
  }

  static GroupMember member(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const <String, dynamic>{};
    return GroupMember(
      uid: doc.id,
      displayName: (data['displayName'] as String?) ?? 'Habitry user',
      role: MemberRole.fromWireName(data['role'] as String?),
      active: data['status'] == 'active',
    );
  }

  static CompletionRule rule(Object? raw) {
    if (raw is! Map) return const CompletionRule.individual();
    return CompletionRule(
      CompletionRuleType.fromWireName((raw['type'] as String?) ?? ''),
      value: (raw['value'] as num?)?.toInt(),
    );
  }

  static Map<String, dynamic> ruleToWire(CompletionRule rule) => {
    'type': rule.type.wireName,
    if (rule.value != null) 'value': rule.value,
  };

  static GroupHabit habit(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const <String, dynamic>{};
    final streak = data['groupStreak'];
    final pending = data['pending'];
    final end = data['endDate'];
    return GroupHabit(
      id: doc.id,
      name: _require<String>(data, 'name'),
      description: (data['description'] as String?) ?? '',
      weekdays: {
        for (final day
            in (data['weekdays'] as List? ?? const [1, 2, 3, 4, 5, 6, 7]))
          (day as num).toInt(),
      },
      target: rule(data['target']),
      startDate: DateKey.parse(_require<String>(data, 'startDate')),
      endDate: end is String ? DateKey.parse(end) : null,
      archived: data['status'] == 'archived',
      groupStreak: GroupStreak(
        current: streak is Map ? (streak['current'] as num?)?.toInt() ?? 0 : 0,
        best: streak is Map ? (streak['best'] as num?)?.toInt() ?? 0 : 0,
      ),
      pendingFrom: pending is Map && pending['effectiveFrom'] is String
          ? DateKey.parse(pending['effectiveFrom'] as String)
          : null,
    );
  }

  static CycleSnapshot cycle(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const <String, dynamic>{};
    List<String> strings(String key) => [
      for (final value in (data[key] as List? ?? const [])) value as String,
    ];
    return CycleSnapshot(
      dateKey: DateKey.parse(doc.id),
      eligibleUids: strings('eligibleUids'),
      visibleCompletedUids: strings('visibleCompletedUids'),
      completedCount: (data['completedCount'] as num?)?.toInt() ?? 0,
      rule: rule(data['rule']),
      closed: data['closed'] == true,
    );
  }
}

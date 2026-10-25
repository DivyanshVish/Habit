import 'package:habit_tracker/features/groups/domain/entities/group_entities.dart';

/// One line of the activity log in plain words. [names] maps user ids to the
/// names the group knows; anyone it does not know is "Someone".
String describeAudit(AuditEntry entry, Map<String, String> names) {
  String who(String? uid) =>
      uid == null || uid.isEmpty ? 'Someone' : (names[uid] ?? 'Someone');
  final actor = who(entry.actorUid);
  final details = entry.details;
  String? detail(String key) {
    final value = details[key];
    return value is String && value.isNotEmpty ? value : null;
  }

  switch (entry.action) {
    case 'group.created':
      return '$actor created the group';
    case 'group.updated':
      return '$actor changed the group settings';
    case 'group.archived':
      return '$actor archived the group';
    case 'group.ownership':
      return '$actor made ${who(detail('to'))} the owner';
    case 'member.joined':
      return '$actor joined';
    case 'member.requested':
      return '$actor asked to join';
    case 'member.request_approved':
      return '$actor let ${who(detail('uid'))} in';
    case 'member.request_rejected':
      return '$actor declined ${who(detail('uid'))}';
    case 'member.left':
      return '$actor left the group';
    case 'member.removed':
      return '$actor removed ${who(detail('uid'))}';
    case 'member.role':
      final role = detail('role') == 'admin' ? 'an admin' : 'a member';
      return '$actor made ${who(detail('uid'))} $role';
    case 'member.accountMoved':
      return '$actor moved to a new account';
    case 'habit.created':
      final name = detail('name');
      return name == null
          ? '$actor added a habit'
          : '$actor added the habit "$name"';
    case 'habit.updated':
      return '$actor changed a habit';
    case 'habit.archived':
      return '$actor archived a habit';
    default:
      return '$actor made a change';
  }
}

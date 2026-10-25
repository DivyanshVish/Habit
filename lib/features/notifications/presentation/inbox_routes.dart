import 'package:habit_tracker/core/router/app_routes.dart';
import 'package:habit_tracker/features/notifications/domain/notifications_domain.dart';

/// Where tapping a notification should lead, or null when there is nothing to
/// open. Uses only the ids the server put in the notification.
String? inboxRouteFor(InboxItem item) {
  final data = item.data;
  switch (item.type) {
    case 'invitation.received':
      // The invitation waits on the Groups page.
      return AppRoutes.groups;
    case 'invitation.accepted':
      final id = data['targetId'];
      if (id == null || id.isEmpty) return null;
      return data['type'] == 'group'
          ? AppRoutes.groupDetail(id)
          : AppRoutes.sharedDetail(id);
    case 'group.target_reached':
      final groupId = data['groupId'];
      final habitId = data['habitId'];
      if (groupId == null || habitId == null) return null;
      return AppRoutes.groupHabit(groupId, habitId);
    case 'group.join_request':
    case 'group.request_approved':
      final groupId = data['groupId'];
      return groupId == null || groupId.isEmpty
          ? null
          : AppRoutes.groupDetail(groupId);
    case 'habit.reminder':
      return AppRoutes.today;
    default:
      // Declined invitations, rejected requests and anything newer.
      return null;
  }
}

import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/features/notifications/domain/notifications_domain.dart';
import 'package:habit_tracker/features/notifications/presentation/inbox_routes.dart';

InboxItem _item(String type, [Map<String, String> data = const {}]) =>
    InboxItem(
      id: 'n1',
      type: type,
      title: 't',
      body: 'b',
      read: false,
      createdAt: null,
      data: data,
    );

void main() {
  test('a new invitation leads to the Groups page where it waits', () {
    expect(inboxRouteFor(_item('invitation.received')), '/groups');
  });

  test('an accepted invitation opens what the person joined', () {
    expect(
      inboxRouteFor(
        _item('invitation.accepted', {'type': 'group', 'targetId': 'g1'}),
      ),
      '/groups/g1',
    );
    expect(
      inboxRouteFor(
        _item('invitation.accepted', {'type': 'shared', 'targetId': 's1'}),
      ),
      '/shared/s1',
    );
  });

  test('a reached target opens that group habit', () {
    expect(
      inboxRouteFor(
        _item('group.target_reached', {'groupId': 'g1', 'habitId': 'h1'}),
      ),
      '/groups/g1/habits/h1',
    );
  });

  test('a join request opens the group so an admin can answer', () {
    expect(
      inboxRouteFor(_item('group.join_request', {'groupId': 'g1'})),
      '/groups/g1',
    );
  });

  test('an approved request opens the group', () {
    expect(
      inboxRouteFor(_item('group.request_approved', {'groupId': 'g1'})),
      '/groups/g1',
    );
  });

  test('a reminder opens Today', () {
    expect(inboxRouteFor(_item('habit.reminder')), '/');
  });

  test('things with nothing to open lead nowhere', () {
    expect(inboxRouteFor(_item('invitation.declined')), isNull);
    expect(inboxRouteFor(_item('group.request_rejected')), isNull);
    expect(inboxRouteFor(_item('something.new.later')), isNull);
  });

  test('missing ids never produce a broken route', () {
    expect(inboxRouteFor(_item('invitation.accepted')), isNull);
    expect(
      inboxRouteFor(_item('group.target_reached', {'groupId': 'g1'})),
      isNull,
    );
    expect(inboxRouteFor(_item('group.join_request')), isNull);
    expect(
      inboxRouteFor(_item('invitation.accepted', {'targetId': ''})),
      isNull,
    );
  });
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/core/error/exceptions.dart';
import 'package:habit_tracker/core/platform/platform_services.dart';
import 'package:habit_tracker/core/time/date_key.dart';
import 'package:habit_tracker/features/groups/data/datasources/group_remote_data_source.dart';
import 'package:habit_tracker/features/groups/domain/entities/completion_rule.dart';
import 'package:habit_tracker/features/groups/domain/entities/group_entities.dart';

import '../../../helpers/fakes.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late FakeCallableClient callable;

  GroupRemoteDataSourceImpl build(String? uid) => GroupRemoteDataSourceImpl(
    firestore: firestore,
    userIdProvider: FakeUserIdProvider(uid),
    callable: callable,
  );

  setUp(() {
    firestore = FakeFirebaseFirestore();
    callable = FakeCallableClient();
  });

  group('reads', () {
    test('lists my memberships from users/{uid}/memberships', () async {
      await firestore.doc('users/alice/memberships/g1').set({
        'groupName': 'Runners',
        'role': 'admin',
        'status': 'active',
        'groupStatus': 'active',
      });
      await firestore.doc('users/bob/memberships/g2').set({
        'groupName': 'Not mine',
        'role': 'member',
        'status': 'active',
      });

      final items = await build('alice').watchMemberships().first;

      expect(items, hasLength(1));
      expect(items.single.groupId, 'g1');
      expect(items.single.role, MemberRole.admin);
      expect(items.single.groupArchived, isFalse);
    });

    test('maps a group and its members', () async {
      await firestore.doc('groups/g1').set({
        'name': 'Runners',
        'description': 'Morning runs',
        'ownerUid': 'alice',
        'memberCount': 2,
        'membersCanInvite': true,
        'status': 'active',
      });
      await firestore.doc('groups/g1/members/alice').set({
        'displayName': 'Alice',
        'role': 'owner',
        'status': 'active',
        'joinedAt': Timestamp.fromDate(DateTime(2026, 10, 1)),
      });
      await firestore.doc('groups/g1/members/bob').set({
        'displayName': 'Bob',
        'role': 'member',
        'status': 'left',
        'joinedAt': Timestamp.fromDate(DateTime(2026, 10, 2)),
      });
      final source = build('alice');

      final group = await source.watchGroup('g1').first;
      final members = await source.watchMembers('g1').first;

      expect(group.name, 'Runners');
      expect(group.membersCanInvite, isTrue);
      expect(members.map((m) => m.displayName), ['Alice', 'Bob']);
      expect(members.last.active, isFalse);
    });

    test('a missing group surfaces as NotFoundException', () {
      expect(
        build('alice').watchGroup('nope').first,
        throwsA(isA<NotFoundException>()),
      );
    });

    test(
      'maps a habit with its schedule, target and pending revision',
      () async {
        await firestore.doc('groups/g1/habits/h1').set({
          'name': 'Run',
          'description': '',
          'weekdays': [1, 3, 5],
          'target': {'type': 'percentage', 'value': 80},
          'startDate': '2026-10-01',
          'endDate': null,
          'status': 'active',
          'groupStreak': {'current': 3, 'best': 7},
          'pending': {'effectiveFrom': '2026-10-20'},
        });

        final habit = await build('alice').watchHabit('g1', 'h1').first;

        expect(habit.weekdays, {1, 3, 5});
        expect(habit.target, const CompletionRule.percentage(80));
        expect(habit.groupStreak.best, 7);
        expect(habit.pendingFrom, DateKey.parse('2026-10-20'));
        expect(habit.endDate, isNull);
      },
    );

    test('a cycle is null until it is opened, then maps the counts', () async {
      final source = build('alice');
      final day = DateKey.parse('2026-10-18');
      expect(await source.watchCycle('g1', 'h1', day).first, isNull);

      await firestore.doc('groups/g1/habits/h1/cycles/2026-10-18').set({
        'eligibleUids': ['a', 'b', 'c'],
        'visibleCompletedUids': ['a'],
        'completedCount': 2,
        'rule': {'type': 'majority'},
        'closed': false,
      });

      final cycle = await source.watchCycle('g1', 'h1', day).first;
      expect(cycle!.eligibleCount, 3);
      expect(cycle.completedCount, 2);
      expect(cycle.progress.reached, isTrue); // 2 of 3 is a majority
      expect(cycle.pendingCount, 1);
    });

    test('only my own completions are returned', () async {
      await firestore
          .doc('groups/g1/habits/h1/completions/alice_2026-10-18')
          .set({'uid': 'alice', 'dateKey': '2026-10-18'});
      await firestore.doc('groups/g1/habits/h1/completions/bob_2026-10-18').set(
        {'uid': 'bob', 'dateKey': '2026-10-18'},
      );

      final mine = await build('alice').watchMyCompletions('g1', 'h1').first;

      expect(mine.dates, {DateKey.parse('2026-10-18')});
    });

    test('an unparseable document is reported, not half-shown', () async {
      await firestore.doc('groups/g1').set({'description': 'no name'});
      await expectLater(
        build('alice').watchGroup('g1').first,
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('completions', () {
    final day = DateKey.parse('2026-10-18');

    test('writes {uid}_{dateKey} with the owner and date', () async {
      await build(
        'alice',
      ).setCompletion(groupId: 'g1', habitId: 'h1', dateKey: day, done: true);

      final doc = await firestore
          .doc('groups/g1/habits/h1/completions/alice_2026-10-18')
          .get();
      expect(doc.exists, isTrue);
      expect(doc.data()!['uid'], 'alice');
      expect(doc.data()!['dateKey'], '2026-10-18');
      expect(doc.data()!.containsKey('completedAt'), isTrue);
    });

    test('repeating the request never creates a second record', () async {
      final source = build('alice');
      for (var i = 0; i < 3; i++) {
        await source.setCompletion(
          groupId: 'g1',
          habitId: 'h1',
          dateKey: day,
          done: true,
        );
      }

      final all = await firestore
          .collection('groups/g1/habits/h1/completions')
          .get();
      expect(all.docs, hasLength(1));
    });

    test('undo deletes only my record', () async {
      await build(
        'bob',
      ).setCompletion(groupId: 'g1', habitId: 'h1', dateKey: day, done: true);
      final alice = build('alice');
      await alice.setCompletion(
        groupId: 'g1',
        habitId: 'h1',
        dateKey: day,
        done: true,
      );

      await alice.setCompletion(
        groupId: 'g1',
        habitId: 'h1',
        dateKey: day,
        done: false,
      );

      final all = await firestore
          .collection('groups/g1/habits/h1/completions')
          .get();
      expect(all.docs.map((d) => d.id), ['bob_2026-10-18']);
    });

    test('signed-out users cannot write', () {
      expect(
        build(
          null,
        ).setCompletion(groupId: 'g1', habitId: 'h1', dateKey: day, done: true),
        throwsA(isA<UnauthenticatedException>()),
      );
    });
  });

  group('join requests, activity and group settings', () {
    test('lists only people still waiting', () async {
      await firestore.doc('groups/g1/joinRequests/bob').set({
        'displayName': 'Bob',
        'status': 'pending',
      });
      await firestore.doc('groups/g1/joinRequests/cy').set({
        'displayName': 'Cy',
        'status': 'approved',
      });

      final requests = await build('alice').watchJoinRequests('g1').first;

      expect(requests.map((r) => (r.uid, r.displayName)), [('bob', 'Bob')]);
    });

    test('the activity log is newest first and limited', () async {
      for (var i = 0; i < 5; i++) {
        await firestore.doc('groups/g1/auditLog/a$i').set({
          'action': 'member.joined',
          'actorUid': 'u$i',
          'details': {'n': i},
          'at': Timestamp.fromDate(DateTime(2026, 10, 18, 9, i)),
        });
      }

      final entries = await build('alice').watchAudit('g1', limit: 3).first;

      expect(entries.map((e) => e.id), ['a4', 'a3', 'a2']);
      expect(entries.first.actorUid, 'u4');
      expect(entries.first.at, DateTime(2026, 10, 18, 9, 4));
      expect(entries.first.details, {'n': 4});
    });

    test('reviewing a request sends the decision', () async {
      await build(
        'alice',
      ).reviewJoinRequest(groupId: 'g1', uid: 'bob', approve: true);

      expect(callable.calls.single.name, 'reviewJoinRequest');
      expect(callable.calls.single.data, {
        'groupId': 'g1',
        'uid': 'bob',
        'approve': true,
      });
    });

    test('a group maps its emblem and approval setting', () async {
      await firestore.doc('groups/g1').set({
        'name': 'Runners',
        'ownerUid': 'alice',
        'memberCount': 1,
        'status': 'active',
        'requireApproval': true,
        'emblem': {'icon': 'run', 'color': 3},
      });

      final group = await build('alice').watchGroup('g1').first;

      expect(group.requireApproval, isTrue);
      expect(group.emblem, const GroupEmblem(icon: 'run', color: 3));
    });

    test('a group without an emblem has none', () async {
      await firestore.doc('groups/g1').set({
        'name': 'Runners',
        'ownerUid': 'alice',
        'status': 'active',
      });

      final group = await build('alice').watchGroup('g1').first;

      expect(group.emblem, isNull);
      expect(group.requireApproval, isFalse);
    });

    test('the membership list carries the emblem too', () async {
      await firestore.doc('users/alice/memberships/g1').set({
        'groupName': 'Runners',
        'role': 'owner',
        'status': 'active',
        'emblem': {'icon': 'book', 'color': 1},
      });

      final items = await build('alice').watchMemberships().first;

      expect(items.single.emblem, const GroupEmblem(icon: 'book', color: 1));
    });

    test('creating a group sends the approval setting and emblem', () async {
      callable.responses['createGroup'] = {'groupId': 'g9'};

      await build('alice').createGroup(
        name: 'Runners',
        description: '',
        membersCanInvite: false,
        requireApproval: true,
        emblem: const GroupEmblem(icon: 'run', color: 2),
      );

      expect(callable.calls.single.data['requireApproval'], isTrue);
      expect(callable.calls.single.data['emblem'], {'icon': 'run', 'color': 2});
    });

    test('settings send only what changed', () async {
      await build('alice').updateSettings(
        groupId: 'g1',
        requireApproval: false,
        emblem: const GroupEmblem(icon: 'star', color: 5),
      );

      expect(callable.calls.single.data, {
        'groupId': 'g1',
        'requireApproval': false,
        'emblem': {'icon': 'star', 'color': 5},
      });
    });

    test('a habit end date can be set or cleared', () async {
      final source = build('alice');

      await source.updateHabit(
        groupId: 'g1',
        habitId: 'h1',
        endDate: DateKey.parse('2026-12-31'),
      );
      await source.updateHabit(
        groupId: 'g1',
        habitId: 'h1',
        clearEndDate: true,
      );

      expect(callable.calls[0].data['endDate'], '2026-12-31');
      expect(callable.calls[1].data.containsKey('endDate'), isTrue);
      expect(callable.calls[1].data['endDate'], isNull);
    });
  });

  group('keeping the day\'s numbers fresh', () {
    final day = DateKey.parse('2026-10-18');

    test('saving a completion asks the server to recompute that day', () async {
      await build(
        'alice',
      ).setCompletion(groupId: 'g1', habitId: 'h1', dateKey: day, done: true);
      await Future<void>.delayed(Duration.zero);

      expect(callable.calls.single.name, 'refreshCycle');
      expect(callable.calls.single.data, {
        'kind': 'group',
        'groupId': 'g1',
        'habitId': 'h1',
        'dateKey': '2026-10-18',
      });
    });

    test('opening the day\'s cycle asks the server to open it', () async {
      await build('alice').watchCycle('g1', 'h1', day).first;

      expect(callable.calls.map((c) => c.name), ['refreshCycle']);
    });

    test('a failing refresh never breaks recording a completion', () async {
      callable.error = const CallableException('unavailable', 'offline');

      await build(
        'alice',
      ).setCompletion(groupId: 'g1', habitId: 'h1', dateKey: day, done: true);
      await Future<void>.delayed(Duration.zero);

      final doc = await firestore
          .doc('groups/g1/habits/h1/completions/alice_2026-10-18')
          .get();
      expect(doc.exists, isTrue);
    });
  });

  group('server actions go through callable functions', () {
    test('createGroup sends the form and returns the new id', () async {
      callable.responses['createGroup'] = {'groupId': 'g9'};

      final id = await build('alice').createGroup(
        name: 'Runners',
        description: 'Morning',
        membersCanInvite: true,
      );

      expect(id, 'g9');
      expect(callable.calls.single.name, 'createGroup');
      expect(callable.calls.single.data, {
        'name': 'Runners',
        'description': 'Morning',
        'membersCanInvite': true,
        'requireApproval': false,
      });
    });

    test('admin actions send the group and target', () async {
      final source = build('alice');
      await source.removeMember('g1', 'bob');
      await source.setRole('g1', 'bob', MemberRole.admin);
      await source.transferOwnership('g1', 'bob');
      await source.leave('g1');
      await source.archive('g1');

      expect(callable.calls.map((c) => c.name), [
        'removeMember',
        'setMemberRole',
        'transferOwnership',
        'leaveGroup',
        'archiveGroup',
      ]);
      expect(callable.calls[1].data, {
        'groupId': 'g1',
        'uid': 'bob',
        'role': 'admin',
      });
    });

    test('createHabit sends a sorted schedule and the wire rule', () async {
      callable.responses['createGroupHabit'] = {'habitId': 'h7'};

      final id = await build('alice').createHabit(
        'g1',
        NewGroupHabit(
          name: 'Run',
          description: '',
          weekdays: const {5, 1, 3},
          target: const CompletionRule.fixed(4),
          startDate: DateKey.parse('2026-10-18'),
        ),
      );

      expect(id, 'h7');
      final data = callable.calls.single.data;
      expect(data['weekdays'], [1, 3, 5]);
      expect(data['target'], {'type': 'fixed', 'value': 4});
      expect(data['startDate'], '2026-10-18');
      expect(data['endDate'], isNull);
    });

    test('updateHabit only sends the fields that changed', () async {
      await build(
        'alice',
      ).updateHabit(groupId: 'g1', habitId: 'h1', name: 'Run more');

      expect(callable.calls.single.data, {
        'groupId': 'g1',
        'habitId': 'h1',
        'name': 'Run more',
      });
    });
  });
}

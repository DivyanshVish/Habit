import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:habit_tracker/core/error/failure.dart';
import 'package:habit_tracker/features/notifications/data/inbox_repository_impl.dart';

import '../../helpers/fakes.dart';

void main() {
  late FakeFirebaseFirestore firestore;

  InboxRepositoryImpl build(String? uid) => InboxRepositoryImpl(
    firestore: firestore,
    userIdProvider: FakeUserIdProvider(uid),
  );

  Future<void> add(
    String uid,
    String id, {
    required int minute,
    bool read = false,
    String type = 'invitation.received',
    Map<String, Object?> data = const {},
  }) {
    return firestore.doc('users/$uid/notifications/$id').set({
      'type': type,
      'title': 'Title $id',
      'body': 'Body $id',
      'read': read,
      'data': data,
      'createdAt': Timestamp.fromDate(DateTime(2026, 10, 18, 9, minute)),
    });
  }

  setUp(() => firestore = FakeFirebaseFirestore());

  test('lists the newest first and maps every field', () async {
    await add('alice', 'old', minute: 1);
    await add(
      'alice',
      'new',
      minute: 30,
      type: 'group.target_reached',
      data: {'groupId': 'g1', 'habitId': 'h1'},
    );

    final items = (await build('alice').watch().first).getRight().toNullable()!;

    expect(items.map((i) => i.id), ['new', 'old']);
    expect(items.first.type, 'group.target_reached');
    expect(items.first.title, 'Title new');
    expect(items.first.read, isFalse);
    expect(items.first.data, {'groupId': 'g1', 'habitId': 'h1'});
    expect(items.first.createdAt, DateTime(2026, 10, 18, 9, 30));
  });

  test('only shows my own notifications', () async {
    await add('alice', 'mine', minute: 1);
    await add('bob', 'theirs', minute: 2);

    final items = (await build('alice').watch().first).getRight().toNullable()!;

    expect(items.map((i) => i.id), ['mine']);
  });

  test('paging: asking for more returns more', () async {
    for (var i = 0; i < 5; i++) {
      await add('alice', 'n$i', minute: i);
    }
    final repo = build('alice');

    final first = (await repo.watch(limit: 2).first).getRight().toNullable()!;
    final more = (await repo.watch(limit: 4).first).getRight().toNullable()!;

    expect(first, hasLength(2));
    expect(more, hasLength(4));
    expect(first.map((i) => i.id), ['n4', 'n3']);
  });

  test('counts unread only', () async {
    await add('alice', 'a', minute: 1);
    await add('alice', 'b', minute: 2, read: true);
    await add('alice', 'c', minute: 3);

    final count = (await build(
      'alice',
    ).watchUnreadCount().first).getRight().toNullable();

    expect(count, 2);
  });

  test('marking one read changes only that one', () async {
    await add('alice', 'a', minute: 1);
    await add('alice', 'b', minute: 2);

    final result = await build('alice').markRead('a');

    expect(result, right(unit));
    expect(
      (await firestore.doc('users/alice/notifications/a').get())
          .data()!['read'],
      isTrue,
    );
    expect(
      (await firestore.doc('users/alice/notifications/b').get())
          .data()!['read'],
      isFalse,
    );
  });

  test(
    'mark all read clears the count and leaves other people alone',
    () async {
      await add('alice', 'a', minute: 1);
      await add('alice', 'b', minute: 2);
      await add('bob', 'x', minute: 3);

      await build('alice').markAllRead();

      final count = (await build(
        'alice',
      ).watchUnreadCount().first).getRight().toNullable();
      expect(count, 0);
      expect(
        (await build('bob').watchUnreadCount().first).getRight().toNullable(),
        1,
      );
    },
  );

  test('mark all read with nothing unread is fine', () async {
    expect(await build('alice').markAllRead(), right(unit));
  });

  test(
    'marking a notification that is gone is a failure, not a crash',
    () async {
      final result = await build('alice').markRead('missing');

      expect(result.isLeft(), isTrue);
    },
  );

  test('signed out users get an unauthenticated failure everywhere', () async {
    final repo = build(null);

    expect(
      (await repo.watch().first).getLeft().toNullable(),
      isA<UnauthenticatedFailure>(),
    );
    expect(
      (await repo.watchUnreadCount().first).getLeft().toNullable(),
      isA<UnauthenticatedFailure>(),
    );
    expect(
      (await repo.markRead('a')).getLeft().toNullable(),
      isA<UnauthenticatedFailure>(),
    );
    expect(
      (await repo.markAllRead()).getLeft().toNullable(),
      isA<UnauthenticatedFailure>(),
    );
  });
}

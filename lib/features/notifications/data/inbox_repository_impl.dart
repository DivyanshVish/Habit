import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fpdart/fpdart.dart';
import 'package:habit_tracker/core/auth/user_id_provider.dart';
import 'package:habit_tracker/core/data/exception_mapper.dart';
import 'package:habit_tracker/core/error/failure.dart';
import 'package:habit_tracker/features/notifications/domain/notifications_domain.dart';
import 'package:rxdart/rxdart.dart';

/// Reads and updates `users/{uid}/notifications`. The rules let only the owner
/// touch it; the server creates the entries.
class InboxRepositoryImpl implements InboxRepository {
  InboxRepositoryImpl({
    required FirebaseFirestore firestore,
    required UserIdProvider userIdProvider,
  }) : _firestore = firestore,
       _userIdProvider = userIdProvider;

  final FirebaseFirestore _firestore;
  final UserIdProvider _userIdProvider;

  /// Most unread entries that are counted or cleared at once.
  static const int _unreadCap = 100;

  CollectionReference<Map<String, dynamic>>? _collection() {
    final uid = _userIdProvider.currentUserId;
    if (uid == null) return null;
    return _firestore.collection('users').doc(uid).collection('notifications');
  }

  static InboxItem _toItem(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    final created = data['createdAt'];
    final extra = data['data'];
    return InboxItem(
      id: doc.id,
      type: (data['type'] as String?) ?? '',
      title: (data['title'] as String?) ?? '',
      body: (data['body'] as String?) ?? '',
      read: data['read'] == true,
      createdAt: created is Timestamp ? created.toDate() : null,
      data: extra is Map
          ? {
              for (final entry in extra.entries)
                entry.key.toString(): entry.value.toString(),
            }
          : const {},
    );
  }

  @override
  Stream<Either<Failure, List<InboxItem>>> watch({int limit = 30}) {
    final collection = _collection();
    if (collection == null) {
      return Stream.value(left(const Failure.unauthenticated()));
    }
    return collection
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map<Either<Failure, List<InboxItem>>>(
          (s) => right(s.docs.map(_toItem).toList()),
        )
        .onErrorReturnWith((error, _) => left(mapExceptionToFailure(error)));
  }

  @override
  Stream<Either<Failure, int>> watchUnreadCount() {
    final collection = _collection();
    if (collection == null) {
      return Stream.value(left(const Failure.unauthenticated()));
    }
    return collection
        .where('read', isEqualTo: false)
        .limit(_unreadCap)
        .snapshots()
        .map<Either<Failure, int>>((s) => right(s.size))
        .onErrorReturnWith((error, _) => left(mapExceptionToFailure(error)));
  }

  @override
  Future<Either<Failure, Unit>> markRead(String id) async {
    final collection = _collection();
    if (collection == null) return left(const Failure.unauthenticated());
    try {
      await collection.doc(id).update({'read': true});
      return right(unit);
    } on Exception catch (error) {
      return left(mapExceptionToFailure(error));
    }
  }

  @override
  Future<Either<Failure, Unit>> markAllRead() async {
    final collection = _collection();
    if (collection == null) return left(const Failure.unauthenticated());
    try {
      final unread = await collection
          .where('read', isEqualTo: false)
          .limit(_unreadCap)
          .get();
      if (unread.docs.isEmpty) return right(unit);
      final batch = _firestore.batch();
      for (final doc in unread.docs) {
        batch.update(doc.reference, {'read': true});
      }
      await batch.commit();
      return right(unit);
    } on Exception catch (error) {
      return left(mapExceptionToFailure(error));
    }
  }
}

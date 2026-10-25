import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:habit_tracker/core/auth/user_id_provider.dart';
import 'package:habit_tracker/core/error/exceptions.dart';
import 'package:habit_tracker/core/platform/platform_services.dart';
import 'package:habit_tracker/core/time/date_key.dart';
import 'package:habit_tracker/features/groups/data/models/group_mappers.dart';
import 'package:habit_tracker/features/groups/domain/entities/cycle_snapshot.dart';
import 'package:habit_tracker/features/groups/domain/entities/group_entities.dart';
import 'package:habit_tracker/features/habits/data/datasources/habit_remote_data_source.dart'
    show awaitWriteAck;
import 'package:habit_tracker/features/shared_habits/domain/entities/shared_habit_entities.dart';

abstract interface class SharedHabitRemoteDataSource {
  Stream<List<SharedHabit>> watchMine();
  Stream<SharedHabit> watchHabit(String sharedId);
  Stream<List<SharedParticipant>> watchParticipants(String sharedId);
  Stream<CycleSnapshot?> watchCycle(String sharedId, DateKey dateKey);
  Stream<MyCompletions> watchMyCompletions(String sharedId);
  Future<void> setCompletion({
    required String sharedId,
    required DateKey dateKey,
    required bool done,
  });
  Future<String> create(NewSharedHabit habit);
  Future<void> leave(String sharedId);
}

class SharedHabitRemoteDataSourceImpl implements SharedHabitRemoteDataSource {
  SharedHabitRemoteDataSourceImpl({
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

  /// Opens today's cycle if needed and recomputes it. Best effort, see the
  /// group data source for why it is safe to fail.
  void _refreshCycle(String sharedId, DateKey dateKey) {
    unawaited(
      _callable
          .call('refreshCycle', {
            'kind': 'shared',
            'sharedId': sharedId,
            'dateKey': dateKey.value,
          })
          .then<void>((_) {}, onError: (Object _) {}),
    );
  }

  DocumentReference<Map<String, dynamic>> _habit(String id) =>
      _firestore.collection('sharedHabits').doc(id);

  static SharedHabit _toHabit(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const <String, dynamic>{};
    final name = data['name'];
    final owner = data['ownerUid'];
    final start = data['startDate'];
    if (name is! String || owner is! String || start is! String) {
      throw FormatException('Invalid shared habit', data);
    }
    return SharedHabit(
      id: doc.id,
      name: name,
      description: (data['description'] as String?) ?? '',
      points: (data['points'] as num?)?.toInt() ?? 0,
      ownerUid: owner,
      weekdays: {
        for (final day
            in (data['weekdays'] as List? ?? const [1, 2, 3, 4, 5, 6, 7]))
          (day as num).toInt(),
      },
      startDate: DateKey.parse(start),
      participantCount: (data['participantCount'] as num?)?.toInt() ?? 0,
      archived: data['status'] == 'archived',
    );
  }

  /// `array-contains` is the one membership query the rules can prove, so the
  /// list needs no extra bookkeeping collection.
  @override
  Stream<List<SharedHabit>> watchMine() {
    return _firestore
        .collection('sharedHabits')
        .where('participantUids', arrayContains: _uid())
        .snapshots()
        .map((s) => s.docs.map(_toHabit).toList());
  }

  @override
  Stream<SharedHabit> watchHabit(String sharedId) {
    return _habit(sharedId).snapshots().map((doc) {
      if (!doc.exists) throw const NotFoundException();
      return _toHabit(doc);
    });
  }

  @override
  Stream<List<SharedParticipant>> watchParticipants(String sharedId) {
    return _habit(sharedId)
        .collection('participants')
        .orderBy('joinedAt')
        .snapshots()
        .map(
          (s) => [
            for (final doc in s.docs)
              SharedParticipant(
                uid: doc.id,
                displayName:
                    (doc.data()['displayName'] as String?) ?? 'Habitry user',
                active: doc.data()['status'] == 'active',
              ),
          ],
        );
  }

  @override
  Stream<CycleSnapshot?> watchCycle(String sharedId, DateKey dateKey) {
    _refreshCycle(sharedId, dateKey);
    return _habit(sharedId)
        .collection('cycles')
        .doc(dateKey.value)
        .snapshots()
        .map((doc) => doc.exists ? GroupMappers.cycle(doc) : null);
  }

  @override
  Stream<MyCompletions> watchMyCompletions(String sharedId) {
    return _habit(sharedId)
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

  @override
  Future<void> setCompletion({
    required String sharedId,
    required DateKey dateKey,
    required bool done,
  }) async {
    final uid = _uid();
    final doc = _habit(
      sharedId,
    ).collection('completions').doc('${uid}_${dateKey.value}');
    final write = done
        ? doc.set({
            'uid': uid,
            'dateKey': dateKey.value,
            'completedAt': FieldValue.serverTimestamp(),
          })
        : doc.delete();
    await awaitWriteAck(write, writeAckTimeout);
    _refreshCycle(sharedId, dateKey);
  }

  @override
  Future<String> create(NewSharedHabit habit) async {
    final result = await _callable.call('createSharedHabit', {
      'name': habit.name,
      'description': habit.description,
      'points': habit.points,
      'weekdays': (habit.weekdays.toList()..sort()),
      'startDate': habit.startDate.value,
      'sourceHabitId': ?habit.sourceHabitId,
    });
    return result['sharedHabitId'] as String;
  }

  @override
  Future<void> leave(String sharedId) async {
    await _callable.call('leaveSharedHabit', {'sharedHabitId': sharedId});
  }
}

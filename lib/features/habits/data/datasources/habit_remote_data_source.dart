import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:habit_tracker/core/auth/user_id_provider.dart';
import 'package:habit_tracker/core/error/exceptions.dart';
import 'package:habit_tracker/core/time/date_key.dart';
import 'package:habit_tracker/features/habits/data/models/completion_model.dart';
import 'package:habit_tracker/features/habits/data/models/habit_model.dart';
import 'package:habit_tracker/features/habits/domain/entities/new_habit.dart';

/// Reads and writes habits in Firestore. Throws exceptions; the repository
/// converts them into `Failure`s.
abstract interface class HabitRemoteDataSource {
  Stream<List<HabitModel>> watchHabits();

  /// Throws [NotFoundException] through the stream when the habit is missing.
  Stream<HabitModel> watchHabit(String habitId);

  Stream<List<CompletionModel>> watchCompletions({
    required DateKey from,
    required DateKey to,
  });

  Future<void> addHabit(NewHabit habit);

  Future<void> setCompletion({
    required String habitId,
    required DateKey dateKey,
    required bool done,
  });

  /// Deletes the habit and every completion that belongs to it.
  Future<void> deleteHabit(String habitId);
}

class HabitRemoteDataSourceImpl implements HabitRemoteDataSource {
  HabitRemoteDataSourceImpl({
    required FirebaseFirestore firestore,
    required UserIdProvider userIdProvider,
    this.writeAckTimeout = const Duration(seconds: 3),
  }) : _firestore = firestore,
       _userIdProvider = userIdProvider;

  final FirebaseFirestore _firestore;
  final UserIdProvider _userIdProvider;

  /// How long to wait for the server to acknowledge a write before treating it
  /// as queued. Offline, Firestore only completes the write future once the
  /// server acks it, but the local cache already shows the change.
  final Duration writeAckTimeout;

  DocumentReference<Map<String, dynamic>> _userDoc() {
    final uid = _userIdProvider.currentUserId;
    if (uid == null) throw const UnauthenticatedException();
    return _firestore.collection('users').doc(uid);
  }

  CollectionReference<Map<String, dynamic>> _habitsCollection() =>
      _userDoc().collection('habits');

  CollectionReference<Map<String, dynamic>> _completionsCollection() =>
      _userDoc().collection('completions');

  @override
  Stream<List<HabitModel>> watchHabits() {
    return _habitsCollection()
        .orderBy(HabitModel.fieldCreatedAt)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map(HabitModel.fromFirestore).toList(),
        );
  }

  @override
  Stream<HabitModel> watchHabit(String habitId) {
    return _habitsCollection().doc(habitId).snapshots().map((doc) {
      if (!doc.exists) throw const NotFoundException();
      return HabitModel.fromFirestore(doc);
    });
  }

  /// Only a range on `dateKey`, so Firestore's automatic single-field index is
  /// enough (no composite index to deploy).
  @override
  Stream<List<CompletionModel>> watchCompletions({
    required DateKey from,
    required DateKey to,
  }) {
    return _completionsCollection()
        .where(CompletionModel.fieldDateKey, isGreaterThanOrEqualTo: from.value)
        .where(CompletionModel.fieldDateKey, isLessThanOrEqualTo: to.value)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map(CompletionModel.fromFirestore).toList(),
        );
  }

  @override
  Future<void> addHabit(NewHabit habit) async {
    final doc = _habitsCollection().doc();
    final model = HabitModel.fromNewHabit(doc.id, habit);
    await awaitWriteAck(doc.set(model.toFirestore()), writeAckTimeout);
  }

  @override
  Future<void> setCompletion({
    required String habitId,
    required DateKey dateKey,
    required bool done,
  }) async {
    final doc = _completionsCollection().doc(
      CompletionModel.docId(habitId, dateKey),
    );
    final write = done
        ? doc.set(
            CompletionModel(
              habitId: habitId,
              dateKey: dateKey.value,
            ).toFirestore(),
          )
        : doc.delete();
    await awaitWriteAck(write, writeAckTimeout);
  }

  /// Firestore allows at most 500 writes per batch.
  static const int _batchLimit = 400;

  @override
  Future<void> deleteHabit(String habitId) async {
    final habitRef = _habitsCollection().doc(habitId);
    final completionDocs = await _completionsOf(habitId);

    // The habit goes in the first batch, so it disappears from the UI at once.
    final refs = [habitRef, ...completionDocs.map((doc) => doc.reference)];
    for (var start = 0; start < refs.length; start += _batchLimit) {
      final batch = _firestore.batch();
      for (final ref in refs.skip(start).take(_batchLimit)) {
        batch.delete(ref);
      }
      await awaitWriteAck(batch.commit(), writeAckTimeout);
    }
  }

  /// Reads the habit's completions, falling back to the local cache when the
  /// server cannot be reached in time (offline).
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> _completionsOf(
    String habitId,
  ) async {
    final query = _completionsCollection().where(
      CompletionModel.fieldHabitId,
      isEqualTo: habitId,
    );
    try {
      return (await query.get().timeout(writeAckTimeout)).docs;
    } on TimeoutException {
      return (await query.get(const GetOptions(source: Source.cache))).docs;
    }
  }
}

/// Waits for [write] to be acknowledged, but gives up after [timeout].
///
/// A timeout means the write is queued in the local cache (typically offline)
/// and will sync later, so it is treated as success. Real errors (e.g.
/// permission denied) still surface because they complete the future with an
/// error before the timeout.
Future<void> awaitWriteAck(Future<void> write, Duration timeout) {
  return write.timeout(timeout, onTimeout: () {});
}

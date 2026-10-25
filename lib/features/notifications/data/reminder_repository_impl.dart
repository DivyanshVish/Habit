import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fpdart/fpdart.dart';
import 'package:habit_tracker/core/auth/user_id_provider.dart';
import 'package:habit_tracker/core/data/exception_mapper.dart';
import 'package:habit_tracker/core/error/failure.dart';
import 'package:habit_tracker/features/notifications/domain/reminders_domain.dart';
import 'package:rxdart/rxdart.dart';

/// Reminders live in `users/{uid}/reminders`. The server sends them (it needs a
/// timer that fires every 15 minutes; see functions/README.md) and builds the
/// records it checks itself, so a reminder only ever looks at its owner's own
/// completions.
class ReminderRepositoryImpl implements ReminderRepository {
  ReminderRepositoryImpl({
    required FirebaseFirestore firestore,
    required UserIdProvider userIdProvider,
  }) : _firestore = firestore,
       _userIdProvider = userIdProvider;

  final FirebaseFirestore _firestore;
  final UserIdProvider _userIdProvider;

  DocumentReference<Map<String, dynamic>>? _doc(ReminderTarget target) {
    final uid = _userIdProvider.currentUserId;
    if (uid == null) return null;
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('reminders')
        .doc(target.docId);
  }

  static Map<String, Object?> _identity(ReminderTarget target) =>
      switch (target) {
        PersonalReminderTarget(:final habitId) => {
          'kind': 'personal',
          'itemId': habitId,
        },
        SharedReminderTarget(:final sharedId) => {
          'kind': 'shared',
          'sharedId': sharedId,
        },
        GroupReminderTarget(:final groupId, :final habitId) => {
          'kind': 'group',
          'groupId': groupId,
          'habitId': habitId,
        },
      };

  @override
  Stream<Either<Failure, ReminderSetting?>> watch(ReminderTarget target) {
    final doc = _doc(target);
    if (doc == null) {
      return Stream.value(left(const Failure.unauthenticated()));
    }
    return doc
        .snapshots()
        .map<Either<Failure, ReminderSetting?>>((snapshot) {
          final data = snapshot.data();
          if (data == null) return right(null);
          return right(
            ReminderSetting(
              enabled: data['enabled'] != false,
              minutesOfDay: (data['minutesOfDay'] as num?)?.toInt() ?? 0,
              onlyIfIncomplete: data['onlyIfIncomplete'] != false,
            ),
          );
        })
        .onErrorReturnWith((error, _) => left(mapExceptionToFailure(error)));
  }

  @override
  Future<Either<Failure, Unit>> save(
    ReminderTarget target,
    ReminderSetting setting,
  ) async {
    final doc = _doc(target);
    if (doc == null) return left(const Failure.unauthenticated());
    try {
      await doc.set({
        ..._identity(target),
        'enabled': setting.enabled,
        'minutesOfDay': setting.minutesOfDay,
        'onlyIfIncomplete': setting.onlyIfIncomplete,
      });
      return right(unit);
    } on Exception catch (error) {
      return left(mapExceptionToFailure(error));
    }
  }

  @override
  Future<Either<Failure, Unit>> remove(ReminderTarget target) async {
    final doc = _doc(target);
    if (doc == null) return left(const Failure.unauthenticated());
    try {
      await doc.delete();
      return right(unit);
    } on Exception catch (error) {
      return left(mapExceptionToFailure(error));
    }
  }
}

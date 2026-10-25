import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fpdart/fpdart.dart';
import 'package:habit_tracker/core/auth/user_id_provider.dart';
import 'package:habit_tracker/core/data/exception_mapper.dart';
import 'package:habit_tracker/core/error/failure.dart';
import 'package:habit_tracker/core/platform/platform_services.dart';
import 'package:habit_tracker/features/invitations/domain/invitation_domain.dart';
import 'package:rxdart/rxdart.dart';

/// Invitations are server-only data (clients cannot read the collection), so
/// everything goes through callable functions.
class InvitationRepositoryImpl implements InvitationRepository {
  InvitationRepositoryImpl(
    this._callable, {
    required FirebaseFirestore firestore,
    required UserIdProvider userIdProvider,
  }) : _firestore = firestore,
       _userIdProvider = userIdProvider;

  final CallableClient _callable;
  final FirebaseFirestore _firestore;
  final UserIdProvider _userIdProvider;

  @override
  Future<Either<Failure, InvitationCode>> create({
    required InvitationType type,
    required String targetId,
    required int maxUses,
    required int ttlHours,
  }) => _guard(() async {
    final result = await _callable.call('createInvitation', {
      'type': type.name,
      'targetId': targetId,
      'maxUses': maxUses,
      'ttlHours': ttlHours,
    });
    return InvitationCode(
      invitationId: result['invitationId'] as String,
      code: result['code'] as String,
    );
  });

  @override
  Future<Either<Failure, InvitationPreview>> preview(String code) => _guard(
    () async {
      final result = await _callable.call('previewInvitation', {'code': code});
      return InvitationPreview(
        type: InvitationType.fromWireName(result['type'] as String?),
        name: (result['name'] as String?) ?? '',
        inviterName: (result['inviterName'] as String?) ?? '',
      );
    },
  );

  @override
  Future<Either<Failure, InvitationResult>> respond({
    required String code,
    required bool accept,
  }) => _guard(() async {
    final result = await _callable.call('respondToInvitation', {
      'code': code,
      'accept': accept,
    });
    return _toResult(result);
  });

  static InvitationResult _toResult(Map<String, dynamic> result) =>
      InvitationResult(
        accepted: result['accepted'] == true,
        type: InvitationType.fromWireName(result['type'] as String?),
        targetId: (result['targetId'] as String?) ?? '',
        pendingApproval: result['pendingApproval'] == true,
      );

  @override
  Future<Either<Failure, Unit>> createForPerson({
    required InvitationType type,
    required String targetId,
    required String inviteeUid,
    required int ttlHours,
  }) => _guard(() async {
    await _callable.call('createInvitation', {
      'type': type.name,
      'targetId': targetId,
      'inviteeUid': inviteeUid,
      'ttlHours': ttlHours,
    });
    return unit;
  });

  @override
  Future<Either<Failure, List<InvitablePerson>>> listPeople({
    required InvitationType type,
    required String targetId,
  }) => _guard(() async {
    final result = await _callable.call('listInvitablePeople', {
      'type': type.name,
      'targetId': targetId,
    });
    return [
      for (final person in (result['people'] as List? ?? const []))
        InvitablePerson(
          uid: (person as Map)['uid'] as String,
          displayName: (person['displayName'] as String?) ?? 'Habitry user',
        ),
    ];
  });

  @override
  Stream<Either<Failure, List<PendingInvitation>>> watchPending() {
    final uid = _userIdProvider.currentUserId;
    if (uid == null) {
      return Stream.value(left(const Failure.unauthenticated()));
    }
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('pendingInvitations')
        .snapshots()
        .map<Either<Failure, List<PendingInvitation>>>((snapshot) {
          final now = DateTime.now();
          final items = <PendingInvitation>[];
          for (final doc in snapshot.docs) {
            final data = doc.data();
            final expires = DateTime.fromMillisecondsSinceEpoch(
              (data['expiresAtMs'] as num?)?.toInt() ?? 0,
            );
            if (!expires.isAfter(now)) continue;
            items.add(
              PendingInvitation(
                invitationId: doc.id,
                type: InvitationType.fromWireName(data['type'] as String?),
                targetName: (data['targetName'] as String?) ?? '',
                inviterName: (data['inviterName'] as String?) ?? '',
                expiresAt: expires,
              ),
            );
          }
          items.sort((a, b) => a.expiresAt.compareTo(b.expiresAt));
          return right(items);
        })
        .onErrorReturnWith((error, _) => left(mapExceptionToFailure(error)));
  }

  @override
  Future<Either<Failure, InvitationResult>> respondById({
    required String invitationId,
    required bool accept,
  }) => _guard(() async {
    final result = await _callable.call('respondToInvitation', {
      'invitationId': invitationId,
      'accept': accept,
    });
    return _toResult(result);
  });

  @override
  Future<Either<Failure, Unit>> revoke(String invitationId) => _guard(() async {
    await _callable.call('revokeInvitation', {'invitationId': invitationId});
    return unit;
  });

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() action) async {
    try {
      return right(await action());
    } on Exception catch (error) {
      return left(mapExceptionToFailure(error));
    } on TypeError {
      // The server answered with an unexpected shape.
      return left(const Failure.server(message: 'Received unexpected data.'));
    }
  }
}

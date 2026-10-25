import 'package:fpdart/fpdart.dart';
import 'package:habit_tracker/core/error/failure.dart';
import 'package:habit_tracker/core/usecase/usecase.dart';

enum InvitationType {
  shared,
  group;

  static InvitationType fromWireName(String? value) => InvitationType.values
      .firstWhere((t) => t.name == value, orElse: () => InvitationType.shared);
}

/// A freshly created invitation. [code] is shown once; the server keeps only
/// a hash of it.
class InvitationCode {
  const InvitationCode({required this.invitationId, required this.code});

  final String invitationId;
  final String code;
}

/// What a code is for. Contains nothing private.
class InvitationPreview {
  const InvitationPreview({
    required this.type,
    required this.name,
    required this.inviterName,
  });

  final InvitationType type;
  final String name;
  final String inviterName;
}

class InvitationResult {
  const InvitationResult({
    required this.accepted,
    required this.type,
    required this.targetId,
    this.pendingApproval = false,
  });

  final bool accepted;
  final InvitationType type;
  final String targetId;

  /// True when the group wants an admin to approve first. The person is not a
  /// member yet.
  final bool pendingApproval;
}

/// Somebody the user shares a group with and could invite.
class InvitablePerson {
  const InvitablePerson({required this.uid, required this.displayName});

  final String uid;
  final String displayName;
}

/// An invitation made for this person, waiting for an answer.
class PendingInvitation {
  const PendingInvitation({
    required this.invitationId,
    required this.type,
    required this.targetName,
    required this.inviterName,
    required this.expiresAt,
  });

  final String invitationId;
  final InvitationType type;
  final String targetName;
  final String inviterName;
  final DateTime expiresAt;
}

abstract interface class InvitationRepository {
  Future<Either<Failure, InvitationCode>> create({
    required InvitationType type,
    required String targetId,
    required int maxUses,
    required int ttlHours,
  });

  Future<Either<Failure, InvitationPreview>> preview(String code);

  /// An invitation for one person. No code is involved: they get a
  /// notification and see it in their list.
  Future<Either<Failure, Unit>> createForPerson({
    required InvitationType type,
    required String targetId,
    required String inviteeUid,
    required int ttlHours,
  });

  Future<Either<Failure, List<InvitablePerson>>> listPeople({
    required InvitationType type,
    required String targetId,
  });

  /// Invitations made for the signed-in user. Expired ones are left out.
  Stream<Either<Failure, List<PendingInvitation>>> watchPending();

  /// Answers an invitation made for this person (no code needed).
  Future<Either<Failure, InvitationResult>> respondById({
    required String invitationId,
    required bool accept,
  });

  Future<Either<Failure, InvitationResult>> respond({
    required String code,
    required bool accept,
  });

  Future<Either<Failure, Unit>> revoke(String invitationId);
}

/// Codes are typed by hand, so tolerate case, spaces and dashes.
String normalizeInviteCode(String input) =>
    input.toUpperCase().replaceAll(RegExp('[^A-Z0-9]'), '');

const int _minCodeLength = 4;

Failure get _badCode => const Failure.validation(
  message: 'Enter the code exactly as it was shared with you.',
);

class CreateInvitationParams {
  const CreateInvitationParams({
    required this.type,
    required this.targetId,
    this.maxUses = 1,
    this.ttlHours = 72,
  });

  final InvitationType type;
  final String targetId;
  final int maxUses;
  final int ttlHours;
}

class CreateInvitation
    implements UseCase<InvitationCode, CreateInvitationParams> {
  CreateInvitation(this._repository);

  final InvitationRepository _repository;

  @override
  Future<Either<Failure, InvitationCode>> call(CreateInvitationParams params) {
    if (params.maxUses < 1 || params.maxUses > 50) {
      return Future.value(
        left(const Failure.validation(message: 'Uses must be 1 to 50.')),
      );
    }
    if (params.ttlHours < 1 || params.ttlHours > 24 * 14) {
      return Future.value(
        left(
          const Failure.validation(
            message: 'Expiry must be 1 hour to 14 days.',
          ),
        ),
      );
    }
    return _repository.create(
      type: params.type,
      targetId: params.targetId,
      // Only group codes can be shared by many people.
      maxUses: params.type == InvitationType.group ? params.maxUses : 1,
      ttlHours: params.ttlHours,
    );
  }
}

class PreviewInvitation implements UseCase<InvitationPreview, String> {
  PreviewInvitation(this._repository);

  final InvitationRepository _repository;

  @override
  Future<Either<Failure, InvitationPreview>> call(String code) {
    final normalized = normalizeInviteCode(code);
    if (normalized.length < _minCodeLength) return Future.value(left(_badCode));
    return _repository.preview(normalized);
  }
}

class RespondToInvitationParams {
  const RespondToInvitationParams({required this.code, required this.accept});

  final String code;
  final bool accept;
}

class RespondToInvitation
    implements UseCase<InvitationResult, RespondToInvitationParams> {
  RespondToInvitation(this._repository);

  final InvitationRepository _repository;

  @override
  Future<Either<Failure, InvitationResult>> call(
    RespondToInvitationParams params,
  ) {
    final normalized = normalizeInviteCode(params.code);
    if (normalized.length < _minCodeLength) return Future.value(left(_badCode));
    return _repository.respond(code: normalized, accept: params.accept);
  }
}

class RevokeInvitation implements UseCase<Unit, String> {
  RevokeInvitation(this._repository);

  final InvitationRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(String invitationId) =>
      _repository.revoke(invitationId);
}

class WatchPendingInvitations
    implements StreamUseCase<List<PendingInvitation>, NoParams> {
  WatchPendingInvitations(this._repository);

  final InvitationRepository _repository;

  @override
  Stream<Either<Failure, List<PendingInvitation>>> call(NoParams params) =>
      _repository.watchPending();
}

class InvitePersonParams {
  const InvitePersonParams({
    required this.type,
    required this.targetId,
    required this.inviteeUid,
    this.ttlHours = 72,
  });

  final InvitationType type;
  final String targetId;
  final String inviteeUid;
  final int ttlHours;
}

class InvitePerson implements UseCase<Unit, InvitePersonParams> {
  InvitePerson(this._repository);

  final InvitationRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(InvitePersonParams params) {
    if (params.ttlHours < 1 || params.ttlHours > 24 * 14) {
      return Future.value(
        left(
          const Failure.validation(
            message: 'Expiry must be 1 hour to 14 days.',
          ),
        ),
      );
    }
    return _repository.createForPerson(
      type: params.type,
      targetId: params.targetId,
      inviteeUid: params.inviteeUid,
      ttlHours: params.ttlHours,
    );
  }
}

class ListInvitablePeopleParams {
  const ListInvitablePeopleParams({required this.type, required this.targetId});

  final InvitationType type;
  final String targetId;
}

class ListInvitablePeople
    implements UseCase<List<InvitablePerson>, ListInvitablePeopleParams> {
  ListInvitablePeople(this._repository);

  final InvitationRepository _repository;

  @override
  Future<Either<Failure, List<InvitablePerson>>> call(
    ListInvitablePeopleParams params,
  ) => _repository.listPeople(type: params.type, targetId: params.targetId);
}

class RespondToPendingParams {
  const RespondToPendingParams({
    required this.invitationId,
    required this.accept,
  });

  final String invitationId;
  final bool accept;
}

class RespondToPending
    implements UseCase<InvitationResult, RespondToPendingParams> {
  RespondToPending(this._repository);

  final InvitationRepository _repository;

  @override
  Future<Either<Failure, InvitationResult>> call(
    RespondToPendingParams params,
  ) => _repository.respondById(
    invitationId: params.invitationId,
    accept: params.accept,
  );
}

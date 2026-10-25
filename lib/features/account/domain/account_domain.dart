import 'package:fpdart/fpdart.dart';
import 'package:habit_tracker/core/error/failure.dart';
import 'package:habit_tracker/core/usecase/usecase.dart';

/// Who may see that you completed a habit.
enum ActivityVisibility {
  /// Other members see your name among those who completed.
  everyone,

  /// Others only see the count. Your name stays out of the list.
  countsOnly;

  static ActivityVisibility fromWireName(String? value) =>
      value == 'countsOnly' ? countsOnly : everyone;
}

class Profile {
  const Profile({required this.displayName, required this.visibility});

  static const Profile empty = Profile(
    displayName: '',
    visibility: ActivityVisibility.everyone,
  );

  final String displayName;
  final ActivityVisibility visibility;

  bool get hasName => displayName.trim().isNotEmpty;

  @override
  bool operator ==(Object other) =>
      other is Profile &&
      other.displayName == displayName &&
      other.visibility == visibility;

  @override
  int get hashCode => Object.hash(displayName, visibility);
}

class NotificationSettings {
  const NotificationSettings({
    this.push = true,
    this.invitations = true,
    this.reminders = true,
    this.milestones = true,
    this.quietStartMinutes = 22 * 60,
    this.quietEndMinutes = 7 * 60,
  });

  final bool push;
  final bool invitations;
  final bool reminders;
  final bool milestones;

  /// Minutes after local midnight. The window may wrap past midnight.
  final int quietStartMinutes;
  final int quietEndMinutes;

  NotificationSettings copyWith({
    bool? push,
    bool? invitations,
    bool? reminders,
    bool? milestones,
    int? quietStartMinutes,
    int? quietEndMinutes,
  }) => NotificationSettings(
    push: push ?? this.push,
    invitations: invitations ?? this.invitations,
    reminders: reminders ?? this.reminders,
    milestones: milestones ?? this.milestones,
    quietStartMinutes: quietStartMinutes ?? this.quietStartMinutes,
    quietEndMinutes: quietEndMinutes ?? this.quietEndMinutes,
  );

  @override
  bool operator ==(Object other) =>
      other is NotificationSettings &&
      other.push == push &&
      other.invitations == invitations &&
      other.reminders == reminders &&
      other.milestones == milestones &&
      other.quietStartMinutes == quietStartMinutes &&
      other.quietEndMinutes == quietEndMinutes;

  @override
  int get hashCode => Object.hash(
    push,
    invitations,
    reminders,
    milestones,
    quietStartMinutes,
    quietEndMinutes,
  );
}

class GoogleLinkState {
  const GoogleLinkState({required this.linked, this.email});

  final bool linked;
  final String? email;
}

abstract interface class AccountRepository {
  Stream<Either<Failure, Profile>> watchProfile();

  Future<Either<Failure, Unit>> saveProfile(Profile profile);

  Stream<Either<Failure, NotificationSettings>> watchNotificationSettings();

  Future<Either<Failure, Unit>> saveNotificationSettings(
    NotificationSettings settings,
  );

  GoogleLinkState get googleLinkState;

  /// Links Google to the current anonymous user without changing the UID.
  Future<Either<Failure, GoogleLinkState>> linkGoogle();

  /// Asks for permission and stores this device's token. Returns false when
  /// the user declined.
  Future<Either<Failure, bool>> registerForPush();

  /// Tells the server where this user is, so reminders and quiet hours use
  /// local time.
  Future<Either<Failure, Unit>> reportUtcOffset(int minutes);

  /// Ends this phone's session and starts a fresh guest account. This
  /// device's push token is removed from the old account first. A Google
  /// linked account keeps all its data online.
  Future<Either<Failure, Unit>> signOut();

  /// Deletes the account and everything in it for good, then starts a fresh
  /// guest account. Refused while the user owns a group or shared habit that
  /// other people still use: ownership has to be handed over first.
  Future<Either<Failure, Unit>> deleteAccount();

  /// Signs in with another Google account and moves everything to it:
  /// habits and history, group memberships and ownership, shared habits and
  /// invitations. The other account must have no Habitry data. The account you
  /// leave is emptied.
  Future<Either<Failure, MoveResult>> moveDataToAnotherAccount();

  /// Signs in with a different Google account the user picks. This device's
  /// push token is removed from the old account first, and put back if the
  /// switch does not happen.
  Future<Either<Failure, Unit>> switchAccount();
}

enum MoveOutcome {
  /// The data is now on the account that is signed in.
  moved,

  /// The new account is signed in, but the data stayed on the old one (for
  /// example the new account already had data). Switch back to see it.
  signedInWithoutData,
}

class MoveResult {
  const MoveResult(this.outcome, {this.message});

  final MoveOutcome outcome;

  /// Why the data did not move, in words for the user.
  final String? message;
}

class AccountRules {
  const AccountRules._();

  static const int nameMax = 40;
}

class WatchProfile implements StreamUseCase<Profile, NoParams> {
  WatchProfile(this._repository);

  final AccountRepository _repository;

  @override
  Stream<Either<Failure, Profile>> call(NoParams params) =>
      _repository.watchProfile();
}

class SaveProfile implements UseCase<Unit, Profile> {
  SaveProfile(this._repository);

  final AccountRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(Profile params) {
    final name = params.displayName.trim();
    if (name.isEmpty) {
      return Future.value(
        left(
          const Failure.validation(message: 'Enter the name others will see.'),
        ),
      );
    }
    if (name.length > AccountRules.nameMax) {
      return Future.value(
        left(
          const Failure.validation(
            message: 'Keep your name under ${AccountRules.nameMax} characters.',
          ),
        ),
      );
    }
    return _repository.saveProfile(
      Profile(displayName: name, visibility: params.visibility),
    );
  }
}

class LinkGoogleAccount implements UseCase<GoogleLinkState, NoParams> {
  LinkGoogleAccount(this._repository);

  final AccountRepository _repository;

  @override
  Future<Either<Failure, GoogleLinkState>> call(NoParams params) {
    if (_repository.googleLinkState.linked) {
      return Future.value(right(_repository.googleLinkState));
    }
    return _repository.linkGoogle();
  }
}

class WatchNotificationSettings
    implements StreamUseCase<NotificationSettings, NoParams> {
  WatchNotificationSettings(this._repository);

  final AccountRepository _repository;

  @override
  Stream<Either<Failure, NotificationSettings>> call(NoParams params) =>
      _repository.watchNotificationSettings();
}

class SaveNotificationSettings implements UseCase<Unit, NotificationSettings> {
  SaveNotificationSettings(this._repository);

  final AccountRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(NotificationSettings params) {
    bool valid(int minutes) => minutes >= 0 && minutes < 24 * 60;
    if (!valid(params.quietStartMinutes) || !valid(params.quietEndMinutes)) {
      return Future.value(
        left(
          const Failure.validation(
            message: 'Quiet hours must be a time of day.',
          ),
        ),
      );
    }
    return _repository.saveNotificationSettings(params);
  }
}

class RegisterForPush implements UseCase<bool, NoParams> {
  RegisterForPush(this._repository);

  final AccountRepository _repository;

  @override
  Future<Either<Failure, bool>> call(NoParams params) =>
      _repository.registerForPush();
}

class ReportDeviceTimeZone implements UseCase<Unit, int> {
  ReportDeviceTimeZone(this._repository);

  final AccountRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(int utcOffsetMinutes) =>
      _repository.reportUtcOffset(utcOffsetMinutes);
}

class SignOut implements UseCase<Unit, NoParams> {
  SignOut(this._repository);

  final AccountRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(NoParams params) => _repository.signOut();
}

class SwitchAccount implements UseCase<Unit, NoParams> {
  SwitchAccount(this._repository);

  final AccountRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(NoParams params) =>
      _repository.switchAccount();
}

class MoveAccountData implements UseCase<MoveResult, NoParams> {
  MoveAccountData(this._repository);

  final AccountRepository _repository;

  @override
  Future<Either<Failure, MoveResult>> call(NoParams params) =>
      _repository.moveDataToAnotherAccount();
}

class DeleteAccount implements UseCase<Unit, NoParams> {
  DeleteAccount(this._repository);

  final AccountRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(NoParams params) =>
      _repository.deleteAccount();
}

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fpdart/fpdart.dart';
import 'package:habit_tracker/core/auth/user_id_provider.dart';
import 'package:habit_tracker/core/data/exception_mapper.dart';
import 'package:habit_tracker/core/error/exceptions.dart';
import 'package:habit_tracker/core/error/failure.dart';
import 'package:habit_tracker/core/platform/platform_services.dart';
import 'package:habit_tracker/features/account/domain/account_domain.dart';
import 'package:rxdart/rxdart.dart';

class AccountRepositoryImpl implements AccountRepository {
  AccountRepositoryImpl({
    required FirebaseFirestore firestore,
    required UserIdProvider userIdProvider,
    required CallableClient callable,
    required AccountLinker linker,
    required PushMessaging push,
  }) : _firestore = firestore,
       _userIdProvider = userIdProvider,
       _callable = callable,
       _linker = linker,
       _push = push;

  final FirebaseFirestore _firestore;
  final UserIdProvider _userIdProvider;
  final CallableClient _callable;
  final AccountLinker _linker;
  final PushMessaging _push;
  StreamSubscription<String>? _tokenRefresh;

  /// The token this app instance saved, as a fallback when the platform
  /// cannot report one (for example offline).
  String? _savedToken;

  String _uid() {
    final uid = _userIdProvider.currentUserId;
    if (uid == null) throw const UnauthenticatedException();
    return uid;
  }

  DocumentReference<Map<String, dynamic>> _settings(String name) => _firestore
      .collection('users')
      .doc(_uid())
      .collection('settings')
      .doc(name);

  @override
  Stream<Either<Failure, Profile>> watchProfile() {
    return _guardStream(
      () => _settings('profile').snapshots().map((doc) {
        final data = doc.data();
        if (data == null) return Profile.empty;
        return Profile(
          displayName: (data['displayName'] as String?) ?? '',
          visibility: ActivityVisibility.fromWireName(
            data['visibility'] as String?,
          ),
        );
      }),
    );
  }

  /// The server copies the name and visibility onto every membership so other
  /// members see the change.
  @override
  Future<Either<Failure, Unit>> saveProfile(Profile profile) =>
      _guard(() async {
        await _callable.call('syncProfile', {
          'displayName': profile.displayName,
          'visibility': profile.visibility.name,
        });
        return unit;
      });

  @override
  Stream<Either<Failure, NotificationSettings>> watchNotificationSettings() {
    return _guardStream(
      () => _settings('notifications').snapshots().map((doc) {
        final data = doc.data();
        if (data == null) return const NotificationSettings();
        final categories = (data['categories'] as Map?) ?? const {};
        bool flag(Object? value) => value != false;
        return NotificationSettings(
          push: flag(data['push']),
          invitations: flag(categories['invitations']),
          reminders: flag(categories['reminders']),
          milestones: flag(categories['milestones']),
          quietStartMinutes:
              (data['quietStartMinutes'] as num?)?.toInt() ?? 22 * 60,
          quietEndMinutes: (data['quietEndMinutes'] as num?)?.toInt() ?? 7 * 60,
        );
      }),
    );
  }

  @override
  Future<Either<Failure, Unit>> saveNotificationSettings(
    NotificationSettings settings,
  ) => _guard(() async {
    await _settings('notifications').set({
      'push': settings.push,
      'categories': {
        'invitations': settings.invitations,
        'reminders': settings.reminders,
        'milestones': settings.milestones,
      },
      'quietStartMinutes': settings.quietStartMinutes,
      'quietEndMinutes': settings.quietEndMinutes,
    }, SetOptions(merge: true));
    return unit;
  });

  @override
  GoogleLinkState get googleLinkState =>
      GoogleLinkState(linked: _linker.isLinked, email: _linker.linkedEmail);

  @override
  Future<Either<Failure, GoogleLinkState>> linkGoogle() async {
    try {
      await _linker.linkWithGoogle();
      return right(googleLinkState);
    } on AccountLinkException catch (error) {
      return left(switch (error.reason) {
        AccountLinkFailure.cancelled => const Failure.validation(
          message: 'Sign-in was cancelled. Nothing changed.',
        ),
        AccountLinkFailure.alreadyInUse => const Failure.validation(
          message:
              'That Google account is already used by another Habitry '
              'account. Use a different one.',
        ),
        AccountLinkFailure.network => const Failure.network(),
        AccountLinkFailure.other => const Failure.server(
          message: 'Could not link Google. Please try again.',
        ),
      });
    } on Exception catch (error) {
      return left(mapExceptionToFailure(error));
    }
  }

  @override
  Future<Either<Failure, bool>> registerForPush() async {
    try {
      final token = await _push.registerForPush();
      if (token == null) return right(false);
      await _saveToken(token);
      await _tokenRefresh?.cancel();
      _tokenRefresh = _push.onTokenRefresh.listen(
        (fresh) => unawaited(_saveToken(fresh).catchError((Object _) {})),
      );
      return right(true);
    } on Exception catch (error) {
      return left(mapExceptionToFailure(error));
    }
  }

  Future<void> _saveToken(String token) {
    _savedToken = token;
    return _firestore
        .collection('users')
        .doc(_uid())
        .collection('devices')
        .doc(token)
        .set({'updatedAt': FieldValue.serverTimestamp()});
  }

  @override
  Future<Either<Failure, Unit>> reportUtcOffset(int minutes) =>
      _guard(() async {
        await _settings(
          'profile',
        ).set({'utcOffsetMinutes': minutes}, SetOptions(merge: true));
        return unit;
      });

  // -------------------------------------------------------------------------
  // Sign out and switch account
  // -------------------------------------------------------------------------

  static const Duration _ackTimeout = Duration(seconds: 3);

  /// Removes this device's push token from the account that is signed in now,
  /// so that account's notifications stop arriving on this phone. Must run
  /// while still signed in as that account (the rules only let it edit its
  /// own devices). Returns what it removed so a failed change can put it back.
  Future<({String uid, String token})?> _removeThisDevice() async {
    await _tokenRefresh?.cancel();
    _tokenRefresh = null;
    final uid = _userIdProvider.currentUserId;
    if (uid == null) return null;
    final token = await _push.currentToken() ?? _savedToken;
    if (token == null) return null;
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('devices')
          .doc(token)
          .delete()
          .timeout(_ackTimeout);
    } on Exception {
      // Offline: the delete is queued and goes through later. The change of
      // account must not wait for the network.
    }
    return (uid: uid, token: token);
  }

  /// Puts the token back after a change that did not happen.
  Future<void> _restoreThisDevice(({String uid, String token})? removed) async {
    if (removed == null || _userIdProvider.currentUserId != removed.uid) return;
    try {
      await _saveToken(removed.token).timeout(_ackTimeout);
    } on Exception {
      // Best effort. Turning notifications on again fixes it.
    }
  }

  @override
  Future<Either<Failure, Unit>> signOut() async {
    final removed = await _removeThisDevice();
    try {
      await _linker.signOut();
    } on Object catch (error) {
      await _restoreThisDevice(removed);
      return left(mapExceptionToFailure(error));
    }
    _savedToken = null;

    // The app always runs as somebody. Start a new, empty guest account.
    try {
      await _userIdProvider.ensureSignedIn();
    } on Object {
      return left(
        const Failure.network(
          message:
              'You are signed out. Reopen the app with an internet '
              'connection to continue.',
        ),
      );
    }
    unawaited(reportUtcOffset(DateTime.now().timeZoneOffset.inMinutes));
    return right(unit);
  }

  @override
  Future<Either<Failure, Unit>> deleteAccount() async {
    // Stop saving tokens for an account that is about to disappear.
    await _tokenRefresh?.cancel();
    _tokenRefresh = null;
    try {
      await _callable.call('deleteAccount');
    } on Object catch (error) {
      // Refused or failed: the account is still there, so push keeps working
      // the way it did.
      return left(mapExceptionToFailure(error));
    }
    _savedToken = null;
    try {
      // The server removed the sign in. Clear what the phone still holds.
      await _linker.signOut();
    } on Object {
      // Already gone on the server; nothing more to clear.
    }
    try {
      await _userIdProvider.ensureSignedIn();
    } on Object {
      return left(
        const Failure.network(
          message:
              'Your account was deleted. Reopen the app with an internet '
              'connection to start again.',
        ),
      );
    }
    return right(unit);
  }

  @override
  Future<Either<Failure, MoveResult>> moveDataToAnotherAccount() async {
    // The old account's token must be read now. Once the new account signs
    // in, only the new account's token is available.
    final String? oldToken;
    try {
      oldToken = await _linker.idToken();
    } on Object catch (error) {
      return left(mapExceptionToFailure(error));
    }
    if (oldToken == null) return left(const Failure.unauthenticated());

    final removed = await _removeThisDevice();
    try {
      await _linker.signInWithGoogle();
    } on AccountLinkException catch (error) {
      await _restoreThisDevice(removed);
      return left(switch (error.reason) {
        AccountLinkFailure.cancelled => const Failure.validation(
          message: 'Nothing changed. Your data is still on this account.',
        ),
        AccountLinkFailure.network => const Failure.network(),
        _ => const Failure.server(
          message: 'Could not sign in to the other account. Try again.',
        ),
      });
    } on Object catch (error) {
      await _restoreThisDevice(removed);
      return left(mapExceptionToFailure(error));
    }
    _savedToken = null;

    try {
      await _callable.call('migrateAccount', {'fromIdToken': oldToken});
    } on Object catch (error) {
      // The new account is signed in now, whatever happened. Say so.
      final failure = mapExceptionToFailure(error);
      return right(
        MoveResult(MoveOutcome.signedInWithoutData, message: failure.message),
      );
    }
    unawaited(reportUtcOffset(DateTime.now().timeZoneOffset.inMinutes));
    return right(const MoveResult(MoveOutcome.moved));
  }

  @override
  Future<Either<Failure, Unit>> switchAccount() async {
    final removed = await _removeThisDevice();
    try {
      await _linker.signInWithGoogle();
    } on AccountLinkException catch (error) {
      await _restoreThisDevice(removed);
      return left(switch (error.reason) {
        AccountLinkFailure.cancelled => const Failure.validation(
          message: 'Nothing changed. You are still signed in.',
        ),
        AccountLinkFailure.network => const Failure.network(),
        _ => const Failure.server(
          message: 'Could not switch account. Please try again.',
        ),
      });
    } on Object catch (error) {
      await _restoreThisDevice(removed);
      return left(mapExceptionToFailure(error));
    }
    _savedToken = null;
    unawaited(reportUtcOffset(DateTime.now().timeZoneOffset.inMinutes));
    return right(unit);
  }

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() action) async {
    try {
      return right(await action());
    } on Exception catch (error) {
      return left(mapExceptionToFailure(error));
    }
  }

  Stream<Either<Failure, T>> _guardStream<T>(Stream<T> Function() open) {
    final Stream<T> source;
    try {
      source = open();
    } on Exception catch (error) {
      return Stream.value(left(mapExceptionToFailure(error)));
    }
    return source
        .map<Either<Failure, T>>(right)
        .onErrorReturnWith((error, _) => left(mapExceptionToFailure(error)));
  }
}

import 'dart:async';

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:habit_tracker/core/error/failure.dart';
import 'package:habit_tracker/core/auth/user_id_provider.dart';
import 'package:habit_tracker/core/platform/platform_services.dart';
import 'package:habit_tracker/core/usecase/usecase.dart';
import 'package:habit_tracker/features/account/data/account_repository_impl.dart';
import 'package:habit_tracker/features/account/domain/account_domain.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fakes.dart';

class MockAccountRepository extends Mock implements AccountRepository {}

/// Shared record of what happened, in order, across the fakes.
class EventLog {
  final List<String> events = [];
}

class FakeLinker implements AccountLinker {
  FakeLinker([this.log]);

  final EventLog? log;
  bool linked = false;
  AccountLinkFailure? failWith;
  AccountLinkFailure? signInFailWith;
  Object? signOutError;

  /// Runs when sign out / sign in succeed, to move the fake user.
  VoidCallback? onSignedOut;
  VoidCallback? onSignedIn;

  @override
  bool get isLinked => linked;

  @override
  String? get linkedEmail => linked ? 'a@b.c' : null;

  @override
  Future<void> linkWithGoogle() async {
    final reason = failWith;
    if (reason != null) throw AccountLinkException(reason);
    linked = true;
  }

  /// The token of whoever is signed in right now. Changes with the user.
  String? Function()? currentToken;

  @override
  Future<String?> idToken() async {
    log?.events.add('linker.idToken');
    return currentToken?.call();
  }

  @override
  Future<void> signOut() async {
    log?.events.add('linker.signOut');
    final error = signOutError;
    if (error != null) throw error;
    onSignedOut?.call();
  }

  @override
  Future<void> signInWithGoogle() async {
    log?.events.add('linker.signInWithGoogle');
    final reason = signInFailWith;
    if (reason != null) throw AccountLinkException(reason);
    onSignedIn?.call();
  }
}

typedef VoidCallback = void Function();

class FakePush implements PushMessaging {
  String? token = 'tok-1';

  /// What the platform reports for this device, when asked without a prompt.
  String? reportedToken = 'tok-1';
  final refresh = StreamController<String>.broadcast();

  @override
  Stream<String> get onTokenRefresh => refresh.stream;

  @override
  Future<String?> registerForPush() async => token;

  @override
  Future<String?> currentToken() async => reportedToken;
}

/// A user id provider whose user can change, and that records sign in calls.
class MovableUserIdProvider implements UserIdProvider {
  MovableUserIdProvider(this.uid, [this.log]);

  String? uid;
  final EventLog? log;
  Object? ensureError;
  int ensureCalls = 0;

  @override
  String? get currentUserId => uid;

  @override
  Future<String> ensureSignedIn() async {
    ensureCalls++;
    log?.events.add('ensureSignedIn');
    final error = ensureError;
    if (error != null) throw error;
    return uid ??= 'guest-new';
  }
}

void main() {
  setUpAll(() {
    registerFallbackValue(Profile.empty);
    registerFallbackValue(const NotificationSettings());
  });

  group('use cases', () {
    late MockAccountRepository repository;

    setUp(() => repository = MockAccountRepository());

    test('SaveProfile trims and saves', () async {
      when(
        () => repository.saveProfile(any()),
      ).thenAnswer((_) async => right(unit));

      await SaveProfile(repository)(
        const Profile(
          displayName: '  Ann  ',
          visibility: ActivityVisibility.countsOnly,
        ),
      );

      final saved =
          verify(() => repository.saveProfile(captureAny())).captured.single
              as Profile;
      expect(saved.displayName, 'Ann');
      expect(saved.visibility, ActivityVisibility.countsOnly);
    });

    for (final (label, name) in [
      ('a blank name', '   '),
      ('a 41 character name', 'x' * 41),
    ]) {
      test('SaveProfile rejects $label', () async {
        final result = await SaveProfile(repository)(
          Profile(displayName: name, visibility: ActivityVisibility.everyone),
        );

        expect(result.getLeft().toNullable(), isA<ValidationFailure>());
        verifyNever(() => repository.saveProfile(any()));
      });
    }

    test(
      'SaveNotificationSettings rejects an out of range quiet time',
      () async {
        final result = await SaveNotificationSettings(repository)(
          const NotificationSettings(quietStartMinutes: 24 * 60),
        );

        expect(result.getLeft().toNullable(), isA<ValidationFailure>());
      },
    );

    test('SaveNotificationSettings accepts a window past midnight', () async {
      when(
        () => repository.saveNotificationSettings(any()),
      ).thenAnswer((_) async => right(unit));

      final result = await SaveNotificationSettings(repository)(
        const NotificationSettings(
          quietStartMinutes: 23 * 60,
          quietEndMinutes: 6 * 60,
        ),
      );

      expect(result.isRight(), isTrue);
    });

    test('LinkGoogleAccount does nothing when already linked', () async {
      when(
        () => repository.googleLinkState,
      ).thenReturn(const GoogleLinkState(linked: true, email: 'a@b.c'));

      final result = await LinkGoogleAccount(repository)(const NoParams());

      expect(result.getRight().toNullable()!.email, 'a@b.c');
      verifyNever(() => repository.linkGoogle());
    });
  });

  group('AccountRepositoryImpl', () {
    late FakeFirebaseFirestore firestore;
    late FakeCallableClient callable;
    late FakeLinker linker;
    late FakePush push;
    late AccountRepositoryImpl repository;

    setUp(() {
      firestore = FakeFirebaseFirestore();
      callable = FakeCallableClient();
      linker = FakeLinker();
      push = FakePush();
      repository = AccountRepositoryImpl(
        firestore: firestore,
        userIdProvider: FakeUserIdProvider('alice'),
        callable: callable,
        linker: linker,
        push: push,
      );
    });

    test('a user with no profile document gets an empty profile', () async {
      final result = await repository.watchProfile().first;

      expect(result.getRight().toNullable(), Profile.empty);
      expect(Profile.empty.hasName, isFalse);
    });

    test('reads the saved profile', () async {
      await firestore.doc('users/alice/settings/profile').set({
        'displayName': 'Ann',
        'visibility': 'countsOnly',
      });

      final profile = (await repository.watchProfile().first)
          .getRight()
          .toNullable()!;

      expect(profile.displayName, 'Ann');
      expect(profile.visibility, ActivityVisibility.countsOnly);
    });

    test('saving goes through the function that updates memberships', () async {
      await repository.saveProfile(
        const Profile(
          displayName: 'Ann',
          visibility: ActivityVisibility.everyone,
        ),
      );

      expect(callable.calls.single.name, 'syncProfile');
      expect(callable.calls.single.data, {
        'displayName': 'Ann',
        'visibility': 'everyone',
      });
    });

    test('notification settings default to everything on', () async {
      final settings = (await repository.watchNotificationSettings().first)
          .getRight()
          .toNullable()!;

      expect(settings, const NotificationSettings());
    });

    test('notification settings round trip', () async {
      const changed = NotificationSettings(
        push: false,
        reminders: false,
        quietStartMinutes: 23 * 60 + 30,
        quietEndMinutes: 6 * 60,
      );

      await repository.saveNotificationSettings(changed);
      final loaded = (await repository.watchNotificationSettings().first)
          .getRight()
          .toNullable()!;

      expect(loaded, changed);
      expect(loaded.invitations, isTrue);
    });

    test('linking Google reports the new state', () async {
      final result = await repository.linkGoogle();

      expect(result.getRight().toNullable()!.linked, isTrue);
      expect(repository.googleLinkState.email, 'a@b.c');
    });

    final linkFailures = <AccountLinkFailure, Matcher>{
      AccountLinkFailure.cancelled: isA<ValidationFailure>(),
      AccountLinkFailure.alreadyInUse: isA<ValidationFailure>(),
      AccountLinkFailure.network: isA<NetworkFailure>(),
      AccountLinkFailure.other: isA<ServerFailure>(),
    };
    linkFailures.forEach((reason, matcher) {
      test('link failure "$reason" becomes the right Failure', () async {
        linker.failWith = reason;

        final result = await repository.linkGoogle();

        expect(result.getLeft().toNullable(), matcher);
        expect(linker.linked, isFalse);
      });
    });

    test('registering for push stores the device token', () async {
      final result = await repository.registerForPush();

      expect(result, right(true));
      final doc = await firestore.doc('users/alice/devices/tok-1').get();
      expect(doc.exists, isTrue);
    });

    test('a declined permission stores nothing', () async {
      push.token = null;

      final result = await repository.registerForPush();

      expect(result, right(false));
      final devices = await firestore.collection('users/alice/devices').get();
      expect(devices.docs, isEmpty);
    });

    test('a refreshed token is stored too', () async {
      await repository.registerForPush();

      push.refresh.add('tok-2');
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      final devices = await firestore.collection('users/alice/devices').get();
      expect(devices.docs.map((d) => d.id), containsAll(['tok-1', 'tok-2']));
    });

    test(
      'reports the UTC offset into the profile without losing the name',
      () async {
        await firestore.doc('users/alice/settings/profile').set({
          'displayName': 'Ann',
        });

        await repository.reportUtcOffset(330);

        final data = (await firestore.doc('users/alice/settings/profile').get())
            .data()!;
        expect(data['utcOffsetMinutes'], 330);
        expect(data['displayName'], 'Ann');
      },
    );
  });

  group('sign out and switch account', () {
    late FakeFirebaseFirestore firestore;
    late EventLog log;
    late MovableUserIdProvider user;
    late FakeLinker linker;
    late FakePush push;
    late AccountRepositoryImpl repository;

    Future<bool> deviceExists(String uid, String token) async =>
        (await firestore.doc('users/$uid/devices/$token').get()).exists;

    setUp(() async {
      firestore = FakeFirebaseFirestore();
      log = EventLog();
      user = MovableUserIdProvider('alice', log);
      linker = FakeLinker(log)
        ..linked = true
        ..onSignedOut = (() => user.uid = null)
        ..onSignedIn = (() => user.uid = 'bob');
      push = FakePush();
      repository = AccountRepositoryImpl(
        firestore: firestore,
        userIdProvider: user,
        callable: FakeCallableClient(),
        linker: linker,
        push: push,
      );
      await firestore.doc('users/alice/devices/tok-1').set({'a': 1});
      await firestore.doc('users/alice/devices/other-phone').set({'a': 1});
    });

    test('sign out removes this phone from the old account first', () async {
      final result = await repository.signOut();

      expect(result, right(unit));
      expect(await deviceExists('alice', 'tok-1'), isFalse);
      // Other phones of the same account keep working.
      expect(await deviceExists('alice', 'other-phone'), isTrue);
    });

    test('sign out starts a guest account only after signing out', () async {
      await repository.signOut();

      expect(log.events, ['linker.signOut', 'ensureSignedIn']);
      expect(user.ensureCalls, 1);
    });

    test('the token is found even if this app never saved it', () async {
      // A fresh install of the app: nothing was registered in this session,
      // but the platform still knows the token.
      expect(await deviceExists('alice', 'tok-1'), isTrue);

      await repository.signOut();

      expect(await deviceExists('alice', 'tok-1'), isFalse);
    });

    test(
      'falls back to the token it saved when the platform has none',
      () async {
        push.reportedToken = null;
        await repository.registerForPush();

        await repository.signOut();

        expect(await deviceExists('alice', 'tok-1'), isFalse);
      },
    );

    test('signing out without any token still works', () async {
      push.reportedToken = null;

      final result = await repository.signOut();

      expect(result, right(unit));
      expect(await deviceExists('alice', 'tok-1'), isTrue);
    });

    test(
      'a failed sign out leaves the account signed in with its token',
      () async {
        linker.signOutError = StateError('boom');

        final result = await repository.signOut();

        expect(result.isLeft(), isTrue);
        expect(user.uid, 'alice');
        expect(user.ensureCalls, 0);
        expect(await deviceExists('alice', 'tok-1'), isTrue);
      },
    );

    test(
      'if the guest account cannot start, it says how to continue',
      () async {
        user.ensureError = StateError('offline');

        final result = await repository.signOut();

        final failure = result.getLeft().toNullable()!;
        expect(failure, isA<NetworkFailure>());
        expect(failure.message, contains('Reopen the app'));
      },
    );

    test('a token refresh after sign out is not saved to anyone', () async {
      await repository.registerForPush();

      await repository.signOut();
      user.uid = 'guest-new';
      push.refresh.add('tok-new');
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(await deviceExists('guest-new', 'tok-new'), isFalse);
      expect(await deviceExists('alice', 'tok-new'), isFalse);
    });

    test(
      'switching signs in to the chosen account after removing the token',
      () async {
        final result = await repository.switchAccount();

        expect(result, right(unit));
        expect(await deviceExists('alice', 'tok-1'), isFalse);
        expect(user.uid, 'bob');
        expect(log.events, ['linker.signInWithGoogle']);
      },
    );

    test(
      'cancelling the Google picker changes nothing and keeps notifications',
      () async {
        linker.signInFailWith = AccountLinkFailure.cancelled;

        final result = await repository.switchAccount();

        final failure = result.getLeft().toNullable()!;
        expect(failure, isA<ValidationFailure>());
        expect(failure.message, contains('still signed in'));
        expect(user.uid, 'alice');
        // The token was put back, so alice is not left without notifications.
        expect(await deviceExists('alice', 'tok-1'), isTrue);
      },
    );

    final failures = <AccountLinkFailure, Matcher>{
      AccountLinkFailure.network: isA<NetworkFailure>(),
      AccountLinkFailure.other: isA<ServerFailure>(),
      AccountLinkFailure.alreadyInUse: isA<ServerFailure>(),
    };
    failures.forEach((reason, matcher) {
      test(
        'switch failure "$reason" is reported and restores the token',
        () async {
          linker.signInFailWith = reason;

          final result = await repository.switchAccount();

          expect(result.getLeft().toNullable(), matcher);
          expect(user.uid, 'alice');
          expect(await deviceExists('alice', 'tok-1'), isTrue);
        },
      );
    });

    test(
      'a switch that succeeded does not put the token back on the old account',
      () async {
        await repository.switchAccount();

        expect(await deviceExists('alice', 'tok-1'), isFalse);
        expect(await deviceExists('bob', 'tok-1'), isFalse);
      },
    );
  });

  group('delete account', () {
    late FakeFirebaseFirestore firestore;
    late _LoggingCallable callable;
    late EventLog log;
    late MovableUserIdProvider user;
    late FakeLinker linker;
    late FakePush push;
    late AccountRepositoryImpl repository;

    setUp(() async {
      firestore = FakeFirebaseFirestore();
      log = EventLog();
      callable = _LoggingCallable(log);
      user = MovableUserIdProvider('alice', log);
      linker = FakeLinker(log)
        ..linked = true
        ..onSignedOut = (() => user.uid = null);
      push = FakePush();
      repository = AccountRepositoryImpl(
        firestore: firestore,
        userIdProvider: user,
        callable: callable,
        linker: linker,
        push: push,
      );
    });

    test(
      'asks the server, clears the phone, then starts a guest account',
      () async {
        final result = await repository.deleteAccount();

        expect(result, right(unit));
        expect(log.events, [
          'callable.deleteAccount',
          'linker.signOut',
          'ensureSignedIn',
        ]);
      },
    );

    test('when the server refuses, nothing is signed out', () async {
      callable.error = const CallableException(
        'failed-precondition',
        'Transfer ownership of your groups before deleting your account.',
      );

      final result = await repository.deleteAccount();

      final failure = result.getLeft().toNullable()!;
      expect(failure, isA<ValidationFailure>());
      expect(failure.message, contains('Transfer ownership'));
      expect(user.uid, 'alice');
      expect(log.events, ['callable.deleteAccount']);
    });

    test('no network leaves the account untouched', () async {
      callable.error = const CallableException('unavailable', 'No connection.');

      final result = await repository.deleteAccount();

      expect(result.getLeft().toNullable(), isA<NetworkFailure>());
      expect(user.uid, 'alice');
    });

    test('if the guest account cannot start, it says what happened', () async {
      user.ensureError = StateError('offline');

      final result = await repository.deleteAccount();

      final failure = result.getLeft().toNullable()!;
      expect(failure.message, contains('was deleted'));
      expect(failure.message, contains('Reopen the app'));
    });

    test('a token refresh after deleting is not saved', () async {
      await repository.registerForPush();

      await repository.deleteAccount();
      user.uid = 'guest-new';
      push.refresh.add('tok-new');
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      final devices = await firestore
          .collection('users/guest-new/devices')
          .get();
      expect(devices.docs, isEmpty);
    });
  });

  group('move data to another account', () {
    late FakeFirebaseFirestore firestore;
    late _LoggingCallable callable;
    late EventLog log;
    late MovableUserIdProvider user;
    late FakeLinker linker;
    late FakePush push;
    late AccountRepositoryImpl repository;

    Future<bool> deviceExists(String uid, String token) async =>
        (await firestore.doc('users/$uid/devices/$token').get()).exists;

    setUp(() async {
      firestore = FakeFirebaseFirestore();
      log = EventLog();
      callable = _LoggingCallable(log);
      user = MovableUserIdProvider('alice', log);
      linker = FakeLinker(log)
        ..linked = true
        ..currentToken = (() => 'token-of-${user.uid}')
        ..onSignedIn = (() => user.uid = 'bob');
      push = FakePush();
      repository = AccountRepositoryImpl(
        firestore: firestore,
        userIdProvider: user,
        callable: callable,
        linker: linker,
        push: push,
      );
      await firestore.doc('users/alice/devices/tok-1').set({'a': 1});
    });

    test(
      'reads the old account token BEFORE signing in to the new one',
      () async {
        final result = await repository.moveDataToAnotherAccount();

        expect(result.getRight().toNullable()!.outcome, MoveOutcome.moved);
        expect(log.events, [
          'linker.idToken',
          'linker.signInWithGoogle',
          'callable.migrateAccount',
        ]);
      },
    );

    test('sends the OLD account token to the server', () async {
      await repository.moveDataToAnotherAccount();

      final call = callable.calls.single;
      expect(call.name, 'migrateAccount');
      expect(call.data, {'fromIdToken': 'token-of-alice'});
    });

    test('removes this phone from the old account', () async {
      await repository.moveDataToAnotherAccount();

      expect(await deviceExists('alice', 'tok-1'), isFalse);
    });

    test(
      'cancelling the picker changes nothing and never calls the server',
      () async {
        linker.signInFailWith = AccountLinkFailure.cancelled;

        final result = await repository.moveDataToAnotherAccount();

        expect(result.getLeft().toNullable(), isA<ValidationFailure>());
        expect(user.uid, 'alice');
        expect(callable.calls, isEmpty);
        expect(await deviceExists('alice', 'tok-1'), isTrue);
      },
    );

    test(
      'no network at the picker is a network failure and restores the token',
      () async {
        linker.signInFailWith = AccountLinkFailure.network;

        final result = await repository.moveDataToAnotherAccount();

        expect(result.getLeft().toNullable(), isA<NetworkFailure>());
        expect(await deviceExists('alice', 'tok-1'), isTrue);
      },
    );

    test('with nobody signed in there is nothing to move', () async {
      linker.currentToken = () => null;

      final result = await repository.moveDataToAnotherAccount();

      expect(result.getLeft().toNullable(), isA<UnauthenticatedFailure>());
      expect(log.events, ['linker.idToken']);
    });

    test(
      'a server refusal says so and tells the user which account is signed in',
      () async {
        callable.error = const CallableException(
          'failed-precondition',
          'The account you picked already has habits or groups.',
        );

        final result = await repository.moveDataToAnotherAccount();

        final value = result.getRight().toNullable()!;
        expect(value.outcome, MoveOutcome.signedInWithoutData);
        expect(value.message, contains('already has habits or groups'));
        // The new account is the one that is signed in.
        expect(user.uid, 'bob');
      },
    );

    test('an expired old sign in is explained, not hidden', () async {
      callable.error = const CallableException(
        'unauthenticated',
        "The previous account's sign in expired.",
      );

      final result = await repository.moveDataToAnotherAccount();

      expect(
        result.getRight().toNullable()!.outcome,
        MoveOutcome.signedInWithoutData,
      );
    });

    test('a network failure while moving is reported as not moved', () async {
      callable.error = const CallableException('unavailable', 'No connection.');

      final result = await repository.moveDataToAnotherAccount();

      expect(
        result.getRight().toNullable()!.outcome,
        MoveOutcome.signedInWithoutData,
      );
    });
  });
}

/// Records calls in the shared event log, and can be made to fail.
class _LoggingCallable implements CallableClient {
  _LoggingCallable(this._log);

  final EventLog _log;
  final List<({String name, Map<String, dynamic> data})> calls = [];
  CallableException? error;

  @override
  Future<Map<String, dynamic>> call(
    String name, [
    Map<String, dynamic> data = const {},
  ]) async {
    _log.events.add('callable.$name');
    calls.add((name: name, data: Map<String, dynamic>.of(data)));
    final failure = error;
    if (failure != null) throw failure;
    return const {};
  }
}

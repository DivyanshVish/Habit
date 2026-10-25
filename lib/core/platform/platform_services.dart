// Thin, plain-Dart seams over the Firebase plugins that only the real app
// needs (callable functions, Google sign-in, push). Only `main.dart` knows the
// real implementations (`firebase_platform.dart`); everything else, tests
// included, depends on these interfaces.

/// An error returned by a callable Cloud Function. [code] is the Firebase
/// functions code, e.g. `permission-denied` or `failed-precondition`.
class CallableException implements Exception {
  const CallableException(this.code, this.message, {this.details});

  final String code;
  final String message;
  final Object? details;

  @override
  String toString() => 'CallableException($code): $message';
}

abstract interface class CallableClient {
  Future<Map<String, dynamic>> call(
    String name, [
    Map<String, dynamic> data = const {},
  ]);
}

/// Thrown by [AccountLinker] when linking fails for a reason worth showing.
class AccountLinkException implements Exception {
  const AccountLinkException(this.reason);

  final AccountLinkFailure reason;

  @override
  String toString() => 'AccountLinkException($reason)';
}

enum AccountLinkFailure {
  /// The user closed the Google picker.
  cancelled,

  /// That Google account already belongs to another Habitry account.
  alreadyInUse,

  network,
  other,
}

abstract interface class AccountLinker {
  /// Whether the signed-in user already has a Google account linked.
  bool get isLinked;

  String? get linkedEmail;

  /// Links Google to the current anonymous user. The UID does not change, so
  /// all data stays where it is. Throws [AccountLinkException].
  Future<void> linkWithGoogle();

  /// A fresh sign in token for the current user, or null if nobody is signed
  /// in. Moving data needs the OLD account's token after the new account has
  /// signed in, so it is read before switching.
  Future<String?> idToken();

  /// Signs the current user out of Firebase and Google. Nobody is signed in
  /// afterwards; the caller starts a new guest session.
  Future<void> signOut();

  /// Signs in with a Google account the user picks, replacing the current
  /// session. This is a different account (a different UID), not a link.
  /// Throws [AccountLinkException].
  Future<void> signInWithGoogle();
}

abstract interface class PushMessaging {
  /// Asks for permission and returns the device token, or null if denied.
  Future<String?> registerForPush();

  /// This device's token without asking for permission, or null if there is
  /// none. Used to remove the token from an account on sign out.
  Future<String?> currentToken();

  Stream<String> get onTokenRefresh;
}

class PlatformServices {
  const PlatformServices({
    required this.callable,
    required this.accountLinker,
    required this.push,
  });

  final CallableClient callable;
  final AccountLinker accountLinker;
  final PushMessaging push;

  /// Used by tests and by builds that do not provide the plugins. Every call
  /// fails with a clear message instead of crashing.
  static const PlatformServices unavailable = PlatformServices(
    callable: _UnavailableCallable(),
    accountLinker: _UnavailableLinker(),
    push: _UnavailablePush(),
  );
}

class _UnavailableCallable implements CallableClient {
  const _UnavailableCallable();

  @override
  Future<Map<String, dynamic>> call(
    String name, [
    Map<String, dynamic> data = const {},
  ]) => Future.error(
    const CallableException(
      'unavailable',
      'Online features are not available.',
    ),
  );
}

class _UnavailableLinker implements AccountLinker {
  const _UnavailableLinker();

  @override
  bool get isLinked => false;

  @override
  String? get linkedEmail => null;

  @override
  Future<void> linkWithGoogle() =>
      Future.error(const AccountLinkException(AccountLinkFailure.other));

  @override
  Future<String?> idToken() async => null;

  @override
  Future<void> signOut() => Future<void>.value();

  @override
  Future<void> signInWithGoogle() =>
      Future.error(const AccountLinkException(AccountLinkFailure.other));
}

class _UnavailablePush implements PushMessaging {
  const _UnavailablePush();

  @override
  Stream<String> get onTokenRefresh => const Stream.empty();

  @override
  Future<String?> registerForPush() async => null;

  @override
  Future<String?> currentToken() async => null;
}

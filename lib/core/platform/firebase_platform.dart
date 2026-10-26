import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:habit_tracker/core/platform/http_callable_client.dart';
import 'package:habit_tracker/core/platform/platform_services.dart';

/// Address of the backend (the Vercel deployment). Override it at build time
/// with `--dart-define=API_BASE_URL=https://your-app.vercel.app`. The default is
/// this project's own deployment, so running from an IDE without the flag still
/// reaches it.
const String apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'https://habbitry.vercel.app',
);

/// The real plugin-backed services. Imported by `main.dart` only.
///
/// Not exercised by the automated tests: it needs the plugins, a deployed
/// backend, and a device. Verify on a phone.
PlatformServices createFirebasePlatformServices() => PlatformServices(
  callable: HttpCallableClient(
    baseUrl: apiBaseUrl,
    idToken: () async => FirebaseAuth.instance.currentUser?.getIdToken(),
  ),
  accountLinker: GoogleAccountLinker(FirebaseAuth.instance),
  push: FirebasePushMessaging(FirebaseMessaging.instance),
);

class GoogleAccountLinker implements AccountLinker {
  GoogleAccountLinker(this._auth);

  final FirebaseAuth _auth;
  bool _initialised = false;

  Future<GoogleSignIn> _googleSignIn() async {
    final signIn = GoogleSignIn.instance;
    if (!_initialised) {
      await signIn.initialize();
      _initialised = true;
    }
    return signIn;
  }

  /// Asks the user to pick a Google account and returns its credential.
  Future<AuthCredential> _pickCredential() async {
    final signIn = await _googleSignIn();
    final account = await signIn.authenticate();
    final idToken = account.authentication.idToken;
    return GoogleAuthProvider.credential(idToken: idToken);
  }

  AccountLinkException _translate(Object error) {
    if (error is GoogleSignInException) {
      return AccountLinkException(
        error.code == GoogleSignInExceptionCode.canceled
            ? AccountLinkFailure.cancelled
            : AccountLinkFailure.other,
      );
    }
    if (error is FirebaseAuthException) {
      return AccountLinkException(switch (error.code) {
        'credential-already-in-use' ||
        'email-already-in-use' => AccountLinkFailure.alreadyInUse,
        'network-request-failed' => AccountLinkFailure.network,
        _ => AccountLinkFailure.other,
      });
    }
    return const AccountLinkException(AccountLinkFailure.other);
  }

  @override
  bool get isLinked =>
      _auth.currentUser?.providerData.any(
        (p) => p.providerId == 'google.com',
      ) ??
      false;

  @override
  String? get linkedEmail => _auth.currentUser?.providerData
      .where((p) => p.providerId == 'google.com')
      .map((p) => p.email)
      .firstOrNull;

  @override
  Future<void> linkWithGoogle() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw const AccountLinkException(AccountLinkFailure.other);
    }
    try {
      await user.linkWithCredential(await _pickCredential());
    } on Object catch (error) {
      throw _translate(error);
    }
  }

  @override
  Future<void> signInWithGoogle() async {
    try {
      await _auth.signInWithCredential(await _pickCredential());
    } on Object catch (error) {
      throw _translate(error);
    }
  }

  @override
  Future<String?> idToken() async => _auth.currentUser?.getIdToken(true);

  @override
  Future<void> signOut() async {
    try {
      // Forget the chosen Google account too, so the next sign in shows the
      // account picker instead of silently reusing it.
      await (await _googleSignIn()).signOut();
    } on Object {
      // Not signed in to Google (a guest). Nothing to forget.
    }
    await _auth.signOut();
  }
}

class FirebasePushMessaging implements PushMessaging {
  FirebasePushMessaging(this._messaging);

  final FirebaseMessaging _messaging;

  @override
  Stream<String> get onTokenRefresh => _messaging.onTokenRefresh;

  @override
  Future<String?> currentToken() async {
    try {
      return await _messaging.getToken();
    } on Object {
      return null;
    }
  }

  @override
  Future<String?> registerForPush() async {
    final settings = await _messaging.requestPermission();
    if (settings.authorizationStatus == AuthorizationStatus.denied) return null;
    return _messaging.getToken();
  }
}

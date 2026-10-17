import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:habit_tracker/bootstrap_exception.dart';
import 'package:habit_tracker/core/auth/user_id_provider.dart';
import 'package:habit_tracker/core/di/injection.dart';
import 'package:habit_tracker/firebase_options.dart';

/// Initializes Firebase, wires dependencies and signs the user in anonymously.
///
/// Throws if anything fails (e.g. no network on first launch); the UI shows a
/// retry screen in that case.
Future<void> bootstrap() async {
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
  configureDependencies();
  try {
    await getIt<UserIdProvider>().ensureSignedIn();
  } on FirebaseAuthException catch (error) {
    throw BootstrapException(describeAuthError(error));
  }
}

/// Turns a sign-in error into an actionable message.
String describeAuthError(FirebaseAuthException error) {
  const notEnabled =
      'Sign-in failed. Anonymous sign-in may not be enabled for this '
      'Firebase project. Enable it under Authentication > Sign-in method, '
      'then retry.';
  switch (error.code) {
    case 'network-request-failed':
      return 'No connection. Check your internet and try again.';
    // Android reports a project without Authentication set up as "unknown"
    // or "internal-error" (server says CONFIGURATION_NOT_FOUND).
    case 'operation-not-allowed':
    case 'admin-restricted-operation':
    case 'configuration-not-found':
    case 'internal-error':
    case 'unknown':
      return notEnabled;
    default:
      return 'Sign-in failed (${error.code}). Please try again.';
  }
}

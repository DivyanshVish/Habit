import 'package:firebase_auth/firebase_auth.dart';
import 'package:habit_tracker/core/auth/user_id_provider.dart';

/// [UserIdProvider] backed by Firebase anonymous authentication.
class FirebaseUserIdProvider implements UserIdProvider {
  FirebaseUserIdProvider(this._auth);

  final FirebaseAuth _auth;

  @override
  String? get currentUserId => _auth.currentUser?.uid;

  @override
  Future<String> ensureSignedIn() async {
    final existing = _auth.currentUser;
    if (existing != null) return existing.uid;

    final credential = await _auth.signInAnonymously();
    final user = credential.user;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'null-user',
        message: 'Anonymous sign-in returned no user.',
      );
    }
    return user.uid;
  }
}

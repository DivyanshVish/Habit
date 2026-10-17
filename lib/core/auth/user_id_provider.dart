/// Provides the id of the current user. Data is scoped under `users/{uid}`.
abstract class UserIdProvider {
  /// The current user id, or null when nobody is signed in.
  String? get currentUserId;

  /// Returns the current user id, signing in anonymously first if needed.
  Future<String> ensureSignedIn();
}

/// Thrown by data sources when a requested document does not exist.
class NotFoundException implements Exception {
  const NotFoundException();

  @override
  String toString() => 'NotFoundException';
}

/// Thrown by data sources when no user is signed in.
class UnauthenticatedException implements Exception {
  const UnauthenticatedException();

  @override
  String toString() => 'UnauthenticatedException: no signed-in user';
}

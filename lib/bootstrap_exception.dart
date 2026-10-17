/// A start-up failure with a message that is safe to show to the user.
class BootstrapException implements Exception {
  const BootstrapException(this.message);

  final String message;

  @override
  String toString() => 'BootstrapException: $message';
}

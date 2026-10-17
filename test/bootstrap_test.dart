import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/bootstrap.dart';

void main() {
  FirebaseAuthException error(String code) => FirebaseAuthException(code: code);

  test('network errors ask the user to check the connection', () {
    expect(
      describeAuthError(error('network-request-failed')),
      contains('connection'),
    );
  });

  for (final code in [
    'operation-not-allowed',
    'admin-restricted-operation',
    'configuration-not-found',
    'internal-error',
    'unknown',
  ]) {
    test('$code points at enabling anonymous sign-in', () {
      expect(describeAuthError(error(code)), contains('Anonymous sign-in'));
    });
  }

  test('unknown codes include the code for debugging', () {
    expect(describeAuthError(error('weird')), contains('weird'));
  });
}

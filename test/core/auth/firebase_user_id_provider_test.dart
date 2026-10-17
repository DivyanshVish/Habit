import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/core/auth/firebase_user_id_provider.dart';
import 'package:mocktail/mocktail.dart';

class _MockFirebaseAuth extends Mock implements FirebaseAuth {}

class _MockUser extends Mock implements User {}

class _MockUserCredential extends Mock implements UserCredential {}

void main() {
  late _MockFirebaseAuth auth;
  late FirebaseUserIdProvider provider;

  setUp(() {
    auth = _MockFirebaseAuth();
    provider = FirebaseUserIdProvider(auth);
  });

  test('returns the existing uid without signing in again', () async {
    final user = _MockUser();
    when(() => user.uid).thenReturn('existing');
    when(() => auth.currentUser).thenReturn(user);

    expect(provider.currentUserId, 'existing');
    expect(await provider.ensureSignedIn(), 'existing');
    verifyNever(() => auth.signInAnonymously());
  });

  test('signs in anonymously when there is no user', () async {
    final user = _MockUser();
    final credential = _MockUserCredential();
    when(() => user.uid).thenReturn('new-uid');
    when(() => credential.user).thenReturn(user);
    when(() => auth.currentUser).thenReturn(null);
    when(() => auth.signInAnonymously()).thenAnswer((_) async => credential);

    expect(provider.currentUserId, isNull);
    expect(await provider.ensureSignedIn(), 'new-uid');
    verify(() => auth.signInAnonymously()).called(1);
  });

  test('throws when sign-in returns no user', () async {
    final credential = _MockUserCredential();
    when(() => credential.user).thenReturn(null);
    when(() => auth.currentUser).thenReturn(null);
    when(() => auth.signInAnonymously()).thenAnswer((_) async => credential);

    expect(provider.ensureSignedIn(), throwsA(isA<FirebaseAuthException>()));
  });
}

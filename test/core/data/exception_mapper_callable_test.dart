import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/core/data/exception_mapper.dart';
import 'package:habit_tracker/core/error/failure.dart';
import 'package:habit_tracker/core/platform/platform_services.dart';

void main() {
  Failure map(String code, [String message = 'A message.']) =>
      mapExceptionToFailure(CallableException(code, message));

  test('a setup problem is never reported as a network problem', () {
    final failure = map(
      'not-configured',
      'The online service address is not set.',
    );

    expect(failure, isA<ServerFailure>());
    expect(failure, isNot(isA<NetworkFailure>()));
    expect(failure.message, 'The online service address is not set.');
  });

  test('a service fault keeps its explanation', () {
    final failure = map(
      'internal',
      'The service answered with an error (HTTP 500).',
    );

    expect(failure, isA<ServerFailure>());
    expect(failure.message, contains('HTTP 500'));
  });

  test('only real connectivity problems say network', () {
    expect(map('unavailable'), isA<NetworkFailure>());
    expect(map('deadline-exceeded'), isA<NetworkFailure>());
    expect(map('internal'), isNot(isA<NetworkFailure>()));
    expect(map('not-configured'), isNot(isA<NetworkFailure>()));
  });

  test("the server's own refusals still show its words", () {
    expect(
      map('failed-precondition', 'Transfer ownership first.').message,
      'Transfer ownership first.',
    );
    expect(
      map('permission-denied', 'Only admins can do this.').message,
      'Only admins can do this.',
    );
    expect(map('not-found', 'Nothing there.').message, 'Nothing there.');
  });

  test('an unknown code is a generic server failure', () {
    expect(map('something-new'), isA<ServerFailure>());
  });
}

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/core/platform/http_callable_client.dart';
import 'package:habit_tracker/core/platform/platform_services.dart';

class FakeTransport implements HttpTransport {
  Uri? url;
  Map<String, String>? headers;
  String? body;
  ({int status, String body}) response = (status: 200, body: '{"result":{}}');
  Object? error;

  @override
  Future<({int status, String body})> post(
    Uri url, {
    required Map<String, String> headers,
    required String body,
  }) async {
    this.url = url;
    this.headers = headers;
    this.body = body;
    final failure = error;
    if (failure != null) throw failure;
    return response;
  }
}

void main() {
  late FakeTransport transport;
  String? token;

  HttpCallableClient build({String baseUrl = 'https://habitry.example'}) =>
      HttpCallableClient(
        baseUrl: baseUrl,
        idToken: () async => token,
        transport: transport,
      );

  setUp(() {
    transport = FakeTransport();
    token = 'abc.def.ghi';
  });

  test('posts the name and data to /api/call with the bearer token', () async {
    transport.response = (status: 200, body: '{"result":{"groupId":"g1"}}');

    final result = await build().call('createGroup', {'name': 'Runners'});

    expect(result, {'groupId': 'g1'});
    expect(transport.url.toString(), 'https://habitry.example/api/call');
    expect(transport.headers!['authorization'], 'Bearer abc.def.ghi');
    expect(transport.headers!['content-type'], 'application/json');
    expect(jsonDecode(transport.body!), {
      'name': 'createGroup',
      'data': {'name': 'Runners'},
    });
  });

  test('a trailing slash on the base address is fine', () async {
    await build(baseUrl: 'https://habitry.example/').call('ping');

    expect(transport.url.toString(), 'https://habitry.example/api/call');
  });

  test('the user id is never sent in the body', () async {
    await build().call('leaveGroup', {'groupId': 'g1'});

    final sent = jsonDecode(transport.body!) as Map<String, dynamic>;
    expect(sent.keys, unorderedEquals(['name', 'data']));
  });

  test('an empty result becomes an empty map', () async {
    transport.response = (status: 200, body: '{"result":{}}');
    expect(await build().call('ping'), isEmpty);

    transport.response = (status: 200, body: '{"result":null}');
    expect(await build().call('ping'), isEmpty);
  });

  test(
    'an error body becomes a CallableException with its code and message',
    () async {
      transport.response = (
        status: 409,
        body:
            '{"error":{"code":"failed-precondition","message":"This invitation has expired."}}',
      );

      await expectLater(
        build().call('respondToInvitation'),
        throwsA(
          isA<CallableException>()
              .having((e) => e.code, 'code', 'failed-precondition')
              .having(
                (e) => e.message,
                'message',
                'This invitation has expired.',
              ),
        ),
      );
    },
  );

  test('error details are kept', () async {
    transport.response = (
      status: 409,
      body:
          '{"error":{"code":"failed-precondition","message":"x","details":{"blockers":["g1"]}}}',
    );

    await expectLater(
      build().call('deleteAccount'),
      throwsA(
        isA<CallableException>().having((e) => e.details, 'details', {
          'blockers': ['g1'],
        }),
      ),
    );
  });

  test('signed-out users never reach the network', () async {
    token = null;

    await expectLater(
      build().call('ping'),
      throwsA(
        isA<CallableException>().having(
          (e) => e.code,
          'code',
          'unauthenticated',
        ),
      ),
    );
    expect(transport.url, isNull);
  });

  test(
    'a missing base address is a setup problem, not a network problem',
    () async {
      await expectLater(
        build(baseUrl: '').call('ping'),
        throwsA(
          isA<CallableException>()
              .having((e) => e.code, 'code', 'not-configured')
              .having((e) => e.message, 'message', contains('API_BASE_URL')),
        ),
      );
      expect(transport.url, isNull);
    },
  );

  test('a blank base address counts as missing', () async {
    await expectLater(
      build(baseUrl: '   ').call('ping'),
      throwsA(
        isA<CallableException>().having(
          (e) => e.code,
          'code',
          'not-configured',
        ),
      ),
    );
  });

  group('network problems', () {
    final cases = <String, (Object, String)>{
      'socket error': (const SocketException('down'), 'unavailable'),
      'http error': (const HttpException('reset'), 'unavailable'),
      'timeout': (TimeoutException('slow'), 'deadline-exceeded'),
    };
    cases.forEach((label, c) {
      test('$label becomes ${c.$2}', () async {
        transport.error = c.$1;

        await expectLater(
          build().call('ping'),
          throwsA(isA<CallableException>().having((e) => e.code, 'code', c.$2)),
        );
      });
    });
  });

  group('unexpected answers', () {
    Future<void> expectError(
      int status,
      String body,
      String code, {
      String? messageHas,
    }) async {
      transport.response = (status: status, body: body);
      await expectLater(
        build().call('ping'),
        throwsA(
          isA<CallableException>()
              .having((e) => e.code, 'code', code)
              .having(
                (e) => e.message,
                'message',
                messageHas == null ? isNotEmpty : contains(messageHas),
              ),
        ),
      );
    }

    test(
      'a gateway problem (502, 503, 504) means not reachable right now',
      () async {
        for (final status in [502, 503, 504]) {
          await expectError(
            status,
            '<html>Bad gateway</html>',
            'unavailable',
            messageHas: 'could not be reached',
          );
        }
      },
    );

    test(
      'a crashed function (500 page) is a service fault, not a network one',
      () async {
        await expectError(
          500,
          'A server error occurred FUNCTION_INVOCATION_FAILED',
          'internal',
          messageHas: 'HTTP 500',
        );
      },
    );

    test(
      'a wrong address (404 page) shows the status so it can be spotted',
      () async {
        await expectError(
          404,
          '<html>The page could not be found</html>',
          'internal',
          messageHas: 'HTTP 404',
        );
      },
    );

    test('a JSON array is not a valid answer', () async {
      await expectError(200, '[1,2]', 'internal');
    });

    test('a 500 with an empty JSON body is a service fault', () async {
      await expectError(500, '{}', 'internal', messageHas: 'HTTP 500');
    });

    test('an error body with a code keeps that code even on a 5xx', () async {
      await expectError(
        500,
        '{"error":{"code":"resource-exhausted","message":"Too many attempts."}}',
        'resource-exhausted',
        messageHas: 'Too many',
      );
    });
  });
}

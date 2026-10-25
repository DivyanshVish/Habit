import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:habit_tracker/core/platform/platform_services.dart';

/// Sends one HTTP request. Replaced by a fake in tests.
abstract interface class HttpTransport {
  Future<({int status, String body})> post(
    Uri url, {
    required Map<String, String> headers,
    required String body,
  });
}

/// [HttpTransport] backed by `dart:io`.
class IoHttpTransport implements HttpTransport {
  IoHttpTransport({this.timeout = const Duration(seconds: 20)});

  final Duration timeout;

  @override
  Future<({int status, String body})> post(
    Uri url, {
    required Map<String, String> headers,
    required String body,
  }) async {
    final client = HttpClient()..connectionTimeout = timeout;
    try {
      final request = await client.postUrl(url).timeout(timeout);
      headers.forEach(request.headers.set);
      request.add(utf8.encode(body));
      final response = await request.close().timeout(timeout);
      final text = await response
          .transform(utf8.decoder)
          .join()
          .timeout(timeout);
      return (status: response.statusCode, body: text);
    } finally {
      client.close(force: true);
    }
  }
}

/// Calls the backend API (`POST {baseUrl}/api/call`) with the user's Firebase
/// ID token. The server takes the user id from the token, never from the body.
class HttpCallableClient implements CallableClient {
  HttpCallableClient({
    required this.baseUrl,
    required this.idToken,
    HttpTransport? transport,
  }) : _transport = transport ?? IoHttpTransport();

  /// For example `https://habitry.vercel.app`. No trailing slash needed.
  final String baseUrl;

  /// Returns a fresh ID token, or null when nobody is signed in.
  final Future<String?> Function() idToken;

  final HttpTransport _transport;

  Uri get _endpoint => Uri.parse(
    '${baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl}/api/call',
  );

  @override
  Future<Map<String, dynamic>> call(
    String name, [
    Map<String, dynamic> data = const {},
  ]) async {
    if (baseUrl.trim().isEmpty) {
      throw const CallableException(
        'unavailable',
        'The online service is not set up for this build.',
      );
    }
    final token = await idToken();
    if (token == null) {
      throw const CallableException('unauthenticated', 'Sign in first.');
    }

    final ({int status, String body}) response;
    try {
      response = await _transport.post(
        _endpoint,
        headers: {
          'content-type': 'application/json',
          'authorization': 'Bearer $token',
        },
        body: jsonEncode({'name': name, 'data': data}),
      );
    } on TimeoutException {
      throw const CallableException(
        'deadline-exceeded',
        'The request timed out.',
      );
    } on SocketException {
      throw const CallableException('unavailable', 'No connection.');
    } on HttpException {
      throw const CallableException('unavailable', 'No connection.');
    }

    final Object? decoded;
    try {
      decoded = jsonDecode(response.body);
    } on FormatException {
      throw CallableException(
        response.status >= 500 ? 'unavailable' : 'internal',
        'The service sent an unexpected answer.',
      );
    }
    if (decoded is! Map) {
      throw const CallableException(
        'internal',
        'The service sent an unexpected answer.',
      );
    }

    final error = decoded['error'];
    if (response.status >= 400 || error != null) {
      if (error is Map) {
        throw CallableException(
          (error['code'] as String?) ?? 'internal',
          (error['message'] as String?) ?? 'Request failed.',
          details: error['details'],
        );
      }
      throw CallableException(
        response.status >= 500 ? 'unavailable' : 'internal',
        'Request failed.',
      );
    }

    final result = decoded['result'];
    return result is Map ? Map<String, dynamic>.from(result) : const {};
  }
}

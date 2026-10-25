import 'package:habit_tracker/core/auth/user_id_provider.dart';
import 'package:habit_tracker/core/platform/platform_services.dart';
import 'package:habit_tracker/core/time/clock.dart';

class FixedClock extends Clock {
  FixedClock(this.current);

  DateTime current;

  @override
  DateTime now() => current;
}

class FakeUserIdProvider implements UserIdProvider {
  FakeUserIdProvider([this.uid = 'test-user']);

  String? uid;

  @override
  String? get currentUserId => uid;

  @override
  Future<String> ensureSignedIn() async => uid!;
}

/// Records callable-function calls and answers from a queue or a handler.
class FakeCallableClient implements CallableClient {
  final List<({String name, Map<String, dynamic> data})> calls = [];

  /// Responses by function name. Missing names answer with `{}`.
  final Map<String, Map<String, dynamic>> responses = {};

  /// When set, every call throws this.
  CallableException? error;

  @override
  Future<Map<String, dynamic>> call(
    String name, [
    Map<String, dynamic> data = const {},
  ]) async {
    calls.add((name: name, data: Map<String, dynamic>.of(data)));
    final failure = error;
    if (failure != null) throw failure;
    return responses[name] ?? const {};
  }
}

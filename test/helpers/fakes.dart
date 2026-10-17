import 'package:habit_tracker/core/auth/user_id_provider.dart';
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

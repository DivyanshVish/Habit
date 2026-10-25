import 'package:fpdart/fpdart.dart';
import 'package:habit_tracker/core/error/failure.dart';
import 'package:habit_tracker/core/usecase/usecase.dart';

/// One saved notification. The server writes these whether or not the push
/// reached the phone, so the inbox is complete even with push turned off.
class InboxItem {
  const InboxItem({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.read,
    required this.createdAt,
    this.data = const {},
  });

  final String id;

  /// For example `invitation.received` or `group.target_reached`.
  final String type;
  final String title;
  final String body;
  final bool read;
  final DateTime? createdAt;

  /// Ids only (never names), so it is safe to show on a lock screen.
  final Map<String, String> data;
}

abstract interface class InboxRepository {
  /// Newest first.
  Stream<Either<Failure, List<InboxItem>>> watch({int limit = 30});

  Stream<Either<Failure, int>> watchUnreadCount();

  Future<Either<Failure, Unit>> markRead(String id);

  Future<Either<Failure, Unit>> markAllRead();
}

class WatchInboxParams {
  const WatchInboxParams({this.limit = 30});

  final int limit;
}

class WatchInbox implements StreamUseCase<List<InboxItem>, WatchInboxParams> {
  WatchInbox(this._repository);

  final InboxRepository _repository;

  @override
  Stream<Either<Failure, List<InboxItem>>> call(WatchInboxParams params) =>
      _repository.watch(limit: params.limit);
}

class WatchUnreadCount implements StreamUseCase<int, NoParams> {
  WatchUnreadCount(this._repository);

  final InboxRepository _repository;

  @override
  Stream<Either<Failure, int>> call(NoParams params) =>
      _repository.watchUnreadCount();
}

class MarkInboxRead implements UseCase<Unit, String> {
  MarkInboxRead(this._repository);

  final InboxRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(String id) => _repository.markRead(id);
}

class MarkAllInboxRead implements UseCase<Unit, NoParams> {
  MarkAllInboxRead(this._repository);

  final InboxRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(NoParams params) =>
      _repository.markAllRead();
}

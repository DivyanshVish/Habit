import 'package:fpdart/fpdart.dart';
import 'package:habit_tracker/core/error/failure.dart';

/// One-shot business operation.
abstract interface class UseCase<Output, Params> {
  Future<Either<Failure, Output>> call(Params params);
}

/// Business operation that emits over time (e.g. live Firestore snapshots).
abstract interface class StreamUseCase<Output, Params> {
  Stream<Either<Failure, Output>> call(Params params);
}

/// Marker for use cases that need no input.
final class NoParams {
  const NoParams();
}

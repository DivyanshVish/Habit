import 'package:freezed_annotation/freezed_annotation.dart';

part 'failure.freezed.dart';

/// Domain-level error. Repositories return `Either<Failure, T>` instead of
/// throwing, so presentation never sees framework exceptions.
@freezed
sealed class Failure with _$Failure {
  const Failure._();

  const factory Failure.server({
    @Default('Something went wrong. Please try again.') String message,
  }) = ServerFailure;

  const factory Failure.network({
    @Default('Network unavailable. Check your connection.') String message,
  }) = NetworkFailure;

  const factory Failure.notFound({
    @Default('That item no longer exists.') String message,
  }) = NotFoundFailure;

  const factory Failure.unauthenticated({
    @Default('You are not signed in.') String message,
  }) = UnauthenticatedFailure;

  const factory Failure.validation({required String message}) =
      ValidationFailure;

  const factory Failure.unknown({
    @Default('An unexpected error occurred.') String message,
  }) = UnknownFailure;
}

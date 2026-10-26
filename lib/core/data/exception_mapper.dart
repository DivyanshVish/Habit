import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:habit_tracker/core/error/exceptions.dart';
import 'package:habit_tracker/core/error/failure.dart';
import 'package:habit_tracker/core/platform/platform_services.dart';

/// Translates framework exceptions into domain [Failure]s. Lives in the data
/// layer so the domain never learns about Firebase.
Failure mapExceptionToFailure(Object error) {
  if (error is Failure) return error;
  if (error is UnauthenticatedException) {
    return const Failure.unauthenticated();
  }
  if (error is NotFoundException) {
    return const Failure.notFound(message: 'This habit no longer exists.');
  }
  if (error is CallableException) {
    return switch (error.code) {
      'unauthenticated' ||
      'permission-denied' => Failure.unauthenticated(message: error.message),
      'not-found' => Failure.notFound(message: error.message),
      // A setup mistake. Saying "network" would send people to check Wi-Fi.
      'not-configured' || 'internal' => Failure.server(message: error.message),
      'unavailable' || 'deadline-exceeded' => const Failure.network(),
      // The server states the rule that was broken in plain words.
      'invalid-argument' ||
      'failed-precondition' ||
      'already-exists' ||
      'resource-exhausted' ||
      'out-of-range' => Failure.validation(message: error.message),
      _ => const Failure.server(),
    };
  }
  if (error is FirebaseAuthException) {
    return switch (error.code) {
      'network-request-failed' => const Failure.network(),
      _ => const Failure.unauthenticated(
        message: 'Could not sign in. Please try again.',
      ),
    };
  }
  if (error is FirebaseException) {
    return switch (error.code) {
      'unavailable' || 'deadline-exceeded' => const Failure.network(),
      'not-found' => const Failure.notFound(),
      'permission-denied' || 'unauthenticated' => const Failure.unauthenticated(
        message: 'You do not have permission to do that.',
      ),
      _ => const Failure.server(),
    };
  }
  if (error is TimeoutException) return const Failure.network();
  if (error is FormatException) {
    return const Failure.server(message: 'Received unexpected data.');
  }
  return const Failure.unknown();
}

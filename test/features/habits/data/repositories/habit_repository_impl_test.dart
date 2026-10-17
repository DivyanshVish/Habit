import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:habit_tracker/core/error/exceptions.dart';
import 'package:habit_tracker/core/error/failure.dart';
import 'package:habit_tracker/features/habits/data/datasources/habit_remote_data_source.dart';
import 'package:habit_tracker/features/habits/data/repositories/habit_repository_impl.dart';
import 'package:habit_tracker/features/habits/domain/entities/new_habit.dart';
import 'package:mocktail/mocktail.dart';

class _MockRemote extends Mock implements HabitRemoteDataSource {}

class _FakeNewHabit extends Fake implements NewHabit {}

void main() {
  late _MockRemote remote;
  late HabitRepositoryImpl repository;
  final habit = NewHabit(
    name: 'Read',
    description: '',
    points: 5,
    createdAt: DateTime(2026, 10, 17),
  );

  setUpAll(() => registerFallbackValue(_FakeNewHabit()));

  setUp(() {
    remote = _MockRemote();
    repository = HabitRepositoryImpl(remote);
  });

  test('returns unit on success', () async {
    when(() => remote.addHabit(any())).thenAnswer((_) async {});

    expect(await repository.addHabit(habit), right<Failure, Unit>(unit));
  });

  final mappings = <String, (Exception, Failure)>{
    'unavailable -> network': (
      FirebaseException(plugin: 'cloud_firestore', code: 'unavailable'),
      const Failure.network(),
    ),
    'not-found -> notFound': (
      FirebaseException(plugin: 'cloud_firestore', code: 'not-found'),
      const Failure.notFound(),
    ),
    'permission-denied -> unauthenticated': (
      FirebaseException(plugin: 'cloud_firestore', code: 'permission-denied'),
      const Failure.unauthenticated(
        message: 'You do not have permission to do that.',
      ),
    ),
    'other firebase code -> server': (
      FirebaseException(plugin: 'cloud_firestore', code: 'aborted'),
      const Failure.server(),
    ),
    'no user -> unauthenticated': (
      const UnauthenticatedException(),
      const Failure.unauthenticated(),
    ),
    'malformed data -> server': (
      const FormatException('bad'),
      const Failure.server(message: 'Received unexpected data.'),
    ),
  };

  mappings.forEach((label, pair) {
    test('maps $label', () async {
      when(() => remote.addHabit(any())).thenThrow(pair.$1);

      expect(await repository.addHabit(habit), left<Failure, Unit>(pair.$2));
    });
  });
}

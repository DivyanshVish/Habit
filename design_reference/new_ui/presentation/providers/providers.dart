import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/habit_remote_datasource.dart';
import '../../data/repositories/habit_repository_impl.dart';
import '../../domain/entities/habit.dart';
import '../../domain/repositories/habit_repository.dart';
import '../../domain/usecases/habit_usecases.dart';

/// Anonymous sign-in keeps the assignment login-free while still giving each
/// device its own `users/{uid}` partition (see firestore.rules).
final uidProvider = FutureProvider<String>((ref) async {
  final auth = FirebaseAuth.instance;
  final user = auth.currentUser ?? (await auth.signInAnonymously()).user!;
  return user.uid;
});

final habitRepositoryProvider = Provider<HabitRepository>((ref) {
  final uid = ref.watch(uidProvider).requireValue;
  return HabitRepositoryImpl(
    HabitRemoteDataSource(FirebaseFirestore.instance, uid),
  );
});

final watchHabitsProvider = Provider(
  (ref) => WatchHabits(ref.watch(habitRepositoryProvider)),
);
final addHabitProvider = Provider(
  (ref) => AddHabit(ref.watch(habitRepositoryProvider)),
);
final setCompletionProvider = Provider(
  (ref) => SetHabitCompletion(ref.watch(habitRepositoryProvider)),
);
final deleteHabitProvider = Provider(
  (ref) => DeleteHabit(ref.watch(habitRepositoryProvider)),
);

final habitsProvider = StreamProvider<List<Habit>>((ref) async* {
  await ref.watch(uidProvider.future);
  yield* ref.watch(watchHabitsProvider)();
});

/// Detail page watches one habit, so toggling there updates live.
final habitProvider = Provider.family<Habit?, String>((ref, id) {
  final list = ref.watch(habitsProvider).valueOrNull ?? const <Habit>[];
  for (final h in list) {
    if (h.id == id) return h;
  }
  return null;
});

final progressProvider = Provider<DailyProgress>(
  (ref) =>
      DailyProgress.from(ref.watch(habitsProvider).valueOrNull ?? const []),
);

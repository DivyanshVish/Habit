import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:habit_tracker/core/auth/firebase_user_id_provider.dart';
import 'package:habit_tracker/core/auth/user_id_provider.dart';
import 'package:habit_tracker/core/time/clock.dart';
import 'package:habit_tracker/features/habits/data/datasources/habit_remote_data_source.dart';
import 'package:habit_tracker/features/habits/data/repositories/habit_repository_impl.dart';
import 'package:habit_tracker/features/habits/domain/repositories/habit_repository.dart';
import 'package:habit_tracker/features/habits/domain/usecases/add_habit.dart';
import 'package:habit_tracker/features/habits/domain/services/streak_calculator.dart';
import 'package:habit_tracker/features/habits/domain/usecases/delete_habit.dart';
import 'package:habit_tracker/features/habits/domain/usecases/toggle_habit_completion.dart';
import 'package:habit_tracker/features/habits/domain/usecases/watch_habit_detail.dart';
import 'package:habit_tracker/features/habits/domain/usecases/watch_today_overview.dart';
import 'package:habit_tracker/features/habits/presentation/bloc/add_habit/add_habit_bloc.dart';
import 'package:habit_tracker/features/habits/presentation/bloc/habit_detail/habit_detail_bloc.dart';
import 'package:habit_tracker/features/habits/presentation/bloc/today/today_bloc.dart';

final GetIt getIt = GetIt.instance;

/// Composition root. Safe to call more than once (e.g. on bootstrap retry).
void configureDependencies() {
  if (getIt.isRegistered<UserIdProvider>()) return;

  // External
  getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  getIt.registerLazySingleton<FirebaseFirestore>(
    () => FirebaseFirestore.instance,
  );

  // Core
  getIt.registerLazySingleton<Clock>(SystemClock.new);
  getIt.registerLazySingleton<UserIdProvider>(
    () => FirebaseUserIdProvider(getIt<FirebaseAuth>()),
  );

  // Data
  getIt.registerLazySingleton<HabitRemoteDataSource>(
    () => HabitRemoteDataSourceImpl(
      firestore: getIt<FirebaseFirestore>(),
      userIdProvider: getIt<UserIdProvider>(),
    ),
  );
  getIt.registerLazySingleton<HabitRepository>(
    () => HabitRepositoryImpl(getIt<HabitRemoteDataSource>()),
  );

  // Domain
  getIt.registerLazySingleton<AddHabit>(
    () => AddHabit(getIt<HabitRepository>(), getIt<Clock>()),
  );

  getIt.registerLazySingleton<WatchTodayOverview>(
    () => WatchTodayOverview(
      getIt<HabitRepository>(),
      getIt<Clock>(),
      getIt<StreakCalculator>(),
    ),
  );
  getIt.registerLazySingleton<ToggleHabitCompletion>(
    () => ToggleHabitCompletion(getIt<HabitRepository>()),
  );
  getIt.registerLazySingleton<DeleteHabit>(
    () => DeleteHabit(getIt<HabitRepository>()),
  );
  getIt.registerLazySingleton<StreakCalculator>(() => const StreakCalculator());
  getIt.registerLazySingleton<WatchHabitDetail>(
    () => WatchHabitDetail(
      getIt<HabitRepository>(),
      getIt<Clock>(),
      getIt<StreakCalculator>(),
    ),
  );

  // Presentation
  getIt.registerFactory<AddHabitBloc>(() => AddHabitBloc(getIt<AddHabit>()));
  getIt.registerFactoryParam<HabitDetailBloc, String, void>(
    (habitId, _) => HabitDetailBloc(
      habitId: habitId,
      watchHabitDetail: getIt<WatchHabitDetail>(),
      toggleHabitCompletion: getIt<ToggleHabitCompletion>(),
      clock: getIt<Clock>(),
    ),
  );
  getIt.registerFactory<TodayBloc>(
    () => TodayBloc(
      watchTodayOverview: getIt<WatchTodayOverview>(),
      toggleHabitCompletion: getIt<ToggleHabitCompletion>(),
      deleteHabit: getIt<DeleteHabit>(),
      clock: getIt<Clock>(),
    ),
  );
}

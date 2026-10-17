import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:habit_tracker/core/di/injection.dart';
import 'package:habit_tracker/core/router/app_routes.dart';
import 'package:habit_tracker/core/router/app_transitions.dart';
import 'package:habit_tracker/features/habits/presentation/bloc/add_habit/add_habit_bloc.dart';
import 'package:habit_tracker/features/habits/presentation/bloc/habit_detail/habit_detail_bloc.dart';
import 'package:habit_tracker/features/habits/presentation/bloc/today/today_bloc.dart';
import 'package:habit_tracker/features/habits/presentation/pages/add_habit_page.dart';
import 'package:habit_tracker/features/habits/presentation/pages/habit_detail_page.dart';
import 'package:habit_tracker/features/habits/presentation/pages/today_page.dart';

GoRouter createRouter() {
  return GoRouter(
    initialLocation: AppRoutes.today,
    routes: [
      GoRoute(
        path: AppRoutes.today,
        pageBuilder: (context, state) => buildAppPage(
          state: state,
          child: BlocProvider(
            create: (_) => getIt<TodayBloc>()..add(const TodayEvent.started()),
            child: const TodayPage(),
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.addHabit,
        pageBuilder: (context, state) => buildAppPage(
          state: state,
          kind: AppTransitionKind.riseUp,
          child: BlocProvider(
            create: (_) => getIt<AddHabitBloc>(),
            child: const AddHabitPage(),
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.habitDetailPattern,
        pageBuilder: (context, state) => buildAppPage(
          state: state,
          child: BlocProvider(
            create: (_) =>
                getIt<HabitDetailBloc>(param1: state.pathParameters['id']!)
                  ..add(const HabitDetailEvent.started()),
            child: const HabitDetailPage(),
          ),
        ),
      ),
    ],
  );
}

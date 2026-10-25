import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:habit_tracker/core/di/injection.dart';
import 'package:habit_tracker/core/router/app_routes.dart';
import 'package:habit_tracker/core/router/app_shell.dart';
import 'package:habit_tracker/core/router/app_transitions.dart';
import 'package:habit_tracker/features/account/presentation/profile_page.dart';
import 'package:habit_tracker/features/groups/presentation/pages/group_activity_page.dart';
import 'package:habit_tracker/features/groups/presentation/pages/group_habit_edit_page.dart';
import 'package:habit_tracker/features/groups/presentation/pages/group_settings_page.dart';
import 'package:habit_tracker/features/groups/presentation/pages/groups_pages.dart';
import 'package:habit_tracker/features/habits/presentation/bloc/add_habit/add_habit_bloc.dart';
import 'package:habit_tracker/features/habits/presentation/bloc/habit_detail/habit_detail_bloc.dart';
import 'package:habit_tracker/features/habits/presentation/bloc/today/today_bloc.dart';
import 'package:habit_tracker/features/habits/presentation/pages/add_habit_page.dart';
import 'package:habit_tracker/features/habits/presentation/pages/habit_detail_page.dart';
import 'package:habit_tracker/features/habits/presentation/pages/today_page.dart';
import 'package:habit_tracker/features/invitations/presentation/join_page.dart';
import 'package:habit_tracker/features/notifications/presentation/inbox_page.dart';
import 'package:habit_tracker/features/shared_habits/presentation/pages/shared_habits_pages.dart';

/// Moving between the five bar tabs should feel like switching tabs, not like
/// opening a new screen: no slide, no fade.
Page<void> _tab(GoRouterState state, Widget child) =>
    NoTransitionPage<void>(key: state.pageKey, child: child);

GoRouter createRouter() {
  return GoRouter(
    initialLocation: AppRoutes.today,
    routes: [
      // The five tabs. The bottom bar stays while moving between them.
      ShellRoute(
        builder: (context, state, child) =>
            AppShell(location: state.uri.path, child: child),
        routes: [
          GoRoute(
            path: AppRoutes.today,
            pageBuilder: (context, state) => _tab(
              state,
              BlocProvider(
                create: (_) =>
                    getIt<TodayBloc>()..add(const TodayEvent.started()),
                child: const TodayPage(),
              ),
            ),
          ),
          GoRoute(
            path: AppRoutes.shared,
            pageBuilder: (context, state) =>
                _tab(state, const SharedHabitsPage()),
          ),
          GoRoute(
            path: AppRoutes.groups,
            pageBuilder: (context, state) => _tab(state, const GroupsPage()),
          ),
          GoRoute(
            path: AppRoutes.inbox,
            pageBuilder: (context, state) => _tab(state, const InboxPage()),
          ),
          GoRoute(
            path: AppRoutes.profile,
            pageBuilder: (context, state) => _tab(state, const ProfilePage()),
          ),
        ],
      ),

      // Everything below opens over the bar.
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

      // Shared habits. 'new' is declared before ':id' so it is not read as one.
      GoRoute(
        path: AppRoutes.sharedNew,
        pageBuilder: (context, state) => buildAppPage(
          state: state,
          kind: AppTransitionKind.riseUp,
          child: SharedHabitFormPage(
            sourceHabitId: state.uri.queryParameters['from'],
            initialName: state.uri.queryParameters['name'],
            initialPoints: int.tryParse(
              state.uri.queryParameters['points'] ?? '',
            ),
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.sharedDetailPattern,
        pageBuilder: (context, state) => buildAppPage(
          state: state,
          child: SharedHabitDetailPage(sharedId: state.pathParameters['id']!),
        ),
      ),

      // Groups. More specific paths first.
      GoRoute(
        path: AppRoutes.groupNew,
        pageBuilder: (context, state) => buildAppPage(
          state: state,
          kind: AppTransitionKind.riseUp,
          child: const CreateGroupPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.join,
        pageBuilder: (context, state) => buildAppPage(
          state: state,
          kind: AppTransitionKind.riseUp,
          child: const JoinPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.groupHabitNewPattern,
        pageBuilder: (context, state) => buildAppPage(
          state: state,
          kind: AppTransitionKind.riseUp,
          child: GroupHabitFormPage(groupId: state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: AppRoutes.groupHabitEditPattern,
        pageBuilder: (context, state) => buildAppPage(
          state: state,
          kind: AppTransitionKind.riseUp,
          child: GroupHabitEditPage(
            groupId: state.pathParameters['gid']!,
            habitId: state.pathParameters['hid']!,
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.groupHabitPattern,
        pageBuilder: (context, state) => buildAppPage(
          state: state,
          child: GroupHabitPage(
            groupId: state.pathParameters['gid']!,
            habitId: state.pathParameters['hid']!,
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.groupSettingsPattern,
        pageBuilder: (context, state) => buildAppPage(
          state: state,
          kind: AppTransitionKind.riseUp,
          child: GroupSettingsPage(groupId: state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: AppRoutes.groupActivityPattern,
        pageBuilder: (context, state) => buildAppPage(
          state: state,
          child: GroupActivityPage(groupId: state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: AppRoutes.groupDetailPattern,
        pageBuilder: (context, state) => buildAppPage(
          state: state,
          child: GroupDetailPage(groupId: state.pathParameters['id']!),
        ),
      ),
    ],
  );
}

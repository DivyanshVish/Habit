import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go_router/go_router.dart';
import 'package:habit_tracker/core/di/injection.dart';
import 'package:habit_tracker/core/error/failure.dart';
import 'package:habit_tracker/core/presentation/view_state.dart';
import 'package:habit_tracker/core/router/app_routes.dart';
import 'package:habit_tracker/core/theme/app_tokens.dart';
import 'package:habit_tracker/core/usecase/usecase.dart';
import 'package:habit_tracker/features/notifications/domain/notifications_domain.dart';

/// The five places the app is built around. The bar stays while the person
/// moves between them; anything opened from one of them (a group, a habit, a
/// form) covers the bar.
enum AppTab {
  home('Home', AppRoutes.today, Icons.today_outlined, Icons.today),
  shared('Shared', AppRoutes.shared, Icons.people_outline, Icons.people),
  groups('Groups', AppRoutes.groups, Icons.groups_outlined, Icons.groups),
  inbox(
    'Inbox',
    AppRoutes.inbox,
    Icons.notifications_none,
    Icons.notifications,
  ),
  profile('Profile', AppRoutes.profile, Icons.person_outline, Icons.person);

  const AppTab(this.label, this.route, this.icon, this.selectedIcon);

  final String label;
  final String route;
  final IconData icon;
  final IconData selectedIcon;

  /// The tab a location belongs to, or null for a page outside the bar.
  static AppTab? forLocation(String location) {
    for (final tab in AppTab.values) {
      if (tab == AppTab.home) continue;
      if (location == tab.route || location.startsWith('${tab.route}/')) {
        return tab;
      }
    }
    return location == AppRoutes.today ? AppTab.home : null;
  }
}

/// Wraps the five top level pages with a bottom navigation bar.
class AppShell extends StatelessWidget {
  const AppShell({required this.location, required this.child, super.key});

  final String location;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final current = AppTab.forLocation(location) ?? AppTab.home;
    final hasInbox = getIt.isRegistered<WatchUnreadCount>();
    return BlocProvider<WatchCubit<int>>(
      // The unread badge is a convenience: without the inbox registered (a
      // test, for example) the bar simply shows no badge.
      create: (_) => WatchCubit<int>(
        () => hasInbox
            ? getIt<WatchUnreadCount>()(const NoParams())
            : Stream<Either<Failure, int>>.value(right(0)),
      )..start(),
      child: Scaffold(
        body: child,
        bottomNavigationBar: _Bar(current: current),
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.current});

  final AppTab current;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final unread = switch (context.watch<WatchCubit<int>>().state) {
      ViewLoaded<int>(:final data) => data,
      _ => 0,
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: tokens.hairline)),
      ),
      child: NavigationBar(
        height: 64,
        backgroundColor: tokens.paper,
        surfaceTintColor: Colors.transparent,
        indicatorColor: tokens.accentTint,
        elevation: 0,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        selectedIndex: AppTab.values.indexOf(current),
        onDestinationSelected: (index) {
          final tab = AppTab.values[index];
          if (tab != current) context.go(tab.route);
        },
        destinations: [
          for (final tab in AppTab.values)
            NavigationDestination(
              key: ValueKey('tab-${tab.name}'),
              label: tab.label,
              tooltip: tab == AppTab.inbox && unread > 0
                  ? 'Inbox, $unread unread'
                  : tab.label,
              icon: _icon(tab, tab.icon, unread),
              selectedIcon: _icon(tab, tab.selectedIcon, unread),
            ),
        ],
      ),
    );
  }

  Widget _icon(AppTab tab, IconData icon, int unread) {
    if (tab != AppTab.inbox || unread == 0) return Icon(icon);
    return Badge(
      label: Text(unread > 99 ? '99+' : '$unread'),
      child: Icon(icon),
    );
  }
}

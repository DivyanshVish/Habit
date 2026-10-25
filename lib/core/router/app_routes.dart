class AppRoutes {
  const AppRoutes._();

  static const String today = '/';
  static const String addHabit = '/habits/new';
  static const String habitDetailPattern = '/habits/:id';

  static String habitDetail(String id) => '/habits/$id';

  // Shared habits
  static const String shared = '/shared';
  static const String sharedNew = '/shared/new';
  static const String sharedDetailPattern = '/shared/:id';
  static String sharedDetail(String id) => '/shared/$id';

  /// Opens the "share" form pre-filled from a personal habit.
  static String sharedNewFrom({
    required String habitId,
    required String name,
    required int points,
  }) => Uri(
    path: sharedNew,
    queryParameters: {'from': habitId, 'name': name, 'points': '$points'},
  ).toString();

  // Groups
  static const String groups = '/groups';
  static const String groupNew = '/groups/new';
  static const String join = '/join';
  static const String groupDetailPattern = '/groups/:id';
  static String groupDetail(String id) => '/groups/$id';
  static const String groupHabitNewPattern = '/groups/:id/habits/new';
  static String groupHabitNew(String groupId) => '/groups/$groupId/habits/new';
  static const String groupHabitPattern = '/groups/:gid/habits/:hid';
  static String groupHabit(String groupId, String habitId) =>
      '/groups/$groupId/habits/$habitId';

  // Account
  static const String profile = '/profile';

  // Inbox
  static const String inbox = '/inbox';

  // Groups: more screens
  static const String groupSettingsPattern = '/groups/:id/settings';
  static String groupSettings(String id) => '/groups/$id/settings';
  static const String groupActivityPattern = '/groups/:id/activity';
  static String groupActivity(String id) => '/groups/$id/activity';
  static const String groupHabitEditPattern = '/groups/:gid/habits/:hid/edit';
  static String groupHabitEdit(String groupId, String habitId) =>
      '/groups/$groupId/habits/$habitId/edit';
}

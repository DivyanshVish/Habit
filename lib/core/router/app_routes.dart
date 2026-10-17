class AppRoutes {
  const AppRoutes._();

  static const String today = '/';
  static const String addHabit = '/habits/new';
  static const String habitDetailPattern = '/habits/:id';

  static String habitDetail(String id) => '/habits/$id';
}

/// 路由路径常量
class RoutePaths {
  RoutePaths._();

  static const String initial = '/';
  static const String home = '/home';
  static const String popular = '/popular';
  static const String live = '/live';
  static const String bangumi = '/bangumi';
  static const String search = '/search';
  static const String user = '/user';
  static const String settings = '/settings';
  static const String player = '/player/:bvid';

  static String playerWithBvid(String bvid) => '/player/$bvid';
}


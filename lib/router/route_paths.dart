/// 路由路径常量
class RoutePaths {
  RoutePaths._();

  static const String initial = '/';
  static const String home = '/home';
  static const String popular = '/popular';
  static const String live = '/live';
  static const String channel = '/channel';
  static const String partition = '/partition';
  static const String bangumi = '/bangumi';
  static const String search = '/search';
  static const String user = '/user';
  static const String settings = '/settings';
  static const String player = '/player/:bvid';
  static const String bangumiPlayer = '/bangumi/player/:seasonId';
  static const String livePlayer = '/live/player/:roomId';

  static String playerWithBvid(String bvid) => '/player/$bvid';
  static String bangumiPlayerWithSeasonId(int seasonId) =>
      '/bangumi/player/$seasonId';
  static String livePlayerWithRoomId(int roomId) => '/live/player/$roomId';
}


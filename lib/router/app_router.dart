import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/bangumi/presentation/screens/tv_bangumi_screen.dart';
import '../features/home/presentation/screens/tv_home_screen.dart';
import '../features/live/data/models/live_room_item_model.dart';
import '../features/live/presentation/screens/tv_live_player_screen.dart';
import '../features/live/presentation/screens/tv_live_screen.dart';
import '../features/main/presentation/screens/tv_main_shell.dart';
import '../features/player/presentation/screens/tv_player_screen.dart';
import '../features/popular/presentation/screens/tv_popular_screen.dart';
import '../features/search/presentation/screens/tv_search_screen.dart';
import '../features/settings/presentation/screens/tv_settings_screen.dart';
import '../features/user/presentation/screens/tv_user_screen.dart';
import 'route_paths.dart';

final GlobalKey<NavigatorState> rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'shell');

/// 全局路由配置 Provider
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: RoutePaths.home,
    routes: [
      // 顶级重定向
      GoRoute(
        path: RoutePaths.initial,
        redirect: (context, state) => RoutePaths.home,
      ),

      // 带有 TV 侧边栏的页面集合 (ShellRoute)
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return TvMainShell(
            state: state,
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: RoutePaths.home,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: TvHomeScreen(),
            ),
          ),
          GoRoute(
            path: RoutePaths.popular,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: TvPopularScreen(),
            ),
          ),
          GoRoute(
            path: RoutePaths.live,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: TvLiveScreen(),
            ),
          ),
          GoRoute(
            path: RoutePaths.bangumi,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: TvBangumiScreen(),
            ),
          ),
          GoRoute(
            path: RoutePaths.search,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: TvSearchScreen(),
            ),
          ),
          GoRoute(
            path: RoutePaths.user,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: TvUserScreen(),
            ),
          ),
          GoRoute(
            path: RoutePaths.settings,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: TvSettingsScreen(),
            ),
          ),
        ],
      ),

      // 全屏播放器独立路由（脱离侧边栏）
      GoRoute(
        path: RoutePaths.player,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final bvid = state.pathParameters['bvid'] ?? '';
          return TvPlayerScreen(bvid: bvid);
        },
      ),

      // 全屏直播播放器独立路由（脱离侧边栏）
      GoRoute(
        path: RoutePaths.livePlayer,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final roomIdStr = state.pathParameters['roomId'] ?? '0';
          final roomId = int.tryParse(roomIdStr) ?? 0;
          final room = state.extra as LiveRoomItemModel?;
          return TvLivePlayerScreen(roomId: roomId, room: room);
        },
      ),
    ],
  );
});


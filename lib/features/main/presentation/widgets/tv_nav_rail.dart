import 'package:flutter/material.dart';
import 'package:dpad/dpad.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/tv_theme.dart';
import '../../../../router/route_paths.dart';

class NavRailItem {
  final String title;
  final IconData icon;
  final String path;

  const NavRailItem({
    required this.title,
    required this.icon,
    required this.path,
  });
}

/// TV 左侧导航导轨
class TvNavRail extends StatelessWidget {
  final String currentPath;

  const TvNavRail({
    super.key,
    required this.currentPath,
  });

  static const List<NavRailItem> items = [
    NavRailItem(
      title: '推荐',
      icon: Icons.recommend_rounded,
      path: RoutePaths.home,
    ),
    NavRailItem(
      title: '热门',
      icon: Icons.local_fire_department_rounded,
      path: RoutePaths.popular,
    ),
    NavRailItem(
      title: '直播',
      icon: Icons.sensors_rounded,
      path: RoutePaths.live,
    ),
    NavRailItem(
      title: '追番',
      icon: Icons.movie_filter_rounded,
      path: RoutePaths.bangumi,
    ),
    NavRailItem(
      title: '搜索',
      icon: Icons.search_rounded,
      path: RoutePaths.search,
    ),
    NavRailItem(
      title: '我的',
      icon: Icons.account_circle_rounded,
      path: RoutePaths.user,
    ),
    NavRailItem(
      title: '设置',
      icon: Icons.settings_rounded,
      path: RoutePaths.settings,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      color: TvTheme.tvSurface,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // App 品牌 Logo
          Padding(
            padding: const EdgeInsets.only(left: 10, bottom: 28),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: TvTheme.biliPink,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.tv_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Bili TV',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 导航选项列表
          Expanded(
            child: ListView.separated(
              itemCount: items.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = items[index];
                final isSelected = currentPath.startsWith(item.path);

                return DpadFocusable(
                  onSelect: () {
                    if (!isSelected) {
                      context.go(item.path);
                    }
                  },
                  child: Container(
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? TvTheme.biliPink.withValues(alpha: 0.22)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          item.icon,
                          color: isSelected
                              ? TvTheme.biliPink
                              : TvTheme.tvTextSecondary,
                          size: 22,
                        ),
                        const SizedBox(width: 14),
                        Text(
                          item.title,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : TvTheme.tvTextSecondary,
                            fontSize: 16,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

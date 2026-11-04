import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dpad/dpad.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/tv_theme.dart';
import '../../../../router/route_paths.dart';
import '../../../../widgets/tv_image.dart';
import '../../../user/presentation/providers/auth_provider.dart';
import '../providers/nav_rail_focus_provider.dart';

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
class TvNavRail extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final size = MediaQuery.of(context).size;
    final bool isCompact = size.width <= 1000 || size.height <= 650;
    final double railWidth = isCompact ? 168.0 : 196.0;

    return Container(
      width: railWidth,
      color: TvTheme.tvSurface,
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 10 : 14,
        vertical: isCompact ? 16 : 22,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // App 品牌 Logo
          Padding(
            padding: EdgeInsets.only(
              left: 6,
              bottom: isCompact ? 18 : 26,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: TvTheme.biliPink,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.tv_rounded,
                    color: Colors.white,
                    size: isCompact ? 19 : 22,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Bili TV',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isCompact ? 17 : 19,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 导航选项列表 (采用 DpadRegion 进行大屏区域管理与焦点记忆)
          Expanded(
            child: DpadRegion(
              enter: DpadEnterBehavior.restore,
              horizontalEdge: DpadEdgeBehavior.leave,
              child: ListView.separated(
                itemCount: items.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final item = items[index];
                  final isSelected = currentPath.startsWith(item.path);
                  final isUserTab = item.path == RoutePaths.user;
                  final isLoggedIn =
                      authState.isLoggedIn && authState.user != null;

                  final displayTitle = (isUserTab && isLoggedIn)
                      ? authState.user!.uname
                      : item.title;

                  return _TvNavRailTile(
                    item: item,
                    isSelected: isSelected,
                    displayTitle: displayTitle,
                    isUserTab: isUserTab,
                    isLoggedIn: isLoggedIn,
                    avatarUrl: isLoggedIn ? authState.user!.face : '',
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TvNavRailTile extends ConsumerStatefulWidget {
  final NavRailItem item;
  final bool isSelected;
  final String displayTitle;
  final bool isUserTab;
  final bool isLoggedIn;
  final String avatarUrl;

  const _TvNavRailTile({
    required this.item,
    required this.isSelected,
    required this.displayTitle,
    required this.isUserTab,
    required this.isLoggedIn,
    required this.avatarUrl,
  });

  @override
  ConsumerState<_TvNavRailTile> createState() => _TvNavRailTileState();
}

class _TvNavRailTileState extends ConsumerState<_TvNavRailTile> {
  FocusNode? _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode(debugLabel: 'NavRail_${widget.item.title}');
    if (widget.isSelected) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(navRailFocusServiceProvider).registerSelectedNode(_focusNode);
      });
    }
  }

  @override
  void didUpdateWidget(covariant _TvNavRailTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected && !oldWidget.isSelected) {
      ref.read(navRailFocusServiceProvider).registerSelectedNode(_focusNode);
    }
  }

  @override
  void dispose() {
    _focusNode?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isCompact = size.width <= 1000 || size.height <= 650;

    return DpadFocusable(
      focusNode: _focusNode,
      entry: widget.isSelected,
      onFocusChange: (focused) {
        ref.read(navRailFocusServiceProvider).notifyFocusChange(focused);
      },
      onSelect: () {
        if (!widget.isSelected) {
          context.go(widget.item.path);
        }
      },
      child: Container(
        height: isCompact ? 44 : 48,
        padding: EdgeInsets.symmetric(horizontal: isCompact ? 12 : 14),
        decoration: BoxDecoration(
          color: widget.isSelected
              ? TvTheme.biliPink.withValues(alpha: 0.22)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            if (widget.isUserTab &&
                widget.isLoggedIn &&
                widget.avatarUrl.isNotEmpty)
              ClipOval(
                child: SizedBox(
                  width: isCompact ? 20 : 22,
                  height: isCompact ? 20 : 22,
                  child: TvImage(
                    imageUrl: widget.avatarUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              )
            else
              Icon(
                widget.item.icon,
                color: widget.isSelected
                    ? TvTheme.biliPink
                    : TvTheme.tvTextSecondary,
                size: isCompact ? 19 : 21,
              ),
            SizedBox(width: isCompact ? 10 : 12),
            Expanded(
              child: Text(
                widget.displayTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: widget.isSelected
                      ? Colors.white
                      : TvTheme.tvTextSecondary,
                  fontSize: isCompact ? 13.5 : 15,
                  fontWeight:
                      widget.isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

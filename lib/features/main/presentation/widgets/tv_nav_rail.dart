import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dpad/dpad.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/tv_theme.dart';
import '../../../../router/route_paths.dart';
import '../../../../widgets/glass_container.dart';
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

/// TV 左侧悬浮折叠微光侧边导轨 (Apple TV Liquid Glass 选项 B)
/// 靠左悬浮半透明微光细条，未获焦轻量通透，获焦展开白色微光胶囊
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
    final double railWidth = isCompact ? 148.0 : 168.0;

    return GlassContainer(
      width: railWidth,
      blur: 24.0,
      opacity: 0.16,
      borderOpacity: 0.32,
      borderWidth: 1.0,
      borderRadius: BorderRadius.circular(24),
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 8 : 10,
        vertical: isCompact ? 16 : 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 极简微光 Logo (纯白微光质感，拒绝生硬彩框)
          Padding(
            padding: EdgeInsets.only(
              left: 6,
              bottom: isCompact ? 16 : 22,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.tv_rounded,
                  color: Colors.white,
                  size: isCompact ? 20 : 22,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'Bili TV',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isCompact ? 16 : 18,
                      fontWeight: FontWeight.w700,
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
                separatorBuilder: (context, index) => const SizedBox(height: 6),
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
      builder: (context, state, child) {
        final bool isFocused = state.focused;
        final bool isSelected = widget.isSelected;

        Color bgColor = Colors.transparent;
        Border? border;
        List<BoxShadow>? shadows;

        if (isFocused) {
          // 获焦：浮起半透明纯白微光胶囊 + 柔和白色漫反射阴影
          bgColor = Colors.white.withValues(alpha: 0.24);
          border = Border.all(color: Colors.white, width: 1.5);
          shadows = [
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.32),
              blurRadius: 16,
              spreadRadius: 1,
            ),
          ];
        } else if (isSelected) {
          // 选中但未落焦：淡雅轻白底
          bgColor = Colors.white.withValues(alpha: 0.12);
          border =
              Border.all(color: Colors.white.withValues(alpha: 0.28), width: 0.8);
        } else {
          bgColor = Colors.transparent;
        }

        return Container(
          height: isCompact ? 42 : 46,
          padding: EdgeInsets.symmetric(horizontal: isCompact ? 10 : 12),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(TvTheme.radiusTile),
            border: border,
            boxShadow: shadows,
          ),
          child: child,
        );
      },
      child: Row(
        children: [
          if (widget.isUserTab &&
              widget.isLoggedIn &&
              widget.avatarUrl.isNotEmpty)
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: widget.isSelected ? Colors.white : Colors.white24,
                  width: 1.2,
                ),
              ),
              child: ClipOval(
                child: SizedBox(
                  width: isCompact ? 20 : 22,
                  height: isCompact ? 20 : 22,
                  child: TvImage(
                    imageUrl: widget.avatarUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            )
          else
            Icon(
              widget.item.icon,
              color: widget.isSelected ? Colors.white : const Color(0x9AFFFFFF),
              size: isCompact ? 19 : 21,
            ),
          SizedBox(width: isCompact ? 10 : 12),
          Expanded(
            child: Text(
              widget.displayTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: widget.isSelected ? Colors.white : const Color(0x9AFFFFFF),
                fontSize: isCompact ? 13.5 : 14.5,
                fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

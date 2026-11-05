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
      decoration: const BoxDecoration(
        gradient: TvTheme.navRailGradient,
        border: Border(
          right: BorderSide(color: TvTheme.tvCardBorder, width: 1.0),
        ),
      ),
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
              left: 4,
              bottom: isCompact ? 18 : 26,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    gradient: TvTheme.biliPinkGradient,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: TvTheme.biliPink.withValues(alpha: 0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.tv_rounded,
                    color: Colors.white,
                    size: isCompact ? 18 : 22,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          'Bili TV',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isCompact ? 16 : 19,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 1.5,
                        ),
                        decoration: BoxDecoration(
                          color: TvTheme.biliBlue.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: TvTheme.biliBlue.withValues(alpha: 0.5),
                            width: 0.8,
                          ),
                        ),
                        child: const Text(
                          '4K',
                          style: TextStyle(
                            color: TvTheme.biliBlue,
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
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
      builder: (context, state, child) {
        final bool isFocused = state.focused;
        final bool isSelected = widget.isSelected;

        Color bgColor = Colors.transparent;
        Gradient? bgGradient;
        Border? border;
        List<BoxShadow>? shadows;

        if (isFocused) {
          if (isSelected) {
            bgGradient = TvTheme.biliPinkGradient;
            shadows = [
              BoxShadow(
                color: TvTheme.biliPink.withValues(alpha: 0.45),
                blurRadius: 14,
                spreadRadius: 1,
              ),
            ];
          } else {
            bgColor = Colors.white.withValues(alpha: 0.18);
            border = Border.all(color: Colors.white, width: 1.5);
          }
        } else if (isSelected) {
          bgColor = TvTheme.biliPink.withValues(alpha: 0.16);
          border = Border.all(color: TvTheme.biliPink.withValues(alpha: 0.35), width: 1);
        } else {
          bgColor = Colors.transparent;
        }

        return Container(
          height: isCompact ? 44 : 48,
          padding: EdgeInsets.symmetric(horizontal: isCompact ? 10 : 12),
          decoration: BoxDecoration(
            color: bgGradient == null ? bgColor : null,
            gradient: bgGradient,
            borderRadius: BorderRadius.circular(10),
            border: border,
            boxShadow: shadows,
          ),
          child: child,
        );
      },
      child: Row(
        children: [
          if (widget.isSelected)
            Container(
              width: 3.5,
              height: 18,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: TvTheme.biliPink,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          if (widget.isUserTab &&
              widget.isLoggedIn &&
              widget.avatarUrl.isNotEmpty)
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: widget.isSelected ? TvTheme.biliPink : Colors.white24,
                  width: 1.5,
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
              color: widget.isSelected
                  ? Colors.white
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
                fontWeight: widget.isSelected
                    ? FontWeight.w700
                    : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

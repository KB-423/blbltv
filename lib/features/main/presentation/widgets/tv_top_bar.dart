import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dpad/dpad.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/tv_theme.dart';
import '../../../../router/route_paths.dart';
import '../../../../widgets/tv_image.dart';
import '../../../user/presentation/providers/auth_provider.dart';
import '../providers/nav_rail_focus_provider.dart';

/// TV 顶部第一行导航栏（功能、账号与时间）
class TvTopHeader extends ConsumerStatefulWidget {
  final String currentPath;

  const TvTopHeader({
    super.key,
    required this.currentPath,
  });

  @override
  ConsumerState<TvTopHeader> createState() => _TvTopHeaderState();
}

class _TvTopHeaderState extends ConsumerState<TvTopHeader> {
  late Timer _clockTimer;
  String _currentTime = '';

  @override
  void initState() {
    super.initState();
    _updateClock();
    _clockTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      _updateClock();
    });
  }

  void _updateClock() {
    final now = DateTime.now();
    final h = now.hour.toString().padLeft(2, '0');
    final m = now.minute.toString().padLeft(2, '0');
    final formatted = '$h:$m';
    if (_currentTime != formatted && mounted) {
      setState(() {
        _currentTime = formatted;
      });
    }
  }

  @override
  void dispose() {
    _clockTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final displayMode = ref.watch(topBarDisplayModeProvider);
    final user = authState.user;
    final bool isCompact = displayMode == TopBarDisplayMode.compact;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      padding: EdgeInsets.symmetric(
        horizontal: 48,
        vertical: isCompact ? 8 : 14,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.85),
            Colors.black.withValues(alpha: 0.40),
            Colors.transparent,
          ],
          stops: const [0.0, 0.7, 1.0],
        ),
      ),
      child: DpadRegion(
        horizontalEdge: DpadEdgeBehavior.stop,
        verticalEdge: DpadEdgeBehavior.leave,
        child: Row(
          children: [
            // 1. 搜索
            _TopBarIconButton(
              icon: Icons.search_rounded,
              label: isCompact ? null : '搜索',
              isSelected: widget.currentPath == RoutePaths.search,
              onSelect: () => context.go(RoutePaths.search),
            ),
            const SizedBox(width: 14),

            // 2. 历史 / 收藏
            _TopBarIconButton(
              icon: Icons.history_rounded,
              label: isCompact ? null : '历史/收藏',
              isSelected: false,
              onSelect: () => context.go(RoutePaths.user),
            ),
            const SizedBox(width: 14),

            // 3. 头像 / 账号
            DpadFocusable(
              onSelect: () => context.go(RoutePaths.user),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                padding: EdgeInsets.symmetric(
                  horizontal: isCompact ? 6 : 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.15),
                    width: 1.0,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipOval(
                      child: user != null && user.face.isNotEmpty
                          ? TvImage(
                              imageUrl: user.face,
                              width: 24,
                              height: 24,
                            )
                          : Container(
                              width: 24,
                              height: 24,
                              color: Colors.white24,
                              child: const Icon(
                                Icons.person_rounded,
                                size: 16,
                                color: Colors.white70,
                              ),
                            ),
                    ),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOutCubic,
                      child: !isCompact
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(width: 8),
                                Text(
                                  authState.isLoggedIn && user != null
                                      ? user.uname
                                      : '未登录',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),

            // 4. 会员状态标签胶囊
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              child: !isCompact
                  ? Padding(
                      padding: const EdgeInsets.only(left: 14),
                      child: _buildVipBadge(user, authState.isLoggedIn),
                    )
                  : const SizedBox.shrink(),
            ),

            const Spacer(),

            // 5. 最右侧当前时间
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.access_time_rounded,
                    size: 14,
                    color: Colors.white70,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _currentTime.isNotEmpty ? _currentTime : '--:--',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVipBadge(dynamic user, bool isLoggedIn) {
    String label = '普通会员';
    Color bg = Colors.white.withValues(alpha: 0.08);
    Color border = Colors.white24;
    Color textCol = Colors.white70;

    if (!isLoggedIn || user == null) {
      label = '未登录';
    } else {
      final int vipType = user.vipType as int? ?? 0;
      final int vipStatus = user.vipStatus as int? ?? 0;
      final String labelText = user.vipLabelText as String? ?? '';

      if (vipStatus == 1 && vipType == 2) {
        label = labelText.isNotEmpty ? labelText : '超级大会员';
        bg = const Color(0xFFFB7299).withValues(alpha: 0.18);
        border = const Color(0xFFFB7299).withValues(alpha: 0.6);
        textCol = const Color(0xFFFF85AD);
      } else if (vipStatus == 1 && vipType == 1) {
        label = '大会员';
        bg = const Color(0xFFFB7299).withValues(alpha: 0.14);
        border = const Color(0xFFFB7299).withValues(alpha: 0.45);
        textCol = const Color(0xFFFF85AD);
      } else {
        label = '普通会员';
      }
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border, width: 0.8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textCol,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// TV 顶部第二行分类栏（直播、推荐、热门、分区、番剧）
class TvCategoryBar extends ConsumerStatefulWidget {
  final String currentPath;

  const TvCategoryBar({
    super.key,
    required this.currentPath,
  });

  @override
  ConsumerState<TvCategoryBar> createState() => _TvCategoryBarState();
}

class _TvCategoryBarState extends ConsumerState<TvCategoryBar> {
  final FocusNode _recommendFocusNode =
      FocusNode(debugLabel: 'CategoryBarRecommendTab');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(navRailFocusServiceProvider)
          .registerRecommendNode(_recommendFocusNode);
    });
  }

  @override
  void dispose() {
    _recommendFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 6),
      child: DpadRegion(
        horizontalEdge: DpadEdgeBehavior.stop,
        verticalEdge: DpadEdgeBehavior.leave,
        child: Row(
          children: [
            _CategoryTabItem(
              title: '直播',
              path: RoutePaths.live,
              isSelected: widget.currentPath == RoutePaths.live,
              onSelect: () => context.go(RoutePaths.live),
            ),
            const SizedBox(width: 16),
            _CategoryTabItem(
              title: '推荐',
              path: RoutePaths.home,
              focusNode: _recommendFocusNode,
              autofocus: widget.currentPath == RoutePaths.home ||
                  widget.currentPath == RoutePaths.initial,
              isSelected: widget.currentPath == RoutePaths.home ||
                  widget.currentPath == RoutePaths.initial,
              onSelect: () => context.go(RoutePaths.home),
            ),
            const SizedBox(width: 16),
            _CategoryTabItem(
              title: '热门',
              path: RoutePaths.popular,
              isSelected: widget.currentPath == RoutePaths.popular,
              onSelect: () => context.go(RoutePaths.popular),
            ),
            const SizedBox(width: 16),
            _CategoryTabItem(
              title: '分区',
              path: '/partition',
              isSelected: false,
              onSelect: () => context.go(RoutePaths.search),
            ),
            const SizedBox(width: 16),
            _CategoryTabItem(
              title: '番剧',
              path: RoutePaths.bangumi,
              isSelected: widget.currentPath == RoutePaths.bangumi,
              onSelect: () => context.go(RoutePaths.bangumi),
            ),
          ],
        ),
      ),
    );
  }
}

/// 顶部整体悬浮栏包装组件（保持向后兼容）
class TvTopBar extends ConsumerWidget {
  final String currentPath;

  const TvTopBar({
    super.key,
    required this.currentPath,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final displayMode = ref.watch(topBarDisplayModeProvider);
    final isCompactOrHidden = displayMode != TopBarDisplayMode.full;

    if (displayMode == TopBarDisplayMode.hidden) {
      return const SizedBox.shrink();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TvTopHeader(currentPath: currentPath),
        AnimatedSize(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: isCompactOrHidden
              ? const SizedBox(width: double.infinity, height: 0)
              : TvCategoryBar(currentPath: currentPath),
        ),
      ],
    );
  }
}

/// 顶部栏操作小按钮 (支持图标+可选文本)
class _TopBarIconButton extends StatelessWidget {
  final IconData icon;
  final String? label;
  final bool isSelected;
  final VoidCallback onSelect;

  const _TopBarIconButton({
    required this.icon,
    this.label,
    required this.isSelected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return DpadFocusable(
      onSelect: onSelect,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withValues(alpha: 0.18)
              : Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.white54 : Colors.white12,
            width: 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: Colors.white),
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              child: label != null
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(width: 6),
                        Text(
                          label!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

/// 第二行分类 Tab 项
class _CategoryTabItem extends ConsumerWidget {
  final String title;
  final String path;
  final FocusNode? focusNode;
  final bool autofocus;
  final bool isSelected;
  final VoidCallback onSelect;

  const _CategoryTabItem({
    required this.title,
    required this.path,
    this.focusNode,
    this.autofocus = false,
    required this.isSelected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isSelected) {
      ref.read(navRailFocusServiceProvider).registerSelectedNode(focusNode);
    }

    return DpadFocusable(
      focusNode: focusNode,
      autofocus: autofocus,
      onSelect: onSelect,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? TvTheme.biliPink.withValues(alpha: 0.22)
              : Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? TvTheme.biliPink : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontSize: 16,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}

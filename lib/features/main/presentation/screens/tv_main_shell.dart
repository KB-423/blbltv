import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/tv_theme.dart';
import '../../../../core/utils/back_navigation_debounce.dart';
import '../../../../router/route_paths.dart';
import '../../../../widgets/tv_image.dart';
import '../providers/nav_rail_focus_provider.dart';
import '../providers/shell_background_provider.dart';
import '../widgets/global_tv_video_surface.dart';
import '../widgets/tv_top_bar.dart';

/// TV 主框架 Shell，纯净分层架构：
/// 1. Stack 底层：纯数据驱动的背景层 (全局单例播放器视窗 / Tab 指定底图 / 默认暗色底图)
/// 2. Stack 上层：Positioned.fill(Column(["头栏", "分类栏", Expanded(child)]))
/// 3. 全量动效编排：头栏进入 compact 或 hidden 模式时，分类栏 AnimatedSize 坍缩至 0，
///    下方 Expanded(child) 伴随 Curves.easeOutCubic 丝滑平滑上移！
class TvMainShell extends ConsumerStatefulWidget {
  final Widget child;
  final GoRouterState state;

  const TvMainShell({
    super.key,
    required this.child,
    required this.state,
  });

  @override
  ConsumerState<TvMainShell> createState() => _TvMainShellState();
}

class _TvMainShellState extends ConsumerState<TvMainShell> {
  DateTime? _lastBackTime;

  KeyEventResult _handleEscapeKey(
    KeyEvent event,
    NavRailFocusService navService,
    TopBarDisplayMode displayMode,
  ) {
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      if (event is KeyDownEvent) {
        if (displayMode != TopBarDisplayMode.full) {
          ref.read(topBarDisplayModeProvider.notifier).showFull();
        } else if (!navService.isNavRailFocused) {
          navService.focusSelected();
        }
      }
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  Widget _buildBackground(ShellBackgroundState bgState, String currentPath) {
    final isVideoStreamTab = currentPath == RoutePaths.home ||
        currentPath == RoutePaths.initial ||
        currentPath == RoutePaths.popular;

    // 若当前 Tab 显式指定了底图
    if (bgState.type == ShellBackgroundType.image &&
        bgState.imageUrl != null &&
        bgState.imageUrl!.isNotEmpty) {
      return TvImage(
        imageUrl: bgState.imageUrl!,
        fit: BoxFit.cover,
      );
    }

    // 若在推荐主页或热门视频流页，或背景模式显式为 player，挂载全局单例播放内核视窗（含冻结帧过渡）
    if (isVideoStreamTab || bgState.type == ShellBackgroundType.player) {
      return const GlobalTvVideoSurface();
    }

    // 其他 Tab 默认暗色质感底图 (承载选择卡片)
    return const _DefaultDarkBackground();
  }

  @override
  Widget build(BuildContext context) {
    final navService = ref.read(navRailFocusServiceProvider);
    final displayMode = ref.watch(topBarDisplayModeProvider);
    final bgState = ref.watch(shellBackgroundProvider);
    final isCompactOrHidden = displayMode != TopBarDisplayMode.full;
    final isHidden = displayMode == TopBarDisplayMode.hidden;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        // 全局防抖锁拦截：若 400ms 内已消费过返回事件，坚决丢弃，杜绝连跳
        if (!BackNavigationDebounce.shouldHandle()) return;

        // 1. 若顶栏当前处于隐藏或精简模式，先恢复全显
        if (displayMode != TopBarDisplayMode.full) {
          ref.read(topBarDisplayModeProvider.notifier).showFull();
          return;
        }

        // 2. 如果当前焦点不在顶部导航栏，按返回键优先平滑交接回顶部分类栏（保留原选中记忆）
        if (!navService.isNavRailFocused) {
          navService.focusSelected();
          return;
        }

        // 3. 如果当前选中的不是推荐 Tab，返回推荐首页
        if (widget.state.matchedLocation != RoutePaths.home &&
            widget.state.matchedLocation != RoutePaths.initial) {
          context.go(RoutePaths.home);
          return;
        }

        // 4. 如果已经在推荐页导航栏：2 秒内连续按两次返回键才真正退出应用，彻底杜绝单次连击误触退出到桌面
        final now = DateTime.now();
        if (_lastBackTime == null ||
            now.difference(_lastBackTime!).inSeconds >= 2) {
          _lastBackTime = now;
          if (mounted) {
            ScaffoldMessenger.of(context).removeCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('再按一次返回键退出 Bili for TV'),
                duration: Duration(seconds: 2),
              ),
            );
          }
          return;
        }

        // 确认退出应用至系统桌面
        SystemNavigator.pop();
      },
      child: Scaffold(
        backgroundColor: TvTheme.tvBackground,
        body: Stack(
          fit: StackFit.expand,
          children: [
            // ================= 1. 纯数据驱动的统一全屏背景层 =================
            Positioned.fill(
              child: _buildBackground(bgState, widget.state.matchedLocation),
            ),

            // ================= 2. 界面层: Column([头栏, 分类栏, child]) =================
            Positioned.fill(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // "头栏" (第一行：搜索、账号、时间等)
                  AnimatedSize(
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeOutCubic,
                    alignment: Alignment.topCenter,
                    child: isHidden
                        ? const SizedBox(width: double.infinity, height: 0)
                        : TvTopHeader(currentPath: widget.state.matchedLocation),
                  ),

                  // "分类栏" (第二行：直播、推荐、热门等分类 Tab)
                  // 当进入 compact 或 hidden 模式时，高度在 280ms 内连续坍缩至 0，
                  // 驱动下方的 Expanded(child) 伴随 Curves.easeOutCubic 平滑向上升起！
                  AnimatedSize(
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeOutCubic,
                    alignment: Alignment.topCenter,
                    child: isCompactOrHidden
                        ? const SizedBox(width: double.infinity, height: 0)
                        : TvCategoryBar(
                            currentPath: widget.state.matchedLocation,
                          ),
                  ),

                  // child 的布局 (随着上方 AnimatedSize 动态坍缩，平滑向上移动拉伸！)
                  Expanded(
                    child: Focus(
                      onKeyEvent: (node, event) =>
                          _handleEscapeKey(event, navService, displayMode),
                      child: widget.child,
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
}

/// 默认 TV 暗色渐变质感底图
class _DefaultDarkBackground extends StatelessWidget {
  const _DefaultDarkBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: TvTheme.tvBackground,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF131524),
            Color(0xFF0C0D14),
            Color(0xFF090A0F),
          ],
          stops: [0.0, 0.45, 1.0],
        ),
      ),
    );
  }
}

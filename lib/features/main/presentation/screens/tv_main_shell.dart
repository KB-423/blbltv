import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/tv_theme.dart';
import '../../../../core/utils/back_navigation_debounce.dart';
import '../../../../router/route_paths.dart';
import '../providers/nav_rail_focus_provider.dart';
import '../widgets/tv_nav_rail.dart';

/// TV 主框架 Shell，左侧导轨 + 右侧动态页面内容
/// 包含全局根 PopScope 防误触退出保护机制：
/// 1. 内容区按返回键优先切回左侧导航导轨
/// 2. 非首页 Tab 按返回键返回首页
/// 3. 首页导航栏需在 2 秒内按两次返回键才真正退出应用，彻底杜绝误触或从播放器连退直接退出到系统桌面
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

  @override
  Widget build(BuildContext context) {
    final navService = ref.read(navRailFocusServiceProvider);
    final isNavRailVisible = ref.watch(navRailVisibilityProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        // 全局防抖锁拦截：若 400ms 内已消费过返回事件，坚决丢弃，杜绝连跳
        if (!BackNavigationDebounce.shouldHandle()) return;

        // 1. 如果当前焦点不在左侧导航栏，按返回键优先平滑交接回左侧导航栏
        if (!navService.isNavRailFocused) {
          // 若导轨当前处于隐退状态，先重新唤出导轨
          if (!isNavRailVisible) {
            ref.read(navRailVisibilityProvider.notifier).show();
          }
          navService.focusSelected();
          return;
        }

        // 2. 如果当前选中的不是首页 Tab，返回首页
        if (widget.state.matchedLocation != RoutePaths.home) {
          context.go(RoutePaths.home);
          return;
        }

        // 3. 如果已经在首页导航栏：2 秒内连续按两次返回键才真正退出应用，彻底杜绝单次连击误触退出到桌面
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
            // 全屏动态页面内容 (Edge-to-Edge 100% 满幅渲染)
            Positioned.fill(
              child: Focus(
                onKeyEvent: (node, event) {
                  // 键盘 Escape 兜底：平滑切回左侧导轨 (Android 物理返回键已由 PopScope 纳管)
                  if (event.logicalKey == LogicalKeyboardKey.escape) {
                    if (!navService.isNavRailFocused) {
                      if (event is KeyDownEvent) {
                        if (!isNavRailVisible) {
                          ref.read(navRailVisibilityProvider.notifier).show();
                        }
                        navService.focusSelected();
                      }
                      return KeyEventResult.handled;
                    }
                  }
                  return KeyEventResult.ignored;
                },
                child: widget.child,
              ),
            ),

            // Apple TV 悬浮折叠微光侧边导轨 (选项 B：左侧浮空无界毛玻璃)
            Positioned(
              left: 16,
              top: 16,
              bottom: 16,
              child: AnimatedSlide(
                duration: const Duration(milliseconds: 320),
                curve: Curves.easeOutCubic,
                offset: isNavRailVisible
                    ? Offset.zero
                    : const Offset(-1.25, 0.0),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeOutCubic,
                  opacity: isNavRailVisible ? 1.0 : 0.0,
                  child: IgnorePointer(
                    ignoring: !isNavRailVisible,
                    child: ExcludeFocus(
                      excluding: !isNavRailVisible,
                      child: TvNavRail(
                        currentPath: widget.state.matchedLocation,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

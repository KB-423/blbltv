import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/tv_theme.dart';
import '../../../../core/utils/back_navigation_debounce.dart';
import '../../../../router/route_paths.dart';
import '../providers/nav_rail_focus_provider.dart';
import '../widgets/tv_top_bar.dart';

/// TV 主框架 Shell，顶部双层悬浮导航栏 + 动态页面内容
/// 包含全局根 PopScope 防误触退出保护机制：
/// 1. 若顶栏处于隐藏或精简模式，按返回键优先恢复全显
/// 2. 内容区按返回键优先切回顶部导航分类栏（保留记忆焦点）
/// 3. 非推荐 Tab 按返回键切回推荐首页
/// 4. 推荐页顶部栏需在 2 秒内按两次返回键才真正退出应用，彻底杜绝误触直接退到系统桌面
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
    final displayMode = ref.watch(topBarDisplayModeProvider);

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
            // 全屏动态页面内容 (Edge-to-Edge 100% 满幅渲染)
            Positioned.fill(
              child: Focus(
                onKeyEvent: (node, event) {
                  // 键盘 Escape 兜底：平滑切回顶部导航 (Android 物理返回键已由 PopScope 纳管)
                  if (event.logicalKey == LogicalKeyboardKey.escape) {
                    if (event is KeyDownEvent) {
                      if (displayMode != TopBarDisplayMode.full) {
                        ref
                            .read(topBarDisplayModeProvider.notifier)
                            .showFull();
                      } else if (!navService.isNavRailFocused) {
                        navService.focusSelected();
                      }
                    }
                    return KeyEventResult.handled;
                  }
                  return KeyEventResult.ignored;
                },
                child: widget.child,
              ),
            ),

            // TV 顶部双层悬浮导航栏 (浮于全屏播放器/内容之上)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: TvTopBar(
                currentPath: widget.state.matchedLocation,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

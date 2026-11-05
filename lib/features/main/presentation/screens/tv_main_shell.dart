import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/tv_theme.dart';
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

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        // 1. 如果当前焦点不在左侧导航栏，按返回键优先平滑交接回左侧导航栏
        if (!navService.isNavRailFocused) {
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
        body: Row(
          children: [
            TvNavRail(currentPath: widget.state.matchedLocation),
            Expanded(
              child: Focus(
                onKeyEvent: (node, event) {
                  // 当在右侧内容区按下遥控器返回键/Esc时，优先平滑切回左侧导轨
                  if (event.logicalKey == LogicalKeyboardKey.escape ||
                      event.logicalKey == LogicalKeyboardKey.goBack) {
                    if (!navService.isNavRailFocused) {
                      if (event is KeyDownEvent) {
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
          ],
        ),
      ),
    );
  }
}

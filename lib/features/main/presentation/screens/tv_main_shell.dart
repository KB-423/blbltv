import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/tv_theme.dart';
import '../providers/nav_rail_focus_provider.dart';
import '../widgets/tv_nav_rail.dart';

/// TV 主框架 Shell，左侧导轨 + 右侧动态页面内容
class TvMainShell extends ConsumerWidget {
  final Widget child;
  final GoRouterState state;

  const TvMainShell({
    super.key,
    required this.child,
    required this.state,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navService = ref.read(navRailFocusServiceProvider);

    return Scaffold(
      backgroundColor: TvTheme.tvBackground,
      body: Row(
        children: [
          TvNavRail(currentPath: state.matchedLocation),
          Expanded(
            child: Focus(
              onKeyEvent: (node, event) {
                // 当在右侧内容区按下遥控器返回键时，优先平滑切回左侧导轨
                if (event is KeyDownEvent) {
                  if (event.logicalKey == LogicalKeyboardKey.escape ||
                      event.logicalKey == LogicalKeyboardKey.goBack) {
                    if (!navService.isNavRailFocused) {
                      final handled = navService.focusSelected();
                      if (handled) return KeyEventResult.handled;
                    }
                  }
                }
                return KeyEventResult.ignored;
              },
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

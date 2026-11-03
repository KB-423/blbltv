import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/tv_theme.dart';
import '../widgets/tv_nav_rail.dart';

/// TV 主框架 Shell，左侧导轨 + 右侧动态页面内容
class TvMainShell extends StatelessWidget {
  final Widget child;
  final GoRouterState state;

  const TvMainShell({
    super.key,
    required this.child,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TvTheme.tvBackground,
      body: Row(
        children: [
          TvNavRail(currentPath: state.matchedLocation),
          Expanded(child: child),
        ],
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dpad/dpad.dart';

import '../../../../core/theme/tv_theme.dart';
import '../../../../widgets/tv_scaffold.dart';
import '../../../../widgets/tv_status_view.dart';
import '../providers/auth_provider.dart';
import '../widgets/tv_bangumi_tab.dart';
import '../widgets/tv_favorites_tab.dart';
import '../widgets/tv_history_tab.dart';
import '../widgets/tv_login_panel.dart';
import '../widgets/tv_user_header.dart';

/// TV 个人中心屏幕
/// 深度优化大屏性能与显示空间：
/// 1. 采用单 Tab 按需懒加载，彻底消除一次性并发 3 个重量级列表请求与大图解码引起的电视严重卡顿
/// 2. 紧凑排版，适配 1080P/720P 等不同 DPI 电视设备的可用空间
class TvUserScreen extends ConsumerStatefulWidget {
  const TvUserScreen({super.key});

  @override
  ConsumerState<TvUserScreen> createState() => _TvUserScreenState();
}

class _TvUserScreenState extends ConsumerState<TvUserScreen> {
  int _selectedTabIndex = 0;

  final List<({IconData icon, String label})> _tabs = const [
    (icon: Icons.history_rounded, label: '观看历史'),
    (icon: Icons.star_rounded, label: '我的收藏'),
    (icon: Icons.movie_filter_rounded, label: '我的追番'),
  ];

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return TvScaffold(
      header: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              gradient: TvTheme.biliPinkGradient,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: TvTheme.biliPink.withValues(alpha: 0.35),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.person_rounded, size: 15, color: Colors.white),
                SizedBox(width: 5),
                Text(
                  '个人空间',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Text(
            '个人中心',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          if (authState.isLoggedIn && authState.user != null) ...[
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white12),
              ),
              child: Text(
                '已登录 · ${authState.user!.uname}',
                style: const TextStyle(
                  color: TvTheme.tvTextSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
      body: _buildBody(authState),
    );
  }

  Widget _buildBody(dynamic authState) {
    if (authState.isCheckingLogin) {
      return const TvLoadingView(message: '正在核验登录状态...');
    }

    if (!authState.isLoggedIn || authState.user == null) {
      return const TvLoginPanel();
    }

    final user = authState.user!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 顶部用户信息栏
        TvUserHeader(user: user),

        const SizedBox(height: 14),

        // 分类标签栏 (独立 DpadRegion，防止横向串焦逃逸到上下区域)
        DpadRegion(
          horizontalEdge: DpadEdgeBehavior.stop,
          verticalEdge: DpadEdgeBehavior.leave,
          child: Row(
            children: List.generate(_tabs.length, (index) {
            final tab = _tabs[index];
            final isSelected = _selectedTabIndex == index;

            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: DpadFocusable(
                onSelect: () {
                  setState(() {
                    _selectedTabIndex = index;
                  });
                },
                builder: (context, state, child) {
                  final isFocused = state.focused;

                  Color? bgColor;
                  Gradient? bgGradient;
                  if (isFocused) {
                    if (isSelected) {
                      bgGradient = TvTheme.biliPinkGradient;
                    } else {
                      bgColor = Colors.white;
                    }
                  } else {
                    if (isSelected) {
                      bgGradient = TvTheme.biliPinkGradient;
                    } else {
                      bgColor = Colors.white.withValues(alpha: 0.08);
                    }
                  }

                  Color textColor;
                  Color iconColor;
                  if (isFocused && !isSelected) {
                    textColor = Colors.black;
                    iconColor = Colors.black;
                  } else if (isSelected) {
                    textColor = Colors.white;
                    iconColor = Colors.white;
                  } else {
                    textColor = TvTheme.tvTextSecondary;
                    iconColor = TvTheme.tvTextSecondary;
                  }

                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: bgGradient == null ? bgColor : null,
                      gradient: bgGradient,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isFocused
                            ? Colors.white
                            : (isSelected ? Colors.transparent : Colors.white12),
                        width: 1.2,
                      ),
                      boxShadow: isFocused
                          ? [
                              BoxShadow(
                                color: (isSelected ? TvTheme.biliPink : Colors.white)
                                    .withValues(alpha: 0.35),
                                blurRadius: 14,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          tab.icon,
                          size: 16,
                          color: iconColor,
                        ),
                        const SizedBox(width: 7),
                        Text(
                          tab.label,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 13.5,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                },
                child: const SizedBox.shrink(),
              ),
            );
          }),
        ),
      ),

        const SizedBox(height: 6),

        // 对应分类内容区域 (单 Tab 按需懒加载，彻底消灭同时加载 3 个 Tab 的严重卡顿)
        Expanded(
          child: _buildCurrentTab(_selectedTabIndex),
        ),
      ],
    );
  }

  Widget _buildCurrentTab(int index) {
    switch (index) {
      case 0:
        return const TvHistoryTab();
      case 1:
        return const TvFavoritesTab();
      case 2:
        return const TvBangumiTab();
      default:
        return const SizedBox.shrink();
    }
  }
}

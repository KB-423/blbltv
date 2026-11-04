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
            width: 4,
            height: 22,
            decoration: BoxDecoration(
              color: TvTheme.biliPink,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '个人中心',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          if (authState.isLoggedIn && authState.user != null) ...[
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: TvTheme.tvSurfaceLight,
                borderRadius: BorderRadius.circular(10),
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

        // 分类标签栏 (遥控器方向键切换)
        Row(
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
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? TvTheme.biliPink : TvTheme.tvSurface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? TvTheme.biliPink : TvTheme.tvDivider,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        tab.icon,
                        size: 16,
                        color:
                            isSelected ? Colors.white : TvTheme.tvTextSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        tab.label,
                        style: TextStyle(
                          color:
                              isSelected ? Colors.white : TvTheme.tvTextPrimary,
                          fontSize: 13,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
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

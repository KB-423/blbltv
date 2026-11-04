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
            height: 24,
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
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: TvTheme.tvSurfaceLight,
                borderRadius: BorderRadius.circular(12),
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

        const SizedBox(height: 20),

        // 分类标签栏 (遥控器方向键切换)
        Row(
          children: List.generate(_tabs.length, (index) {
            final tab = _tabs[index];
            final isSelected = _selectedTabIndex == index;

            return Padding(
              padding: const EdgeInsets.only(right: 14),
              child: DpadFocusable(
                onSelect: () {
                  setState(() {
                    _selectedTabIndex = index;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? TvTheme.biliPink : TvTheme.tvSurface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? TvTheme.biliPink
                          : TvTheme.tvDivider,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        tab.icon,
                        size: 18,
                        color: isSelected ? Colors.white : TvTheme.tvTextSecondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        tab.label,
                        style: TextStyle(
                          color: isSelected ? Colors.white : TvTheme.tvTextPrimary,
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),

        const SizedBox(height: 8),

        // 对应分类内容区域
        Expanded(
          child: IndexedStack(
            index: _selectedTabIndex,
            children: const [
              TvHistoryTab(),
              TvFavoritesTab(),
              TvBangumiTab(),
            ],
          ),
        ),
      ],
    );
  }
}

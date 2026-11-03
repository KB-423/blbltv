import 'package:flutter/material.dart';
import '../../../../core/theme/tv_theme.dart';
import '../../../../widgets/tv_scaffold.dart';

/// TV 热门视频屏幕
class TvPopularScreen extends StatelessWidget {
  const TvPopularScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
            '全站热门',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.local_fire_department_rounded,
              size: 64,
              color: TvTheme.biliPink,
            ),
            const SizedBox(height: 16),
            Text(
              '热门视频模块即将推出',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              '基于 /x/web-interface/popular 接口开发中',
              style: TextStyle(color: TvTheme.tvTextSecondary, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}


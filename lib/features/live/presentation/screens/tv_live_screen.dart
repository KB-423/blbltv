import 'package:flutter/material.dart';
import '../../../../core/theme/tv_theme.dart';
import '../../../../widgets/tv_scaffold.dart';

/// TV 直播专区屏幕
class TvLiveScreen extends StatelessWidget {
  const TvLiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return TvScaffold(
      header: Row(
        children: [
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(
              color: TvTheme.biliBlue,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '直播专区',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.sensors_rounded,
              size: 64,
              color: TvTheme.biliBlue,
            ),
            const SizedBox(height: 16),
            Text(
              '大屏直播模块即将推出',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              '支持各分类热门直播间与大屏高清流切换',
              style: TextStyle(color: TvTheme.tvTextSecondary, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}


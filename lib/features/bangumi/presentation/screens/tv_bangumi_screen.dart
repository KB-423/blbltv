import 'package:flutter/material.dart';
import '../../../../core/theme/tv_theme.dart';
import '../../../../widgets/tv_scaffold.dart';

/// TV 追番 / 影视屏幕
class TvBangumiScreen extends StatelessWidget {
  const TvBangumiScreen({super.key});

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
            '追番 / 影视',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.movie_filter_rounded,
              size: 64,
              color: TvTheme.biliPink,
            ),
            const SizedBox(height: 16),
            Text(
              '追番与影视专区正在开发中',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              '支持新番时刻表、追番列表及季度索引',
              style: TextStyle(color: TvTheme.tvTextSecondary, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}


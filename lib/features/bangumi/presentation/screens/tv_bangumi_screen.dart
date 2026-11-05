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
                Icon(Icons.movie_filter_rounded, size: 15, color: Colors.white),
                SizedBox(width: 5),
                Text(
                  '新番影视',
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
            '追番 / 影视',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ],
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
          decoration: BoxDecoration(
            gradient: TvTheme.cardSurfaceGradient,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: TvTheme.tvCardBorder),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: TvTheme.biliPink.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.movie_filter_rounded,
                  size: 48,
                  color: TvTheme.biliPink,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                '追番与影视专区即将上线',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              const Text(
                '支持新番时刻表、追番进度同步、剧集选集与 PGC 杜比视界专属播放流',
                style: TextStyle(color: TvTheme.tvTextSecondary, fontSize: 13.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


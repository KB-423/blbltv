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
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              gradient: TvTheme.biliBlueGradient,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: TvTheme.biliBlue.withValues(alpha: 0.35),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.sensors_rounded, size: 15, color: Colors.white),
                SizedBox(width: 5),
                Text(
                  '实时大厅',
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
            '直播专区',
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
                  color: TvTheme.biliBlue.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.sensors_rounded,
                  size: 48,
                  color: TvTheme.biliBlue,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                '大屏超清直播即将上线',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              const Text(
                '支持单机游戏、网游赛事、虚拟主播等多分区原画 60fps 低延迟直连',
                style: TextStyle(color: TvTheme.tvTextSecondary, fontSize: 13.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


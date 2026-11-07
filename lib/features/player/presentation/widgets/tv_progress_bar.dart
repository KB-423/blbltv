import 'package:flutter/material.dart';

import '../../../../core/theme/tv_theme.dart';
import '../../../../core/utils/formatters.dart';

/// TV 播放器进度条组件
/// - 显示当前播放时间与总时长 (高对比度大屏字体)
/// - 显示缓冲条与播放进度条
class TvProgressBar extends StatelessWidget {
  final Duration position;
  final Duration duration;
  final Duration? bufferedPosition;
  final double height;

  const TvProgressBar({
    super.key,
    required this.position,
    required this.duration,
    this.bufferedPosition,
    this.height = 6.0,
  });

  @override
  Widget build(BuildContext context) {
    final double playedRatio = duration.inMilliseconds > 0
        ? (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0)
        : 0.0;

    final double bufferRatio = (bufferedPosition != null &&
            duration.inMilliseconds > 0)
        ? (bufferedPosition!.inMilliseconds / duration.inMilliseconds)
            .clamp(0.0, 1.0)
        : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 时间进度文字排布 (左：当前时间，右：总时长)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                Formatters.formatDuration(position.inSeconds),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'monospace',
                ),
              ),
              Text(
                Formatters.formatDuration(duration.inSeconds),
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // 进度条主体 (背景槽 + 缓冲层 + 已播放层 + 焦点光标)
          Container(
            height: height,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(height / 2),
            ),
            child: Stack(
              children: [
                // 缓冲进度
                if (bufferRatio > 0.0)
                  FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: bufferRatio,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(height / 2),
                      ),
                    ),
                  ),

                // 播放进度 (品牌粉光渐变)
                FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: playedRatio,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          TvTheme.biliPinkLight,
                          TvTheme.biliPink,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(height / 2),
                      boxShadow: [
                        BoxShadow(
                          color: TvTheme.biliPink.withValues(alpha: 0.5),
                          blurRadius: 8,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

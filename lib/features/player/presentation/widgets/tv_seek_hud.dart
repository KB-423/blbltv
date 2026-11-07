import 'package:flutter/material.dart';

import '../../../../core/theme/tv_theme.dart';
import '../../../../core/utils/formatters.dart';

/// TV 播放器长按快进/快退居中 HUD 浮层
class TvSeekHUD extends StatelessWidget {
  final bool isForward;
  final Duration targetPosition;
  final Duration duration;
  final int accumulatedSeconds;

  const TvSeekHUD({
    super.key,
    required this.isForward,
    required this.targetPosition,
    required this.duration,
    required this.accumulatedSeconds,
  });

  @override
  Widget build(BuildContext context) {
    final double progress = duration.inMilliseconds > 0
        ? (targetPosition.inMilliseconds / duration.inMilliseconds)
            .clamp(0.0, 1.0)
        : 0.0;

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.88),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: TvTheme.biliPink,
            width: 1.8,
          ),
          boxShadow: [
            BoxShadow(
              color: TvTheme.biliPink.withValues(alpha: 0.35),
              blurRadius: 28,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isForward
                      ? Icons.fast_forward_rounded
                      : Icons.fast_rewind_rounded,
                  color: TvTheme.biliPink,
                  size: 30,
                ),
                const SizedBox(width: 8),
                Text(
                  isForward ? '快进中 (松手定位)' : '快退中 (松手定位)',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '${Formatters.formatDuration(targetPosition.inSeconds)} / ${Formatters.formatDuration(duration.inSeconds)} (${accumulatedSeconds > 0 ? "+$accumulatedSeconds" : "$accumulatedSeconds"}s)',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: 240,
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: Colors.white24,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  TvTheme.biliPink,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:dpad/dpad.dart';
import '../../../../core/theme/tv_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../models/video/play_url_model.dart';

/// TV 播放器大屏控制层浮层
class TvPlayerControls extends StatelessWidget {
  final String title;
  final String bvid;
  final bool isPlaying;
  final Duration position;
  final Duration duration;
  final int currentQn;
  final List<VideoQualityItem> qualities;
  final VoidCallback onTogglePlay;
  final VoidCallback onSeekBackward;
  final VoidCallback onSeekForward;
  final VoidCallback onOpenQuality;
  final VoidCallback onBack;

  const TvPlayerControls({
    super.key,
    required this.title,
    required this.bvid,
    required this.isPlaying,
    required this.position,
    required this.duration,
    required this.currentQn,
    required this.qualities,
    required this.onTogglePlay,
    required this.onSeekBackward,
    required this.onSeekForward,
    required this.onOpenQuality,
    required this.onBack,
  });

  String _getCurrentQnDesc() {
    for (final q in qualities) {
      if (q.qn == currentQn) return q.desc;
    }
    return '${currentQn}P';
  }

  @override
  Widget build(BuildContext context) {
    final double progress = duration.inMilliseconds > 0
        ? (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0)
        : 0.0;

    return Stack(
      children: [
        // 顶部阴影遮罩与标题栏
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 28),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.85),
                  Colors.transparent,
                ],
              ),
            ),
            child: Row(
              children: [
                DpadFocusable(
                  onSelect: onBack,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                        SizedBox(width: 6),
                        Text('返回', style: TextStyle(color: Colors.white, fontSize: 14)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title.isNotEmpty ? title : '视频播放: $bvid',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '稿件号: $bvid',
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // 底部阴影遮罩与播放控制条
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.9),
                  Colors.transparent,
                ],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 进度条
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 5,
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      TvTheme.biliPink,
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // 操作按钮与时间
                Row(
                  children: [
                    // 播放/暂停
                    DpadFocusable(
                      onSelect: onTogglePlay,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white12,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // 快退 10 秒
                    DpadFocusable(
                      onSelect: onSeekBackward,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white12,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.replay_10_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // 快进 10 秒
                    DpadFocusable(
                      onSelect: onSeekForward,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white12,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.forward_10_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // 时间信息
                    Text(
                      '${Formatters.formatDuration(position.inSeconds)} / ${Formatters.formatDuration(duration.inSeconds)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const Spacer(),

                    // 画质选择入口按钮
                    DpadFocusable(
                      onSelect: onOpenQuality,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white12,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: TvTheme.tvFocusBorder.withValues(alpha: 0.6),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.high_quality_rounded,
                              size: 18,
                              color: TvTheme.tvFocusBorder,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _getCurrentQnDesc(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.arrow_drop_down_rounded,
                              size: 18,
                              color: Colors.white70,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

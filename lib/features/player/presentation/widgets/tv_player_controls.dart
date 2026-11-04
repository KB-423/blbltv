import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dpad/dpad.dart';
import '../../../../core/theme/tv_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../models/video/play_url_model.dart';

/// TV 播放器大屏控制层浮层
/// 分层架构：
/// - 顶部标题信息栏（纯展示，不抢遥控器焦点）
/// - 底部控制栏作为一个独立的横向行 (DpadRegion)
/// - 进入控制栏后，左右方向键仅在同行内平移按钮
/// - 向上方向键 (ArrowUp) 立即切回主视频组件
/// - 返回键 (Back/Escape) 隐藏控制栏并把焦点归还给主视频组件
class TvPlayerControls extends StatelessWidget {
  final String title;
  final String bvid;
  final bool isPlaying;
  final Duration position;
  final Duration duration;
  final int currentQn;
  final List<VideoQualityItem> qualities;
  final bool showDebugOverlay;
  final FocusNode? playPauseFocusNode;
  final FocusNode? qualityFocusNode;
  final VoidCallback? onFocusVideo;
  final VoidCallback? onUserInteraction;
  final VoidCallback onToggleDebugOverlay;
  final VoidCallback onTogglePlay;
  final VoidCallback onSeekBackward;
  final VoidCallback onSeekForward;
  final VoidCallback? onLongSeekBackward;
  final VoidCallback? onLongSeekForward;
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
    required this.showDebugOverlay,
    this.playPauseFocusNode,
    this.qualityFocusNode,
    this.onFocusVideo,
    this.onUserInteraction,
    required this.onToggleDebugOverlay,
    required this.onTogglePlay,
    required this.onSeekBackward,
    required this.onSeekForward,
    this.onLongSeekBackward,
    this.onLongSeekForward,
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
        // 顶部阴影遮罩与标题栏 (纯视觉展示 + 触控返回，遥控器由物理返回键主导)
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
                GestureDetector(
                  onTap: onBack,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.arrow_back_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        SizedBox(width: 6),
                        Text(
                          '返回',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
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

        // 底部阴影遮罩与播放控制条 (独立横向行)
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

                // 操作按钮与时间 (独立横向行)
                Focus(
                  onKeyEvent: (node, event) {
                    if (event is KeyDownEvent) {
                      onUserInteraction?.call();

                      // 向上方向键：切回主视频组件
                      if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
                        onFocusVideo?.call();
                        return KeyEventResult.handled;
                      }

                      // 返回键：收起控制栏并切回主视频组件
                      if (event.logicalKey == LogicalKeyboardKey.escape ||
                          event.logicalKey == LogicalKeyboardKey.goBack) {
                        onBack();
                        return KeyEventResult.handled;
                      }
                    }
                    return KeyEventResult.ignored;
                  },
                  child: DpadRegion(
                    horizontalEdge: DpadEdgeBehavior.stop,
                    verticalEdge: DpadEdgeBehavior.stop,
                    child: Row(
                      children: [
                        // 1. 播放/暂停
                        DpadFocusable(
                          focusNode: playPauseFocusNode,
                          autofocus: true,
                          onSelect: () {
                            onUserInteraction?.call();
                            onTogglePlay();
                          },
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

                        // 2. 快退 10 秒 (长按 30 秒)
                        DpadFocusable(
                          onSelect: () {
                            onUserInteraction?.call();
                            onSeekBackward();
                          },
                          onLongSelect: () {
                            onUserInteraction?.call();
                            if (onLongSeekBackward != null) {
                              onLongSeekBackward!();
                            } else {
                              onSeekBackward();
                            }
                          },
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

                        // 3. 快进 10 秒 (长按 30 秒)
                        DpadFocusable(
                          onSelect: () {
                            onUserInteraction?.call();
                            onSeekForward();
                          },
                          onLongSelect: () {
                            onUserInteraction?.call();
                            if (onLongSeekForward != null) {
                              onLongSeekForward!();
                            } else {
                              onSeekForward();
                            }
                          },
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

                        // 4. 时间信息
                        Text(
                          '${Formatters.formatDuration(position.inSeconds)} / ${Formatters.formatDuration(duration.inSeconds)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        const Spacer(),

                        // 5. 调试统计信息切换按钮
                        DpadFocusable(
                          onSelect: () {
                            onUserInteraction?.call();
                            onToggleDebugOverlay();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: showDebugOverlay
                                  ? TvTheme.biliPink.withValues(alpha: 0.25)
                                  : Colors.white12,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: showDebugOverlay
                                    ? TvTheme.biliPink
                                    : Colors.transparent,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.analytics_outlined,
                                  size: 16,
                                  color: showDebugOverlay
                                      ? TvTheme.biliPink
                                      : Colors.white70,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  '统计信息',
                                  style: TextStyle(
                                    color: showDebugOverlay
                                        ? TvTheme.biliPink
                                        : Colors.white70,
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // 6. 画质选择入口按钮
                        DpadFocusable(
                          focusNode: qualityFocusNode,
                          onSelect: () {
                            onUserInteraction?.call();
                            onOpenQuality();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white12,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: TvTheme.tvFocusBorder
                                    .withValues(alpha: 0.6),
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
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

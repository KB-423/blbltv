import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dpad/dpad.dart';
import '../../../../core/theme/tv_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../models/video/play_url_model.dart';

/// TV 播放器大屏控制层浮层
/// 分层架构：
/// - 顶部标题信息栏 + 实时在线人数统计
/// - 底部控制栏作为一个独立的横向行 (DpadRegion)
/// - 支持选集抽屉唤出、点赞状态切换、一键三连操作
class TvPlayerControls extends StatelessWidget {
  final String title;
  final String bvid;
  final bool isPlaying;
  final Duration position;
  final Duration duration;
  final int currentQn;
  final List<VideoQualityItem> qualities;
  final bool showDebugOverlay;
  final String onlineCount;
  final bool hasParts;
  final int currentPart;
  final bool isLiked;
  final FocusNode? playPauseFocusNode;
  final FocusNode? qualityFocusNode;
  final FocusNode? partBtnFocusNode;
  final VoidCallback? onFocusVideo;
  final VoidCallback? onUserInteraction;
  final VoidCallback onToggleDebugOverlay;
  final VoidCallback onTogglePlay;
  final VoidCallback onSeekBackward;
  final VoidCallback onSeekForward;
  final VoidCallback? onLongSeekBackward;
  final VoidCallback? onLongSeekForward;
  final VoidCallback onOpenQuality;
  final VoidCallback? onOpenPartDrawer;
  final VoidCallback? onToggleLike;
  final VoidCallback? onTriple;
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
    this.onlineCount = '',
    this.hasParts = false,
    this.currentPart = 1,
    this.isLiked = false,
    this.playPauseFocusNode,
    this.qualityFocusNode,
    this.partBtnFocusNode,
    this.onFocusVideo,
    this.onUserInteraction,
    required this.onToggleDebugOverlay,
    required this.onTogglePlay,
    required this.onSeekBackward,
    required this.onSeekForward,
    this.onLongSeekBackward,
    this.onLongSeekForward,
    required this.onOpenQuality,
    this.onOpenPartDrawer,
    this.onToggleLike,
    this.onTriple,
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
        // 顶部阴影遮罩与标题栏 (标题 + 稿件号 + 实时在看人数)
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
                  Colors.black.withValues(alpha: 0.88),
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
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.arrow_back_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                        SizedBox(width: 6),
                        Text(
                          '返回',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w500,
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
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Text(
                            '稿件: $bvid',
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                          if (onlineCount.isNotEmpty) ...[
                            const SizedBox(width: 12),
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Color(0xFF00E676),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              '$onlineCount 人正在看',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
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
                  Colors.black.withValues(alpha: 0.92),
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
                      Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // 操作按钮与时间 (独立横向行)
                Focus(
                  onKeyEvent: (node, event) {
                    if (event is KeyDownEvent) {
                      onUserInteraction?.call();

                      if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
                        onFocusVideo?.call();
                        return KeyEventResult.handled;
                      }

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
                          builder: (context, state, child) {
                            final isFocused = state.focused;
                            return Container(
                              padding: const EdgeInsets.all(9),
                              decoration: BoxDecoration(
                                color: isFocused
                                    ? Colors.white
                                    : Colors.white.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: isFocused
                                    ? [
                                        BoxShadow(
                                          color: Colors.white.withValues(alpha: 0.35),
                                          blurRadius: 12,
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Icon(
                                isPlaying
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                                color: isFocused ? Colors.black : Colors.white,
                                size: 26,
                              ),
                            );
                          },
                          child: const SizedBox.shrink(),
                        ),
                        const SizedBox(width: 12),

                        // 2. 快退 10 秒
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
                          builder: (context, state, child) {
                            final isFocused = state.focused;
                            return Container(
                              padding: const EdgeInsets.all(9),
                              decoration: BoxDecoration(
                                color: isFocused
                                    ? Colors.white
                                    : Colors.white.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: isFocused
                                    ? [
                                        BoxShadow(
                                          color: Colors.white.withValues(alpha: 0.35),
                                          blurRadius: 12,
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Icon(
                                Icons.replay_10_rounded,
                                color: isFocused ? Colors.black : Colors.white,
                                size: 22,
                              ),
                            );
                          },
                          child: const SizedBox.shrink(),
                        ),
                        const SizedBox(width: 12),

                        // 3. 快进 10 秒
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
                          builder: (context, state, child) {
                            final isFocused = state.focused;
                            return Container(
                              padding: const EdgeInsets.all(9),
                              decoration: BoxDecoration(
                                color: isFocused
                                    ? Colors.white
                                    : Colors.white.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: isFocused
                                    ? [
                                        BoxShadow(
                                          color: Colors.white.withValues(alpha: 0.35),
                                          blurRadius: 12,
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Icon(
                                Icons.forward_10_rounded,
                                color: isFocused ? Colors.black : Colors.white,
                                size: 22,
                              ),
                            );
                          },
                          child: const SizedBox.shrink(),
                        ),
                        const SizedBox(width: 16),

                        // 4. 时间信息
                        Text(
                          '${Formatters.formatDuration(position.inSeconds)} / ${Formatters.formatDuration(duration.inSeconds)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const Spacer(),

                        // 5. 多 P 选集按钮 (若存在多P)
                        if (hasParts && onOpenPartDrawer != null) ...[
                          DpadFocusable(
                            focusNode: partBtnFocusNode,
                            onSelect: () {
                              onUserInteraction?.call();
                              onOpenPartDrawer!();
                            },
                            builder: (context, state, child) {
                              final isFocused = state.focused;
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: isFocused
                                      ? Colors.white
                                      : Colors.white.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isFocused ? Colors.white : Colors.white12,
                                  ),
                                  boxShadow: isFocused
                                      ? [
                                          BoxShadow(
                                            color: Colors.white.withValues(alpha: 0.35),
                                            blurRadius: 12,
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.format_list_numbered_rounded,
                                      size: 16,
                                      color: isFocused ? Colors.black : Colors.white70,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      '选集 P$currentPart',
                                      style: TextStyle(
                                        color: isFocused ? Colors.black : Colors.white,
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: const SizedBox.shrink(),
                          ),
                          const SizedBox(width: 10),
                        ],

                        // 6. 点赞互动按钮
                        if (onToggleLike != null) ...[
                          DpadFocusable(
                            onSelect: () {
                              onUserInteraction?.call();
                              onToggleLike!();
                            },
                            builder: (context, state, child) {
                              final isFocused = state.focused;
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: isFocused
                                      ? Colors.white
                                      : (isLiked
                                          ? TvTheme.biliPink.withValues(alpha: 0.22)
                                          : Colors.white.withValues(alpha: 0.12)),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isFocused
                                        ? Colors.white
                                        : (isLiked ? TvTheme.biliPink : Colors.white12),
                                  ),
                                  boxShadow: isFocused
                                      ? [
                                          BoxShadow(
                                            color: Colors.white.withValues(alpha: 0.35),
                                            blurRadius: 12,
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      isLiked ? Icons.thumb_up_alt_rounded : Icons.thumb_up_off_alt_rounded,
                                      size: 16,
                                      color: isFocused
                                          ? Colors.black
                                          : (isLiked ? TvTheme.biliPink : Colors.white70),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      isLiked ? '已赞' : '点赞',
                                      style: TextStyle(
                                        color: isFocused
                                            ? Colors.black
                                            : (isLiked ? TvTheme.biliPink : Colors.white70),
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: const SizedBox.shrink(),
                          ),
                          const SizedBox(width: 10),
                        ],

                        // 7. 一键三连按钮
                        if (onTriple != null) ...[
                          DpadFocusable(
                            onSelect: () {
                              onUserInteraction?.call();
                              onTriple!();
                            },
                            builder: (context, state, child) {
                              final isFocused = state.focused;
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: isFocused
                                      ? Colors.white
                                      : Colors.white.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isFocused ? Colors.white : Colors.white12,
                                  ),
                                  boxShadow: isFocused
                                      ? [
                                          BoxShadow(
                                            color: Colors.white.withValues(alpha: 0.35),
                                            blurRadius: 12,
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.favorite_rounded,
                                      size: 16,
                                      color: isFocused ? Colors.black : Colors.white70,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '三连',
                                      style: TextStyle(
                                        color: isFocused ? Colors.black : Colors.white,
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: const SizedBox.shrink(),
                          ),
                          const SizedBox(width: 10),
                        ],

                        // 8. 调试统计信息切换按钮
                        DpadFocusable(
                          onSelect: () {
                            onUserInteraction?.call();
                            onToggleDebugOverlay();
                          },
                          builder: (context, state, child) {
                            final isFocused = state.focused;
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isFocused
                                    ? Colors.white
                                    : (showDebugOverlay
                                        ? Colors.white.withValues(alpha: 0.22)
                                        : Colors.white.withValues(alpha: 0.12)),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isFocused ? Colors.white : Colors.white12,
                                ),
                                boxShadow: isFocused
                                    ? [
                                        BoxShadow(
                                          color: Colors.white.withValues(alpha: 0.35),
                                          blurRadius: 12,
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.analytics_outlined,
                                    size: 16,
                                    color: isFocused
                                        ? Colors.black
                                        : Colors.white70,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    '统计',
                                    style: TextStyle(
                                      color: isFocused
                                          ? Colors.black
                                          : Colors.white70,
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: const SizedBox.shrink(),
                        ),
                        const SizedBox(width: 10),

                        // 9. 画质选择入口按钮
                        DpadFocusable(
                          focusNode: qualityFocusNode,
                          onSelect: () {
                            onUserInteraction?.call();
                            onOpenQuality();
                          },
                          builder: (context, state, child) {
                            final isFocused = state.focused;
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isFocused
                                    ? Colors.white
                                    : Colors.white.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isFocused ? Colors.white : Colors.white24,
                                  width: 1.0,
                                ),
                                boxShadow: isFocused
                                    ? [
                                        BoxShadow(
                                          color: Colors.white.withValues(alpha: 0.35),
                                          blurRadius: 14,
                                          spreadRadius: 1,
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.high_quality_rounded,
                                    size: 18,
                                    color: isFocused ? Colors.black : Colors.white,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    _getCurrentQnDesc(),
                                    style: TextStyle(
                                      color: isFocused ? Colors.black : Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.arrow_drop_down_rounded,
                                    size: 18,
                                    color: isFocused ? Colors.black54 : Colors.white70,
                                  ),
                                ],
                              ),
                            );
                          },
                          child: const SizedBox.shrink(),
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

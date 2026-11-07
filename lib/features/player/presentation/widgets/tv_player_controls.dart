import 'package:flutter/material.dart';
import 'package:dpad/dpad.dart';

import '../../../../core/theme/tv_theme.dart';
import '../../../../models/video/play_url_model.dart';
import 'tv_play_pause_button.dart';
import 'tv_player_header.dart';
import 'tv_progress_bar.dart';
import 'tv_quick_seek_button.dart';

/// TV 播放器通用控制浮层组件
/// 适配模式：
/// 1. 普通视频 (Video): 显示进度条、快进快退、分P选集、画质切换、点赞三连
/// 2. 番剧影视 (Bangumi): 显示进度条、快进快退、集数选集、画质切换、追番
/// 3. 直播流 (Live): 隐藏进度条与快进快退、显示直播标签与线路/清晰度切换
class TvPlayerControls extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? bvid;
  final String? badgeText;
  final Color? badgeColor;
  final String onlineCount;
  final bool isLive;
  final bool isPlaying;
  final Duration position;
  final Duration duration;
  final Duration? bufferedPosition;
  final int currentQn;
  final List<VideoQualityItem> qualities;
  final bool showDebugOverlay;
  final bool hasEpisodes;
  final bool hasParts;
  final int currentPart;
  final String episodeButtonLabel;
  final bool isLiked;

  // 专用焦点节点
  final FocusNode? playPauseFocusNode;
  final FocusNode? qualityFocusNode;
  final FocusNode? episodeBtnFocusNode;
  final FocusNode? partBtnFocusNode;

  // 交互回调
  final VoidCallback onTogglePlay;
  final VoidCallback onSeekBackward;
  final VoidCallback onSeekForward;
  final VoidCallback? onLongSeekBackward;
  final VoidCallback? onLongSeekForward;
  final VoidCallback onOpenQuality;
  final VoidCallback? onOpenEpisodes;
  final VoidCallback? onOpenPartDrawer;
  final VoidCallback? onToggleLike;
  final VoidCallback? onTriple;
  final VoidCallback onToggleDebugOverlay;
  final VoidCallback onBack;
  final VoidCallback? onUserInteraction;
  final VoidCallback? onFocusVideo;

  const TvPlayerControls({
    super.key,
    required this.title,
    this.subtitle,
    this.bvid,
    this.badgeText,
    this.badgeColor,
    this.onlineCount = '',
    this.isLive = false,
    required this.isPlaying,
    required this.position,
    required this.duration,
    this.bufferedPosition,
    required this.currentQn,
    required this.qualities,
    required this.showDebugOverlay,
    this.hasEpisodes = false,
    this.hasParts = false,
    this.currentPart = 1,
    this.episodeButtonLabel = '选集',
    this.isLiked = false,
    this.playPauseFocusNode,
    this.qualityFocusNode,
    this.episodeBtnFocusNode,
    this.partBtnFocusNode,
    required this.onTogglePlay,
    required this.onSeekBackward,
    required this.onSeekForward,
    this.onLongSeekBackward,
    this.onLongSeekForward,
    required this.onOpenQuality,
    this.onOpenEpisodes,
    this.onOpenPartDrawer,
    this.onToggleLike,
    this.onTriple,
    required this.onToggleDebugOverlay,
    required this.onBack,
    this.onUserInteraction,
    this.onFocusVideo,
  });

  String _getCurrentQnDesc() {
    for (final q in qualities) {
      if (q.qn == currentQn) return q.desc;
    }
    return '${currentQn}P';
  }

  @override
  Widget build(BuildContext context) {
    final String? effectiveSubtitle =
        subtitle ?? (bvid != null && bvid!.isNotEmpty ? bvid : null);
    final bool effectiveHasEpisodes = hasEpisodes || hasParts;
    final String effectiveEpisodeLabel = episodeButtonLabel != '选集'
        ? episodeButtonLabel
        : (hasParts ? '选集 (P$currentPart)' : '选集');
    final FocusNode? effectiveEpisodeFocusNode =
        episodeBtnFocusNode ?? partBtnFocusNode;
    final VoidCallback? effectiveOpenEpisodes =
        onOpenEpisodes ?? onOpenPartDrawer;

    return Stack(
      children: [
        // 1. 顶部标题与信息栏
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: TvPlayerHeader(
            title: title,
            subtitle: effectiveSubtitle,
            badgeText: badgeText ?? (isLive ? '直播中' : null),
            badgeColor: badgeColor ?? (isLive ? const Color(0xFFFF4D4F) : null),
            onlineCount: onlineCount,
            onBack: onBack,
          ),
        ),

        // 2. 底部控制栏区 (渐变遮罩 + 进度条 + 控制按钮行)
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            padding: const EdgeInsets.only(top: 40, bottom: 28),
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
                // 仅点播/番剧显示进度条
                if (!isLive) ...[
                  TvProgressBar(
                    position: position,
                    duration: duration,
                    bufferedPosition: bufferedPosition,
                  ),
                  const SizedBox(height: 18),
                ],

                // 核心控制按钮行 (独立 DpadRegion，左右键受限不跨区，上键交接给视频画面)
                DpadRegion(
                  horizontalEdge: DpadEdgeBehavior.stop,
                  verticalEdge: DpadEdgeBehavior.leave,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Row(
                      children: [
                        // 播放 / 暂停按钮
                        TvPlayPauseButton(
                          focusNode: playPauseFocusNode,
                          autofocus: true,
                          isPlaying: isPlaying,
                          onTogglePlay: () {
                            onUserInteraction?.call();
                            onTogglePlay();
                          },
                        ),

                        // 非直播模式提供快进/快退
                        if (!isLive) ...[
                          const SizedBox(width: 14),
                          TvQuickSeekButton(
                            isForward: false,
                            seconds: 10,
                            onSeek: () {
                              onUserInteraction?.call();
                              onSeekBackward();
                            },
                            onLongSeek: onLongSeekBackward != null
                                ? () {
                                    onUserInteraction?.call();
                                    onLongSeekBackward!();
                                  }
                                : null,
                          ),
                          const SizedBox(width: 14),
                          TvQuickSeekButton(
                            isForward: true,
                            seconds: 10,
                            onSeek: () {
                              onUserInteraction?.call();
                              onSeekForward();
                            },
                            onLongSeek: onLongSeekForward != null
                                ? () {
                                    onUserInteraction?.call();
                                    onLongSeekForward!();
                                  }
                                : null,
                          ),
                        ],

                        // 选集 / 分 P 按钮 (当存在多集或多 P 时展示)
                        if (effectiveHasEpisodes &&
                            effectiveOpenEpisodes != null) ...[
                          const SizedBox(width: 14),
                          DpadFocusable(
                            focusNode: effectiveEpisodeFocusNode,
                            onSelect: () {
                              onUserInteraction?.call();
                              effectiveOpenEpisodes();
                            },
                            builder: (context, state, child) {
                              final isFocused = state.focused;
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: isFocused
                                      ? Colors.white
                                      : Colors.white.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isFocused
                                        ? Colors.white
                                        : Colors.white12,
                                    width: 1.2,
                                  ),
                                  boxShadow: isFocused
                                      ? [
                                          BoxShadow(
                                            color: Colors.white
                                                .withValues(alpha: 0.35),
                                            blurRadius: 14,
                                            spreadRadius: 1,
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.format_list_bulleted_rounded,
                                      size: 16,
                                      color: isFocused
                                          ? Colors.black
                                          : Colors.white,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      effectiveEpisodeLabel,
                                      style: TextStyle(
                                        color: isFocused
                                            ? Colors.black
                                            : Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: const SizedBox.shrink(),
                          ),
                        ],

                        const Spacer(),

                        // 画质选择入口按钮
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
                                horizontal: 16,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: isFocused
                                    ? Colors.white
                                    : Colors.white.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color:
                                      isFocused ? Colors.white : Colors.white12,
                                  width: 1.2,
                                ),
                                boxShadow: isFocused
                                    ? [
                                        BoxShadow(
                                          color: Colors.white
                                              .withValues(alpha: 0.35),
                                          blurRadius: 14,
                                          spreadRadius: 1,
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.high_quality_rounded,
                                    size: 16,
                                    color:
                                        isFocused ? Colors.black : Colors.white,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    _getCurrentQnDesc(),
                                    style: TextStyle(
                                      color: isFocused
                                          ? Colors.black
                                          : Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: const SizedBox.shrink(),
                        ),

                        // 点赞操作按钮 (非直播)
                        if (!isLive && onToggleLike != null) ...[
                          const SizedBox(width: 12),
                          DpadFocusable(
                            onSelect: () {
                              onUserInteraction?.call();
                              onToggleLike!();
                            },
                            onLongSelect: onTriple != null
                                ? () {
                                    onUserInteraction?.call();
                                    onTriple!();
                                  }
                                : null,
                            builder: (context, state, child) {
                              final isFocused = state.focused;
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: isFocused
                                      ? Colors.white
                                      : (isLiked
                                          ? TvTheme.biliPink
                                              .withValues(alpha: 0.3)
                                          : Colors.white
                                              .withValues(alpha: 0.12)),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isFocused
                                        ? Colors.white
                                        : (isLiked
                                            ? TvTheme.biliPink
                                            : Colors.white12),
                                    width: 1.2,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      isLiked
                                          ? Icons.thumb_up_rounded
                                          : Icons.thumb_up_outlined,
                                      size: 16,
                                      color: isFocused
                                          ? Colors.black
                                          : (isLiked
                                              ? TvTheme.biliPinkLight
                                              : Colors.white),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      isLiked ? '已点赞' : '点赞 (长按三连)',
                                      style: TextStyle(
                                        color: isFocused
                                            ? Colors.black
                                            : (isLiked
                                                ? TvTheme.biliPinkLight
                                                : Colors.white),
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: const SizedBox.shrink(),
                          ),
                        ],

                        // 极客调试面板开关按钮
                        const SizedBox(width: 12),
                        DpadFocusable(
                          onSelect: () {
                            onUserInteraction?.call();
                            onToggleDebugOverlay();
                          },
                          builder: (context, state, child) {
                            final isFocused = state.focused;
                            return Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isFocused
                                    ? Colors.white
                                    : (showDebugOverlay
                                        ? TvTheme.biliPink.withValues(alpha: 0.4)
                                        : Colors.white.withValues(alpha: 0.12)),
                                border: Border.all(
                                  color:
                                      isFocused ? Colors.white : Colors.white12,
                                  width: 1.2,
                                ),
                              ),
                              child: Icon(
                                Icons.bug_report_rounded,
                                size: 16,
                                color: isFocused
                                    ? Colors.black
                                    : (showDebugOverlay
                                        ? TvTheme.biliPinkLight
                                        : Colors.white70),
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

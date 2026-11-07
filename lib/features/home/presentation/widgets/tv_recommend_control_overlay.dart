import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dpad/dpad.dart';

import '../../../../core/theme/tv_theme.dart';
import '../../../../core/utils/back_navigation_debounce.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../models/video/play_url_model.dart';
import '../../../../models/video/video_item_model.dart';
import '../../../../widgets/tv_image.dart';
import '../providers/home_provider.dart';
import '../providers/recommend_player_provider.dart';
import '../providers/recommend_player_state.dart';

/// TV 推荐流播放器全功能控制浮层
/// 设计规范：
/// 1. 顶部：视频标题，下方为实时在线观看人数
/// 2. 底部第一行：点赞（支持长按蓄力一键三连）、点踩、投币、收藏
/// 3. 底部第二行：播放进度条（获得默认初始焦点），OK 播放/暂停，左右 seek
/// 4. 底部第三行：弹幕开关、画质选择、倍速切换、设置（连播/循环、弹幕调节）
/// 5. 底部第四行及后续：合集（如果存在）、他的作品、他的合集、相关推荐合集
///    默认状态下第四行露个头（48px），提示下方有内容；向下移动可完全滑入浏览
class TvRecommendControlOverlay extends ConsumerStatefulWidget {
  final VoidCallback onClose;
  final ValueChanged<String>? onSelectVideo;

  const TvRecommendControlOverlay({
    super.key,
    required this.onClose,
    this.onSelectVideo,
  });

  @override
  ConsumerState<TvRecommendControlOverlay> createState() =>
      _TvRecommendControlOverlayState();
}

class _TvRecommendControlOverlayState
    extends ConsumerState<TvRecommendControlOverlay>
    with SingleTickerProviderStateMixin {
  final FocusNode _progressFocusNode =
      FocusNode(debugLabel: 'RecommendProgressBar');
  final ScrollController _verticalScrollController = ScrollController();

  // 长按点赞蓄力动效状态
  bool _isLongPressingLike = false;
  double _tripleProgress = 0.0;
  Timer? _tripleTimer;
  DateTime? _tripleStartTime;
  bool _showTripleSuccessHUD = false;

  // 左右 Seek 预览状态
  Duration? _previewSeekTarget;
  Timer? _previewSeekClearTimer;

  // 设置弹窗状态
  bool _showSettingsDialog = false;
  bool _showQualityDialog = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _progressFocusNode.canRequestFocus) {
        _progressFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _tripleTimer?.cancel();
    _previewSeekClearTimer?.cancel();
    _progressFocusNode.dispose();
    _verticalScrollController.dispose();
    super.dispose();
  }

  void _startTriplePress(RecommendPlayerNotifier notifier) {
    _tripleTimer?.cancel();
    _tripleStartTime = DateTime.now();
    _isLongPressingLike = true;
    _tripleProgress = 0.0;
    setState(() {});

    _tripleTimer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      final elapsed =
          DateTime.now().difference(_tripleStartTime!).inMilliseconds;
      // 1500ms 蓄满
      final progress = (elapsed / 1500.0).clamp(0.0, 1.0);
      setState(() {
        _tripleProgress = progress;
      });

      if (progress >= 1.0) {
        timer.cancel();
        _tripleTimer = null;
        _isLongPressingLike = false;
        notifier.doTriple();
        _triggerTripleSuccess();
      }
    });
  }

  void _finishTriplePress(RecommendPlayerNotifier notifier) {
    if (_tripleProgress < 1.0 && _isLongPressingLike) {
      // 短按点赞
      notifier.toggleLike();
    }
    _tripleTimer?.cancel();
    _tripleTimer = null;
    setState(() {
      _isLongPressingLike = false;
      _tripleProgress = 0.0;
    });
  }

  void _triggerTripleSuccess() {
    setState(() {
      _showTripleSuccessHUD = true;
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showTripleSuccessHUD = false;
        });
      }
    });
  }

  void _onSeekRelative(int seconds, RecommendPlayerNotifier notifier,
      RecommendPlayerState state) {
    final cur = _previewSeekTarget ?? state.position;
    final maxDur = state.duration;
    final target = cur + Duration(seconds: seconds);
    final safeTarget = target < Duration.zero
        ? Duration.zero
        : (maxDur > Duration.zero && target > maxDur ? maxDur : target);

    setState(() {
      _previewSeekTarget = safeTarget;
    });

    _previewSeekClearTimer?.cancel();
    _previewSeekClearTimer = Timer(const Duration(milliseconds: 350), () {
      if (mounted && _previewSeekTarget != null) {
        notifier.seekTo(_previewSeekTarget!);
        setState(() {
          _previewSeekTarget = null;
        });
      }
    });
  }

  void _handleBack() {
    if (_showQualityDialog) {
      setState(() => _showQualityDialog = false);
      _progressFocusNode.requestFocus();
      return;
    }
    if (_showSettingsDialog) {
      setState(() => _showSettingsDialog = false);
      _progressFocusNode.requestFocus();
      return;
    }
    if (_verticalScrollController.hasClients &&
        _verticalScrollController.offset > 80) {
      _verticalScrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
      _progressFocusNode.requestFocus();
      return;
    }
    widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    final playerState = ref.watch(recommendPlayerProvider);
    final feedState = ref.watch(homeFeedProvider);
    final notifier = ref.read(recommendPlayerProvider.notifier);
    final videos = feedState.videos;

    final currentVideo = videos.isNotEmpty &&
            playerState.currentIndex < videos.length
        ? videos[playerState.currentIndex]
        : null;

    final title = currentVideo?.title ?? '推荐视频';
    final onlineCount = playerState.onlineCount.isNotEmpty
        ? '${playerState.onlineCount} 正在看'
        : '实时观看中';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (!BackNavigationDebounce.shouldHandle()) return;
        _handleBack();
      },
      child: Focus(
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent &&
              (event.logicalKey == LogicalKeyboardKey.escape ||
                  event.logicalKey == LogicalKeyboardKey.goBack)) {
            if (BackNavigationDebounce.shouldHandle()) {
              _handleBack();
              return KeyEventResult.handled;
            }
          }
          return KeyEventResult.ignored;
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
        // 背景渐变遮罩 (深邃微光电影感)
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.85),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.75),
                  Colors.black.withValues(alpha: 0.96),
                ],
                stops: const [0.0, 0.25, 0.65, 1.0],
              ),
            ),
          ),
        ),

        // ================= 顶部信息：标题与观看人数 =================
        Positioned(
          top: 36,
          left: 56,
          right: 56,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF00FF88),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    onlineCount,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 20),
                  if (currentVideo?.owner != null) ...[
                    const Icon(
                      Icons.person_pin_rounded,
                      size: 16,
                      color: TvTheme.biliPink,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      currentVideo!.owner!.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),

        // ================= 底部面板 (带露头与向下滚入合集) =================
        Positioned(
          left: 56,
          right: 56,
          bottom: 0,
          top: 150,
          child: ListView(
            controller: _verticalScrollController,
            children: [
              const SizedBox(height: 120),

              // 第一行：点赞（长按三连）、点踩、投币、收藏
              DpadRegion(
                horizontalEdge: DpadEdgeBehavior.stop,
                verticalEdge: DpadEdgeBehavior.leave,
                child: Row(
                  children: [
                    // 点赞按钮 (支持长按蓄力一键三连)
                    _LikeActionItem(
                      hasLike: playerState.hasLike,
                      isLongPressing: _isLongPressingLike,
                      progress: _tripleProgress,
                      onStartPress: () => _startTriplePress(notifier),
                      onFinishPress: () => _finishTriplePress(notifier),
                    ),
                    const SizedBox(width: 20),

                    // 点踩
                    _SimpleActionItem(
                      icon: Icons.thumb_down_rounded,
                      activeIcon: Icons.thumb_down_alt_rounded,
                      label: '点踩',
                      isActive: playerState.hasDislike,
                      onSelect: notifier.toggleDislike,
                    ),
                    const SizedBox(width: 20),

                    // 投币
                    _SimpleActionItem(
                      icon: Icons.monetization_on_outlined,
                      activeIcon: Icons.monetization_on_rounded,
                      label: '投币',
                      isActive: playerState.hasCoin,
                      onSelect: () => notifier.addCoin(multiply: 1),
                    ),
                    const SizedBox(width: 20),

                    // 收藏
                    _SimpleActionItem(
                      icon: Icons.star_border_rounded,
                      activeIcon: Icons.star_rounded,
                      label: '收藏',
                      isActive: playerState.hasFav,
                      onSelect: notifier.toggleFavorite,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 第二行：播放进度条 (默认落焦)
              DpadRegion(
                horizontalEdge: DpadEdgeBehavior.stop,
                verticalEdge: DpadEdgeBehavior.leave,
                child: _ProgressBarItem(
                  focusNode: _progressFocusNode,
                  position: _previewSeekTarget ?? playerState.position,
                  duration: playerState.duration,
                  isPlaying: playerState.isPlaying,
                  isBuffering: playerState.isBuffering,
                  onTogglePlay: notifier.togglePlay,
                  onSeekRelative: (secs) =>
                      _onSeekRelative(secs, notifier, playerState),
                ),
              ),
              const SizedBox(height: 24),

              // 第三行：快捷设置 (弹幕、画质、倍速、设置)
              DpadRegion(
                horizontalEdge: DpadEdgeBehavior.stop,
                verticalEdge: DpadEdgeBehavior.leave,
                child: Row(
                  children: [
                    // 弹幕开关
                    _QuickSettingItem(
                      icon: playerState.danmakuEnabled
                          ? Icons.subtitles_rounded
                          : Icons.subtitles_off_rounded,
                      label: playerState.danmakuEnabled ? '弹幕: 开' : '弹幕: 关',
                      isActive: playerState.danmakuEnabled,
                      onSelect: notifier.toggleDanmaku,
                    ),
                    const SizedBox(width: 16),

                    // 画质
                    _QuickSettingItem(
                      icon: Icons.high_quality_rounded,
                      label: _formatQualityLabel(playerState.currentQn),
                      isActive: false,
                      onSelect: () {
                        setState(() {
                          _showQualityDialog = true;
                        });
                      },
                    ),
                    const SizedBox(width: 16),

                    // 倍速
                    _QuickSettingItem(
                      icon: Icons.speed_rounded,
                      label: '${playerState.speed}x',
                      isActive: playerState.speed != 1.0,
                      onSelect: () {
                        final speeds = [0.75, 1.0, 1.25, 1.5, 2.0];
                        final curIdx = speeds.indexOf(playerState.speed);
                        final next = speeds[(curIdx + 1) % speeds.length];
                        notifier.changeSpeed(next);
                      },
                    ),
                    const SizedBox(width: 16),

                    // 设置 (连播/循环、弹幕调整)
                    _QuickSettingItem(
                      icon: Icons.tune_rounded,
                      label: '设置',
                      isActive: false,
                      onSelect: () {
                        setState(() {
                          _showSettingsDialog = true;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // ================= 第四行及后续：合集与作品 (默认露头) =================
              _CollectionsSection(
                ugcSeason: playerState.ugcSeason,
                upWorks: playerState.upWorks,
                relatedVideos: playerState.relatedVideos,
                onSelectVideo: (bvid) {
                  if (widget.onSelectVideo != null) {
                    widget.onSelectVideo!(bvid);
                  } else {
                    widget.onClose();
                  }
                },
              ),
              const SizedBox(height: 60),
            ],
          ),
        ),

        // 三连成功金色 HUD 动效
        if (_showTripleSuccessHUD)
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFFFFD700),
                  width: 2.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFD700).withValues(alpha: 0.4),
                    blurRadius: 36,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.auto_awesome_rounded,
                    color: Color(0xFFFFD700),
                    size: 32,
                  ),
                  SizedBox(width: 12),
                  Text(
                    '一键三连成功！',
                    style: TextStyle(
                      color: Color(0xFFFFD700),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

        // 画质选择弹层
        if (_showQualityDialog)
          _QualityDialog(
            qualities: playerState.qualities,
            currentQn: playerState.currentQn,
            onSelect: (qn) {
              notifier.changeQuality(qn);
              setState(() {
                _showQualityDialog = false;
              });
            },
            onClose: () => setState(() => _showQualityDialog = false),
          ),

        // 设置弹层 (连播/单曲循环、弹幕参数)
        if (_showSettingsDialog)
          _SettingsDialog(
            playMode: playerState.playMode,
            danmakuSize: playerState.danmakuSize,
            danmakuSpeed: playerState.danmakuSpeed,
            danmakuArea: playerState.danmakuArea,
            onSelectPlayMode: notifier.setPlayMode,
            onSelectDanmakuSize: notifier.setDanmakuSize,
            onSelectDanmakuSpeed: notifier.setDanmakuSpeed,
            onSelectDanmakuArea: notifier.setDanmakuArea,
            onClose: () => setState(() => _showSettingsDialog = false),
          ),
      ],
    ),
    ),
    );
  }

  String _formatQualityLabel(int qn) {
    switch (qn) {
      case 127:
        return '8K 超高清';
      case 120:
        return '4K 超清';
      case 116:
        return '1080P 60帧';
      case 80:
        return '1080P 高清';
      case 64:
        return '720P 高清';
      case 32:
        return '480P 清晰';
      default:
        return '$qn P';
    }
  }
}

/// 点赞按钮 (支持遥控器 OK 键长按蓄力三连动画)
class _LikeActionItem extends StatelessWidget {
  final bool hasLike;
  final bool isLongPressing;
  final double progress;
  final VoidCallback onStartPress;
  final VoidCallback onFinishPress;

  const _LikeActionItem({
    required this.hasLike,
    required this.isLongPressing,
    required this.progress,
    required this.onStartPress,
    required this.onFinishPress,
  });

  @override
  Widget build(BuildContext context) {
    return Focus(
      onKeyEvent: (node, event) {
        if (event.logicalKey == LogicalKeyboardKey.select ||
            event.logicalKey == LogicalKeyboardKey.enter) {
          if (event is KeyDownEvent) {
            onStartPress();
            return KeyEventResult.handled;
          } else if (event is KeyUpEvent) {
            onFinishPress();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: DpadFocusable(
        onSelect: () {},
        child: Container(
          width: 140,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: hasLike
                ? TvTheme.biliPink.withValues(alpha: 0.25)
                : Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: hasLike
                  ? TvTheme.biliPink
                  : (isLongPressing
                      ? const Color(0xFFFFD700)
                      : Colors.white.withValues(alpha: 0.15)),
              width: 1.5,
            ),
          ),
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              // 蓄力进度背景层 (按住时逐渐变满)
              if (isLongPressing)
                Positioned.fill(
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progress,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD700).withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),

              // 内容前景色
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    hasLike
                        ? Icons.thumb_up_alt_rounded
                        : Icons.thumb_up_rounded,
                    size: 18,
                    color: hasLike
                        ? TvTheme.biliPink
                        : (isLongPressing ? const Color(0xFFFFD700) : Colors.white),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isLongPressing ? '蓄力三连...' : (hasLike ? '已点赞' : '点赞'),
                    style: TextStyle(
                      color: hasLike
                          ? TvTheme.biliPink
                          : (isLongPressing ? const Color(0xFFFFD700) : Colors.white),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 底部简单操作按钮 (点踩、投币、收藏)
class _SimpleActionItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onSelect;

  const _SimpleActionItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return DpadFocusable(
      onSelect: onSelect,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isActive
              ? TvTheme.biliPink.withValues(alpha: 0.22)
              : Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? TvTheme.biliPink : Colors.white.withValues(alpha: 0.15),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              size: 18,
              color: isActive ? TvTheme.biliPink : Colors.white,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isActive ? TvTheme.biliPink : Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 播放进度条组件 (获得默认落焦点)
class _ProgressBarItem extends StatelessWidget {
  final FocusNode focusNode;
  final Duration position;
  final Duration duration;
  final bool isPlaying;
  final bool isBuffering;
  final VoidCallback onTogglePlay;
  final ValueChanged<int> onSeekRelative;

  const _ProgressBarItem({
    required this.focusNode,
    required this.position,
    required this.duration,
    required this.isPlaying,
    required this.isBuffering,
    required this.onTogglePlay,
    required this.onSeekRelative,
  });

  @override
  Widget build(BuildContext context) {
    final double progress = duration.inMilliseconds > 0
        ? (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0)
        : 0.0;

    return Focus(
      focusNode: focusNode,
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
            onSeekRelative(-10);
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
            onSeekRelative(10);
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.select ||
              event.logicalKey == LogicalKeyboardKey.enter) {
            onTogglePlay();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: DpadFocusable(
        onSelect: onTogglePlay,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.15),
              width: 1.0,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 时间戳与播放状态
              Row(
                children: [
                  Icon(
                    isPlaying
                        ? Icons.pause_circle_rounded
                        : Icons.play_circle_rounded,
                    size: 22,
                    color: TvTheme.biliPink,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    Formatters.formatDuration(position.inSeconds),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Text(
                    ' / ',
                    style: TextStyle(color: Colors.white38, fontSize: 14),
                  ),
                  Text(
                    Formatters.formatDuration(duration.inSeconds),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    '左右方向键快进快退 · OK键播放/暂停',
                    style: TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 进度条槽
              LayoutBuilder(
                builder: (context, constraints) {
                  return Stack(
                    children: [
                      // 背景条
                      Container(
                        height: 6,
                        width: constraints.maxWidth,
                        decoration: BoxDecoration(
                          color: Colors.white12,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      // 播放进度
                      Container(
                        height: 6,
                        width: constraints.maxWidth * progress,
                        decoration: BoxDecoration(
                          color: TvTheme.biliPink,
                          borderRadius: BorderRadius.circular(3),
                          boxShadow: [
                            BoxShadow(
                              color: TvTheme.biliPink.withValues(alpha: 0.6),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 第三行快捷设置项 (弹幕、画质、倍速、设置)
class _QuickSettingItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onSelect;

  const _QuickSettingItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return DpadFocusable(
      onSelect: onSelect,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? TvTheme.biliPink.withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive ? TvTheme.biliPink : Colors.white12,
            width: 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive ? TvTheme.biliPink : Colors.white,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isActive ? TvTheme.biliPink : Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 第四行及后续：合集、他的作品、相关合集横向滚动行
class _CollectionsSection extends StatelessWidget {
  final dynamic ugcSeason;
  final List<VideoItemModel> upWorks;
  final List<VideoItemModel> relatedVideos;
  final ValueChanged<String> onSelectVideo;

  const _CollectionsSection({
    required this.ugcSeason,
    required this.upWorks,
    required this.relatedVideos,
    required this.onSelectVideo,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. 合集 (如果存在)
        if (ugcSeason != null && ugcSeason.items.isNotEmpty) ...[
          _HorizontalCollectionRow(
            title: '合集 · ${ugcSeason.title}',
            items: ugcSeason.items,
            onSelect: onSelectVideo,
          ),
          const SizedBox(height: 24),
        ],

        // 2. 他的作品
        if (upWorks.isNotEmpty) ...[
          _HorizontalCollectionRow(
            title: '他的作品',
            items: upWorks,
            onSelect: onSelectVideo,
          ),
          const SizedBox(height: 24),
        ],

        // 3. 相关推荐合集 / 视频
        if (relatedVideos.isNotEmpty) ...[
          _HorizontalCollectionRow(
            title: '相关推荐',
            items: relatedVideos,
            onSelect: onSelectVideo,
          ),
        ],
      ],
    );
  }
}

class _HorizontalCollectionRow extends StatelessWidget {
  final String title;
  final List<VideoItemModel> items;
  final ValueChanged<String> onSelect;

  const _HorizontalCollectionRow({
    required this.title,
    required this.items,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return DpadRegion(
      horizontalEdge: DpadEdgeBehavior.stop,
      verticalEdge: DpadEdgeBehavior.leave,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            height: 120,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              separatorBuilder: (context, index) => const SizedBox(width: 14),
              itemBuilder: (context, index) {
                final item = items[index];
                return DpadFocusable(
                  onSelect: () => onSelect(item.bvid),
                  child: Container(
                    width: 180,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                          child: AspectRatio(
                            aspectRatio: 16 / 9,
                            child: TvImage(imageUrl: item.pic),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 4,
                          ),
                          child: Text(
                            item.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// 画质选择浮层对话框
class _QualityDialog extends StatelessWidget {
  final List<VideoQualityItem> qualities;
  final int currentQn;
  final ValueChanged<int> onSelect;
  final VoidCallback onClose;

  const _QualityDialog({
    required this.qualities,
    required this.currentQn,
    required this.onSelect,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 320,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '画质选择',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...qualities.map((q) {
              final isCur = q.qn == currentQn;
              return DpadFocusable(
                onSelect: () => onSelect(q.qn),
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isCur
                        ? TvTheme.biliPink.withValues(alpha: 0.22)
                        : Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isCur ? TvTheme.biliPink : Colors.transparent,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        q.desc,
                        style: TextStyle(
                          color: isCur ? TvTheme.biliPink : Colors.white,
                          fontSize: 14,
                          fontWeight:
                              isCur ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      const Spacer(),
                      if (isCur)
                        const Icon(
                          Icons.check_rounded,
                          color: TvTheme.biliPink,
                          size: 16,
                        ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

/// 设置弹层 (连播方式、弹幕参数调节)
class _SettingsDialog extends StatelessWidget {
  final TvPlayMode playMode;
  final double danmakuSize;
  final double danmakuSpeed;
  final double danmakuArea;
  final ValueChanged<TvPlayMode> onSelectPlayMode;
  final ValueChanged<double> onSelectDanmakuSize;
  final ValueChanged<double> onSelectDanmakuSpeed;
  final ValueChanged<double> onSelectDanmakuArea;
  final VoidCallback onClose;

  const _SettingsDialog({
    required this.playMode,
    required this.danmakuSize,
    required this.danmakuSpeed,
    required this.danmakuArea,
    required this.onSelectPlayMode,
    required this.onSelectDanmakuSize,
    required this.onSelectDanmakuSpeed,
    required this.onSelectDanmakuArea,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 380,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.94),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  '播放器设置',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                DpadFocusable(
                  onSelect: onClose,
                  child: const Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Icon(Icons.close_rounded,
                        size: 20, color: Colors.white70),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 播放模式
            const Text(
              '播放方式',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                DpadFocusable(
                  onSelect: () => onSelectPlayMode(TvPlayMode.sequence),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: playMode == TvPlayMode.sequence
                          ? TvTheme.biliPink.withValues(alpha: 0.25)
                          : Colors.white10,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: playMode == TvPlayMode.sequence
                            ? TvTheme.biliPink
                            : Colors.transparent,
                      ),
                    ),
                    child: const Text('顺序连播',
                        style: TextStyle(color: Colors.white, fontSize: 13)),
                  ),
                ),
                const SizedBox(width: 12),
                DpadFocusable(
                  onSelect: () => onSelectPlayMode(TvPlayMode.loopSingle),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: playMode == TvPlayMode.loopSingle
                          ? TvTheme.biliPink.withValues(alpha: 0.25)
                          : Colors.white10,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: playMode == TvPlayMode.loopSingle
                            ? TvTheme.biliPink
                            : Colors.transparent,
                      ),
                    ),
                    child: const Text('单集循环',
                        style: TextStyle(color: Colors.white, fontSize: 13)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 弹幕设置
            const Text(
              '弹幕字号',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildSizePill('小', 0.8, danmakuSize, onSelectDanmakuSize),
                const SizedBox(width: 8),
                _buildSizePill('标准', 1.0, danmakuSize, onSelectDanmakuSize),
                const SizedBox(width: 8),
                _buildSizePill('大', 1.3, danmakuSize, onSelectDanmakuSize),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSizePill(String label, double val, double cur,
      ValueChanged<double> onSelect) {
    final isCur = (cur - val).abs() < 0.05;
    return DpadFocusable(
      onSelect: () => onSelect(val),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isCur
              ? TvTheme.biliPink.withValues(alpha: 0.25)
              : Colors.white10,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isCur ? TvTheme.biliPink : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ),
    );
  }
}

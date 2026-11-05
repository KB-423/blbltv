import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dpad/dpad.dart';
import 'package:go_router/go_router.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../../../../core/theme/tv_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../models/video/video_item_model.dart';
import '../../../../widgets/tv_image.dart';
import '../../../main/presentation/providers/nav_rail_focus_provider.dart';
import '../../../player/presentation/providers/player_provider.dart';
import '../providers/home_provider.dart';

/// TV 全新沉浸纯享首页 (开屏即开播、上下切流、5秒自动隐退纯享、按键自愈唤醒)
class TvImmersiveHomeScreen extends ConsumerStatefulWidget {
  final VoidCallback onSwitchToGrid;

  const TvImmersiveHomeScreen({
    super.key,
    required this.onSwitchToGrid,
  });

  @override
  ConsumerState<TvImmersiveHomeScreen> createState() =>
      _TvImmersiveHomeScreenState();
}

class _TvImmersiveHomeScreenState extends ConsumerState<TvImmersiveHomeScreen> {
  int _currentIndex = 0;
  bool _isPureMode = false;
  Timer? _pureModeTimer;

  final FocusNode _pureFocusNode = FocusNode(debugLabel: 'ImmersivePureFocus');
  final FocusNode _stripFocusNode = FocusNode(debugLabel: 'ImmersiveStripFocus');

  @override
  void initState() {
    super.initState();
    _startPureModeTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _stripFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _pureModeTimer?.cancel();
    _pureFocusNode.dispose();
    _stripFocusNode.dispose();
    final videos = ref.read(homeFeedProvider).videos;
    if (videos.isNotEmpty && _currentIndex >= 0 && _currentIndex < videos.length) {
      try {
        ref.read(playerProvider(videos[_currentIndex].bvid).notifier).disposePlayer();
      } catch (_) {}
    }
    super.dispose();
  }

  void _startPureModeTimer() {
    _pureModeTimer?.cancel();
    _pureModeTimer = Timer(const Duration(seconds: 5), () {
      if (mounted && !_isPureMode) {
        setState(() {
          _isPureMode = true;
        });
        _pureFocusNode.requestFocus();
      }
    });
  }

  void _wakeUpFromPureMode() {
    _pureModeTimer?.cancel();
    if (_isPureMode) {
      setState(() {
        _isPureMode = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _stripFocusNode.requestFocus();
        }
      });
    }
    _startPureModeTimer();
  }

  void _switchNext(List<VideoItemModel> videos) {
    if (videos.isEmpty) return;
    if (_currentIndex < videos.length - 1) {
      try {
        ref
            .read(playerProvider(videos[_currentIndex].bvid).notifier)
            .disposePlayer();
      } catch (_) {}
      setState(() {
        _currentIndex++;
      });
      _startPureModeTimer();
    } else {
      // 触底自动拉取下一页
      ref.read(homeFeedProvider.notifier).loadMore();
    }
  }

  void _switchPrev(List<VideoItemModel> videos) {
    if (_currentIndex > 0 && videos.isNotEmpty) {
      try {
        ref
            .read(playerProvider(videos[_currentIndex].bvid).notifier)
            .disposePlayer();
      } catch (_) {}
      setState(() {
        _currentIndex--;
      });
      _startPureModeTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    final feedState = ref.watch(homeFeedProvider);
    final videos = feedState.videos;

    if (videos.isEmpty) {
      return Center(
        child: feedState.isLoading
            ? const CircularProgressIndicator(
                strokeWidth: 3.0,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.cloud_off_rounded,
                      size: 48, color: Colors.white38),
                  const SizedBox(height: 12),
                  const Text('暂无推荐视频，请稍后重试',
                      style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 16),
                  DpadFocusable(
                    autofocus: true,
                    onSelect: () =>
                        ref.read(homeFeedProvider.notifier).refresh(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white12,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text('重试刷新',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
      );
    }

    final safeIndex = _currentIndex.clamp(0, videos.length - 1);
    final currentVideo = videos[safeIndex];

    final playerState = ref.watch(playerProvider(currentVideo.bvid));
    final playerNotifier =
        ref.read(playerProvider(currentVideo.bvid).notifier);
    final videoController = playerNotifier.videoController;

    return Focus(
      focusNode: _pureFocusNode,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          // 纯享模式下按任意键唤醒侧边悬浮滑轨
          if (_isPureMode) {
            _wakeUpFromPureMode();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. 底层全屏满幅开播层 (硬件加速无缝渲染)
          GestureDetector(
            onTap: _wakeUpFromPureMode,
            child: Container(
              color: Colors.black,
              child: Center(
                child: videoController != null
                    ? Video(
                        controller: videoController,
                        controls: NoVideoControls,
                        fit: BoxFit.cover,
                      )
                    : Stack(
                        fit: StackFit.expand,
                        children: [
                          TvImage(
                            imageUrl: currentVideo.pic,
                            fit: BoxFit.cover,
                          ),
                          Container(color: Colors.black45),
                          const Center(
                            child: SizedBox(
                              width: 36,
                              height: 36,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.8,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white70),
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),

          // 2. 纯享微暗渐变边衬 (保证大屏远距离下文字清晰，不破坏全屏通透感)
          IgnorePointer(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 350),
              opacity: _isPureMode ? 0.0 : 1.0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.black.withValues(alpha: 0.82),
                      Colors.black.withValues(alpha: 0.45),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.42, 0.85],
                  ),
                ),
              ),
            ),
          ),

          // 3. 侧边悬浮微光推荐滑道 (Float Recommend Strip)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutCubic,
            left: _isPureMode ? -440 : 16,
            top: 20,
            bottom: 20,
            width: 380,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: _isPureMode ? 0.0 : 1.0,
              child: DpadRegion(
                horizontalEdge: DpadEdgeBehavior.stop,
                verticalEdge: DpadEdgeBehavior.stop,
                child: Focus(
                  focusNode: _stripFocusNode,
                  onKeyEvent: (node, event) {
                    if (event is KeyDownEvent) {
                      _startPureModeTimer();

                      // 向下切流
                      if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
                        _switchNext(videos);
                        return KeyEventResult.handled;
                      }
                      // 向上切流
                      if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
                        _switchPrev(videos);
                        return KeyEventResult.handled;
                      }
                      // 向左键：切回左侧导轨
                      if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
                        ref
                            .read(navRailFocusServiceProvider)
                            .focusSelected();
                        return KeyEventResult.handled;
                      }
                      // OK 键：直接淡出进入纯享播放
                      if (event.logicalKey == LogicalKeyboardKey.select ||
                          event.logicalKey == LogicalKeyboardKey.enter) {
                        setState(() {
                          _isPureMode = true;
                        });
                        _pureFocusNode.requestFocus();
                        return KeyEventResult.handled;
                      }
                    }
                    return KeyEventResult.ignored;
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 22, vertical: 20),
                    decoration: BoxDecoration(
                      color: const Color(0x28000000),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: TvTheme.tvGlassBorder,
                        width: 0.8,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.35),
                          blurRadius: 28,
                          offset: const Offset(4, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 顶部操作行：极简模式胶囊 + 网格切换按钮
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.25),
                                  width: 0.8,
                                ),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.play_circle_fill_rounded,
                                      size: 13, color: Colors.white),
                                  SizedBox(width: 5),
                                  Text(
                                    '正在播映',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            DpadFocusable(
                              onSelect: () {
                                try {
                                  ref
                                      .read(playerProvider(currentVideo.bvid).notifier)
                                      .disposePlayer();
                                } catch (_) {}
                                widget.onSwitchToGrid();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: TvTheme.tvGlassBorder,
                                    width: 0.8,
                                  ),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.grid_view_rounded,
                                        size: 13, color: Colors.white70),
                                    SizedBox(width: 4),
                                    Text(
                                      '网格浏览',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),

                        // 当前视频标题
                        Text(
                          currentVideo.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // UP 主与播放元数据
                        Row(
                          children: [
                            const Icon(Icons.person_outline_rounded,
                                size: 14, color: Colors.white60),
                            const SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                currentVideo.owner?.name ?? '未知UP主',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Icon(Icons.play_arrow_outlined,
                                size: 14, color: Colors.white60),
                            const SizedBox(width: 3),
                            Text(
                              Formatters.formatCount(
                                  currentVideo.stat?.view ?? 0),
                              style: const TextStyle(
                                color: Colors.white60,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // 实时进度条
                        ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: LinearProgressIndicator(
                            value: playerState.duration.inMilliseconds > 0
                                ? (playerState.position.inMilliseconds /
                                        playerState.duration.inMilliseconds)
                                    .clamp(0.0, 1.0)
                                : 0.0,
                            minHeight: 3.5,
                            backgroundColor: Colors.white12,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        ),

                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              Formatters.formatDuration(
                                  playerState.position.inSeconds),
                              style: const TextStyle(
                                color: Colors.white60,
                                fontSize: 11,
                                fontFamily: 'monospace',
                              ),
                            ),
                            Text(
                              Formatters.formatDuration(
                                  playerState.duration.inSeconds),
                              style: const TextStyle(
                                color: Colors.white60,
                                fontSize: 11,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),
                        const Divider(
                            color: Color(0x18FFFFFF), height: 1),
                        const SizedBox(height: 14),

                        // 遥控器切流提示
                        Row(
                          children: [
                            const Icon(Icons.unfold_more_rounded,
                                size: 16, color: Colors.white54),
                            const SizedBox(width: 6),
                            const Text(
                              '按遥控器上下键切流 · OK纯享全屏',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 11.5,
                              ),
                            ),
                            const Spacer(),
                            // 全屏播放器独立入口
                            DpadFocusable(
                              onSelect: () {
                                try {
                                  ref
                                      .read(playerProvider(currentVideo.bvid).notifier)
                                      .disposePlayer();
                                } catch (_) {}
                                context.push(
                                    '/player/${currentVideo.bvid}');
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.white10,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.fullscreen_rounded,
                                        size: 14, color: Colors.white70),
                                    SizedBox(width: 3),
                                    Text('全屏',
                                        style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 11)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        // 后续推荐微卡列表
                        Expanded(
                          child: ListView.separated(
                            itemCount: (videos.length - safeIndex - 1)
                                .clamp(0, 5),
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, idx) {
                              final nextVideo =
                                  videos[safeIndex + 1 + idx];
                              return Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.1),
                                    width: 0.8,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: SizedBox(
                                        width: 72,
                                        height: 44,
                                        child: TvImage(
                                          imageUrl: nextVideo.pic,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            nextVideo.title,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            nextVideo.owner?.name ?? '',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              color: Colors.white54,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


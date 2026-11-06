import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dpad/dpad.dart';
import 'package:go_router/go_router.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../models/video/video_item_model.dart';
import '../../../../widgets/glass_container.dart';
import '../../../../widgets/tv_image.dart';
import '../../../main/presentation/providers/nav_rail_focus_provider.dart';
import '../../../player/presentation/providers/player_provider.dart';
import '../providers/home_provider.dart';

/// TV 全新沉浸纯享首页 (Apple TV Liquid Glass 风格)
/// 交互与视觉架构：
/// 1. 开屏即开播：底层全屏渲染当前推荐视频流
/// 2. 悬浮无界毛玻璃：左侧浮空导轨 + 导轨右侧并列浮空推荐流 (GlassContainer 景深模糊)
/// 3. 遥控器直觉交互：上下键无缝切流、左键直达导轨、OK键纯享全屏
/// 4. 纯享防打扰：5 秒无操作或按 OK 键，导轨与推荐流同步淡出隐退，进入纯粹大屏影音观赏
/// 5. 按键自愈唤醒：任意遥控器按键立即唤醒并交接回焦点
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
  String? _activeBvid;

  final FocusNode _pureFocusNode =
      FocusNode(debugLabel: 'ImmersivePureFocus');
  final FocusNode _stripFocusNode =
      FocusNode(debugLabel: 'ImmersiveStripFocus');

  @override
  void initState() {
    super.initState();
    _startPureModeTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(navRailVisibilityProvider.notifier).setVisible(true);
        _stripFocusNode.requestFocus();
      }
    });
  }

  @override
  void deactivate() {
    if (_activeBvid != null) {
      try {
        ref.read(playerProvider(_activeBvid!).notifier).disposePlayer();
      } catch (_) {}
    }
    super.deactivate();
  }

  @override
  void dispose() {
    _pureModeTimer?.cancel();
    _pureFocusNode.dispose();
    _stripFocusNode.dispose();
    super.dispose();
  }

  void _startPureModeTimer() {
    _pureModeTimer?.cancel();
    _pureModeTimer = Timer(const Duration(seconds: 5), () {
      if (mounted && !_isPureMode) {
        _enterPureMode();
      }
    });
  }

  void _enterPureMode() {
    setState(() {
      _isPureMode = true;
    });
    ref.read(navRailVisibilityProvider.notifier).setVisible(false);
    _pureFocusNode.requestFocus();
  }

  void _wakeUpFromPureMode() {
    _pureModeTimer?.cancel();
    if (_isPureMode) {
      setState(() {
        _isPureMode = false;
      });
      ref.read(navRailVisibilityProvider.notifier).setVisible(true);
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
    final size = MediaQuery.of(context).size;
    final bool isCompact = size.width <= 1000 || size.height <= 650;

    // 导轨与推荐流的相对布局间距
    final double streamLeft = isCompact ? 172.0 : 196.0;
    final double streamWidth = isCompact ? 350.0 : 396.0;

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
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.refresh_rounded,
                              size: 16, color: Colors.white70),
                          SizedBox(width: 6),
                          Text('换一批',
                              style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      );
    }

    final safeIndex = _currentIndex.clamp(0, videos.length - 1);
    final currentVideo = videos[safeIndex];
    _activeBvid = currentVideo.bvid;

    final playerState = ref.watch(playerProvider(currentVideo.bvid));
    final playerNotifier =
        ref.read(playerProvider(currentVideo.bvid).notifier);
    final videoController = playerNotifier.videoController;

    return Focus(
      focusNode: _pureFocusNode,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
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
          // 1. 底层满屏全屏开播层 (硬件解码视频 + 缓冲封面平滑渐隐过渡)
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

          // 2. 左侧影院级微暗渐变边衬 (保证大屏远距离下文字与毛玻璃边缘对比度，不影响画面主体)
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
                      Colors.black.withValues(alpha: 0.85),
                      Colors.black.withValues(alpha: 0.50),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.45, 0.88],
                  ),
                ),
              ),
            ),
          ),

          // 3. 导航旁边悬浮的毛玻璃推荐流 (Floating Liquid Glass Recommend Feed)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutCubic,
            left: _isPureMode ? -(streamWidth + 60) : streamLeft,
            top: isCompact ? 16 : 20,
            bottom: isCompact ? 16 : 20,
            width: streamWidth,
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

                      // 向下切换下一个视频
                      if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
                        _switchNext(videos);
                        return KeyEventResult.handled;
                      }
                      // 向上切换上一个视频
                      if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
                        _switchPrev(videos);
                        return KeyEventResult.handled;
                      }
                      // 向左键：平滑跨界回左侧导航导轨
                      if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
                        ref
                            .read(navRailFocusServiceProvider)
                            .focusSelected();
                        return KeyEventResult.handled;
                      }
                      // OK 键：隐退控制面板，开启纯享播放
                      if (event.logicalKey == LogicalKeyboardKey.select ||
                          event.logicalKey == LogicalKeyboardKey.enter) {
                        _enterPureMode();
                        return KeyEventResult.handled;
                      }
                    }
                    return KeyEventResult.ignored;
                  },
                  child: GlassContainer(
                    blur: 24.0,
                    opacity: 0.16,
                    borderOpacity: 0.32,
                    borderRadius: BorderRadius.circular(24),
                    padding: EdgeInsets.symmetric(
                      horizontal: isCompact ? 16 : 20,
                      vertical: isCompact ? 16 : 20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 顶部控制行：正在播映微光胶囊 + 换一批 + 网格浏览入口
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.30),
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
                            const Spacer(),
                            // 换一批刷新按钮 (纯白微光胶囊)
                            DpadFocusable(
                              onSelect: () =>
                                  ref.read(homeFeedProvider.notifier).refresh(),
                              builder: (context, state, child) {
                                final isFocused = state.focused;
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 9, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isFocused
                                        ? Colors.white.withValues(alpha: 0.28)
                                        : Colors.white.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: isFocused
                                          ? Colors.white
                                          : Colors.white.withValues(alpha: 0.2),
                                      width: isFocused ? 1.4 : 0.8,
                                    ),
                                  ),
                                  child: child,
                                );
                              },
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.refresh_rounded,
                                      size: 13, color: Colors.white70),
                                  SizedBox(width: 4),
                                  Text(
                                    '换一批',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            // 网格浏览切换按钮
                            DpadFocusable(
                              onSelect: () {
                                try {
                                  ref
                                      .read(playerProvider(currentVideo.bvid)
                                          .notifier)
                                      .disposePlayer();
                                } catch (_) {}
                                widget.onSwitchToGrid();
                              },
                              builder: (context, state, child) {
                                final isFocused = state.focused;
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 9, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isFocused
                                        ? Colors.white.withValues(alpha: 0.28)
                                        : Colors.white.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: isFocused
                                          ? Colors.white
                                          : Colors.white.withValues(alpha: 0.2),
                                      width: isFocused ? 1.4 : 0.8,
                                    ),
                                  ),
                                  child: child,
                                );
                              },
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.grid_view_rounded,
                                      size: 13, color: Colors.white70),
                                  SizedBox(width: 4),
                                  Text(
                                    '网格',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // 当前视频标题 (纯净纯白排版)
                        Text(
                          currentVideo.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            height: 1.3,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // UP 主与播放量元数据
                        Row(
                          children: [
                            const Icon(Icons.person_outline_rounded,
                                size: 14, color: Colors.white70),
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

                        // 实时播放进度条
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

                        const SizedBox(height: 14),
                        const Divider(
                            color: Color(0x22FFFFFF), height: 1),
                        const SizedBox(height: 12),

                        // 遥控器提示与全屏播放器独立入口
                        Row(
                          children: [
                            const Icon(Icons.unfold_more_rounded,
                                size: 15, color: Colors.white54),
                            const SizedBox(width: 5),
                            const Text(
                              '上下键切流 · OK纯享',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 11.5,
                              ),
                            ),
                            const Spacer(),
                            DpadFocusable(
                              onSelect: () {
                                try {
                                  ref
                                      .read(playerProvider(currentVideo.bvid)
                                          .notifier)
                                      .disposePlayer();
                                } catch (_) {}
                                context.push('/player/${currentVideo.bvid}');
                              },
                              builder: (context, state, child) {
                                final isFocused = state.focused;
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: isFocused
                                        ? Colors.white.withValues(alpha: 0.3)
                                        : Colors.white.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: isFocused
                                          ? Colors.white
                                          : Colors.transparent,
                                      width: 1.0,
                                    ),
                                  ),
                                  child: child,
                                );
                              },
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.fullscreen_rounded,
                                      size: 13, color: Colors.white70),
                                  SizedBox(width: 3),
                                  Text('全功能播放器',
                                      style: TextStyle(
                                          color: Colors.white70, fontSize: 11)),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // 推荐片单队列 (Upcoming Playlist)
                        Expanded(
                          child: ListView.separated(
                            itemCount: (videos.length - safeIndex - 1)
                                .clamp(0, 5),
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 8),
                            itemBuilder: (context, idx) {
                              final nextVideo =
                                  videos[safeIndex + 1 + idx];
                              return Container(
                                padding: const EdgeInsets.all(7),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.06),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color:
                                        Colors.white.withValues(alpha: 0.12),
                                    width: 0.8,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: SizedBox(
                                        width: 68,
                                        height: 42,
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

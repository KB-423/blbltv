import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../../../../core/theme/tv_theme.dart';
import '../../../../core/utils/back_navigation_debounce.dart';
import '../../../../widgets/tv_status_view.dart';
import '../../../main/presentation/providers/nav_rail_focus_provider.dart';
import '../providers/home_provider.dart';
import '../providers/home_state.dart';
import '../providers/recommend_player_provider.dart';
import '../providers/recommend_player_state.dart';
import '../widgets/tv_recommend_control_overlay.dart';
import '../widgets/tv_recommend_rail.dart';

/// TV 沉浸式全屏推荐页
/// 核心架构与交互：
/// 1. 底层：全屏背景硬件加速视频播放器（默认起播首个视频）
/// 2. 左侧：悬浮推荐视频流导轨 (`TvRecommendRail`)，向下浏览时精简顶栏
/// 3. 沉浸：3秒静止或OK触发全屏纯享播放，隐藏列表与顶栏
/// 4. 切台：纯享播放状态按上下键直接切换上一个/下一个视频（保持纯享不唤出列表）
/// 5. 控制：按确定键 (OK) 呼出全功能控制面板 (`TvRecommendControlOverlay`)，首焦锁定在进度条，支持长按一键三连与合集浏览
/// 6. 多级返回：控制面板 -> 退出纯享恢复列表 -> 切回顶部导航栏（保留下部卡片焦点记忆）
class TvHomeScreen extends ConsumerStatefulWidget {
  const TvHomeScreen({super.key});

  @override
  ConsumerState<TvHomeScreen> createState() => _TvHomeScreenState();
}

class _TvHomeScreenState extends ConsumerState<TvHomeScreen> {
  final FocusNode _playerFocusNode = FocusNode(debugLabel: 'HomeScreenPlayerFocus');
  final FocusNode _railActiveFocusNode = FocusNode(debugLabel: 'HomeScreenRailActiveCardFocus');

  bool _showChannelHUD = false;
  Timer? _channelHudTimer;
  RecommendPlayerNotifier? _playerNotifier;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _playerNotifier = ref.read(recommendPlayerProvider.notifier);
  }

  @override
  void dispose() {
    _channelHudTimer?.cancel();
    _playerFocusNode.dispose();
    _railActiveFocusNode.dispose();
    // 切换离开推荐页时切断播放器音频
    _playerNotifier?.pauseAndStopAudio();
    super.dispose();
  }

  void _triggerChannelHUD() {
    _channelHudTimer?.cancel();
    setState(() {
      _showChannelHUD = true;
    });
    _channelHudTimer = Timer(const Duration(milliseconds: 1800), () {
      if (mounted) {
        setState(() {
          _showChannelHUD = false;
        });
      }
    });
  }

  KeyEventResult _handlePurePlaybackKey(KeyEvent event, RecommendPlayerNotifier notifier) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    final key = event.logicalKey;

    // 上方向键：切换上一个视频
    if (key == LogicalKeyboardKey.arrowUp) {
      notifier.playPrevious();
      _triggerChannelHUD();
      return KeyEventResult.handled;
    }

    // 下方向键：切换下一个视频
    if (key == LogicalKeyboardKey.arrowDown) {
      notifier.playNext();
      _triggerChannelHUD();
      return KeyEventResult.handled;
    }

    // OK / Select / Enter / 左右方向键：呼出控制面板 (默认落焦进度条)
    if (key == LogicalKeyboardKey.select ||
        key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.gameButtonA ||
        key == LogicalKeyboardKey.arrowLeft ||
        key == LogicalKeyboardKey.arrowRight) {
      notifier.openControls();
      return KeyEventResult.handled;
    }

    // 返回键 / Escape：退出纯享模式，唤醒被隐藏的左侧推荐列表与顶部栏
    if (key == LogicalKeyboardKey.escape || key == LogicalKeyboardKey.goBack) {
      if (BackNavigationDebounce.shouldHandle()) {
        notifier.exitPurePlayback();
        return KeyEventResult.handled;
      }
    }

    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final feedState = ref.watch(homeFeedProvider);
    final playerState = ref.watch(recommendPlayerProvider);
    final notifier = ref.read(recommendPlayerProvider.notifier);
    final navService = ref.read(navRailFocusServiceProvider);

    // 监听状态自动交接焦点
    ref.listen(recommendPlayerProvider, (prev, next) {
      // 1. 进入纯享且无控制层时，立即自愈聚焦全屏播放器按键节点
      if (next.isPurePlayback && !next.showControls) {
        if (prev == null || !prev.isPurePlayback || prev.showControls) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && _playerFocusNode.canRequestFocus) {
              _playerFocusNode.requestFocus();
            }
          });
        }
      }
      // 2. 退出纯享时，焦点恢复至左侧推荐列表当前正在播放的卡片
      if (!next.isPurePlayback && !next.showControls) {
        if (prev != null && prev.isPurePlayback) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && _railActiveFocusNode.canRequestFocus) {
              _railActiveFocusNode.requestFocus();
            }
          });
        }
      }
    });

    if (feedState.isLoading && feedState.videos.isEmpty) {
      return const Scaffold(
        backgroundColor: TvTheme.tvBackground,
        body: TvLoadingView(message: '正在为您推荐精彩内容...'),
      );
    }

    if (feedState.error != null && feedState.videos.isEmpty) {
      return Scaffold(
        backgroundColor: TvTheme.tvBackground,
        body: TvErrorView(
          error: feedState.error!,
          onRetry: () => ref.read(homeFeedProvider.notifier).refresh(),
        ),
      );
    }

    final isRailVisible = !playerState.isPurePlayback && !playerState.showControls;
    final canPopToShell =
        !playerState.showControls && !playerState.isPurePlayback && navService.isNavRailFocused;

    return PopScope(
      canPop: canPopToShell,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (!BackNavigationDebounce.shouldHandle()) return;

        // 1. 若控制面板打开，关闭控制面板
        if (playerState.showControls) {
          notifier.closeControls();
          return;
        }

        // 2. 若处于纯享播放，先退出纯享，恢复左侧列表与顶部栏
        if (playerState.isPurePlayback) {
          notifier.exitPurePlayback();
          return;
        }

        // 3. 若列表可见但焦点在列表，先恢复顶栏全显，再平滑交接回顶部导航栏「推荐」Tab (保留下方列表记忆)
        if (!navService.isNavRailFocused) {
          ref.read(topBarDisplayModeProvider.notifier).showFull();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              navService.focusSelected();
            }
          });
          return;
        }
      },
      child: Scaffold(
        backgroundColor: TvTheme.tvBackground,
        body: Stack(
          fit: StackFit.expand,
          children: [
            // 1. 全屏背景视频播放器渲染层
            _buildVideoLayer(playerState, notifier),

            // 2. 纯享模式上下键即时切台按键监听节点 (无遮罩零延迟)
            if (playerState.isPurePlayback && !playerState.showControls)
              Positioned.fill(
                child: Focus(
                  focusNode: _playerFocusNode,
                  autofocus: true,
                  onKeyEvent: (node, event) => _handlePurePlaybackKey(event, notifier),
                  child: const SizedBox.expand(),
                ),
              ),

            // 3. 上下键切台微型 HUD 指示
            _buildChannelHUD(playerState, feedState),

            // 4. 左侧悬浮推荐列表导轨 (平滑淡入滑出 + 焦点隔离)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: AnimatedSlide(
                offset: isRailVisible ? Offset.zero : const Offset(-1.2, 0),
                duration: const Duration(milliseconds: 320),
                curve: Curves.easeOutCubic,
                child: AnimatedOpacity(
                  opacity: isRailVisible ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 260),
                  child: ExcludeFocus(
                    excluding: !isRailVisible,
                    child: TvRecommendRail(activeCardFocusNode: _railActiveFocusNode),
                  ),
                ),
              ),
            ),

            // 5. 全功能播放控制浮层 (OK 键呼出，进度条首焦，长按三连，合集露头)
            if (playerState.showControls)
              TvRecommendControlOverlay(
                onClose: notifier.closeControls,
                onSelectVideo: (video) {
                  // 单播放器换流切播并立即进入纯享模式，绝不跳新路由
                  notifier.playVideo(video);
                  notifier.enterPurePlayback();
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoLayer(RecommendPlayerState playerState, RecommendPlayerNotifier notifier) {
    final controller = notifier.videoController;
    if (controller != null) {
      return Video(controller: controller, controls: NoVideoControls, fit: BoxFit.cover);
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      color: Colors.black,
      child: playerState.isLoading
          ? const Center(
              child: SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white38),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildChannelHUD(RecommendPlayerState playerState, HomeFeedState feedState) {
    final current =
        playerState.currentVideo ??
        (feedState.videos.isNotEmpty && playerState.currentIndex < feedState.videos.length
            ? feedState.videos[playerState.currentIndex]
            : null);

    if (current == null) return const SizedBox.shrink();

    return Positioned(
      left: 48,
      bottom: 48,
      child: AnimatedOpacity(
        opacity: _showChannelHUD ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 250),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 1.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.6),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Text(
                  current.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

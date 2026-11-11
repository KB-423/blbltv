import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/back_navigation_debounce.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../widgets/tv_status_view.dart';
import '../../../home/presentation/providers/recommend_player_state.dart';
import '../../../main/presentation/providers/nav_rail_focus_provider.dart';
import '../providers/popular_player_provider.dart';
import '../providers/popular_provider.dart';
import '../widgets/tv_popular_rail.dart';

/// TV 全站热门专区全屏视频流屏幕 (与推荐视频流体验统一，零Mock)
/// 核心架构与交互：
/// 1. 底层：全屏硬件加速视频流（由 TvMainShell 统一承载 GlobalTvVideoSurface，默认起播首个视频）
/// 2. 左侧：悬浮热门视频流导轨 (TvPopularRail)，含 TOP 1~3 勋章标识
/// 3. 沉浸：5秒静止或 OK 触发全屏纯享播放，隐藏列表与顶栏
/// 4. 切台：纯享模式下按上下键即时换流切台（保持纯享，零遮挡，仅弹出微型 HUD）
/// 5. 状态：切页离开时通过 pauseAndStopAudio() 冻结快照，切回时 0ms 恢复
class TvPopularScreen extends ConsumerStatefulWidget {
  const TvPopularScreen({super.key});

  @override
  ConsumerState<TvPopularScreen> createState() => _TvPopularScreenState();
}

class _TvPopularScreenState extends ConsumerState<TvPopularScreen> {
  final FocusNode _playerFocusNode =
      FocusNode(debugLabel: 'PopularScreenPlayerFocus');
  final FocusNode _railActiveFocusNode =
      FocusNode(debugLabel: 'PopularScreenRailActiveCardFocus');

  bool _showChannelHUD = false;
  Timer? _channelHudTimer;
  PopularPlayerNotifier? _playerNotifier;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _playerNotifier = ref.read(popularPlayerProvider.notifier);
  }

  @override
  void dispose() {
    _channelHudTimer?.cancel();
    _playerFocusNode.dispose();
    _railActiveFocusNode.dispose();
    // 切换离开热门页时保存会话快照并切断播放器音频
    _playerNotifier?.pauseAndStopAudio();
    super.dispose();
  }

  void _triggerChannelHUD() {
    _channelHudTimer?.cancel();
    setState(() {
      _showChannelHUD = true;
    });
    _channelHudTimer = Timer(const Duration(milliseconds: 2200), () {
      if (mounted) {
        setState(() {
          _showChannelHUD = false;
        });
      }
    });
  }

  KeyEventResult _handlePurePlaybackKey(
    KeyEvent event,
    PopularPlayerNotifier notifier,
  ) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    final key = event.logicalKey;

    // 上方向键：切换上一个热门视频
    if (key == LogicalKeyboardKey.arrowUp) {
      notifier.playPrevious();
      _triggerChannelHUD();
      return KeyEventResult.handled;
    }

    // 下方向键：切换下一个热门视频
    if (key == LogicalKeyboardKey.arrowDown) {
      notifier.playNext();
      _triggerChannelHUD();
      return KeyEventResult.handled;
    }

    // OK / Select / Enter / 空格：切换播放/暂停
    if (key == LogicalKeyboardKey.select ||
        key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.space ||
        key == LogicalKeyboardKey.gameButtonA) {
      notifier.togglePlay();
      _triggerChannelHUD();
      return KeyEventResult.handled;
    }

    // 左右方向键 / 返回键 / Escape：退出纯享模式，唤醒左侧热门列表
    if (key == LogicalKeyboardKey.arrowLeft ||
        key == LogicalKeyboardKey.arrowRight ||
        key == LogicalKeyboardKey.escape ||
        key == LogicalKeyboardKey.goBack) {
      if (BackNavigationDebounce.shouldHandle()) {
        notifier.exitPurePlayback();
        return KeyEventResult.handled;
      }
    }

    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final feedState = ref.watch(popularFeedProvider);
    final playerState = ref.watch(popularPlayerProvider);
    final notifier = ref.read(popularPlayerProvider.notifier);
    final navService = ref.read(navRailFocusServiceProvider);

    // 焦点自愈机制
    ref.listen(popularPlayerProvider, (prev, next) {
      // 1. 进入纯享模式，焦点锚定到全屏播放器按键节点
      if (next.isPurePlayback && !next.showControls) {
        if (prev == null || !prev.isPurePlayback) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && _playerFocusNode.canRequestFocus) {
              _playerFocusNode.requestFocus();
            }
          });
        }
      }
      // 2. 退出纯享时，焦点恢复至左侧热门列表当前卡片
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
        backgroundColor: Colors.transparent,
        body: TvLoadingView(message: '正在拉取全站热门榜单...'),
      );
    }

    if (feedState.error != null && feedState.videos.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: TvErrorView(
          error: feedState.error!,
          onRetry: () => ref.read(popularFeedProvider.notifier).refresh(),
        ),
      );
    }

    final isRailVisible = !playerState.isPurePlayback && !playerState.showControls;
    final canPopToShell =
        !playerState.isPurePlayback && navService.isNavRailFocused;

    return PopScope(
      canPop: canPopToShell,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (!BackNavigationDebounce.shouldHandle()) return;

        // 1. 若处于纯享模式，先退出纯享，恢复左侧列表与顶部栏
        if (playerState.isPurePlayback) {
          notifier.exitPurePlayback();
          return;
        }

        // 2. 若列表可见但焦点在列表，先恢复顶栏全显，再平滑交接回顶部导航栏「热门」Tab
        if (!navService.isNavRailFocused) {
          notifier.cancelHoverPlay();
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
        backgroundColor: Colors.transparent,
        body: Stack(
          fit: StackFit.expand,
          children: [
            // 1. 纯享模式上下键即时切台按键监听节点 (零遮罩零延迟)
            if (playerState.isPurePlayback && !playerState.showControls)
              Positioned.fill(
                child: Focus(
                  focusNode: _playerFocusNode,
                  autofocus: true,
                  onKeyEvent: (node, event) =>
                      _handlePurePlaybackKey(event, notifier),
                  child: const SizedBox.expand(),
                ),
              ),

            // 2. 上下键切台微型 HUD 指示
            _buildChannelHUD(playerState, feedState),

            // 3. 左侧悬浮热门列表导轨 (平滑淡入滑出 + 焦点隔离)
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
                    child: TvPopularRail(
                      activeCardFocusNode: _railActiveFocusNode,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChannelHUD(
    RecommendPlayerState playerState,
    PopularState feedState,
  ) {
    final current = playerState.currentVideo ??
        (feedState.videos.isNotEmpty &&
                playerState.currentIndex < feedState.videos.length
            ? feedState.videos[playerState.currentIndex]
            : null);

    if (current == null) return const SizedBox.shrink();

    final rank = playerState.currentIndex + 1;

    return Positioned(
      left: 48,
      bottom: 48,
      child: AnimatedOpacity(
        opacity: _showChannelHUD ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 250),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.88),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.16),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.65),
                blurRadius: 28,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 榜单名次
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: rank <= 3
                      ? const Color(0xFFFF6699)
                      : Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'TOP $rank',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // 播放状态图标
              Icon(
                playerState.isPlaying
                    ? Icons.play_arrow_rounded
                    : Icons.pause_rounded,
                size: 20,
                color: Colors.white70,
              ),
              const SizedBox(width: 8),
              // 视频标题与 UP 主
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      current.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${(current.owner?.name.isNotEmpty == true ? current.owner!.name : "UP主")} · ${Formatters.formatCount(current.stat?.view)}播放',
                      style: const TextStyle(
                        color: Colors.white54,
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
    );
  }
}

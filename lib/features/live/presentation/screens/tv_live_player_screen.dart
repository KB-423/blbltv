import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../../../../core/theme/tv_theme.dart';
import '../../../../core/utils/back_navigation_debounce.dart';
import '../../../../models/video/play_url_model.dart';
import '../../../../widgets/tv_status_view.dart';
import '../../../player/presentation/providers/player_provider.dart';
import '../../../player/presentation/widgets/tv_player_controls.dart';
import '../../../player/presentation/widgets/tv_player_debug_overlay.dart';
import '../../data/models/live_room_item_model.dart';
import '../providers/live_player_provider.dart';
import '../providers/live_player_state.dart';

/// TV 全屏直播播放器界面
/// 遵循 10-foot TV 大屏规范：
/// - 纯 C 原生 OpenSL ES 音频驱动与 MediaCodec 硬件解码
/// - 动态控制条 5 秒自动淡出
/// - 遥控器单次返回键平滑出栈，第 0 毫秒切断音频
/// - 退出生命周期严格回收，组件 unmount 时释放解码资源
class TvLivePlayerScreen extends ConsumerStatefulWidget {
  final int roomId;
  final LiveRoomItemModel? room;

  const TvLivePlayerScreen({
    super.key,
    required this.roomId,
    this.room,
  });

  @override
  ConsumerState<TvLivePlayerScreen> createState() =>
      _TvLivePlayerScreenState();
}

class _TvLivePlayerScreenState extends ConsumerState<TvLivePlayerScreen>
    with WidgetsBindingObserver {
  final FocusNode _videoFocusNode = FocusNode(debugLabel: 'LiveVideoFocus');
  final FocusNode _playPauseFocusNode =
      FocusNode(debugLabel: 'LivePlayPauseBtn');

  bool _isExiting = false;
  LivePlayerNotifier? _playerNotifier;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _videoFocusNode.requestFocus();
        if (widget.room != null) {
          ref
              .read(livePlayerProvider(widget.roomId).notifier)
              .setInitialRoomMeta(widget.room);
        }
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _videoFocusNode.dispose();
    _playPauseFocusNode.dispose();

    // 关键生命周期保障：组件卸载时立即停止音频与释放硬解实例，杜绝后台残留播放
    _playerNotifier?.disposePlayer();
    _playerNotifier = null;
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden) {
      _playerNotifier?.player?.pause();
    } else if (state == AppLifecycleState.resumed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _videoFocusNode.requestFocus();
        }
      });
    }
  }

  void _handleBack(
    BuildContext context,
    LivePlayerState playerState,
    LivePlayerNotifier notifier,
  ) {
    if (_isExiting) return;
    if (!BackNavigationDebounce.shouldHandle()) return;

    if (playerState.showControls) {
      notifier.hideControls();
    } else {
      _isExiting = true;
      // 退出确认：第 0 毫秒立即掐断音频，零延迟彻底静音
      notifier.pauseAndStopAudio();
      if (context.mounted) {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        } else {
          try {
            context.pop();
          } catch (_) {}
        }
      }
    }
  }

  KeyEventResult _handleVideoKeyEvent(
    KeyEvent event,
    LivePlayerState state,
    LivePlayerNotifier notifier,
  ) {
    if (event is KeyDownEvent &&
        (event.logicalKey == LogicalKeyboardKey.keyD ||
            event.logicalKey == LogicalKeyboardKey.digit0)) {
      ref.read(playerDebugOverlayProvider.notifier).toggle();
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.escape) {
      if (event is KeyDownEvent) {
        _handleBack(context, state, notifier);
      }
      return KeyEventResult.handled;
    }

    if (event is KeyDownEvent &&
        (event.logicalKey == LogicalKeyboardKey.arrowDown ||
            event.logicalKey == LogicalKeyboardKey.arrowUp)) {
      notifier.showControlsTemporarily();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _playPauseFocusNode.requestFocus();
        }
      });
      return KeyEventResult.handled;
    }

    if (event is KeyDownEvent &&
        (event.logicalKey == LogicalKeyboardKey.select ||
            event.logicalKey == LogicalKeyboardKey.enter)) {
      notifier.togglePlay();
      notifier.showControlsTemporarily();
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final playerState = ref.watch(livePlayerProvider(widget.roomId));
    final notifier = ref.read(livePlayerProvider(widget.roomId).notifier);
    _playerNotifier = notifier;

    final showDebugOverlay = ref.watch(playerDebugOverlayProvider);
    final videoController = notifier.videoController;

    // 焦点自愈：控制栏隐藏时将焦点安全归还视频画面
    ref.listen(
      livePlayerProvider(widget.roomId).select((s) => s.showControls),
      (prev, show) {
        if (prev == true && !show) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _videoFocusNode.requestFocus();
          });
        }
      },
    );

    final title = playerState.title.isNotEmpty
        ? playerState.title
        : (widget.room?.title ?? '直播间 ${widget.roomId}');

    final subtitle = playerState.uname.isNotEmpty
        ? '主播: ${playerState.uname}'
        : (widget.room?.uname != null ? '主播: ${widget.room!.uname}' : '');

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBack(context, playerState, notifier);
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            // 1. 直播画面与独立焦点组件
            Focus(
              focusNode: _videoFocusNode,
              autofocus: true,
              onKeyEvent: (node, event) =>
                  _handleVideoKeyEvent(event, playerState, notifier),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  notifier.toggleControls();
                  _videoFocusNode.requestFocus();
                },
                child: Center(
                  child: videoController != null
                      ? Video(
                          controller: videoController,
                          controls: NoVideoControls,
                        )
                      : const SizedBox.shrink(),
                ),
              ),
            ),

            // 2. 缓冲动画
            if (playerState.isLoading || playerState.isBuffering)
              const Center(
                child: SizedBox(
                  width: 44,
                  height: 44,
                  child: CircularProgressIndicator(
                    strokeWidth: 3.0,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      TvTheme.biliPink,
                    ),
                  ),
                ),
              ),

            // 3. 极客调试面板
            if (showDebugOverlay)
              Positioned(
                top: 20,
                left: 20,
                child: TvPlayerDebugOverlay(
                  player: notifier.player,
                  title: '$title ($subtitle)',
                  qn: 10000,
                  cdnUrl: playerState.streamUrl,
                ),
              ),

            // 4. 错误提示
            if (playerState.error != null && !playerState.isLoading)
              Center(
                child: TvErrorView(
                  error: playerState.error!,
                  onRetry: () => notifier.retry(),
                ),
              ),

            // 5. 直播控制栏 (isLive: true)
            if (playerState.showControls)
              TvPlayerControls(
                title: title,
                subtitle: subtitle,
                badgeText: '🔴 直播中',
                badgeColor: Colors.redAccent,
                onlineCount: playerState.onlineCount,
                isLive: true,
                isPlaying: playerState.isPlaying,
                position: Duration.zero,
                duration: Duration.zero,
                currentQn: 10000,
                qualities: const [
                  VideoQualityItem(qn: 10000, desc: '原画'),
                ],
                showDebugOverlay: showDebugOverlay,
                playPauseFocusNode: _playPauseFocusNode,
                onFocusVideo: () => _videoFocusNode.requestFocus(),
                onUserInteraction: notifier.showControlsTemporarily,
                onToggleDebugOverlay: () =>
                    ref.read(playerDebugOverlayProvider.notifier).toggle(),
                onTogglePlay: notifier.togglePlay,
                onSeekBackward: () {},
                onSeekForward: () {},
                onOpenQuality: () {},
                onBack: () {
                  notifier.pauseAndStopAudio();
                  if (context.mounted) {
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    } else {
                      try {
                        context.pop();
                      } catch (_) {}
                    }
                  }
                },
              ),
          ],
        ),
      ),
    );
  }
}

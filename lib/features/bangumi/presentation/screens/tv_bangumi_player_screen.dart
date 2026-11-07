import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../../../../core/theme/tv_theme.dart';
import '../../../../core/utils/back_navigation_debounce.dart';
import '../../../../router/route_paths.dart';
import '../../../../widgets/tv_status_view.dart';
import '../../../player/presentation/providers/player_provider.dart';
import '../../../player/presentation/widgets/tv_episode_drawer.dart';
import '../../../player/presentation/widgets/tv_player_controls.dart';
import '../../../player/presentation/widgets/tv_player_debug_overlay.dart';
import '../../../player/presentation/widgets/tv_quality_panel.dart';
import '../../../player/presentation/widgets/tv_seek_hud.dart';
import '../providers/bangumi_player_provider.dart';
import '../providers/bangumi_player_state.dart';

/// TV 全屏番剧/影视播放器界面
/// 具备：
/// - 严密的大屏 D-Pad 焦点控制模型
/// - 多集/选集抽屉平滑切集
/// - 多级返回拦截 (Drawer -> Panel -> Controls -> Exit)
/// - 退出第 0 毫秒强制掐断音频与释放硬解资源
class TvBangumiPlayerScreen extends ConsumerStatefulWidget {
  final int seasonId;
  final int? epId;

  const TvBangumiPlayerScreen({
    super.key,
    required this.seasonId,
    this.epId,
  });

  @override
  ConsumerState<TvBangumiPlayerScreen> createState() =>
      _TvBangumiPlayerScreenState();
}

class _TvBangumiPlayerScreenState extends ConsumerState<TvBangumiPlayerScreen>
    with WidgetsBindingObserver {
  final FocusNode _videoFocusNode = FocusNode(debugLabel: 'BangumiVideoFocus');
  final FocusNode _playPauseFocusNode =
      FocusNode(debugLabel: 'BangumiPlayPauseBtn');
  final FocusNode _qualityFocusNode = FocusNode(debugLabel: 'BangumiQualityBtn');
  final FocusNode _episodeBtnFocusNode =
      FocusNode(debugLabel: 'BangumiEpisodeBtn');

  // 长按快进/快退状态机
  bool _isSeekingLongPress = false;
  Duration _currentSeekTarget = Duration.zero;
  bool _isSeekForward = true;
  Timer? _longPressSeekTimer;
  DateTime? _seekStartTime;
  int _accumulatedSeekSeconds = 0;

  bool _isExiting = false;
  BangumiPlayerNotifier? _playerNotifier;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _videoFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _longPressSeekTimer?.cancel();
    _videoFocusNode.dispose();
    _playPauseFocusNode.dispose();
    _qualityFocusNode.dispose();
    _episodeBtnFocusNode.dispose();

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
    BangumiPlayerState playerState,
    BangumiPlayerNotifier notifier,
  ) {
    if (_isExiting) return;
    if (!BackNavigationDebounce.shouldHandle()) return;

    if (playerState.showEpisodeDrawer) {
      notifier.closeEpisodeDrawer();
    } else if (playerState.showQualityPanel) {
      notifier.closeQualityPanel();
    } else if (playerState.showControls) {
      notifier.hideControls();
    } else {
      _isExiting = true;
      // 退出确认：第 0 毫秒立即掐断音频，零延迟彻底静音
      notifier.pauseAndStopAudio();
      _safeNavigateBack(context, RoutePaths.bangumi);
    }
  }

  void _safeNavigateBack(BuildContext context, String fallbackPath) {
    if (!context.mounted) return;
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
      return;
    }
    try {
      final router = GoRouter.maybeOf(context);
      if (router != null) {
        if (router.canPop()) {
          router.pop();
        } else {
          router.go(fallbackPath);
        }
      }
    } catch (_) {}
  }

  void _startLongPressSeek(
    bool isForward,
    BangumiPlayerState playerState,
    BangumiPlayerNotifier notifier,
  ) {
    _longPressSeekTimer?.cancel();
    _isSeekForward = isForward;
    _seekStartTime = DateTime.now();
    _currentSeekTarget =
        notifier.player?.state.position ?? playerState.position;
    _accumulatedSeekSeconds = isForward ? 10 : -10;
    _isSeekingLongPress = false;

    _longPressSeekTimer = Timer(const Duration(milliseconds: 280), () {
      if (!mounted) return;
      setState(() {
        _isSeekingLongPress = true;
      });

      _longPressSeekTimer =
          Timer.periodic(const Duration(milliseconds: 150), (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }

        final elapsed =
            DateTime.now().difference(_seekStartTime!).inMilliseconds;
        final int step = elapsed > 2500 ? 30 : (elapsed > 1200 ? 20 : 10);
        final int delta = _isSeekForward ? step : -step;
        _accumulatedSeekSeconds += delta;

        final newTarget = _currentSeekTarget + Duration(seconds: delta);
        final maxDur = playerState.duration;
        _currentSeekTarget = newTarget < Duration.zero
            ? Duration.zero
            : (maxDur > Duration.zero && newTarget > maxDur
                ? maxDur
                : newTarget);

        setState(() {});
      });
    });
  }

  void _finishLongPressSeek(BangumiPlayerNotifier notifier) {
    final wasLongPress = _isSeekingLongPress;
    _longPressSeekTimer?.cancel();
    _longPressSeekTimer = null;

    if (wasLongPress) {
      notifier.seekTo(_currentSeekTarget);
      setState(() {
        _isSeekingLongPress = false;
        _accumulatedSeekSeconds = 0;
      });
    } else {
      if (_isSeekForward) {
        notifier.seekForward(seconds: 10);
      } else {
        notifier.seekBackward(seconds: 10);
      }
    }
  }

  KeyEventResult _handleVideoKeyEvent(
    KeyEvent event,
    BangumiPlayerState state,
    BangumiPlayerNotifier notifier,
  ) {
    if (state.showQualityPanel || state.showEpisodeDrawer) {
      return KeyEventResult.ignored;
    }

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
        event.logicalKey == LogicalKeyboardKey.arrowDown) {
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

    final isLeft = event.logicalKey == LogicalKeyboardKey.arrowLeft;
    final isRight = event.logicalKey == LogicalKeyboardKey.arrowRight;

    if (isLeft || isRight) {
      if (event is KeyDownEvent) {
        _startLongPressSeek(isRight, state, notifier);
        return KeyEventResult.handled;
      } else if (event is KeyUpEvent) {
        _finishLongPressSeek(notifier);
        return KeyEventResult.handled;
      }
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final playerState = ref.watch(bangumiPlayerProvider(widget.seasonId));
    final notifier =
        ref.read(bangumiPlayerProvider(widget.seasonId).notifier);
    _playerNotifier = notifier;

    final showDebugOverlay = ref.watch(playerDebugOverlayProvider);
    final videoController = notifier.videoController;

    final curEp = playerState.episodes.isNotEmpty &&
            playerState.currentEpIndex < playerState.episodes.length
        ? playerState.episodes[playerState.currentEpIndex]
        : null;

    final episodeSubtitle = curEp != null
        ? '${curEp.title} ${curEp.longTitle}'.trim()
        : '';

    // 焦点自愈 1：控制栏隐藏时交接回视频画面
    ref.listen(
      bangumiPlayerProvider(widget.seasonId).select((s) => s.showControls),
      (prev, show) {
        if (prev == true && !show) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _videoFocusNode.requestFocus();
          });
        }
      },
    );

    // 焦点自愈 2：画质面板关闭时交接回按钮
    ref.listen(
      bangumiPlayerProvider(widget.seasonId).select((s) => s.showQualityPanel),
      (prev, show) {
        if (prev == true && !show) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              if (ref.read(bangumiPlayerProvider(widget.seasonId)).showControls) {
                _qualityFocusNode.requestFocus();
              } else {
                _videoFocusNode.requestFocus();
              }
            }
          });
        }
      },
    );

    // 焦点自愈 3：选集抽屉关闭时交接回按钮
    ref.listen(
      bangumiPlayerProvider(widget.seasonId).select((s) => s.showEpisodeDrawer),
      (prev, show) {
        if (prev == true && !show) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              if (ref.read(bangumiPlayerProvider(widget.seasonId)).showControls) {
                _episodeBtnFocusNode.requestFocus();
              } else {
                _videoFocusNode.requestFocus();
              }
            }
          });
        }
      },
    );

    final episodesList = playerState.episodes.asMap().entries.map((e) {
      final ep = e.value;
      return TvEpisodeItem(
        index: e.key,
        title: ep.title,
        subtitle: ep.longTitle.isNotEmpty ? ep.longTitle : ep.title,
        badge: ep.badge.isNotEmpty ? ep.badge : null,
        durationSeconds: ep.duration,
        bvid: ep.bvid,
        cid: ep.cid,
      );
    }).toList();

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
            // 1. 视频渲染主体与焦点监听
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
                  title: '${playerState.seasonTitle} $episodeSubtitle',
                  qn: playerState.currentQn,
                  cdnUrl: playerState.currentPlayUrl,
                ),
              ),

            // 4. 长按快进快退 HUD
            if (_isSeekingLongPress)
              TvSeekHUD(
                isForward: _isSeekForward,
                targetPosition: _currentSeekTarget,
                duration: playerState.duration,
                accumulatedSeconds: _accumulatedSeekSeconds,
              ),

            // 5. 错误提示
            if (playerState.error != null && !playerState.isLoading)
              Center(
                child: TvErrorView(
                  error: playerState.error!,
                  onRetry: () => notifier.retry(),
                ),
              ),

            // 6. 播放器控制栏浮层
            if (playerState.showControls)
              TvPlayerControls(
                title: playerState.seasonTitle.isNotEmpty
                    ? playerState.seasonTitle
                    : '加载中...',
                subtitle: episodeSubtitle,
                badgeText: '番剧',
                badgeColor: TvTheme.biliPink,
                isPlaying: playerState.isPlaying,
                position: playerState.position,
                duration: playerState.duration,
                currentQn: playerState.currentQn,
                qualities: playerState.qualities,
                showDebugOverlay: showDebugOverlay,
                hasEpisodes: playerState.episodes.length > 1,
                episodeButtonLabel:
                    '选集 (${curEp?.title ?? "${playerState.currentEpIndex + 1}"})',
                playPauseFocusNode: _playPauseFocusNode,
                qualityFocusNode: _qualityFocusNode,
                episodeBtnFocusNode: _episodeBtnFocusNode,
                onFocusVideo: () => _videoFocusNode.requestFocus(),
                onUserInteraction: notifier.showControlsTemporarily,
                onToggleDebugOverlay: () =>
                    ref.read(playerDebugOverlayProvider.notifier).toggle(),
                onTogglePlay: notifier.togglePlay,
                onSeekBackward: () => notifier.seekBackward(seconds: 10),
                onSeekForward: () => notifier.seekForward(seconds: 10),
                onLongSeekBackward: () => notifier.seekBackward(seconds: 30),
                onLongSeekForward: () => notifier.seekForward(seconds: 30),
                onOpenQuality: notifier.openQualityPanel,
                onOpenEpisodes: notifier.openEpisodeDrawer,
                onBack: () {
                  notifier.pauseAndStopAudio();
                  _safeNavigateBack(context, RoutePaths.bangumi);
                },
              ),

            // 7. 画质选择面板
            if (playerState.showQualityPanel) ...[
              GestureDetector(
                onTap: notifier.closeQualityPanel,
                child: Container(color: Colors.black45),
              ),
              Positioned(
                top: 0,
                right: 0,
                bottom: 0,
                child: TvQualityPanel(
                  qualities: playerState.qualities,
                  currentQn: playerState.currentQn,
                  onSelectQuality: (qn) => notifier.changeQuality(qn),
                  onClose: notifier.closeQualityPanel,
                ),
              ),
            ],

            // 8. 番剧选集抽屉
            if (playerState.showEpisodeDrawer) ...[
              GestureDetector(
                onTap: notifier.closeEpisodeDrawer,
                child: Container(color: Colors.black45),
              ),
              Positioned(
                top: 0,
                right: 0,
                bottom: 0,
                child: TvEpisodeDrawer(
                  drawerTitle: '剧集列表',
                  countLabel: '共${playerState.episodes.length}集',
                  episodes: episodesList,
                  currentIndex: playerState.currentEpIndex,
                  onSelectEpisode: notifier.changeEpisode,
                  onClose: notifier.closeEpisodeDrawer,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

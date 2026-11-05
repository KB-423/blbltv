import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../../../../core/theme/tv_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../widgets/tv_status_view.dart';
import '../providers/player_provider.dart';
import '../widgets/tv_player_controls.dart';
import '../widgets/tv_player_debug_overlay.dart';
import '../widgets/tv_quality_panel.dart';
import '../widgets/tv_part_drawer.dart';

/// TV 全屏视频播放器屏幕
/// 分层焦点模型：
/// 1. 播放器主体：独立 Focus 组件。
///    - 左右键（短按/长按）：视频快退/快进（带屏幕 HUD）；
///    - OK / Enter 键：播放/暂停；
///    - 向下键 (Down)：唤出控制栏并将焦点平滑交接到底部控制栏；
///    - 返回键 (Back/Escape)：退出播放器。
/// 2. 底部控制栏：独立的横向行。
///    - 左右键：在同行内各个按钮（播放、快退、快进、统计、画质）之间平移；
///    - 向上键 (Up)：切回播放器主体；
///    - 返回键 (Back)：收起控制栏并交回焦点给播放器主体；
///    - 超时自动隐藏时：焦点自愈回播播放器主体。
/// 3. 画质选择面板：独立 FocusScope。
///    - 挂载立即落焦当前画质，上下键顺畅切换；
///    - 返回键或向左键收起，焦点交接回底部画质按钮。
class TvPlayerScreen extends ConsumerStatefulWidget {
  final String bvid;

  const TvPlayerScreen({
    super.key,
    required this.bvid,
  });

  @override
  ConsumerState<TvPlayerScreen> createState() => _TvPlayerScreenState();
}

class _TvPlayerScreenState extends ConsumerState<TvPlayerScreen>
    with WidgetsBindingObserver {
  // 播放器主体专属 FocusNode
  final FocusNode _videoFocusNode = FocusNode(debugLabel: 'TvVideoPlayer');

  // 控制栏各主要入口专用 FocusNode，用于精确交接焦点
  final FocusNode _playPauseFocusNode = FocusNode(debugLabel: 'TvPlayPauseBtn');
  final FocusNode _qualityFocusNode = FocusNode(debugLabel: 'TvQualityBtn');
  final FocusNode _partBtnFocusNode = FocusNode(debugLabel: 'TvPartBtn');

  // 长按快进快退状态机
  bool _isSeekingLongPress = false;
  Duration _currentSeekTarget = Duration.zero;
  bool _isSeekForward = true;
  Timer? _longPressSeekTimer;
  DateTime? _seekStartTime;
  int _accumulatedSeekSeconds = 0;

  // 返回键防抖时间戳与退出状态锁，防止遥控器单次点击在 onKeyEvent 与 PopScope 间重复分发
  DateTime? _lastBackTime;
  bool _isExiting = false;

  PlayerNotifier? _playerNotifier;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _playerNotifier = ref.read(playerProvider(widget.bvid).notifier);
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
    _partBtnFocusNode.dispose();
    // 退出界面组件树卸载时，主动显式停止并销毁播放器，彻底解决退出后声音残留
    _playerNotifier?.disposePlayer();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final notifier = ref.read(playerProvider(widget.bvid).notifier);
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden) {
      // 当 TV 熄屏、切换信号源或转入后台时，主动暂停、存盘并上报进度，掐断后台播放
      notifier.player?.pause();
      notifier.saveCurrentProgress();
      notifier.reportHistoryHeartbeat();
    } else if (state == AppLifecycleState.resumed) {
      // 重新回到前台，恢复遥控器焦点
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _videoFocusNode.requestFocus();
        }
      });
    }
  }

  void _handleBack(
    BuildContext context,
    dynamic playerState,
    dynamic notifier,
  ) {
    if (_isExiting) return;

    // 350ms 防抖保护：彻底过滤物理按键与 PopScope 重复触发导致退出界面的问题
    final now = DateTime.now();
    if (_lastBackTime != null &&
        now.difference(_lastBackTime!).inMilliseconds < 350) {
      return;
    }
    _lastBackTime = now;

    if (playerState.showPartDrawer) {
      notifier.closePartDrawer();
    } else if (playerState.showQualityPanel) {
      notifier.closeQualityPanel();
    } else if (playerState.showControls) {
      notifier.toggleControls();
      _videoFocusNode.requestFocus();
    } else {
      _isExiting = true;
      notifier.disposePlayer();
      if (context.mounted) {
        context.pop();
      }
    }
  }

  /// 启动长按快进/快退检测与累积推进
  void _startLongPressSeek(
    bool isForward,
    dynamic playerState,
    dynamic notifier,
  ) {
    _longPressSeekTimer?.cancel();
    _isSeekForward = isForward;
    _seekStartTime = DateTime.now();
    _currentSeekTarget =
        notifier.player?.state.position ?? playerState.position;
    _accumulatedSeekSeconds = isForward ? 10 : -10;
    _isSeekingLongPress = false;

    // 按住超过 280ms 自动转入长按连续快进模式
    _longPressSeekTimer = Timer(const Duration(milliseconds: 280), () {
      if (!mounted) return;
      setState(() {
        _isSeekingLongPress = true;
      });

      // 每 150ms 连续步进，按住越久步长递增加速 (10s -> 20s -> 30s)
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

  /// 松开快进/快退按键：长按则一次性向底层提交 seek，短按则轻跳 10 秒
  void _finishLongPressSeek(dynamic notifier) {
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

  /// 视频主体落焦时的遥控器按键处理
  KeyEventResult _handleVideoKeyEvent(
    KeyEvent event,
    dynamic state,
    dynamic notifier,
  ) {
    // 1. 如果画质面板已打开，交由画质面板接管
    if (state.showQualityPanel) {
      return KeyEventResult.ignored;
    }

    // 2. 遥控器快捷键：按按键 D 或数字 0 切换调试信息面板
    if (event is KeyDownEvent &&
        (event.logicalKey == LogicalKeyboardKey.keyD ||
            event.logicalKey == LogicalKeyboardKey.digit0)) {
      ref.read(playerDebugOverlayProvider.notifier).toggle();
      return KeyEventResult.handled;
    }

    // 3. 遥控器与键盘返回键处理：
    // 必须在 KeyDownEvent 时触发 _handleBack()，并且在 KeyUpEvent 时同样返回 handled！
    // 关键机制：同时拦截 KeyDown 与 KeyUp，彻底防止 Android 原生 onKeyUp(KEYCODE_BACK) 重复派发系统 onBackPressed() 导致连跳两次
    if (event.logicalKey == LogicalKeyboardKey.escape ||
        event.logicalKey == LogicalKeyboardKey.goBack) {
      if (event is KeyDownEvent) {
        _handleBack(context, state, notifier);
      }
      return KeyEventResult.handled;
    }

    // 4. 方向向下键：唤出控制栏并将焦点平滑交接到底部控制栏第一项（播放/暂停）
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

    // 5. 确定键 (OK / Select / Enter)：切换播放/暂停
    if (event is KeyDownEvent &&
        (event.logicalKey == LogicalKeyboardKey.select ||
            event.logicalKey == LogicalKeyboardKey.enter)) {
      notifier.togglePlay();
      notifier.showControlsTemporarily();
      return KeyEventResult.handled;
    }

    // 6. 方向左/右键：快退/快进（支持轻触 10 秒与长按累加）
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
    final playerState = ref.watch(playerProvider(widget.bvid));
    final notifier = ref.read(playerProvider(widget.bvid).notifier);
    final showDebugOverlay = ref.watch(playerDebugOverlayProvider);
    final videoController = notifier.videoController;

    // 焦点自愈 1：当控制栏收起隐藏时，无论焦点处于何处，下一帧立即将焦点安全归还给播放器主体
    ref.listen(playerProvider(widget.bvid).select((s) => s.showControls),
        (prev, showControls) {
      if (prev == true && !showControls) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _videoFocusNode.requestFocus();
          }
        });
      }
    });

    // 焦点自愈 2：当画质面板关闭时，将焦点交接回底部控制栏画质按钮（若控制栏在）或播放器主体
    ref.listen(playerProvider(widget.bvid).select((s) => s.showQualityPanel),
        (prev, showQuality) {
      if (prev == true && !showQuality) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            final isControlsShowing =
                ref.read(playerProvider(widget.bvid)).showControls;
            if (isControlsShowing) {
              _qualityFocusNode.requestFocus();
            } else {
              _videoFocusNode.requestFocus();
            }
          }
        });
      }
    });

    // 焦点自愈 3：当选集抽屉关闭时，将焦点交接回选集按钮或播放器主体
    ref.listen(playerProvider(widget.bvid).select((s) => s.showPartDrawer),
        (prev, showDrawer) {
      if (prev == true && !showDrawer) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            final isControlsShowing =
                ref.read(playerProvider(widget.bvid)).showControls;
            if (isControlsShowing) {
              _partBtnFocusNode.requestFocus();
            } else {
              _videoFocusNode.requestFocus();
            }
          }
        });
      }
    });

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _handleBack(context, playerState, notifier);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            // 1. 播放器主体（视频渲染与独立焦点组件）
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

            // 2. 播放器中央轻量缓冲指示器
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

            // 3. 播放器极客调试信息面板
            if (showDebugOverlay)
              Positioned(
                top: 20,
                left: 20,
                child: TvPlayerDebugOverlay(
                  player: notifier.player,
                  title: playerState.title,
                  qn: playerState.currentQn,
                  cdnUrl: playerState.currentUrl,
                ),
              ),

            // 4. 大屏长按快进/快退沉浸式 HUD 浮层 (松开定位)
            if (_isSeekingLongPress)
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 20,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.88),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: TvTheme.biliPink,
                      width: 1.8,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: TvTheme.biliPink.withValues(alpha: 0.35),
                        blurRadius: 28,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _isSeekForward
                                ? Icons.fast_forward_rounded
                                : Icons.fast_rewind_rounded,
                            color: TvTheme.biliPink,
                            size: 30,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _isSeekForward ? '快进中 (松手定位)' : '快退中 (松手定位)',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${Formatters.formatDuration(_currentSeekTarget.inSeconds)} / ${Formatters.formatDuration(playerState.duration.inSeconds)} (${_accumulatedSeekSeconds > 0 ? "+$_accumulatedSeekSeconds" : "$_accumulatedSeekSeconds"}s)',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: 240,
                        child: LinearProgressIndicator(
                          value: playerState.duration.inMilliseconds > 0
                              ? (_currentSeekTarget.inMilliseconds /
                                      playerState.duration.inMilliseconds)
                                  .clamp(0.0, 1.0)
                              : 0.0,
                          minHeight: 6,
                          backgroundColor: Colors.white24,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            TvTheme.biliPink,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // 5. 错误重试界面
            if (playerState.error != null && !playerState.isLoading)
              Center(
                child: TvErrorView(
                  error: playerState.error!,
                  onRetry: () => notifier.retry(),
                ),
              ),

            // 6. 播放器控制栏浮层 (独立横向行)
            if (playerState.showControls)
              TvPlayerControls(
                title: playerState.title.isNotEmpty
                    ? playerState.title
                    : '加载中...',
                bvid: widget.bvid,
                isPlaying: playerState.isPlaying,
                position: playerState.position,
                duration: playerState.duration,
                currentQn: playerState.currentQn,
                qualities: playerState.qualities,
                showDebugOverlay: showDebugOverlay,
                onlineCount: playerState.onlineCount,
                hasParts: playerState.parts.length > 1,
                currentPart: playerState.currentPartIndex + 1,
                isLiked: playerState.isLiked,
                playPauseFocusNode: _playPauseFocusNode,
                qualityFocusNode: _qualityFocusNode,
                partBtnFocusNode: _partBtnFocusNode,
                onFocusVideo: () {
                  _videoFocusNode.requestFocus();
                },
                onUserInteraction: () {
                  notifier.showControlsTemporarily();
                },
                onToggleDebugOverlay: () {
                  ref.read(playerDebugOverlayProvider.notifier).toggle();
                },
                onTogglePlay: notifier.togglePlay,
                onSeekBackward: () => notifier.seekBackward(seconds: 10),
                onSeekForward: () => notifier.seekForward(seconds: 10),
                onLongSeekBackward: () => notifier.seekBackward(seconds: 30),
                onLongSeekForward: () => notifier.seekForward(seconds: 30),
                onOpenQuality: notifier.openQualityPanel,
                onOpenPartDrawer: notifier.openPartDrawer,
                onToggleLike: notifier.toggleLike,
                onTriple: () async {
                  final ok = await notifier.doTriple();
                  if (context.mounted && ok) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('一键三连成功！感谢支持！'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
                onBack: () => _handleBack(context, playerState, notifier),
              ),

            // 7. 侧边弹出式画质选择面板 (独立 FocusScope)
            if (playerState.showQualityPanel) ...[
              // 背景半透明遮罩，点击可关闭
              GestureDetector(
                onTap: notifier.closeQualityPanel,
                child: Container(
                  color: Colors.black45,
                ),
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

            // 8. 侧边弹出式分 P 选集抽屉 (独立 FocusScope)
            if (playerState.showPartDrawer) ...[
              GestureDetector(
                onTap: notifier.closePartDrawer,
                child: Container(
                  color: Colors.black45,
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                bottom: 0,
                child: TvPartDrawer(
                  parts: playerState.parts,
                  currentPartIndex: playerState.currentPartIndex,
                  onSelectPart: notifier.changePart,
                  onClose: notifier.closePartDrawer,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

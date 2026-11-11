import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart' hide PlayerState;
import 'package:media_kit_video/media_kit_video.dart';

import '../utils/tv_player_engine_helper.dart';
import 'playback_session.dart';

/// 全局播放内核状态
class GlobalPlayerKernelState {
  final PlaybackSession? activeSession;
  final bool isPlaying;
  final bool isBuffering;
  final bool isFirstFrameRendered;
  final Duration position;
  final Duration duration;
  final String? error;

  const GlobalPlayerKernelState({
    this.activeSession,
    this.isPlaying = false,
    this.isBuffering = false,
    this.isFirstFrameRendered = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.error,
  });

  GlobalPlayerKernelState copyWith({
    PlaybackSession? activeSession,
    bool? isPlaying,
    bool? isBuffering,
    bool? isFirstFrameRendered,
    Duration? position,
    Duration? duration,
    String? error,
  }) {
    return GlobalPlayerKernelState(
      activeSession: activeSession ?? this.activeSession,
      isPlaying: isPlaying ?? this.isPlaying,
      isBuffering: isBuffering ?? this.isBuffering,
      isFirstFrameRendered:
          isFirstFrameRendered ?? this.isFirstFrameRendered,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      error: error,
    );
  }
}

/// 全局单例播放器管理提供者
final globalPlayerManagerProvider =
    NotifierProvider<GlobalPlayerManager, GlobalPlayerKernelState>(
  GlobalPlayerManager.new,
);

/// 全局唯一的 TV 播放器内核管理器
/// 职责：
/// 1. 维护全生命周期唯一的 Player 与 VideoController，彻底消除重复销毁重连引发的黑屏与显存泄漏
/// 2. 硬件硬解与色调映射调优 (vo=gpu, bt.2446a, OpenSL ES)，无缝支持 HDR10 与 SDR 动态换流
/// 3. 管理当前激活的 PlaybackSession，支持无感换流与精确断点 seek
/// 4. 支持切页瞬间捕获最后一帧冻结快照 (screenshot)，实现切回时 0ms 视觉黑屏无缝过渡
class GlobalPlayerManager extends Notifier<GlobalPlayerKernelState> {
  Player? _player;
  VideoController? _videoController;

  StreamSubscription<bool>? _playingSub;
  StreamSubscription<bool>? _bufferingSub;
  StreamSubscription<Duration>? _posSub;
  StreamSubscription<Duration>? _durSub;
  StreamSubscription<String>? _errSub;

  Player? get player => _player;
  VideoController? get videoController => _videoController;

  @override
  GlobalPlayerKernelState build() {
    _initKernel();

    ref.onDispose(() {
      _disposeKernel();
    });

    return const GlobalPlayerKernelState();
  }

  void _initKernel() {
    try {
      final p = TvPlayerEngineHelper.createPlayer();
      _player = p;
      _videoController = TvPlayerEngineHelper.createVideoController(p);

      TvPlayerEngineHelper.configurePlatformProperties(p.platform);

      _playingSub = p.stream.playing.listen((playing) {
        state = state.copyWith(isPlaying: playing);
        if (playing && !state.isFirstFrameRendered) {
          state = state.copyWith(isFirstFrameRendered: true);
        }
      });

      _bufferingSub = p.stream.buffering.listen((buffering) {
        state = state.copyWith(isBuffering: buffering);
      });

      _posSub = p.stream.position.listen((pos) {
        state = state.copyWith(position: pos);
        if (pos > Duration.zero && !state.isFirstFrameRendered) {
          state = state.copyWith(isFirstFrameRendered: true);
        }
      });

      _durSub = p.stream.duration.listen((dur) {
        state = state.copyWith(duration: dur);
      });

      _errSub = p.stream.error.listen((err) {
        state = state.copyWith(error: err);
      });
    } catch (e, st) {
      debugPrint('GlobalPlayerManager init failed: $e\n$st');
    }
  }

  /// 激活并加载某业务会话 (若换流，重置 isFirstFrameRendered 为 false 以触发快照过渡)
  Future<void> activateSession(
    PlaybackSession session, {
    bool autoPlay = true,
  }) async {
    final p = _player;
    if (p == null) return;

    final isSameStream = state.activeSession?.sessionId == session.sessionId &&
        state.activeSession?.videoUrl == session.videoUrl;

    state = state.copyWith(
      activeSession: session,
      isFirstFrameRendered: isSameStream,
      error: null,
    );

    if (session.videoUrl == null || session.videoUrl!.isEmpty) return;

    if (!isSameStream) {
      await TvPlayerEngineHelper.configurePlatformProperties(
        p.platform,
        audioUrl: session.audioUrl,
        isLive: session.isLive,
      );

      await p.open(Media(session.videoUrl!), play: autoPlay);

      // 若有记忆断点且大于 1 秒，执行定位
      if (session.lastPosition > const Duration(seconds: 1)) {
        await p.seek(session.lastPosition);
      }
    } else if (autoPlay && !p.state.playing) {
      await p.play();
    }
  }

  /// 离开当前会话前截取冻结快照并记录进度，实现 0ms 视觉黑屏
  Future<PlaybackSession?> pauseAndCaptureCurrentSession() async {
    final p = _player;
    final current = state.activeSession;
    if (p == null || current == null) return current;

    // 1. 获取当前精确进度
    final currentPos = p.state.position;

    // 2. 截取最后一帧冻结快照
    Uint8List? frameBytes;
    try {
      frameBytes = await p.screenshot(format: 'image/jpeg');
    } catch (e) {
      debugPrint('Capture freeze-frame screenshot failed: $e');
    }

    // 3. 瞬间静音并暂停音频
    try {
      await p.pause();
    } catch (_) {}

    // 4. 返回包含最新进度与冻结快照的会话对象
    final updatedSession = current.copyWith(
      lastPosition: currentPos,
      lastFrameBytes: frameBytes ?? current.lastFrameBytes,
    );

    state = state.copyWith(activeSession: updatedSession);
    return updatedSession;
  }

  /// 播放
  Future<void> play() async {
    await _player?.play();
  }

  /// 暂停
  Future<void> pause() async {
    await _player?.pause();
  }

  /// 跳转进度
  Future<void> seek(Duration position) async {
    await _player?.seek(position);
  }

  /// 快速切断音频 (离开路由第 0ms 触发)
  void stopAudio() {
    try {
      _player?.setVolume(0).catchError((_) {});
      _player?.pause().catchError((_) {});
    } catch (_) {}
  }

  void _disposeKernel() {
    _playingSub?.cancel();
    _bufferingSub?.cancel();
    _posSub?.cancel();
    _durSub?.cancel();
    _errSub?.cancel();

    _player?.stop();
    _player?.dispose();
    _player = null;
    _videoController = null;
  }
}

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart' hide PlayerState;
import 'package:media_kit_video/media_kit_video.dart';

import '../constants/api_constants.dart';
import '../utils/tv_player_engine_helper.dart';
import 'playback_session.dart';

/// 全局播放内核状态 (完全解耦与可观测)
class GlobalPlayerKernelState {
  final String activeOwnerId; // 当前拥有播放器的组件标识 (如 'recommend', 'popular', 'channel', 'player')
  final PlaybackSession? activeSession; // 当前激活的播放会话
  final bool isPlaying; // 是否正在播放
  final bool isBuffering; // 是否正在缓冲
  final bool isFirstFrameRendered; // 首帧是否已成功渲染入纹理
  final bool isCompleted; // 是否播放完毕
  final Duration position; // 当前播放时间戳
  final Duration duration; // 视频总时长
  final double speed; // 当前播放倍速
  final double volume; // 当前音量
  final Uint8List? snapshotBytes; // 最近一次截取的定格快照 (用于 0ms 黑屏恢复)
  final String? error; // 错误信息

  const GlobalPlayerKernelState({
    this.activeOwnerId = '',
    this.activeSession,
    this.isPlaying = false,
    this.isBuffering = false,
    this.isFirstFrameRendered = false,
    this.isCompleted = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.speed = 1.0,
    this.volume = 100.0,
    this.snapshotBytes,
    this.error,
  });

  bool isOwnerActive(String ownerId) => activeOwnerId == ownerId;

  GlobalPlayerKernelState copyWith({
    String? activeOwnerId,
    PlaybackSession? activeSession,
    bool? isPlaying,
    bool? isBuffering,
    bool? isFirstFrameRendered,
    bool? isCompleted,
    Duration? position,
    Duration? duration,
    double? speed,
    double? volume,
    Uint8List? snapshotBytes,
    String? error,
    bool clearError = false,
  }) {
    return GlobalPlayerKernelState(
      activeOwnerId: activeOwnerId ?? this.activeOwnerId,
      activeSession: activeSession ?? this.activeSession,
      isPlaying: isPlaying ?? this.isPlaying,
      isBuffering: isBuffering ?? this.isBuffering,
      isFirstFrameRendered:
          isFirstFrameRendered ?? this.isFirstFrameRendered,
      isCompleted: isCompleted ?? this.isCompleted,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      speed: speed ?? this.speed,
      volume: volume ?? this.volume,
      snapshotBytes: snapshotBytes ?? this.snapshotBytes,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// 全局单例播放器管理提供者
final globalPlayerManagerProvider =
    NotifierProvider<GlobalPlayerManager, GlobalPlayerKernelState>(
  GlobalPlayerManager.new,
);

/// 全局统一封装的 TV 播放器内核管理器 (单实例多租户核心)
/// 职责与特性：
/// 1. 深度封装 MPV 内核：对外提供标准化的 play(), pause(), togglePlay(), seekTo(), setRate() 接口
/// 2. 内部闭环处理 DASH 独立视频流 + 音频流注入与防盗链 Headers，维持音画时钟严格同步 (video-sync: audio)
/// 3. 所有权机制 (Ownership Management)：跟踪 activeOwnerId，支持组件借调、原组件状态获知与会话缓存
/// 4. 快照捕获与降级机制：切走瞬间捕获最后一帧 (screenshot)，无快照时优雅降级为高清封面图，彻底杜绝黑屏
/// 5. 原点恢复起播：原组件恢复焦点后，携带 lastPosition 原点无缝起播，零进度偏差
class GlobalPlayerManager extends Notifier<GlobalPlayerKernelState> {
  Player? _player;
  VideoController? _videoController;

  final Map<String, PlaybackSession> _cachedSessions = {};

  StreamSubscription<bool>? _playingSub;
  StreamSubscription<bool>? _bufferingSub;
  StreamSubscription<Duration>? _posSub;
  StreamSubscription<Duration>? _durSub;
  StreamSubscription<bool>? _completedSub;
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
      try {
        _videoController = TvPlayerEngineHelper.createVideoController(p);
      } catch (e) {
        debugPrint('[GlobalPlayerManager] 创建 VideoController 异常 (测试环境可忽略): $e');
      }

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
        if (dur > Duration.zero) {
          state = state.copyWith(duration: dur);
        }
      });

      _completedSub = p.stream.completed.listen((completed) {
        state = state.copyWith(isCompleted: completed);
      });

      _errSub = p.stream.error.listen((err) {
        debugPrint('[GlobalPlayerManager] 底层引擎错误: $err');
        state = state.copyWith(error: err);
      });
    } catch (e, st) {
      debugPrint('[GlobalPlayerManager] 初始化失败: $e\n$st');
    }
  }

  /// 索取播放器控制权 (支持多租户借调与原组件快照保存)
  Future<void> claimPlayer({
    required String ownerId,
    required PlaybackSession session,
    bool autoPlay = true,
  }) async {
    // 1. 若当前有其他组件占用，为原组件安全拍摄快照并缓存原会话
    if (state.activeOwnerId.isNotEmpty && state.activeOwnerId != ownerId) {
      final previousOwner = state.activeOwnerId;
      final savedSession = await pauseAndCaptureCurrentSession();
      if (savedSession != null) {
        _cachedSessions[previousOwner] = savedSession;
      }
    }

    final effectiveSession = session.copyWith(ownerId: ownerId);
    state = state.copyWith(activeOwnerId: ownerId);

    await activateSession(effectiveSession, autoPlay: autoPlay);
  }

  /// 释放播放器控制权并返回带快照的会话对象
  Future<PlaybackSession?> releasePlayer(String ownerId) async {
    if (state.activeOwnerId == ownerId) {
      final savedSession = await pauseAndCaptureCurrentSession();
      if (savedSession != null) {
        _cachedSessions[ownerId] = savedSession;
      }
      state = state.copyWith(activeOwnerId: '');
      return savedSession;
    }
    return _cachedSessions[ownerId] ?? state.activeSession;
  }

  /// 获取指定组件缓存的历史会话 (含快照与上次断点)
  PlaybackSession? getCachedSession(String ownerId) => _cachedSessions[ownerId];

  /// 激活并加载某业务会话 (音视频内部统一封装)
  Future<void> activateSession(
    PlaybackSession session, {
    bool autoPlay = true,
  }) async {
    final p = _player;
    if (p == null) return;

    final isSameStream = state.activeSession?.sessionId == session.sessionId &&
        state.activeSession?.videoUrl == session.videoUrl;

    // 若换流，重置首帧就绪状态以触发快照/封面平滑过渡
    state = state.copyWith(
      activeSession: session,
      snapshotBytes: session.lastFrameBytes,
      isFirstFrameRendered: isSameStream,
      clearError: true,
    );

    if (session.videoUrl == null || session.videoUrl!.isEmpty) return;

    if (!isSameStream) {
      // 1. 统一防盗链请求头
      final Map<String, String> headers = {
        'Referer': ApiConstants.defaultReferer,
        'User-Agent': ApiConstants.defaultUserAgent,
        ...session.httpHeaders,
      };

      // 2. 底层配置独立音频流与严格时钟同步 (video-sync: audio)
      await TvPlayerEngineHelper.configurePlatformProperties(
        p.platform,
        audioUrl: session.audioUrl,
        isLive: session.isLive,
      );

      // 3. 打开主视频流
      await p.open(
        Media(session.videoUrl!, httpHeaders: headers),
        play: autoPlay,
      );

      // 4. 原点续播：若会话记录了历史进度且大于 1 秒，精准 seek 回原点
      if (session.lastPosition > const Duration(seconds: 1)) {
        await p.seek(session.lastPosition);
      }

      // 5. 还原倍速
      if (session.speed != 1.0) {
        await p.setRate(session.speed);
      }
    } else if (autoPlay && !p.state.playing) {
      await p.play();
    }
  }

  /// 切页或借调前截取定格快照并记录进度，实现 0ms 视觉黑屏
  Future<PlaybackSession?> pauseAndCaptureCurrentSession() async {
    final p = _player;
    final current = state.activeSession;
    if (p == null || current == null) return current;

    // 1. 获取当前精确进度
    final currentPos = p.state.position;

    // 2. 截取最后一帧冻结快照 (加保护与超时，防止无活动帧时底层死等)
    Uint8List? frameBytes;
    if (state.isFirstFrameRendered && p.state.duration > Duration.zero) {
      try {
        frameBytes = await p.screenshot(format: 'image/jpeg').timeout(
          const Duration(milliseconds: 400),
          onTimeout: () => null,
        );
      } catch (e) {
        debugPrint('[GlobalPlayerManager] 截取定格快照异常: $e');
      }
    }

    // 3. 瞬间静音并暂停音频 (仅在播放中执行，带超时防锁死)
    if (p.state.playing) {
      try {
        await p.pause().timeout(
          const Duration(milliseconds: 300),
          onTimeout: () => null,
        );
      } catch (_) {}
    }

    // 4. 返回包含最新进度与冻结快照的会话对象
    final updatedSession = current.copyWith(
      lastPosition: currentPos,
      lastFrameBytes: frameBytes ?? current.lastFrameBytes,
    );

    state = state.copyWith(
      activeSession: updatedSession,
      snapshotBytes: updatedSession.lastFrameBytes,
    );
    return updatedSession;
  }

  // ================= 播放控制方法统一封装 =================

  /// 播放 (带超时与防重保护)
  Future<void> play() async {
    final p = _player;
    if (p == null || p.state.playing) return;
    try {
      await p.play().timeout(
        const Duration(milliseconds: 300),
        onTimeout: () => null,
      );
    } catch (_) {}
  }

  /// 暂停 (带超时与防重保护)
  Future<void> pause() async {
    final p = _player;
    if (p == null || !p.state.playing) return;
    try {
      await p.pause().timeout(
        const Duration(milliseconds: 300),
        onTimeout: () => null,
      );
    } catch (_) {}
  }

  /// 切换播放 / 暂停
  Future<void> togglePlay() async {
    if (state.isPlaying) {
      await pause();
    } else {
      await play();
    }
  }

  /// 进度跳转 (带范围安全钳制)
  Future<void> seekTo(Duration target) async {
    final maxDur = state.duration;
    final safeTarget = target < Duration.zero
        ? Duration.zero
        : (maxDur > Duration.zero && target > maxDur ? maxDur : target);
    try {
      await _player?.seek(safeTarget).timeout(
        const Duration(milliseconds: 400),
        onTimeout: () => null,
      );
    } catch (_) {}
  }

  /// 相对跳转 (快进 / 快退 秒数)
  Future<void> seekRelative(int seconds) async {
    final target = state.position + Duration(seconds: seconds);
    await seekTo(target);
  }

  /// 调整播放倍速
  Future<void> setRate(double rate) async {
    state = state.copyWith(speed: rate);
    try {
      await _player?.setRate(rate).timeout(
        const Duration(milliseconds: 300),
        onTimeout: () => null,
      );
    } catch (_) {}
  }

  /// 调整音量
  Future<void> setVolume(double volume) async {
    state = state.copyWith(volume: volume);
    try {
      await _player?.setVolume(volume).timeout(
        const Duration(milliseconds: 300),
        onTimeout: () => null,
      );
    } catch (_) {}
  }

  /// 快速切断音频 (离开路由第 0ms 触发)
  void stopAudio() {
    try {
      _player?.setVolume(0).catchError((_) {});
      _player?.pause().catchError((_) {});
    } catch (_) {}
  }

  /// 捕获快照 (加保护与超时，防止无活动帧时底层死等)
  Future<Uint8List?> captureSnapshot() async {
    final p = _player;
    if (p == null || !state.isFirstFrameRendered || p.state.duration == Duration.zero) {
      return null;
    }
    try {
      final bytes = await p.screenshot(format: 'image/jpeg').timeout(
        const Duration(milliseconds: 400),
        onTimeout: () => null,
      );
      if (bytes != null) {
        state = state.copyWith(snapshotBytes: bytes);
      }
      return bytes;
    } catch (e) {
      debugPrint('[GlobalPlayerManager] 截图失败: $e');
      return null;
    }
  }

  void _disposeKernel() {
    _playingSub?.cancel();
    _bufferingSub?.cancel();
    _posSub?.cancel();
    _durSub?.cancel();
    _completedSub?.cancel();
    _errSub?.cancel();

    _player?.stop();
    _player?.dispose();
    _player = null;
    _videoController = null;
  }
}

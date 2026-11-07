import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/utils/tv_player_engine_helper.dart';
import '../../data/models/live_room_item_model.dart';
import '../../data/repositories/live_repository.dart';
import 'live_player_state.dart';

/// TV 直播播放器状态机
class LivePlayerNotifier extends Notifier<LivePlayerState> {
  final int roomId;
  Player? _player;
  VideoController? _videoController;

  Timer? _hideControlsTimer;
  bool _isDisposed = false;

  StreamSubscription<bool>? _playingSub;
  StreamSubscription<bool>? _bufferingSub;
  StreamSubscription<String>? _errorSub;

  late final LiveRepository _repository;

  LivePlayerNotifier(this.roomId);

  Player? get player => _player;
  VideoController? get videoController => _videoController;

  @override
  LivePlayerState build() {
    _isDisposed = false;
    _repository = ref.read(liveRepositoryProvider);

    ref.onDispose(() {
      _stopAndDispose();
    });

    Future.microtask(() => _initLive(roomId));

    return LivePlayerState(roomId: roomId);
  }

  void _cancelSubscriptions() {
    _playingSub?.cancel();
    _bufferingSub?.cancel();
    _errorSub?.cancel();
  }

  /// 外部主动显式调用停止并销毁播放器
  void disposePlayer() {
    _stopAndDispose();
  }

  /// 瞬间静音并暂停，专用于退出路由触发的第 0 毫秒切断音频
  void pauseAndStopAudio() {
    if (_isDisposed) return;
    try {
      final p = _player;
      if (p != null) {
        p.setVolume(0).catchError((_) {});
        p.pause().catchError((_) {});
      }
    } catch (_) {}
  }

  void _stopAndDispose() {
    if (_isDisposed) return;
    _isDisposed = true;

    _hideControlsTimer?.cancel();
    _cancelSubscriptions();

    final p = _player;
    _player = null;
    _videoController = null;

    TvPlayerEngineHelper.safeDisposePlayer(p);
  }

  /// 绑定初始传入的房间元数据
  void setInitialRoomMeta(LiveRoomItemModel? room) {
    if (room != null && !_isDisposed && ref.mounted) {
      state = state.copyWith(
        title: room.title,
        uname: room.uname,
        cover: room.cover,
        onlineCount: room.online > 0 ? '${room.online}' : '',
      );
    }
  }

  /// 初始化直播流并起播
  Future<void> _initLive(int roomId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final playUrl = await _repository.fetchLivePlayUrl(roomId);
      if (_isDisposed) return;

      state = state.copyWith(streamUrl: playUrl);

      await _setupController(playUrl);
    } catch (e) {
      if (_isDisposed) return;
      debugPrint('[LivePlayer] 加载直播流异常: $e');
      state = state.copyWith(
        isLoading: false,
        error: '直播流加载失败: $e',
      );
    }
  }

  Future<void> _setupController(String playUrl) async {
    if (_isDisposed) return;

    final oldPlayer = _player;
    _player = null;
    _videoController = null;
    _cancelSubscriptions();

    if (oldPlayer != null) {
      TvPlayerEngineHelper.safeDisposePlayer(oldPlayer);
    }

    if (_isDisposed) return;

    try {
      // 1. 创建直播优化的底层 Player 实例
      final player = TvPlayerEngineHelper.createPlayer(
        bufferSize: 32 * 1024 * 1024,
      );
      _player = player;

      if (_isDisposed) {
        TvPlayerEngineHelper.safeDisposePlayer(player);
        _player = null;
        return;
      }

      final dynamic platform = player.platform;

      // 2. 针对 Android TV 大屏 MediaCodec 硬解直通与极速渲染着色器配置 (Live 模式)
      await TvPlayerEngineHelper.configurePlatformProperties(
        platform,
        isLive: true,
      );

      if (_isDisposed) {
        TvPlayerEngineHelper.safeDisposePlayer(player);
        _player = null;
        return;
      }

      // 3. 创建配置了 mediacodec + mediacodec_embed 原生 Surface 的控制器
      final controller = TvPlayerEngineHelper.createVideoController(player);
      _videoController = controller;

      // 4. 等待 Android Native Surface 完全绑定，杜绝在 Surface 缺失下提早解码
      await TvPlayerEngineHelper.waitForSurfaceReady(controller);

      if (_isDisposed) {
        TvPlayerEngineHelper.safeDisposePlayer(player);
        _player = null;
        _videoController = null;
        return;
      }

      _cancelSubscriptions();

      _playingSub = player.stream.playing.listen((isPlaying) {
        if (!_isDisposed && ref.mounted) {
          state = state.copyWith(isPlaying: isPlaying);
        }
      });

      _bufferingSub = player.stream.buffering.listen((isBuffering) {
        if (!_isDisposed && ref.mounted) {
          state = state.copyWith(isBuffering: isBuffering);
        }
      });

      _errorSub = player.stream.error.listen((err) {
        debugPrint('[LivePlayer] 播放器底层错误: $err');
      });

      await player.open(
        Media(
          playUrl,
          httpHeaders: {
            'Referer': 'https://live.bilibili.com',
            'User-Agent': ApiConstants.defaultUserAgent,
          },
        ),
        play: true,
      );

      if (!_isDisposed && ref.mounted) {
        state = state.copyWith(
          isLoading: false,
          isPlaying: true,
          error: null,
        );
        _resetHideControlsTimer();
      }
    } catch (e) {
      if (_isDisposed) return;
      debugPrint('[LivePlayer] 初始化直播引擎异常: $e');
      state = state.copyWith(
        isLoading: false,
        error: '直播引擎初始化失败: $e',
      );
    }
  }

  void togglePlay() {
    _player?.playOrPause();
    _resetHideControlsTimer();
  }

  void toggleControls() {
    if (state.showControls) {
      hideControls();
    } else {
      showControlsTemporarily();
    }
  }

  void showControlsTemporarily() {
    state = state.copyWith(showControls: true);
    _resetHideControlsTimer();
  }

  void hideControls() {
    _hideControlsTimer?.cancel();
    state = state.copyWith(showControls: false);
  }

  void _resetHideControlsTimer() {
    _hideControlsTimer?.cancel();
    if (!state.showControls) return;
    _hideControlsTimer = Timer(const Duration(seconds: 5), () {
      if (!_isDisposed && ref.mounted && state.showControls) {
        state = state.copyWith(showControls: false);
      }
    });
  }

  Future<void> retry() async {
    await _initLive(roomId);
  }
}

/// Live Player Provider (基于 roomId autoDispose)
final livePlayerProvider = NotifierProvider.autoDispose
    .family<LivePlayerNotifier, LivePlayerState, int>(
  LivePlayerNotifier.new,
);

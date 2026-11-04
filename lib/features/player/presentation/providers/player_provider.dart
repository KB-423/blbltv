import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart' hide PlayerState;
import 'package:media_kit_video/media_kit_video.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/storage/storage_service.dart';
import '../../data/repositories/player_repository.dart';
import 'player_state.dart';

/// TV 播放器控制器与状态管理 (基于 MediaKit，跨 Linux Desktop 与 Android TV 大屏通用)
class PlayerNotifier extends Notifier<PlayerState> {
  final String bvid;
  Player? _player;
  VideoController? _videoController;
  Timer? _hideControlsTimer;

  StreamSubscription<Duration>? _posSub;
  StreamSubscription<Duration>? _durSub;
  StreamSubscription<bool>? _playingSub;
  StreamSubscription<bool>? _bufferingSub;
  StreamSubscription<String>? _errorSub;

  PlayerNotifier(this.bvid);

  VideoController? get videoController => _videoController;

  @override
  PlayerState build() {
    ref.onDispose(() {
      _hideControlsTimer?.cancel();
      _cancelSubscriptions();
      _player?.dispose();
    });

    // 启动异步加载视频
    Future.microtask(() => _initVideo(bvid));
    return PlayerState(bvid: bvid);
  }

  PlayerRepository get _repository => ref.read(playerRepositoryProvider);

  void _cancelSubscriptions() {
    _posSub?.cancel();
    _durSub?.cancel();
    _playingSub?.cancel();
    _bufferingSub?.cancel();
    _errorSub?.cancel();
  }

  /// 初始化视频流
  Future<void> _initVideo(String bvid) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // 1. 获取视频详情 (title, cid)
      final detail = await _repository.fetchVideoDetail(bvid);
      state = state.copyWith(
        title: detail.title,
        cid: detail.cid,
        duration: Duration(seconds: detail.durationSeconds),
      );

      // 2. 获取播放流 (优先申请用户手动设置的偏好画质，默认 120/4K 超清规格)
      final preferredQn = ref.read(storageServiceProvider).preferredQuality;
      final playInfo = await _repository.fetchPlayUrl(
        bvid: bvid,
        cid: detail.cid,
        qn: preferredQn,
      );

      state = state.copyWith(
        currentUrl: playInfo.playUrl,
        currentAudioUrl: playInfo.audioUrl,
        currentQn: playInfo.currentQn,
        qualities: playInfo.qualities,
      );

      // 3. 初始化播放器引擎
      await _setupController(
        playInfo.playUrl,
        audioUrl: playInfo.audioUrl,
      );
    } catch (e) {
      debugPrint('[PlayerNotifier] 初始化异常: $e');
      state = state.copyWith(
        isLoading: false,
        error: '视频加载失败: $e',
      );
    }
  }

  /// 错误重试加载视频
  Future<void> retry() async {
    await _initVideo(bvid);
  }

  /// 创建并挂载 MediaKit Player 与 VideoController
  Future<void> _setupController(
    String url, {
    String audioUrl = '',
    Duration startPosition = Duration.zero,
  }) async {
    final oldPlayer = _player;
    _player = null;
    _videoController = null;
    _cancelSubscriptions();
    await oldPlayer?.dispose();

    try {
      final player = Player();
      final videoController = VideoController(player);

      _posSub = player.stream.position.listen((pos) {
        state = state.copyWith(position: pos);
      });

      _durSub = player.stream.duration.listen((dur) {
        if (dur > Duration.zero) {
          state = state.copyWith(duration: dur);
        }
      });

      _playingSub = player.stream.playing.listen((playing) {
        state = state.copyWith(isPlaying: playing);
      });

      _bufferingSub = player.stream.buffering.listen((buffering) {
        state = state.copyWith(isBuffering: buffering);
      });

      _errorSub = player.stream.error.listen((err) {
        debugPrint('[PlayerNotifier] MediaKit error: $err');
      });

      _player = player;
      _videoController = videoController;

      await player.open(
        Media(
          url,
          httpHeaders: const {
            'Referer': ApiConstants.defaultReferer,
            'User-Agent': ApiConstants.defaultUserAgent,
          },
        ),
        play: true,
      );

      // 加载 DASH 独立音轨
      if (audioUrl.isNotEmpty) {
        await player.setAudioTrack(
          AudioTrack.uri(
            audioUrl,
            title: 'Bilibili Audio',
          ),
        );
      }

      if (startPosition > Duration.zero) {
        await player.seek(startPosition);
      }

      state = state.copyWith(
        isLoading: false,
        isPlaying: true,
        error: null,
      );

      _resetHideControlsTimer();
    } catch (e) {
      debugPrint('[PlayerNotifier] 播放器初始化错误: $e');
      state = state.copyWith(
        isLoading: false,
        error: '视频流解析失败，请尝试切换画质或重试: $e',
      );
    }
  }

  /// 切换播放/暂停
  void togglePlay() {
    final p = _player;
    if (p == null) return;

    p.playOrPause();
    showControlsTemporarily();
  }

  /// 遥控器快进
  void seekForward({int seconds = 10}) {
    final p = _player;
    if (p == null) return;

    final target = p.state.position + Duration(seconds: seconds);
    final max = p.state.duration;
    p.seek(target > max ? max : target);
    showControlsTemporarily();
  }

  /// 遥控器快退
  void seekBackward({int seconds = 10}) {
    final p = _player;
    if (p == null) return;

    final target = p.state.position - Duration(seconds: seconds);
    p.seek(target < Duration.zero ? Duration.zero : target);
    showControlsTemporarily();
  }

  /// 切换画质 (无缝记忆播放进度)
  Future<void> changeQuality(int targetQn) async {
    if (targetQn == state.currentQn || state.isLoading) {
      closeQualityPanel();
      return;
    }

    final currentPos = _player?.state.position ?? Duration.zero;
    state = state.copyWith(
      isLoading: true,
      showQualityPanel: false,
    );

    try {
      final playInfo = await _repository.fetchPlayUrl(
        bvid: state.bvid,
        cid: state.cid,
        qn: targetQn,
      );

      // 持久化用户选择的画质偏好，后续打开任何视频优先尝试该画质
      await ref.read(storageServiceProvider).setPreferredQuality(targetQn);

      state = state.copyWith(
        currentUrl: playInfo.playUrl,
        currentAudioUrl: playInfo.audioUrl,
        currentQn: playInfo.currentQn,
        qualities: playInfo.qualities.isNotEmpty ? playInfo.qualities : state.qualities,
      );

      // 用保存的播放进度无缝切换流
      await _setupController(
        playInfo.playUrl,
        audioUrl: playInfo.audioUrl,
        startPosition: currentPos,
      );
    } catch (e) {
      debugPrint('[PlayerNotifier] 切换画质失败: $e');
      state = state.copyWith(
        isLoading: false,
        error: '切换画质失败: $e',
      );
    }
  }

  /// 显示/隐藏控制栏
  void toggleControls() {
    state = state.copyWith(showControls: !state.showControls);
    if (state.showControls) {
      _resetHideControlsTimer();
    } else {
      _hideControlsTimer?.cancel();
    }
  }

  void showControlsTemporarily() {
    state = state.copyWith(showControls: true);
    _resetHideControlsTimer();
  }

  void _resetHideControlsTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 5), () {
      if (state.showControls && !state.showQualityPanel) {
        state = state.copyWith(showControls: false);
      }
    });
  }

  /// 打开画质选择面板
  void openQualityPanel() {
    _hideControlsTimer?.cancel();
    state = state.copyWith(showQualityPanel: true, showControls: true);
  }

  /// 关闭画质选择面板
  void closeQualityPanel() {
    state = state.copyWith(showQualityPanel: false);
    _resetHideControlsTimer();
  }
}

/// Family Provider，基于 bvid 独立创建和管理播放器状态
final playerProvider =
    NotifierProvider.autoDispose.family<PlayerNotifier, PlayerState, String>(
  PlayerNotifier.new,
);

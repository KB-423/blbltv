import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/storage/storage_service.dart';
import '../../../player/data/repositories/player_repository.dart';
import '../../data/models/bangumi_episode_model.dart';
import '../../data/repositories/bangumi_repository.dart';
import 'bangumi_player_state.dart';

/// TV 番剧播放器状态机
class BangumiPlayerNotifier extends Notifier<BangumiPlayerState> {
  final int seasonId;
  Player? _player;
  VideoController? _videoController;

  Timer? _hideControlsTimer;
  Timer? _heartbeatTimer;
  bool _isDisposed = false;

  StreamSubscription<Duration>? _posSub;
  StreamSubscription<Duration>? _durSub;
  StreamSubscription<bool>? _playingSub;
  StreamSubscription<bool>? _bufferingSub;
  StreamSubscription<bool>? _completedSub;

  late final BangumiRepository _bangumiRepository;
  late final PlayerRepository _playerRepository;
  late final StorageService _storageService;

  BangumiPlayerNotifier(this.seasonId);

  Player? get player => _player;
  VideoController? get videoController => _videoController;

  @override
  BangumiPlayerState build() {
    _isDisposed = false;
    _bangumiRepository = ref.read(bangumiRepositoryProvider);
    _playerRepository = ref.read(playerRepositoryProvider);
    _storageService = ref.read(storageServiceProvider);

    ref.onDispose(() {
      _stopAndDispose();
    });

    Future.microtask(() => _initSeason(seasonId));

    return BangumiPlayerState(seasonId: seasonId);
  }

  void _cancelSubscriptions() {
    _posSub?.cancel();
    _durSub?.cancel();
    _playingSub?.cancel();
    _bufferingSub?.cancel();
    _completedSub?.cancel();
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

  void _safeDisposePlayer(Player? p) {
    if (p == null) return;
    try {
      p.setVolume(0).catchError((_) {});
    } catch (_) {}
    try {
      p.pause().catchError((_) {});
    } catch (_) {}
    try {
      p.stop().catchError((_) {});
    } catch (_) {}
    try {
      p.dispose().catchError((_) {});
    } catch (_) {}
  }

  void _stopAndDispose() {
    if (_isDisposed) return;
    _isDisposed = true;

    _hideControlsTimer?.cancel();
    _heartbeatTimer?.cancel();
    _cancelSubscriptions();

    final p = _player;
    _player = null;
    _videoController = null;

    _safeDisposePlayer(p);
  }

  /// 初始化番剧并起播
  Future<void> _initSeason(int seasonId, {int targetEpIndex = 0}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final (seasonTitle, episodes) =
          await _bangumiRepository.fetchSeasonEpisodes(seasonId);
      if (_isDisposed) return;

      if (episodes.isEmpty) {
        throw Exception('该番剧暂无可播放剧集');
      }

      final validIndex =
          targetEpIndex.clamp(0, episodes.length - 1).toInt();
      state = state.copyWith(
        seasonTitle: seasonTitle,
        episodes: episodes,
        currentEpIndex: validIndex,
      );

      await _playEpisode(episodes[validIndex]);
    } catch (e) {
      if (_isDisposed) return;
      debugPrint('[BangumiPlayer] 初始化番剧异常: $e');
      state = state.copyWith(
        isLoading: false,
        error: '番剧加载失败: $e',
      );
    }
  }

  /// 播放指定剧集
  Future<void> _playEpisode(BangumiEpisodeModel episode) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final preferredQn = _storageService.preferredQuality;
      final playInfo = await _playerRepository.fetchPlayUrl(
        bvid: episode.bvid,
        cid: episode.cid,
        qn: preferredQn,
      );
      if (_isDisposed) return;

      state = state.copyWith(
        currentPlayUrl: playInfo.playUrl,
        currentAudioUrl: playInfo.audioUrl,
        currentQn: playInfo.currentQn,
        qualities: playInfo.qualities,
      );

      await _setupController(
        playInfo.playUrl,
        audioUrl: playInfo.audioUrl,
        targetQn: playInfo.currentQn,
      );
    } catch (e) {
      if (_isDisposed) return;
      debugPrint('[BangumiPlayer] 播放剧集失败: $e');
      state = state.copyWith(
        isLoading: false,
        error: '剧集加载失败: $e',
      );
    }
  }

  /// 配置 MediaKit 引擎并挂载
  Future<void> _setupController(
    String videoUrl, {
    String audioUrl = '',
    int targetQn = 80,
  }) async {
    final oldPlayer = _player;
    _player = null;
    _videoController = null;
    _safeDisposePlayer(oldPlayer);

    try {
      final player = Player(
        configuration: const PlayerConfiguration(
          bufferSize: 64 * 1024 * 1024,
        ),
      );
      _player = player;

      final controller = VideoController(
        player,
        configuration: const VideoControllerConfiguration(
          enableHardwareAcceleration: true,
          androidAttachSurfaceAfterVideoParameters: true,
        ),
      );
      _videoController = controller;

      final dynamic platform = player.platform;
      if (Platform.isAndroid) {
        await platform?.setProperty('volume-max', '100');
        await platform?.setProperty('ao', 'opensles');
        await platform?.setProperty('hwdec', 'mediacodec_embed');
        await platform?.setProperty('opengl-es', 'yes');
        await platform?.setProperty('video-sync', 'audio');
        await platform?.setProperty('hr-seek', 'yes');
        await platform?.setProperty('hr-seek-framedrop', 'yes');
        await platform?.setProperty('autosync', '30');
      }

      _cancelSubscriptions();

      _posSub = player.stream.position.listen((pos) {
        if (!_isDisposed && ref.mounted) {
          state = state.copyWith(position: pos);
        }
      });

      _durSub = player.stream.duration.listen((dur) {
        if (!_isDisposed && ref.mounted && dur > Duration.zero) {
          state = state.copyWith(duration: dur);
        }
      });

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

      _completedSub = player.stream.completed.listen((completed) {
        if (!_isDisposed && ref.mounted && completed) {
          _onPlaybackCompleted();
        }
      });

      final headers = {
        'Referer': ApiConstants.defaultReferer,
        'User-Agent': ApiConstants.defaultUserAgent,
      };

      final media = Media(
        videoUrl,
        httpHeaders: headers,
        extras: audioUrl.isNotEmpty
            ? {
                'audio-resource': audioUrl,
                'audio-headers': headers,
              }
            : null,
      );

      await player.open(media, play: true);

      if (!_isDisposed && ref.mounted) {
        state = state.copyWith(
          isLoading: false,
          isPlaying: true,
          currentQn: targetQn,
        );
        _resetHideControlsTimer();
      }
    } catch (e) {
      if (_isDisposed) return;
      debugPrint('[BangumiPlayer] 初始化播放引擎异常: $e');
      state = state.copyWith(
        isLoading: false,
        error: '播放引擎初始化失败: $e',
      );
    }
  }

  /// 剧集播放完成自动连播下一集
  void _onPlaybackCompleted() {
    final nextIndex = state.currentEpIndex + 1;
    if (nextIndex < state.episodes.length) {
      debugPrint('[BangumiPlayer] 当前集播放完毕，自动连播下一集: index=$nextIndex');
      changeEpisode(nextIndex);
    }
  }

  /// 切换剧集
  Future<void> changeEpisode(int index) async {
    if (index < 0 || index >= state.episodes.length) return;
    state = state.copyWith(
      currentEpIndex: index,
      showEpisodeDrawer: false,
    );
    await _playEpisode(state.episodes[index]);
  }

  /// 切换清晰度 (记忆续播)
  Future<void> changeQuality(int targetQn) async {
    if (targetQn == state.currentQn) {
      closeQualityPanel();
      return;
    }

    final curEp = state.episodes.isNotEmpty
        ? state.episodes[state.currentEpIndex]
        : null;
    if (curEp == null) return;

    final currentPos = _player?.state.position ?? state.position;
    state = state.copyWith(isLoading: true, showQualityPanel: false);

    try {
      final playInfo = await _playerRepository.fetchPlayUrl(
        bvid: curEp.bvid,
        cid: curEp.cid,
        qn: targetQn,
      );
      if (_isDisposed) return;

      state = state.copyWith(
        currentPlayUrl: playInfo.playUrl,
        currentAudioUrl: playInfo.audioUrl,
        currentQn: playInfo.currentQn,
        qualities: playInfo.qualities,
      );

      await _setupController(
        playInfo.playUrl,
        audioUrl: playInfo.audioUrl,
        targetQn: playInfo.currentQn,
      );

      if (currentPos > Duration.zero) {
        await _player?.seek(currentPos);
      }
    } catch (e) {
      if (_isDisposed) return;
      debugPrint('[BangumiPlayer] 切换画质异常: $e');
      state = state.copyWith(
        isLoading: false,
        error: '画质切换失败: $e',
      );
    }
  }

  void togglePlay() {
    _player?.playOrPause();
    _resetHideControlsTimer();
  }

  void seekTo(Duration target) {
    _player?.seek(target);
    _resetHideControlsTimer();
  }

  void seekForward({int seconds = 10}) {
    final cur = _player?.state.position ?? state.position;
    seekTo(cur + Duration(seconds: seconds));
  }

  void seekBackward({int seconds = 10}) {
    final cur = _player?.state.position ?? state.position;
    final target = cur - Duration(seconds: seconds);
    seekTo(target < Duration.zero ? Duration.zero : target);
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
    state = state.copyWith(
      showControls: false,
      showQualityPanel: false,
      showEpisodeDrawer: false,
    );
  }

  void _resetHideControlsTimer() {
    _hideControlsTimer?.cancel();
    if (!state.showQualityPanel && !state.showEpisodeDrawer) {
      _hideControlsTimer = Timer(const Duration(seconds: 5), () {
        if (!_isDisposed && ref.mounted && state.showControls) {
          state = state.copyWith(showControls: false);
        }
      });
    }
  }

  void openEpisodeDrawer() {
    _hideControlsTimer?.cancel();
    state = state.copyWith(
      showEpisodeDrawer: true,
      showQualityPanel: false,
      showControls: true,
    );
  }

  void closeEpisodeDrawer() {
    state = state.copyWith(showEpisodeDrawer: false);
    _resetHideControlsTimer();
  }

  void openQualityPanel() {
    _hideControlsTimer?.cancel();
    state = state.copyWith(
      showQualityPanel: true,
      showEpisodeDrawer: false,
      showControls: true,
    );
  }

  void closeQualityPanel() {
    state = state.copyWith(showQualityPanel: false);
    _resetHideControlsTimer();
  }

  Future<void> retry() async {
    await _initSeason(seasonId, targetEpIndex: state.currentEpIndex);
  }
}

/// Bangumi Player Provider (基于 seasonId autoDispose)
final bangumiPlayerProvider = NotifierProvider.autoDispose
    .family<BangumiPlayerNotifier, BangumiPlayerState, int>(
  BangumiPlayerNotifier.new,
);

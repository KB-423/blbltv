import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart' hide PlayerState;
import 'package:media_kit_video/media_kit_video.dart';

import '../../../../core/player/global_player_manager.dart';
import '../../../../core/player/playback_session.dart';
import '../../../../core/storage/storage_service.dart';
import '../../../../models/video/video_item_model.dart';
import '../../../home/presentation/providers/recommend_player_state.dart';
import '../../../main/presentation/providers/nav_rail_focus_provider.dart';
import '../../../player/data/repositories/player_repository.dart';
import 'popular_provider.dart';

/// 热门流全屏背景播放器状态机 (与推荐流统一使用全局单例内核)
class PopularPlayerNotifier extends Notifier<RecommendPlayerState> {
  Player? _player;
  VideoController? _videoController;

  Timer? _idleTimer;
  Timer? _hoverPlayTimer;
  Timer? _heartbeatTimer;
  bool _isDisposed = false;
  bool _hasStartedInitialVideo = false;

  StreamSubscription<Duration>? _posSub;
  StreamSubscription<Duration>? _durSub;
  StreamSubscription<bool>? _playingSub;
  StreamSubscription<bool>? _bufferingSub;
  StreamSubscription<bool>? _completedSub;
  StreamSubscription<String>? _errorSub;

  late final PlayerRepository _playerRepository;
  late final StorageService _storageService;

  Player? get player =>
      _player ??
      (ref.mounted
          ? ref.read(globalPlayerManagerProvider.notifier).player
          : null);
  VideoController? get videoController =>
      _videoController ??
      (ref.mounted
          ? ref.read(globalPlayerManagerProvider.notifier).videoController
          : null);

  @override
  RecommendPlayerState build() {
    _isDisposed = false;
    _hasStartedInitialVideo = false;
    _playerRepository = ref.read(playerRepositoryProvider);
    _storageService = ref.read(storageServiceProvider);

    ref.onDispose(() {
      _stopAndDispose();
    });

    // 监听热门视频流数据：数据就绪后默认起播第 1 个视频
    ref.listen(popularFeedProvider, (prev, next) {
      if (!_hasStartedInitialVideo && next.videos.isNotEmpty) {
        _hasStartedInitialVideo = true;
        Future.microtask(() => playAt(0));
      }
    });

    final initialVideos = ref.read(popularFeedProvider).videos;
    if (initialVideos.isNotEmpty) {
      _hasStartedInitialVideo = true;
      Future.microtask(() => playAt(0));
    }

    return const RecommendPlayerState();
  }

  void _cancelSubscriptions() {
    _posSub?.cancel();
    _durSub?.cancel();
    _playingSub?.cancel();
    _bufferingSub?.cancel();
    _completedSub?.cancel();
    _errorSub?.cancel();
  }

  void pauseAndStopAudio() {
    if (_isDisposed) return;
    try {
      if (ref.mounted) {
        ref
            .read(globalPlayerManagerProvider.notifier)
            .pauseAndCaptureCurrentSession();
      }
    } catch (_) {}
  }

  void _stopAndDispose() {
    if (_isDisposed) return;
    _isDisposed = true;

    _idleTimer?.cancel();
    _hoverPlayTimer?.cancel();
    _heartbeatTimer?.cancel();
    _cancelSubscriptions();

    try {
      if (ref.mounted) {
        ref
            .read(globalPlayerManagerProvider.notifier)
            .pauseAndCaptureCurrentSession();
      }
    } catch (_) {}

    _player = null;
    _videoController = null;
  }

  void resetIdleTimer() {
    _idleTimer?.cancel();
    if (!state.isPurePlayback && !state.showControls) {
      _idleTimer = Timer(const Duration(seconds: 5), () {
        if (!_isDisposed && ref.mounted) {
          enterPurePlayback();
        }
      });
    }
  }

  void scheduleHoverPlay(int index) {
    _hoverPlayTimer?.cancel();
    if (index < 0 || index == state.currentIndex) return;

    _hoverPlayTimer = Timer(const Duration(seconds: 3), () {
      if (!_isDisposed && ref.mounted) {
        final videos = ref.read(popularFeedProvider).videos;
        if (index < videos.length) {
          playAt(index, resetIdle: false);
        }
      }
    });
  }

  void cancelHoverPlay() {
    _hoverPlayTimer?.cancel();
    _hoverPlayTimer = null;
  }

  void enterPurePlayback() {
    _idleTimer?.cancel();
    cancelHoverPlay();
    state = state.copyWith(
      isPurePlayback: true,
      showControls: false,
    );
    ref.read(topBarDisplayModeProvider.notifier).hide();
  }

  void exitPurePlayback() {
    state = state.copyWith(
      isPurePlayback: false,
      showControls: false,
    );
    ref.read(topBarDisplayModeProvider.notifier).showFull();
    resetIdleTimer();
  }

  void toggleControls() {
    if (state.showControls) {
      closeControls();
    } else {
      openControls();
    }
  }

  void openControls() {
    _idleTimer?.cancel();
    state = state.copyWith(showControls: true);
  }

  void closeControls() {
    state = state.copyWith(showControls: false);
    if (!state.isPurePlayback) {
      resetIdleTimer();
    }
  }

  Future<void> playVideo(
    VideoItemModel targetVideo, {
    Duration startPosition = Duration.zero,
    bool resetIdle = true,
  }) async {
    final videos = ref.read(popularFeedProvider).videos;
    final existingIdx = videos.indexWhere((v) => v.bvid == targetVideo.bvid);
    final idx = existingIdx >= 0 ? existingIdx : state.currentIndex;

    state = state.copyWith(
      currentIndex: idx,
      currentVideo: targetVideo,
      isLoading: true,
      error: null,
    );

    if (resetIdle) {
      resetIdleTimer();
    }

    try {
      int cid = targetVideo.cid;
      VideoItemModel actualVideo = targetVideo;

      if (cid <= 0 && targetVideo.bvid.isNotEmpty) {
        final detail =
            await _playerRepository.fetchFullVideoDetail(targetVideo.bvid);
        cid = detail.cid;
        actualVideo = targetVideo.copyWith(
          cid: cid,
          title: detail.title.isNotEmpty ? detail.title : targetVideo.title,
          owner: detail.owner ?? targetVideo.owner,
          stat: detail.stat ?? targetVideo.stat,
          duration: detail.durationSeconds > 0
              ? detail.durationSeconds
              : targetVideo.duration,
        );
      }

      if (_isDisposed) return;

      final preferredQn = _storageService.preferredQuality;
      final playInfo = await _playerRepository.fetchPlayUrl(
        bvid: actualVideo.bvid,
        cid: cid,
        qn: preferredQn,
      );
      if (_isDisposed) return;

      state = state.copyWith(
        currentVideo: actualVideo,
        currentPlayUrl: playInfo.playUrl,
        currentAudioUrl: playInfo.audioUrl,
        currentQn: playInfo.currentQn,
        qualities: playInfo.qualities,
      );

      await _setupController(
        playInfo.playUrl,
        audioUrl: playInfo.audioUrl,
        targetQn: playInfo.currentQn,
        startPosition: startPosition,
      );
    } catch (e) {
      if (_isDisposed) return;
      debugPrint('[PopularPlayer] 播放热门视频失败: $e');
      state = state.copyWith(
        isLoading: false,
        error: '视频加载失败: $e',
      );
    }
  }

  Future<void> playAt(
    int index, {
    Duration startPosition = Duration.zero,
    bool resetIdle = true,
  }) async {
    final videos = ref.read(popularFeedProvider).videos;
    if (index < 0 || index >= videos.length) return;

    if (index >= videos.length - 4) {
      ref.read(popularFeedProvider.notifier).loadMore();
    }

    await playVideo(
      videos[index],
      startPosition: startPosition,
      resetIdle: resetIdle,
    );
  }

  Future<void> playPrevious() async {
    if (state.currentIndex > 0) {
      await playAt(state.currentIndex - 1);
    }
  }

  Future<void> playNext() async {
    final videos = ref.read(popularFeedProvider).videos;
    if (state.currentIndex < videos.length - 1) {
      await playAt(state.currentIndex + 1);
    }
  }

  Future<void> _setupController(
    String videoUrl, {
    String audioUrl = '',
    int targetQn = 80,
    Duration startPosition = Duration.zero,
  }) async {
    if (_isDisposed) return;

    _cancelSubscriptions();
    _heartbeatTimer?.cancel();

    final globalManager = ref.read(globalPlayerManagerProvider.notifier);
    final player = globalManager.player;
    final controller = globalManager.videoController;
    _player = player;
    _videoController = controller;

    if (player == null) return;

    final session = PlaybackSession(
      sessionId: 'popular_${state.currentVideo?.bvid ?? ""}',
      playlist: ref.read(popularFeedProvider).videos,
      currentIndex: state.currentIndex,
      currentVideo: state.currentVideo,
      videoUrl: videoUrl,
      audioUrl: audioUrl,
      coverUrl: state.currentVideo?.pic,
      lastPosition: startPosition,
      quality: targetQn,
    );

    await globalManager.activateSession(session, autoPlay: true);

    bool isWaitingInitialSeek = startPosition > Duration.zero;

    _posSub = player.stream.position.listen((pos) {
      if (!_isDisposed && ref.mounted) {
        if (isWaitingInitialSeek) {
          if (pos == Duration.zero) return;
          isWaitingInitialSeek = false;
        }
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
        playNext();
      }
    });

    _errorSub = player.stream.error.listen((err) {
      debugPrint('[PopularPlayer] MediaKit 错误: $err');
    });

    if (state.speed != 1.0) {
      await player.setRate(state.speed);
    }

    if (!_isDisposed && ref.mounted) {
      state = state.copyWith(
        isLoading: false,
        isPlaying: true,
        currentQn: targetQn,
        error: null,
      );
    }
  }

  void togglePlay() {
    _player?.playOrPause();
  }

  void seekTo(Duration target) {
    final maxDur = state.duration;
    final safeTarget = target < Duration.zero
        ? Duration.zero
        : (maxDur > Duration.zero && target > maxDur ? maxDur : target);
    _player?.seek(safeTarget);
  }
}

final popularPlayerProvider =
    NotifierProvider<PopularPlayerNotifier, RecommendPlayerState>(
  PopularPlayerNotifier.new,
);

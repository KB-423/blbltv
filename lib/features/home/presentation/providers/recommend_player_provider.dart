import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart' hide PlayerState;
import 'package:media_kit_video/media_kit_video.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/storage/storage_service.dart';
import '../../../../core/utils/tv_player_engine_helper.dart';
import '../../../../models/video/video_item_model.dart';
import '../../../main/presentation/providers/nav_rail_focus_provider.dart';
import '../../../player/data/repositories/player_repository.dart';
import 'home_provider.dart';
import 'recommend_player_state.dart';

/// TV 推荐流全屏背景播放器状态机
class RecommendPlayerNotifier extends Notifier<RecommendPlayerState> {
  Player? _player;
  VideoController? _videoController;

  Timer? _idleTimer;
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

  Player? get player => _player;
  VideoController? get videoController => _videoController;

  @override
  RecommendPlayerState build() {
    _isDisposed = false;
    _hasStartedInitialVideo = false;
    _playerRepository = ref.read(playerRepositoryProvider);
    _storageService = ref.read(storageServiceProvider);

    ref.onDispose(() {
      _stopAndDispose();
    });

    // 监听首页推荐数据流：一旦推荐数据就绪，默认起播第 1 个视频
    ref.listen(homeFeedProvider, (prev, next) {
      if (!_hasStartedInitialVideo && next.videos.isNotEmpty) {
        _hasStartedInitialVideo = true;
        Future.microtask(() => playAt(0));
      }
    });

    // 检查初始是否已有视频
    final initialVideos = ref.read(homeFeedProvider).videos;
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
    reportHistoryHeartbeat();
    _isDisposed = true;

    _idleTimer?.cancel();
    _heartbeatTimer?.cancel();
    _cancelSubscriptions();

    final p = _player;
    _player = null;
    _videoController = null;

    TvPlayerEngineHelper.safeDisposePlayer(p);
  }

  /// 向 B 站官方上报播放心跳进度，确保观看记录进入云端历史
  void reportHistoryHeartbeat() {
    if (_isDisposed) return;
    try {
      final videos = ref.read(homeFeedProvider).videos;
      final cur = state.currentVideo ??
          (videos.isNotEmpty && state.currentIndex < videos.length
              ? videos[state.currentIndex]
              : null);
      if (cur != null && cur.bvid.isNotEmpty && cur.cid > 0) {
        final playedSec =
            _player?.state.position.inSeconds ?? state.position.inSeconds;
        _playerRepository.reportHeartbeat(
          bvid: cur.bvid,
          cid: cur.cid,
          playedTime: playedSec,
          duration: state.duration.inSeconds,
        );
      }
    } catch (_) {}
  }

  /// 重置 3 秒无操作定时器（在左侧卡片未隐藏时，任何按键操作均重置该计时）
  void resetIdleTimer() {
    _idleTimer?.cancel();
    if (!state.isPurePlayback && !state.showControls) {
      _idleTimer = Timer(const Duration(seconds: 3), () {
        if (!_isDisposed && ref.mounted) {
          enterPurePlayback();
        }
      });
    }
  }

  /// 进入纯享播放模式（左侧卡片与顶栏全部淡出隐藏）
  void enterPurePlayback() {
    _idleTimer?.cancel();
    state = state.copyWith(
      isPurePlayback: true,
      showControls: false,
    );
    ref.read(topBarDisplayModeProvider.notifier).hide();
  }

  /// 退出纯享播放模式（重新唤出左侧推荐列表与顶部栏）
  void exitPurePlayback() {
    state = state.copyWith(
      isPurePlayback: false,
      showControls: false,
    );
    ref.read(topBarDisplayModeProvider.notifier).showFull();
    resetIdleTimer();
  }

  /// 切换播放器控制浮层显隐
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

  /// 播放指定视频对象 (支持来自推荐流、合集、UP主作品或相关推荐)
  Future<void> playVideo(
    VideoItemModel targetVideo, {
    Duration startPosition = Duration.zero,
  }) async {
    final videos = ref.read(homeFeedProvider).videos;
    final existingIdx = videos.indexWhere((v) => v.bvid == targetVideo.bvid);
    final idx = existingIdx >= 0 ? existingIdx : state.currentIndex;

    state = state.copyWith(
      currentIndex: idx,
      currentVideo: targetVideo,
      isLoading: true,
      error: null,
    );

    resetIdleTimer();

    try {
      int cid = targetVideo.cid;
      VideoItemModel actualVideo = targetVideo;

      // 若未携带有效 cid，异步从详情接口拉取
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

      // 并行异步加载额外数据（在线人数、合集、UP主作品、相关推荐、点赞状态）
      _loadExtraDetails(actualVideo);
    } catch (e) {
      if (_isDisposed) return;
      debugPrint('[RecommendPlayer] 播放视频失败: $e');
      state = state.copyWith(
        isLoading: false,
        error: '视频加载失败: $e',
      );
    }
  }

  /// 播放指定 BVID 的视频
  Future<void> playBvid(
    String bvid, {
    int cid = 0,
    Duration startPosition = Duration.zero,
  }) async {
    final video = VideoItemModel(
      bvid: bvid,
      cid: cid,
      title: '加载中...',
    );
    await playVideo(video, startPosition: startPosition);
  }

  /// 播放指定索引的推荐视频
  Future<void> playAt(
    int index, {
    Duration startPosition = Duration.zero,
  }) async {
    final videos = ref.read(homeFeedProvider).videos;
    if (index < 0 || index >= videos.length) return;

    // 预加载下一页
    if (index >= videos.length - 4) {
      ref.read(homeFeedProvider.notifier).loadMore();
    }

    await playVideo(videos[index], startPosition: startPosition);
  }

  /// 即时上下键切台：上一个视频（在纯享模式下保持纯享）
  Future<void> playPrevious() async {
    if (state.currentIndex > 0) {
      await playAt(state.currentIndex - 1);
    }
  }

  /// 即时上下键切台：下一个视频（在纯享模式下保持纯享）
  Future<void> playNext() async {
    final videos = ref.read(homeFeedProvider).videos;
    if (state.currentIndex + 1 < videos.length) {
      await playAt(state.currentIndex + 1);
    } else {
      await ref.read(homeFeedProvider.notifier).loadMore();
      final updatedVideos = ref.read(homeFeedProvider).videos;
      if (state.currentIndex + 1 < updatedVideos.length) {
        await playAt(state.currentIndex + 1);
      }
    }
  }

  /// 异步并行加载当前视频的合集、UP主作品、相关推荐与点赞
  void _loadExtraDetails(VideoItemModel video) {
    // 1. 在线人数
    _playerRepository
        .fetchOnlineTotal(bvid: video.bvid, cid: video.cid)
        .then((total) {
      if (!_isDisposed && ref.mounted) {
        state = state.copyWith(onlineCount: total);
      }
    }).catchError((_) {});

    // 2. 点赞状态
    _playerRepository.fetchHasLike(video.bvid).then((hasLike) {
      if (!_isDisposed && ref.mounted) {
        state = state.copyWith(hasLike: hasLike);
      }
    }).catchError((_) {});

    // 3. 完整详情（包括 ugc_season 合集）
    _playerRepository.fetchFullVideoDetail(video.bvid).then((detail) {
      if (!_isDisposed && ref.mounted) {
        state = state.copyWith(
          ugcSeason: detail.ugcSeason,
        );
        // 4. UP主作品 (根据 owner.mid)
        if (detail.owner != null && detail.owner!.mid > 0) {
          _playerRepository
              .fetchUpWorks(mid: detail.owner!.mid)
              .then((upWorks) {
            if (!_isDisposed && ref.mounted) {
              state = state.copyWith(upWorks: upWorks);
            }
          }).catchError((_) {});
        }
      }
    }).catchError((_) {});

    // 5. 相关推荐
    _playerRepository.fetchRelatedVideos(video.bvid).then((related) {
      if (!_isDisposed && ref.mounted) {
        state = state.copyWith(relatedVideos: related);
      }
    }).catchError((_) {});
  }

  /// 初始化/重置 MediaKit Player 引擎
  Future<void> _setupController(
    String videoUrl, {
    String audioUrl = '',
    int targetQn = 80,
    Duration startPosition = Duration.zero,
  }) async {
    if (_isDisposed) return;

    final oldPlayer = _player;
    _player = null;
    _videoController = null;
    _cancelSubscriptions();
    _heartbeatTimer?.cancel();

    if (oldPlayer != null) {
      TvPlayerEngineHelper.safeDisposePlayer(oldPlayer);
    }

    if (_isDisposed) return;

    try {
      final player = TvPlayerEngineHelper.createPlayer(
        bufferSize: 128 * 1024 * 1024,
      );
      _player = player;

      if (_isDisposed) {
        TvPlayerEngineHelper.safeDisposePlayer(player);
        _player = null;
        return;
      }

      final dynamic platform = player.platform;

      // 配置 MediaCodec 硬解直通与着色器调优
      await TvPlayerEngineHelper.configurePlatformProperties(
        platform,
        audioUrl: audioUrl,
        isLive: false,
      );

      if (_isDisposed) {
        TvPlayerEngineHelper.safeDisposePlayer(player);
        _player = null;
        return;
      }

      final controller = TvPlayerEngineHelper.createVideoController(player);
      _videoController = controller;

      await TvPlayerEngineHelper.waitForSurfaceReady(controller);

      if (_isDisposed) {
        TvPlayerEngineHelper.safeDisposePlayer(player);
        _player = null;
        _videoController = null;
        return;
      }

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
          _onPlaybackCompleted();
        }
      });

      _errorSub = player.stream.error.listen((err) {
        debugPrint('[RecommendPlayer] MediaKit 错误: $err');
      });

      final media = Media(
        videoUrl,
        httpHeaders: const {
          'Referer': ApiConstants.defaultReferer,
          'User-Agent': ApiConstants.defaultUserAgent,
        },
        start: startPosition > Duration.zero ? startPosition : null,
      );

      await player.open(media, play: false);

      if (_isDisposed) {
        TvPlayerEngineHelper.safeDisposePlayer(player);
        _player = null;
        _videoController = null;
        return;
      }

      // 设置播放速率
      if (state.speed != 1.0) {
        await player.setRate(state.speed);
      }

      await player.setVolume(100.0);
      await player.play();

      if (!_isDisposed && ref.mounted) {
        state = state.copyWith(
          isLoading: false,
          isPlaying: true,
          currentQn: targetQn,
          error: null,
        );

        _heartbeatTimer = Timer.periodic(const Duration(seconds: 15), (_) {
          reportHistoryHeartbeat();
        });
      }
    } catch (e) {
      if (_isDisposed) return;
      debugPrint('[RecommendPlayer] 初始化播放引擎异常: $e');
      state = state.copyWith(
        isLoading: false,
        error: '播放引擎初始化失败: $e',
      );
    }
  }

  void _onPlaybackCompleted() {
    if (state.playMode == TvPlayMode.loopSingle) {
      _player?.seek(Duration.zero);
      _player?.play();
    } else {
      playNext();
    }
  }

  /// 播放 / 暂停切换
  void togglePlay() {
    _player?.playOrPause();
  }

  /// 进度跳转 (Seek)
  void seekTo(Duration target) {
    final maxDur = state.duration;
    final safeTarget = target < Duration.zero
        ? Duration.zero
        : (maxDur > Duration.zero && target > maxDur ? maxDur : target);
    _player?.seek(safeTarget);
  }

  void seekForward({int seconds = 10}) {
    final cur = _player?.state.position ?? state.position;
    seekTo(cur + Duration(seconds: seconds));
  }

  void seekBackward({int seconds = 10}) {
    final cur = _player?.state.position ?? state.position;
    seekTo(cur - Duration(seconds: seconds));
  }

  /// 切换清晰度 (记忆续播)
  Future<void> changeQuality(int targetQn) async {
    if (targetQn == state.currentQn) return;

    final videos = ref.read(homeFeedProvider).videos;
    if (state.currentIndex >= videos.length) return;
    final curVideo = videos[state.currentIndex];

    final currentPos = _player?.state.position ?? state.position;
    state = state.copyWith(isLoading: true);

    try {
      final playInfo = await _playerRepository.fetchPlayUrl(
        bvid: curVideo.bvid,
        cid: curVideo.cid,
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
        startPosition: currentPos,
      );
    } catch (e) {
      if (_isDisposed) return;
      state = state.copyWith(
        isLoading: false,
        error: '清晰度切换失败: $e',
      );
    }
  }

  /// 切换倍速
  Future<void> changeSpeed(double speed) async {
    state = state.copyWith(speed: speed);
    try {
      await _player?.setRate(speed);
    } catch (_) {}
  }

  /// 切换播放模式 (顺序连播 vs 单集循环)
  void setPlayMode(TvPlayMode mode) {
    state = state.copyWith(playMode: mode);
  }

  /// 弹幕开关与参数调节
  void toggleDanmaku() {
    state = state.copyWith(danmakuEnabled: !state.danmakuEnabled);
  }

  void setDanmakuSize(double size) {
    state = state.copyWith(danmakuSize: size);
  }

  void setDanmakuSpeed(double speed) {
    state = state.copyWith(danmakuSpeed: speed);
  }

  void setDanmakuArea(double area) {
    state = state.copyWith(danmakuArea: area);
  }

  /// 点赞操作
  Future<void> toggleLike() async {
    final videos = ref.read(homeFeedProvider).videos;
    if (state.currentIndex >= videos.length) return;
    final bvid = videos[state.currentIndex].bvid;

    final prev = state.hasLike;
    final success = await _playerRepository.toggleLike(
      bvid: bvid,
      currentLiked: prev,
    );
    if (success && !_isDisposed && ref.mounted) {
      state = state.copyWith(hasLike: !prev, hasDislike: false);
    }
  }

  /// 点踩操作
  void toggleDislike() {
    state = state.copyWith(
      hasDislike: !state.hasDislike,
      hasLike: false,
    );
  }

  /// 投币操作
  Future<bool> addCoin({int multiply = 1}) async {
    final videos = ref.read(homeFeedProvider).videos;
    if (state.currentIndex >= videos.length) return false;
    final bvid = videos[state.currentIndex].bvid;

    final success = await _playerRepository.addCoin(
      bvid: bvid,
      multiply: multiply,
    );
    if (success && !_isDisposed && ref.mounted) {
      state = state.copyWith(hasCoin: true);
    }
    return success;
  }

  /// 收藏操作
  void toggleFavorite() {
    state = state.copyWith(hasFav: !state.hasFav);
  }

  /// 一键三连 (长按蓄力满触发)
  Future<bool> doTriple() async {
    final videos = ref.read(homeFeedProvider).videos;
    if (state.currentIndex >= videos.length) return false;
    final bvid = videos[state.currentIndex].bvid;

    final success = await _playerRepository.doTriple(bvid);
    if (success && !_isDisposed && ref.mounted) {
      state = state.copyWith(
        hasLike: true,
        hasCoin: true,
        hasFav: true,
      );
    }
    return success;
  }
}

/// Recommend Player Provider
final recommendPlayerProvider =
    NotifierProvider<RecommendPlayerNotifier, RecommendPlayerState>(
  RecommendPlayerNotifier.new,
);

import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart' hide PlayerState;
import 'package:media_kit_video/media_kit_video.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/storage/storage_service.dart';
import '../../../../models/video/video_part_model.dart';
import '../../data/repositories/player_repository.dart';
import 'player_state.dart';

/// TV 播放器控制器与状态管理 (基于 MediaKit，跨 Linux Desktop 与 Android TV 大屏通用)
class PlayerNotifier extends Notifier<PlayerState> {
  final String bvid;
  Player? _player;
  VideoController? _videoController;
  Timer? _hideControlsTimer;
  Timer? _saveHistoryTimer;
  Timer? _heartbeatTimer;

  bool _isDisposed = false;

  StreamSubscription<Duration>? _posSub;
  StreamSubscription<Duration>? _durSub;
  StreamSubscription<bool>? _playingSub;
  StreamSubscription<bool>? _bufferingSub;
  StreamSubscription<String>? _errorSub;

  late final PlayerRepository _repository;
  late final StorageService _storageService;

  PlayerNotifier(this.bvid);

  VideoController? get videoController => _videoController;
  Player? get player => _player;

  @override
  PlayerState build() {
    _isDisposed = false;
    _repository = ref.read(playerRepositoryProvider);
    _storageService = ref.read(storageServiceProvider);

    ref.onDispose(() {
      _stopAndDispose();
    });

    // 启动异步加载视频
    Future.microtask(() => _initVideo(bvid));
    return PlayerState(bvid: bvid);
  }

  void _cancelSubscriptions() {
    _posSub?.cancel();
    _durSub?.cancel();
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
        p.setVolume(0);
        p.pause();
      }
    } catch (_) {}
  }

  /// 安全释放底层 Player 实例，防止重复销毁触发 MediaKit 断言崩溃
  void _safeDisposePlayer(Player? p) {
    if (p == null) return;
    try {
      p.setVolume(0);
    } catch (_) {}
    try {
      p.pause();
    } catch (_) {}
    try {
      p.stop();
    } catch (_) {}
    try {
      p.dispose();
    } catch (_) {}
  }

  /// 停止音频与视频输出并销毁 MPV 实例，彻底消除退出界面后声音还在继续的竞态问题
  void _stopAndDispose() {
    if (_isDisposed) return;
    saveCurrentProgress();
    reportHistoryHeartbeat();

    _isDisposed = true;

    _hideControlsTimer?.cancel();
    _saveHistoryTimer?.cancel();
    _heartbeatTimer?.cancel();
    _cancelSubscriptions();

    final p = _player;
    _player = null;
    _videoController = null;

    _safeDisposePlayer(p);
  }

  /// 保存当前视频播放进度
  void saveCurrentProgress() {
    if (_isDisposed) return;
    final p = _player;
    if (p == null) return;
    try {
      final pos = p.state.position;
      final dur = p.state.duration;

      if (pos.inSeconds > 5) {
        if (dur > Duration.zero && (dur.inSeconds - pos.inSeconds) <= 10) {
          // 视频接近尾声（剩余不到 10 秒），重置进度
          _storageService.removeVideoProgress(bvid);
        } else {
          _storageService.saveVideoProgress(bvid, pos.inSeconds);
        }
      }
    } catch (_) {}
  }

  /// 向 B 站官方上报播放心跳进度，确保视频进入云端观看历史
  void reportHistoryHeartbeat() {
    if (_isDisposed) return;
    try {
      if (state.bvid.isNotEmpty && state.cid > 0) {
        final playedSec =
            _player?.state.position.inSeconds ?? state.position.inSeconds;
        _repository.reportHeartbeat(
          bvid: state.bvid,
          cid: state.cid,
          playedTime: playedSec,
          duration: state.duration.inSeconds,
        );
      }
    } catch (_) {}
  }

  /// 初始化视频流
  Future<void> _initVideo(String bvid) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // 1. 获取视频详情 (title, cid)
      final detail = await _repository.fetchVideoDetail(bvid);
      if (_isDisposed) return;

      final totalDuration = Duration(seconds: detail.durationSeconds);
      state = state.copyWith(
        title: detail.title,
        cid: detail.cid,
        duration: totalDuration,
      );

      // 2. 读取该视频历史播放记录
      final savedProgressSec = _storageService.getVideoProgress(bvid);
      Duration initialPosition = Duration.zero;
      if (savedProgressSec > 5 &&
          (detail.durationSeconds == 0 ||
              savedProgressSec < detail.durationSeconds - 10)) {
        initialPosition = Duration(seconds: savedProgressSec);
      }

      // 3. 获取播放流 (优先申请用户手动设置的偏好画质，默认 120/4K 超清规格)
      final preferredQn = _storageService.preferredQuality;
      final playInfo = await _repository.fetchPlayUrl(
        bvid: bvid,
        cid: detail.cid,
        qn: preferredQn,
      );
      if (_isDisposed) return;

      state = state.copyWith(
        currentUrl: playInfo.playUrl,
        currentAudioUrl: playInfo.audioUrl,
        currentQn: playInfo.currentQn,
        qualities: playInfo.qualities,
        position: initialPosition,
      );

      // 4. 初始化播放器引擎并从历史进度开始播放
      await _setupController(
        playInfo.playUrl,
        audioUrl: playInfo.audioUrl,
        targetQn: playInfo.currentQn,
        startPosition: initialPosition,
      );

      // 5. 异步并行加载分P选集列表、在线观看人数与点赞状态 (零Mock，真实API)
      _loadExtraVideoData(bvid, detail.cid);
    } catch (e) {
      if (_isDisposed) return;
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
    int targetQn = 120,
    Duration startPosition = Duration.zero,
  }) async {
    if (_isDisposed) return;

    final oldPlayer = _player;
    _player = null;
    _videoController = null;
    _cancelSubscriptions();
    _saveHistoryTimer?.cancel();

    if (oldPlayer != null) {
      _safeDisposePlayer(oldPlayer);
    }

    if (_isDisposed) return;

    try {
      // 通过 PlayerConfiguration 扩大 4K 高码率解复用网络缓存 (64MB)
      final player = Player(
        configuration: const PlayerConfiguration(
          bufferSize: 64 * 1024 * 1024,
        ),
      );
      // 立即挂载底层实例句柄，确保任何中途退出或销毁操作都能立即调用 player.stop() 与 dispose()
      _player = player;
      final dynamic platform = player.platform;

      if (_isDisposed) {
        _safeDisposePlayer(player);
        _player = null;
        return;
      }

      // 关键：初始锁定暂停状态，严禁底层在未完成音画混合时偷跑音频
      await platform?.setProperty('pause', 'yes');

      // 0. 网络高清流预读与大屏解复用器性能调优
      // 确保在网络通畅时，底层积极向前预读 45 秒音视频数据，彻底杜绝播放卡顿
      await platform?.setProperty('demuxer-readahead-secs', '45');
      await platform?.setProperty('demuxer-max-bytes', '${96 * 1024 * 1024}');
      await platform?.setProperty('demuxer-max-back-bytes', '${32 * 1024 * 1024}');
      await platform?.setProperty('cache-secs', '45');
      await platform?.setProperty('network-timeout', '10');
      await platform?.setProperty('force-seekable', 'yes');

      // 0.1 强制显式启用 Android 原生 mediacodec 直通硬件解码
      if (Platform.isAndroid) {
        await platform?.setProperty('hwdec', 'mediacodec');
        await platform?.setProperty('hwdec-codecs', 'all');
      } else {
        await platform?.setProperty('hwdec', 'auto');
      }

      // 1. Android 电视平台专用音频驱动配置与音画严格同步 (A/V Sync)
      // 关键：必须使用 opensles 纯 C 原生音频驱动！
      // 绝对严禁使用 audiotrack，因为 audiotrack 依赖 Java JNI 反射调用，在 Android 15/16 CheckJNI 下因 CheckMethodID 触发 JniAbort 导致应用原生闪退！
      if (Platform.isAndroid) {
        await platform?.setProperty('volume-max', '100');
        await platform?.setProperty('ao', 'opensles');
      }

      // 音视频高精度同步配置，彻底杜绝外挂音轨音画不同步
      await platform?.setProperty('video-sync', 'audio');
      await platform?.setProperty('hr-seek', 'yes');
      await platform?.setProperty('hr-seek-framedrop', 'yes');
      await platform?.setProperty('audio-pitch-correction', 'no');
      await platform?.setProperty('autosync', '30');

      if (_isDisposed) {
        _safeDisposePlayer(player);
        _player = null;
        return;
      }

      // 2. 原生 HDR 硬件直通与色彩空间提示配置
      // 在 Android 上 mediacodec 会直接将 HDR 帧渲染至 Surface，设置 target-colorspace-hint 或 target-trc 会导致 EGL 初始化失败
      if (!Platform.isAndroid) {
        await platform?.setProperty('target-colorspace-hint', 'yes');
        await platform?.setProperty('target-trc', 'auto');
        await platform?.setProperty('target-prim', 'auto');
        await platform?.setProperty('tone-mapping', 'auto');
      }

      // 3. 配置 DASH 独立音轨 (解决声音缺失核心痛点)
      // 关键 1: 必须为 audioUrl 预先注册附带 Referer 防盗链的 Media 缓存，否则 B 站 CDN 返回 403 静音
      // 关键 2: 在 player.open 之前通过 audio-files 属性挂载，保证音视频流同步初始化
      if (audioUrl.isNotEmpty) {
        Media(
          audioUrl,
          httpHeaders: const {
            'Referer': ApiConstants.defaultReferer,
            'User-Agent': ApiConstants.defaultUserAgent,
          },
        );

        final safeAudioUrl = Platform.isWindows
            ? audioUrl.replaceAll(';', '\\;')
            : audioUrl.replaceAll(':', '\\:');
        await platform?.setProperty('audio-files', safeAudioUrl);
      }

      if (_isDisposed) {
        _safeDisposePlayer(player);
        _player = null;
        return;
      }

      final videoController = VideoController(
        player,
        configuration: VideoControllerConfiguration(
          enableHardwareAcceleration: true,
          hwdec: Platform.isAndroid ? 'mediacodec' : 'auto',
        ),
      );

      _player = player;
      _videoController = videoController;

      // 关键时序保障：等待 Android Native Surface 完全绑定到 MPV 实例
      // 杜绝冷启动时在 Surface 缺失状态下提早解码导致 MediaCodec 降级为 isSurface:0 (Buffer拷贝模式) 造成严重丢帧！
      if (Platform.isAndroid) {
        try {
          final dynamic platformController =
              await videoController.platform.future;
          final dynamic widNotifier = platformController?.wid;
          if (widNotifier is ValueNotifier<int?> && widNotifier.value == null) {
            final widCompleter = Completer<void>();
            void onWidChanged() {
              if (widNotifier.value != null && !widCompleter.isCompleted) {
                widCompleter.complete();
              }
            }

            widNotifier.addListener(onWidChanged);
            // 设置 800ms 保护闸门，一旦 Surface 附着完毕立即触发唤醒
            await widCompleter.future.timeout(
              const Duration(milliseconds: 800),
              onTimeout: () {},
            );
            widNotifier.removeListener(onWidChanged);
          }
        } catch (e) {
          debugPrint('[PlayerNotifier] 等待 Native Surface 异常: $e');
        }
      } else {
        try {
          await videoController.platform.future.timeout(
            const Duration(milliseconds: 500),
            onTimeout: () => videoController.platform.future,
          );
        } catch (_) {}
      }

      if (_isDisposed) {
        _safeDisposePlayer(player);
        _player = null;
        _videoController = null;
        return;
      }

      bool isWaitingInitialSeek = startPosition > Duration.zero;

      _posSub = player.stream.position.listen((pos) {
        if (!_isDisposed) {
          // 起播恢复进度防闪烁：底层 MPV 初始化时常先派发一个 0 秒伪事件，随后立即跳转到 startPosition。
          // 此时过滤掉该初始 0 秒事件，彻底消除进度条闪回 0 再跳回历史进度的双重闪烁！
          if (isWaitingInitialSeek) {
            if (pos == Duration.zero) return;
            isWaitingInitialSeek = false;
          }
          state = state.copyWith(position: pos);
        }
      });

      _durSub = player.stream.duration.listen((dur) {
        if (!_isDisposed && dur > Duration.zero) {
          state = state.copyWith(duration: dur);
        }
      });

      _playingSub = player.stream.playing.listen((playing) {
        if (!_isDisposed) {
          state = state.copyWith(isPlaying: playing);
        }
      });

      _bufferingSub = player.stream.buffering.listen((buffering) {
        if (!_isDisposed) {
          state = state.copyWith(isBuffering: buffering);
        }
      });

      _errorSub = player.stream.error.listen((err) {
        debugPrint('[PlayerNotifier] MediaKit error: $err');
      });

      // 4. 打开主视频流并指定起始续播位置 (Surface 已就绪，MediaCodec 命中 isSurface:1 直通硬解)
      try {
        await player.open(
          Media(
            url,
            httpHeaders: const {
              'Referer': ApiConstants.defaultReferer,
              'User-Agent': ApiConstants.defaultUserAgent,
            },
            start: startPosition > Duration.zero ? startPosition : null,
          ),
          play: false,
        );
      } catch (openErr) {
        if (_isDisposed) return;
        rethrow;
      }

      if (_isDisposed) {
        _safeDisposePlayer(player);
        _player = null;
        _videoController = null;
        return;
      }

      // 音量重设为 100%
      try {
        await player.setVolume(100.0);
        // 5. 音画流完全对齐就绪后，正式统一开播！彻底消除声音偷跑与二次从头播放
        await player.play();
      } catch (_) {}

      if (!_isDisposed) {
        state = state.copyWith(
          isLoading: false,
          isPlaying: true,
          error: null,
        );

        _resetHideControlsTimer();

        // 启动每 5 秒定期持久化本地播放进度的定时器
        _saveHistoryTimer = Timer.periodic(const Duration(seconds: 5), (_) {
          if (!_isDisposed) {
            saveCurrentProgress();
          }
        });

        // 启动每 15 秒向 B 站官方上报播放心跳进度的定时器，确保视频写入云端历史记录
        _heartbeatTimer?.cancel();
        reportHistoryHeartbeat();
        _heartbeatTimer = Timer.periodic(const Duration(seconds: 15), (_) {
          if (!_isDisposed) {
            reportHistoryHeartbeat();
          }
        });
      }
    } catch (e) {
      if (_isDisposed) return;
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
    if (p == null || _isDisposed) return;

    p.playOrPause();
    showControlsTemporarily();
  }

  /// 遥控器快进
  void seekForward({int seconds = 10}) {
    final p = _player;
    if (p == null || _isDisposed) return;

    final target = p.state.position + Duration(seconds: seconds);
    final max = p.state.duration;
    p.seek(target > max ? max : target);
    showControlsTemporarily();
  }

  /// 遥控器快退
  void seekBackward({int seconds = 10}) {
    final p = _player;
    if (p == null || _isDisposed) return;

    final target = p.state.position - Duration(seconds: seconds);
    p.seek(target < Duration.zero ? Duration.zero : target);
    showControlsTemporarily();
  }

  /// 精确跳转指定进度 (用于长按连续快进快退松手时一次性提交)
  void seekTo(Duration target) {
    final p = _player;
    if (p == null || _isDisposed) return;

    final max = p.state.duration;
    final clamped = target < Duration.zero
        ? Duration.zero
        : (max > Duration.zero && target > max ? max : target);
    p.seek(clamped);
    showControlsTemporarily();
  }

  /// 切换画质 (无缝记忆并接续当前播放进度，绝不从头开始)
  Future<void> changeQuality(int targetQn) async {
    if (targetQn == state.currentQn || state.isLoading || _isDisposed) {
      closeQualityPanel();
      return;
    }

    // 记录切换前精准的播放进度
    final currentPos = _player?.state.position ?? state.position;
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
      if (_isDisposed) return;

      // 持久化用户选择的画质偏好，后续打开任何视频优先尝试该画质
      await _storageService.setPreferredQuality(targetQn);

      state = state.copyWith(
        currentUrl: playInfo.playUrl,
        currentAudioUrl: playInfo.audioUrl,
        currentQn: playInfo.currentQn,
        qualities: playInfo.qualities.isNotEmpty
            ? playInfo.qualities
            : state.qualities,
      );

      // 优化：若当前已有存活的播放器与视频控制器，直接无缝切流并继承进度
      // 杜绝反复销毁/重建 Player 与 Native Surface 导致的黑屏停顿与 JNI 资源抖动
      if (_player != null && _videoController != null) {
        final player = _player!;
        final dynamic platform = player.platform;

        // 1. 更新独立音轨 (audio-files)
        if (playInfo.audioUrl.isNotEmpty) {
          Media(
            playInfo.audioUrl,
            httpHeaders: const {
              'Referer': ApiConstants.defaultReferer,
              'User-Agent': ApiConstants.defaultUserAgent,
            },
          );
          final safeAudioUrl = Platform.isWindows
              ? playInfo.audioUrl.replaceAll(';', '\\;')
              : playInfo.audioUrl.replaceAll(':', '\\:');
          await platform?.setProperty('audio-files', safeAudioUrl);
        } else {
          await platform?.setProperty('audio-files', '');
        }

        // 2. 直接打开新画质视频流，实现无闪烁、无销毁的无缝续播
        await player.open(
          Media(
            playInfo.playUrl,
            httpHeaders: const {
              'Referer': ApiConstants.defaultReferer,
              'User-Agent': ApiConstants.defaultUserAgent,
            },
            start: currentPos,
          ),
          play: true,
        );

        if (!_isDisposed) {
          state = state.copyWith(
            isLoading: false,
            isPlaying: true,
            error: null,
          );
          _resetHideControlsTimer();
        }
        return;
      }

      // 兜底：若播放器尚未创建，走全量构建流程
      await _setupController(
        playInfo.playUrl,
        audioUrl: playInfo.audioUrl,
        targetQn: playInfo.currentQn,
        startPosition: currentPos,
      );
    } catch (e) {
      if (_isDisposed) return;
      debugPrint('[PlayerNotifier] 切换画质失败: $e');
      state = state.copyWith(
        isLoading: false,
        error: '切换画质失败: $e',
      );
    }
  }

  /// 显示/隐藏控制栏
  void toggleControls() {
    if (_isDisposed) return;
    state = state.copyWith(showControls: !state.showControls);
    if (state.showControls) {
      _resetHideControlsTimer();
    } else {
      _hideControlsTimer?.cancel();
    }
  }

  /// 隐藏控制栏
  void hideControls() {
    if (_isDisposed) return;
    _hideControlsTimer?.cancel();
    state = state.copyWith(showControls: false);
  }

  void showControlsTemporarily() {
    if (_isDisposed) return;
    state = state.copyWith(showControls: true);
    _resetHideControlsTimer();
  }

  void _resetHideControlsTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 5), () {
      if (state.showControls && !state.showQualityPanel && !_isDisposed) {
        state = state.copyWith(showControls: false);
      }
    });
  }

  /// 打开画质选择面板
  void openQualityPanel() {
    if (_isDisposed) return;
    _hideControlsTimer?.cancel();
    state = state.copyWith(showQualityPanel: true, showControls: true);
  }

  /// 关闭画质选择面板
  void closeQualityPanel() {
    if (_isDisposed) return;
    state = state.copyWith(showQualityPanel: false);
    _resetHideControlsTimer();
  }

  /// 异步并行获取附加数据 (分P选集、在线人数、点赞状态)
  Future<void> _loadExtraVideoData(String bvid, int currentCid) async {
    if (_isDisposed) return;
    try {
      final partsFuture = _repository.fetchPageList(bvid);
      final onlineFuture = _repository.fetchOnlineTotal(bvid: bvid, cid: currentCid);
      final likeFuture = _repository.fetchHasLike(bvid);

      final results = await Future.wait([partsFuture, onlineFuture, likeFuture]);
      if (_isDisposed) return;

      final parts = results[0] as List<VideoPartItem>;
      final online = results[1] as String;
      final hasLike = results[2] as bool;

      int partIdx = 0;
      for (int i = 0; i < parts.length; i++) {
        if (parts[i].cid == currentCid) {
          partIdx = i;
          break;
        }
      }

      state = state.copyWith(
        parts: parts,
        currentPartIndex: partIdx,
        onlineCount: online,
        isLiked: hasLike,
      );
    } catch (e) {
      if (!_isDisposed) {
        debugPrint('[PlayerNotifier] 获取额外数据异常: $e');
      }
    }
  }

  /// 切换分 P 选集
  Future<void> changePart(int index) async {
    if (index < 0 || index >= state.parts.length || _isDisposed) return;
    final targetPart = state.parts[index];
    if (targetPart.cid == state.cid) {
      closePartDrawer();
      return;
    }

    state = state.copyWith(
      isLoading: true,
      cid: targetPart.cid,
      currentPartIndex: index,
      showPartDrawer: false,
    );

    try {
      final preferredQn = _storageService.preferredQuality;
      final playInfo = await _repository.fetchPlayUrl(
        bvid: bvid,
        cid: targetPart.cid,
        qn: preferredQn,
      );
      if (_isDisposed) return;

      state = state.copyWith(
        currentUrl: playInfo.playUrl,
        currentAudioUrl: playInfo.audioUrl,
        currentQn: playInfo.currentQn,
        qualities: playInfo.qualities,
      );

      await _setupController(
        playInfo.playUrl,
        audioUrl: playInfo.audioUrl,
        targetQn: playInfo.currentQn,
        startPosition: Duration.zero,
      );

      // 更新该分 P 的实时在线人数
      final online = await _repository.fetchOnlineTotal(
        bvid: bvid,
        cid: targetPart.cid,
      );
      if (!_isDisposed) {
        state = state.copyWith(onlineCount: online);
      }
    } catch (e) {
      if (_isDisposed) return;
      state = state.copyWith(isLoading: false, error: '切换分P失败: $e');
    }
  }

  /// 切换点赞状态
  Future<void> toggleLike() async {
    final current = state.isLiked;
    final ok = await _repository.toggleLike(bvid: bvid, currentLiked: current);
    if (ok && !_isDisposed) {
      state = state.copyWith(isLiked: !current);
    }
  }

  /// 一键三连 (点赞+投币+收藏)
  Future<bool> doTriple() async {
    final ok = await _repository.doTriple(bvid);
    if (ok && !_isDisposed) {
      state = state.copyWith(isLiked: true);
    }
    return ok;
  }

  /// 打开选集抽屉
  void openPartDrawer() {
    if (_isDisposed) return;
    _hideControlsTimer?.cancel();
    state = state.copyWith(showPartDrawer: true, showControls: true);
  }

  /// 关闭选集抽屉
  void closePartDrawer() {
    if (_isDisposed) return;
    state = state.copyWith(showPartDrawer: false);
    _resetHideControlsTimer();
  }
}

/// 播放器调试信息面板可见性 Notifier (在 Debug 模式下默认开启，支持遥控器一键切换)
class PlayerDebugOverlayNotifier extends Notifier<bool> {
  @override
  bool build() => kDebugMode;

  void toggle() => state = !state;
  void setVisible(bool visible) => state = visible;
}

/// Provider 定义，兼容 Riverpod 3.x 规范，杜绝 legacy 依赖
final playerDebugOverlayProvider =
    NotifierProvider<PlayerDebugOverlayNotifier, bool>(
  PlayerDebugOverlayNotifier.new,
);

/// Family Provider，基于 bvid 独立创建和管理播放器状态
final playerProvider =
    NotifierProvider.autoDispose.family<PlayerNotifier, PlayerState, String>(
  PlayerNotifier.new,
);

import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../constants/api_constants.dart';

/// TV 播放器底层引擎调优与硬件硬解适配助手
/// 专为 Android TV 大屏（如联发科 Pentonic MT9655 / MT5877、晶晨 Amlogic、海思等 SOC）调优：
/// 1. 强制启用 MediaCodec 直通硬件解码并解除格式白名单 (`hwdec=mediacodec`, `hwdec-codecs=all`)
/// 2. 启用 mediacodec_embed 零拷贝原生 Surface 输出 (`vo=mediacodec_embed`)
/// 3. 等待 Native Surface 完全挂载后再解码，杜绝 Surface 缺失降级为软解 Buffer 拷贝模式
/// 4. 优化 Mali GPU 极速渲染着色器 (`profile=fast`, 禁用 deband/dither/高阶缩放)，解决 4K/高帧率丢帧与卡顿
/// 5. 纯 C 原生 OpenSL ES 音频驱动 (`ao=opensles`)，杜绝 Java AudioTrack CheckJNI 崩溃
class TvPlayerEngineHelper {
  TvPlayerEngineHelper._();

  /// 创建配置优化的高缓存 Player 实例
  static Player createPlayer({
    int bufferSize = 128 * 1024 * 1024,
  }) {
    return Player(
      configuration: PlayerConfiguration(
        bufferSize: bufferSize,
        // 在 Linux/Windows 等桌面端避免 mpv 启动独立窗口，统一通过 Flutter 纹理嵌入
        vo: Platform.isAndroid ? null : 'libmpv',
      ),
    );
  }

  /// 创建配置了 MediaCodec 直通硬解与嵌入 Surface 的 VideoController
  static VideoController createVideoController(Player player) {
    return VideoController(
      player,
      configuration: VideoControllerConfiguration(
        enableHardwareAcceleration: true,
        hwdec: Platform.isAndroid ? 'mediacodec' : 'auto',
        // Android TV 大屏端使用 mediacodec_embed 原生 Surface 零拷贝硬解渲染；
        // Linux/Windows 等桌面开发与测试环境使用 libmpv，防止 mpv (vo=gpu) 弹出独立宿主窗口
        vo: Platform.isAndroid ? 'mediacodec_embed' : 'libmpv',
      ),
    );
  }

  /// 针对大屏 SOC 与底层 libmpv 执行全套参数调优
  static Future<void> configurePlatformProperties(
    dynamic platform, {
    String? audioUrl,
    bool isLive = false,
  }) async {
    if (platform == null) return;

    // 0. 起始锁定暂停状态，严禁底层在未完成音画混合时偷跑音频
    if (!isLive) {
      await platform.setProperty('pause', 'yes');
    }

    if (Platform.isAndroid) {
      // 1. 音量上限与纯 C 原生 OpenSL ES 音频驱动
      // 关键：必须使用 opensles，严禁使用 audiotrack（避免 Android 15/16 CheckJNI 崩溃）
      await platform.setProperty('volume-max', '100');
      await platform.setProperty('ao', 'opensles');

      // 2. 强制启用 Android MediaCodec 直通硬件解码，并开放全部视频编码格式支持 (HEVC/AV1/AVC)
      await platform.setProperty('hwdec', 'mediacodec');
      await platform.setProperty('hwdec-codecs', 'all');
      await platform.setProperty('opengl-es', 'yes');

      // 3. TV SOC (Mali GPU) 4K 极速渲染着色器配置 (彻底解决 4K/高码率丢帧与卡顿核心)
      // 启用 profile=fast 并禁用耗费算力的抖动与高阶滤波算法，避免每秒 5 亿像素渲染拖垮电视 GPU
      await platform.setProperty('profile', 'fast');
      await platform.setProperty('scale', 'bilinear');
      await platform.setProperty('cscale', 'bilinear');
      await platform.setProperty('dscale', 'bilinear');
      await platform.setProperty('dither', 'no');
      await platform.setProperty('dither-depth', 'no');
      await platform.setProperty('deband', 'no');
      await platform.setProperty('correct-downscaling', 'no');
      await platform.setProperty('linear-downscaling', 'no');
      await platform.setProperty('sigmoid-upscaling', 'no');
      await platform.setProperty('hdr-compute-peak', 'no');
    } else {
      await platform.setProperty('hwdec', 'auto');
    }

    // 4. 网络高清流预读与大屏解复用器性能调优
    final int demuxerMax = isLive ? 32 * 1024 * 1024 : 160 * 1024 * 1024;
    final int demuxerBack = isLive ? 8 * 1024 * 1024 : 48 * 1024 * 1024;
    await platform.setProperty('demuxer-readahead-secs', isLive ? '10' : '60');
    await platform.setProperty('demuxer-max-bytes', '$demuxerMax');
    await platform.setProperty('demuxer-max-back-bytes', '$demuxerBack');
    await platform.setProperty('cache-secs', isLive ? '10' : '60');
    await platform.setProperty('network-timeout', '15');
    if (!isLive) {
      await platform.setProperty('force-seekable', 'yes');
    }

    // 5. 音视频严格时钟同步配置与平滑丢帧
    await platform.setProperty('video-sync', 'audio');
    await platform.setProperty('framedrop', 'vo');
    await platform.setProperty('video-sync-max-video-change', '5');
    await platform.setProperty('hr-seek', 'yes');
    await platform.setProperty('hr-seek-framedrop', 'yes');
    await platform.setProperty('audio-pitch-correction', 'no');
    await platform.setProperty('autosync', '30');

    // 6. 原生 HDR 色彩空间提示
    if (!Platform.isAndroid) {
      await platform.setProperty('target-colorspace-hint', 'yes');
      await platform.setProperty('target-trc', 'auto');
      await platform.setProperty('target-prim', 'auto');
      await platform.setProperty('tone-mapping', 'auto');
    }

    // 7. 外挂独立 DASH 音频流配置 (带 Referer 防盗链注册)
    if (audioUrl != null && audioUrl.isNotEmpty) {
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
      await platform.setProperty('audio-files', safeAudioUrl);
    }
  }

  /// 等待 Android Native Surface 完全绑定至 VideoController
  /// 杜绝在 Surface 缺失状态下提前解码导致 MediaCodec 降级为软解 Buffer 拷贝模式
  static Future<void> waitForSurfaceReady(
    VideoController videoController, {
    Duration timeout = const Duration(milliseconds: 800),
  }) async {
    if (!Platform.isAndroid) {
      try {
        await videoController.platform.future.timeout(
          const Duration(milliseconds: 500),
          onTimeout: () => videoController.platform.future,
        );
      } catch (_) {}
      return;
    }

    try {
      final dynamic platformController = await videoController.platform.future;
      final dynamic widNotifier = platformController?.wid;
      if (widNotifier is ValueNotifier<int?> && widNotifier.value == null) {
        final widCompleter = Completer<void>();
        void onWidChanged() {
          if (widNotifier.value != null && !widCompleter.isCompleted) {
            widCompleter.complete();
          }
        }

        widNotifier.addListener(onWidChanged);
        await widCompleter.future.timeout(
          timeout,
          onTimeout: () {},
        );
        widNotifier.removeListener(onWidChanged);
      }
    } catch (e) {
      debugPrint('[TvPlayerEngineHelper] 等待 Native Surface 异常: $e');
    }
  }

  /// 安全销毁 Player 句柄，第 0 毫秒强制静音并异步释放 C 句柄
  static void safeDisposePlayer(Player? player) {
    if (player == null) return;
    try {
      player.setVolume(0);
      player.stop();
    } catch (e) {
      debugPrint('[TvPlayerEngineHelper] 停止播放器异常: $e');
    }
    Future.microtask(() async {
      try {
        await player.dispose();
      } catch (e) {
        debugPrint('[TvPlayerEngineHelper] 释放底层 Player 异常: $e');
      }
    });
  }
}

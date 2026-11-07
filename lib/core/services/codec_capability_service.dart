import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 硬件视频解码能力模型 (具备跨设备动态自适应能力)
class DeviceCodecCapability {
  final int maxOverallWidth;
  final int maxOverallHeight;
  final double maxOverallFps;
  final bool supports4k;
  final bool supports8k;
  final bool supports4k60;
  final bool supports4k120;

  const DeviceCodecCapability({
    this.maxOverallWidth = 3840,
    this.maxOverallHeight = 2160,
    this.maxOverallFps = 60.0,
    this.supports4k = true,
    this.supports8k = false,
    this.supports4k60 = true,
    this.supports4k120 = false,
  });

  /// 对应 B 站 fnval 参数
  /// 若设备硬件硬解支持 8K，则开启 8K bit (1024) -> 4048
  /// 若设备硬件最高支持 4K，则剔除 8K bit (1024) -> 3024，防止请求到超规格流触发 ERROR_NO_MEMORY 黑屏
  int get appropriateFnval => supports8k ? 4048 : 3024;

  /// 最高支持的画质 QN (127: 8K, 120: 4K, 80: 1080P)
  int get maxSupportedQn {
    if (supports8k) return 127;
    if (supports4k) return 120;
    return 80;
  }

  DeviceCodecCapability copyWith({
    int? maxOverallWidth,
    int? maxOverallHeight,
    double? maxOverallFps,
    bool? supports4k,
    bool? supports8k,
    bool? supports4k60,
    bool? supports4k120,
  }) {
    return DeviceCodecCapability(
      maxOverallWidth: maxOverallWidth ?? this.maxOverallWidth,
      maxOverallHeight: maxOverallHeight ?? this.maxOverallHeight,
      maxOverallFps: maxOverallFps ?? this.maxOverallFps,
      supports4k: supports4k ?? this.supports4k,
      supports8k: supports8k ?? this.supports8k,
      supports4k60: supports4k60 ?? this.supports4k60,
      supports4k120: supports4k120 ?? this.supports4k120,
    );
  }

  @override
  String toString() {
    return 'DeviceCodecCapability(maxOverallWidth: $maxOverallWidth, maxOverallHeight: $maxOverallHeight, maxOverallFps: $maxOverallFps, supports4k: $supports4k, supports8k: $supports8k, supports4k60: $supports4k60, supports4k120: $supports4k120)';
  }
}

/// 硬件视频编解码能力动态探测与流轨校验服务
class CodecCapabilityService {
  static const MethodChannel _codecChannel =
      MethodChannel('cloud.kitasaitamablues.bili_tv/codec');

  static DeviceCodecCapability? _cachedCapability;

  /// 应用启动时向操作系统查询真实的视频硬件解码器能力
  static Future<DeviceCodecCapability> detect() async {
    if (_cachedCapability != null) return _cachedCapability!;

    if (!Platform.isAndroid) {
      // 桌面端 (Linux / Windows / macOS): GPU/CPU 支持高达 8K 120fps 硬解
      _cachedCapability = const DeviceCodecCapability(
        maxOverallWidth: 7680,
        maxOverallHeight: 4320,
        maxOverallFps: 120.0,
        supports4k: true,
        supports8k: true,
        supports4k60: true,
        supports4k120: true,
      );
      return _cachedCapability!;
    }

    try {
      final res = await _codecChannel
          .invokeMapMethod<String, dynamic>('getDecoderCapabilities');
      if (res != null) {
        _cachedCapability = DeviceCodecCapability(
          maxOverallWidth: res['maxOverallWidth'] as int? ?? 3840,
          maxOverallHeight: res['maxOverallHeight'] as int? ?? 2160,
          maxOverallFps: (res['maxOverallFps'] as num?)?.toDouble() ?? 60.0,
          supports4k: res['supports4k'] as bool? ?? true,
          supports8k: res['supports8k'] as bool? ?? false,
          supports4k60: res['supports4k60'] as bool? ?? true,
          supports4k120: res['supports4k120'] as bool? ?? false,
        );
        debugPrint(
          '[CodecCapabilityService] 探测到设备硬件解码能力: $_cachedCapability',
        );
        return _cachedCapability!;
      }
    } catch (e) {
      debugPrint('[CodecCapabilityService] 探测解码能力异常: $e');
    }

    _cachedCapability = const DeviceCodecCapability();
    return _cachedCapability!;
  }

  /// 解析 B 站 DASH 流的帧率 (例如 "120.000", "60.000", "30.000", "120000/1000")
  static double parseFrameRate(dynamic frameRate) {
    if (frameRate == null) return 0.0;
    if (frameRate is num) return frameRate.toDouble();
    final str = frameRate.toString().trim();
    if (str.isEmpty) return 0.0;
    if (str.contains('/')) {
      final parts = str.split('/');
      final num = double.tryParse(parts[0]) ?? 0.0;
      final den = double.tryParse(parts[1]) ?? 1.0;
      return den > 0 ? num / den : 0.0;
    }
    return double.tryParse(str) ?? 0.0;
  }

  /// 将 B 站 codecid / codecs 映射为标准 Android MIME 类型
  static String mapCodecToMime(int codecid, String codecs) {
    final lower = codecs.toLowerCase();
    if (codecid == 12 ||
        lower.startsWith('hev') ||
        lower.startsWith('hvc') ||
        lower.startsWith('dvh')) {
      return 'video/hevc';
    }
    if (codecid == 13 || lower.startsWith('av01') || lower.startsWith('av1')) {
      return 'video/av01';
    }
    if (codecid == 7 || codecid == 1 || lower.startsWith('avc')) {
      return 'video/avc';
    }
    return 'video/hevc';
  }

  /// 批量校验候选视频流轨是否在当前设备的物理硬件硬解能力范围内
  /// 动态调用 Android MediaCodecList VideoCapabilities.areSizeAndRateSupported() 校验
  static Future<List<bool>> filterSupportedTracks(
    List<Map<String, dynamic>> tracks, {
    DeviceCodecCapability capability = const DeviceCodecCapability(),
  }) async {
    if (tracks.isEmpty) return const [];

    if (Platform.isAndroid) {
      try {
        final payload = tracks.map((t) {
          final codecid = t['codecid'] as int? ?? 0;
          final codecs = t['codecs'] as String? ?? '';
          final width = t['width'] as int? ?? 0;
          final height = t['height'] as int? ?? 0;
          final fps = parseFrameRate(t['frameRate'] ?? t['frame_rate']);
          final mime = mapCodecToMime(codecid, codecs);
          return {
            'mime': mime,
            'width': width,
            'height': height,
            'frameRate': fps,
          };
        }).toList();

        final res = await _codecChannel.invokeListMethod<bool>(
          'checkTracksSupport',
          {'tracks': payload},
        );
        if (res != null && res.length == tracks.length) {
          return res;
        }
      } catch (e) {
        debugPrint('[CodecCapabilityService] 动态批量检测硬件流轨异常: $e');
      }
    }

    // 兜底回退：若非 Android 或 Native 调用异常，执行基于硬件能力的本地计算
    return tracks.map((t) => fallbackCheck(t, capability: capability)).toList();
  }

  /// 本地宏块吞吐量计算兜底校验 (针对单测、非 Android 平台或 Native 通信异常)
  static bool fallbackCheck(
    Map<String, dynamic> track, {
    DeviceCodecCapability capability = const DeviceCodecCapability(),
  }) {
    final width = track['width'] as int? ?? 0;
    final height = track['height'] as int? ?? 0;
    if (width <= 0 || height <= 0) return true;

    // 1. 分辨率上限校验 (若设备不支持 8K 硬解，则超出 4096x2304 视为不支持)
    if (!capability.supports8k && (width > 4096 || height > 2304)) {
      return false;
    }

    // 2. 吞吐上限校验 (若设备不支持 4K 120fps，则超出 2,211,840 blocks/sec 视为不支持)
    final fps = parseFrameRate(track['frameRate'] ?? track['frame_rate']);
    if (fps > 0) {
      final blocksPerFrame = ((width + 15) ~/ 16) * ((height + 15) ~/ 16);
      final blocksPerSec = blocksPerFrame * fps;
      if (!capability.supports4k120 && blocksPerSec > 2211840) {
        return false;
      }
    }
    return true;
  }
}

/// 全局硬件编解码能力 Provider，在 main.dart 中注入
final codecCapabilityProvider = Provider<DeviceCodecCapability>((ref) {
  return const DeviceCodecCapability();
});

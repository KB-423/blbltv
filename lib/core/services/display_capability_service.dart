import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/storage_service.dart';

/// 系统与显示设备 HDR / 杜比视界硬件渲染能力模型
class DisplayHdrCapability {
  /// 是否支持任何形式的高动态范围 (HDR)
  final bool isHdrSupported;

  /// 是否支持 HDR10 / HDR10+ 硬件直通渲染
  final bool hasHdr10;

  /// 是否支持杜比视界 (Dolby Vision) 硬件直通渲染
  final bool hasDolbyVision;

  /// 是否支持 HLG (Hybrid Log-Gamma) 广播级高动态范围
  final bool hasHlg;

  /// 屏幕期望峰值亮度 (nits, 0 表示自动协商或未报告)
  final double maxLuminance;

  const DisplayHdrCapability({
    this.isHdrSupported = false,
    this.hasHdr10 = false,
    this.hasDolbyVision = false,
    this.hasHlg = false,
    this.maxLuminance = 0.0,
  });

  DisplayHdrCapability copyWith({
    bool? isHdrSupported,
    bool? hasHdr10,
    bool? hasDolbyVision,
    bool? hasHlg,
    double? maxLuminance,
  }) {
    return DisplayHdrCapability(
      isHdrSupported: isHdrSupported ?? this.isHdrSupported,
      hasHdr10: hasHdr10 ?? this.hasHdr10,
      hasDolbyVision: hasDolbyVision ?? this.hasDolbyVision,
      hasHlg: hasHlg ?? this.hasHlg,
      maxLuminance: maxLuminance ?? this.maxLuminance,
    );
  }

  @override
  String toString() {
    return 'DisplayHdrCapability(isHdrSupported: $isHdrSupported, hasHdr10: $hasHdr10, hasDolbyVision: $hasDolbyVision, hasHlg: $hasHlg, maxLuminance: $maxLuminance)';
  }
}

/// 显示设备硬件能力探测服务
class DisplayCapabilityService {
  static const MethodChannel _displayChannel =
      MethodChannel('cloud.kitasaitamablues.bili_tv/display');

  /// 应用启动时向操作系统查询真实的 HDR / 杜比视界硬件直通输出能力
  static Future<DisplayHdrCapability> detect() async {
    try {
      if (Platform.isAndroid) {
        return await _detectAndroid();
      }
      // 注：当前项目核心面向 Android TV 电视端大屏。
      // 在 PC 桌面端 (Linux GTK3 / Windows)，Flutter 窗口表面默认仅支持标准 8-bit sRGB (SDR)，
      // 故非 Android 平台如实返回默认 SDR 显示规格。开发者可在 Debug 模式下通过设置开启模拟测试。
    } catch (_) {
      // 任何探测异常均安全降级为标准 SDR 输出
    }
    return const DisplayHdrCapability();
  }

  /// Android / Android TV: 通过系统 Display.getHdrCapabilities() 硬件探测
  static Future<DisplayHdrCapability> _detectAndroid() async {
    try {
      final res = await _displayChannel
          .invokeMapMethod<String, dynamic>('getHdrCapabilities');
      if (res != null) {
        return DisplayHdrCapability(
          isHdrSupported: res['isHdrSupported'] as bool? ?? false,
          hasHdr10: res['hasHdr10'] as bool? ?? false,
          hasDolbyVision: res['hasDolbyVision'] as bool? ?? false,
          hasHlg: res['hasHlg'] as bool? ?? false,
          maxLuminance: (res['maxLuminance'] as num?)?.toDouble() ?? 0.0,
        );
      }
    } catch (_) {}
    return const DisplayHdrCapability();
  }
}

/// 系统底层实际探测到的物理硬件能力 Provider
final rawDisplayCapabilityProvider = Provider<DisplayHdrCapability>((ref) {
  return const DisplayHdrCapability();
});

/// 供全应用业务与 UI 使用的 HDR 硬件能力 Provider
/// - 生产环境下：直接反映底层真实的物理硬件检测结果；
/// - 电脑开发调试环境 (kDebugMode)：允许开发者在设置中开启“模拟 HDR”，方便在不支持 HDR 的开发机上调试 HDR 片源与画质切换。
final displayCapabilityProvider = Provider<DisplayHdrCapability>((ref) {
  final detected = ref.watch(rawDisplayCapabilityProvider);
  if (kDebugMode) {
    try {
      final storage = ref.watch(storageServiceProvider);
      if (storage.debugSimulateHdrSupport) {
        return const DisplayHdrCapability(
          isHdrSupported: true,
          hasHdr10: true,
          hasDolbyVision: true,
          maxLuminance: 1000.0,
        );
      }
    } catch (_) {}
  }
  return detected;
});

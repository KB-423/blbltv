import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dpad/dpad.dart';

import '../../../../core/services/display_capability_service.dart';
import '../../../../core/storage/storage_service.dart';
import '../../../../core/theme/tv_theme.dart';
import '../../../../widgets/tv_scaffold.dart';
import '../../../user/presentation/providers/auth_provider.dart';

/// TV 系统与播放设置屏幕
class TvSettingsScreen extends ConsumerStatefulWidget {
  const TvSettingsScreen({super.key});

  @override
  ConsumerState<TvSettingsScreen> createState() => _TvSettingsScreenState();
}

class _TvSettingsScreenState extends ConsumerState<TvSettingsScreen> {
  // 清晰度选项列表与文案
  static const List<int> _qualityOptions = [120, 112, 80, 64];

  String _getQualityName(int qn) {
    switch (qn) {
      case 120:
        return '4K 超清 (大会员专享)';
      case 112:
        return '1080P 高码率 (大会员专享)';
      case 80:
        return '1080P 高清 (推荐大屏电视)';
      case 64:
        return '720P 高清 (节省带宽)';
      default:
        return '自动优先 (4K)';
    }
  }

  String _getQualityBadge(int qn) {
    switch (qn) {
      case 120:
        return '4K 超清';
      case 112:
        return '1080P 高码率';
      case 80:
        return '1080P 高清';
      case 64:
        return '720P 高清';
      default:
        return '4K';
    }
  }

  void _showNotice(String message) {
    if (!mounted || !context.mounted) return;
    if (Scaffold.maybeOf(context) != null) {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final storage = ref.watch(storageServiceProvider);
    final authState = ref.watch(authProvider);
    final displayCapability = ref.watch(displayCapabilityProvider);

    final int currentQn = storage.preferredQuality;

    return TvScaffold(
      header: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              gradient: TvTheme.biliBlueGradient,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: TvTheme.biliBlue.withValues(alpha: 0.35),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.tune_rounded, size: 15, color: Colors.white),
                SizedBox(width: 5),
                Text(
                  '首选项',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Text(
            '系统与播放设置',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ],
      ),
      body: ListView(
        children: [
          // 1. 系统与显示设备 HDR 硬件直通能力检测
          _buildInteractiveCard(
            title: '显示设备 HDR / 杜比视界支持',
            subtitle: displayCapability.isHdrSupported
                ? '硬件支持: ${displayCapability.hasDolbyVision ? "杜比视界、" : ""}${displayCapability.hasHdr10 ? "HDR10" : "HDR"} 直通渲染已就绪${displayCapability.maxLuminance > 0 ? " (峰值: ${displayCapability.maxLuminance.toInt()} nits)" : ""}'
                : '当前设备或显示屏仅支持 SDR 标准动态范围 (未检测到系统 HDR10 / 杜比视界硬件支持)',
            icon: Icons.hdr_on_rounded,
            badge: displayCapability.isHdrSupported ? '支持 HDR' : '仅 SDR',
            badgeColor: displayCapability.isHdrSupported
                ? Colors.greenAccent
                : Colors.white38,
            onSelect: () {
              _showNotice(
                displayCapability.isHdrSupported
                    ? '检测到当前显示设备支持 HDR 原生直通渲染，播放 HDR 片源时将自动触发高动态范围'
                    : '当前设备或显示屏不支持 HDR 硬件直通，画质面板中 HDR 选项将按大屏规范置灰',
              );
            },
          ),
          const SizedBox(height: 14),

          // 2. PC 调试辅助开关 (仅在 Debug 模式下可见，解决在不支持 HDR 的电脑上调试 HDR 选项的诉求)
          if (kDebugMode) ...[
            _buildInteractiveCard(
              title: 'PC 调试模拟：强制支持 HDR',
              subtitle: storage.debugSimulateHdrSupport
                  ? '已启用模拟 (方便在电脑端测试 HDR 10-bit 片源播放与画质切换，画质面板已解锁 HDR)'
                  : '已关闭模拟 (当前使用真实硬件检测结果: ${ref.watch(rawDisplayCapabilityProvider).isHdrSupported ? "支持 HDR" : "仅 SDR"})',
              icon: Icons.developer_mode_rounded,
              badge: storage.debugSimulateHdrSupport ? '模拟开启' : '真实状态',
              badgeColor: storage.debugSimulateHdrSupport
                  ? Colors.cyanAccent
                  : Colors.white38,
              onSelect: () async {
                final next = !storage.debugSimulateHdrSupport;
                await storage.setDebugSimulateHdrSupport(next);
                if (!mounted) return;
                setState(() {});
                _showNotice(
                  next
                      ? '已开启 PC 调试 HDR 模拟，画质面板已解锁 HDR/杜比视界选项'
                      : '已关闭 PC 调试 HDR 模拟，恢复真实硬件状态',
                );
              },
            ),
            const SizedBox(height: 14),
          ],

          // 2. 默认视频清晰度设置
          _buildInteractiveCard(
            title: '默认视频清晰度',
            subtitle: '当前：${_getQualityName(currentQn)}  (按确定键循环切换)',
            icon: Icons.high_quality_rounded,
            badge: _getQualityBadge(currentQn),
            badgeColor: TvTheme.biliBlue,
            onSelect: () async {
              final currentIndex = _qualityOptions.indexOf(currentQn);
              final nextIndex =
                  (currentIndex + 1) % _qualityOptions.length;
              final nextQn = _qualityOptions[nextIndex];
              await storage.setPreferredQuality(nextQn);
              if (!mounted) return;
              setState(() {});
              _showNotice('默认清晰度已设置为: ${_getQualityName(nextQn)}');
            },
          ),
          const SizedBox(height: 14),

          // 3. 硬件解码策略
          _buildInteractiveCard(
            title: '视频硬件解码策略',
            subtitle: '硬解优先 (自动调度 MediaCodec / D3D11VA / 系统硬件加速，降低发热与丢帧)',
            icon: Icons.memory_rounded,
            badge: '硬解优先',
            badgeColor: Colors.tealAccent,
            onSelect: () {
              _showNotice('当前已强制锁定系统硬件解码加速，遇到不支持规格时自动软解兜底');
            },
          ),
          const SizedBox(height: 14),

          // 4. 账号管理 (若已登录)
          if (authState.isLoggedIn && authState.user != null) ...[
            _buildInteractiveCard(
              title: '登录账号：${authState.user!.uname}',
              subtitle:
                  'UID: ${authState.user!.mid} | 状态: ${authState.user!.vipStatus == 1 ? "哔哩哔哩大会员" : "普通用户"} (按确定键退出登录)',
              icon: Icons.account_circle_outlined,
              badge: '退出登录',
              badgeColor: Colors.orangeAccent,
              onSelect: () async {
                await ref.read(authProvider.notifier).logout();
                if (!mounted) return;
                _showNotice('已退出当前账号登录');
              },
            ),
            const SizedBox(height: 14),
          ],

          // 5. 关于 Bili for TV
          _buildInteractiveCard(
            title: '关于 Bili for TV',
            subtitle: '版本 v1.0.0 (仅供个人技术研究与大屏跨端架构学习交流，非商业运营)',
            icon: Icons.info_outline_rounded,
            badge: 'v1.0.0',
            badgeColor: Colors.white38,
            onSelect: () {
              _showNotice('Bili for TV 大屏客户端 - 纯技术学习交流开源研究项目');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInteractiveCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required String badge,
    required Color badgeColor,
    required VoidCallback onSelect,
  }) {
    return DpadFocusable(
      onSelect: onSelect,
      builder: (context, state, child) {
        final isFocused = state.focused;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            gradient: TvTheme.cardSurfaceGradient,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isFocused ? Colors.white : TvTheme.tvCardBorder,
              width: isFocused ? 2.0 : 1.0,
            ),
            boxShadow: isFocused
                ? [
                    BoxShadow(
                      color: TvTheme.biliBlue.withValues(alpha: 0.35),
                      blurRadius: 18,
                      spreadRadius: 1,
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isFocused
                      ? TvTheme.biliBlue.withValues(alpha: 0.25)
                      : Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 24, color: isFocused ? Colors.white : TvTheme.biliBlue),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: TvTheme.tvTextSecondary,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: badgeColor.withValues(alpha: 0.5)),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    color: badgeColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                color: isFocused ? Colors.white : TvTheme.tvTextDisabled,
                size: 24,
              ),
            ],
          ),
        );
      },
      child: const SizedBox.shrink(),
    );
  }
}

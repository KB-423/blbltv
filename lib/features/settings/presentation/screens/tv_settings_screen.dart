import 'package:flutter/material.dart';
import 'package:dpad/dpad.dart';
import '../../../../core/theme/tv_theme.dart';
import '../../../../widgets/tv_scaffold.dart';

/// TV 设置屏幕骨架
class TvSettingsScreen extends StatelessWidget {
  const TvSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return TvScaffold(
      header: Row(
        children: [
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(
              color: TvTheme.biliBlue,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '系统与播放设置',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ],
      ),
      body: ListView(
        children: [
          _buildSettingCard(
            title: '默认视频清晰度',
            subtitle: '1080P 高清 (推荐电视大屏)',
            icon: Icons.high_quality_rounded,
          ),
          const SizedBox(height: 14),
          _buildSettingCard(
            title: '视频解码策略',
            subtitle: '硬解优先 (MediaCodec / 系统硬件加速)',
            icon: Icons.memory_rounded,
          ),
          const SizedBox(height: 14),
          _buildSettingCard(
            title: '大屏弹幕显示',
            subtitle: '已开启 (字号适中，防遮挡智能合并)',
            icon: Icons.subtitles_outlined,
          ),
          const SizedBox(height: 14),
          _buildSettingCard(
            title: '关于 Bili for TV',
            subtitle: '版本 v1.0.0 (仅供个人技术交流与研究，非商业运营)',
            icon: Icons.info_outline_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingCard({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return DpadFocusable(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: TvTheme.tvSurface,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, size: 26, color: TvTheme.biliBlue),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: TvTheme.tvTextPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: TvTheme.tvTextSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: TvTheme.tvTextDisabled,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}

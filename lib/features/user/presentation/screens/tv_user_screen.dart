import 'package:flutter/material.dart';
import 'package:dpad/dpad.dart';
import '../../../../core/theme/tv_theme.dart';
import '../../../../widgets/tv_scaffold.dart';

/// TV 个人中心与扫码登录骨架
class TvUserScreen extends StatelessWidget {
  const TvUserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return TvScaffold(
      header: Row(
        children: [
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(
              color: TvTheme.biliPink,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '个人中心',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ],
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: TvTheme.tvSurface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: const Center(
                      child: Icon(
                        Icons.qr_code_2_rounded,
                        size: 150,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    '请使用 哔哩哔哩手机客户端 扫码登录',
                    style: TextStyle(
                      color: TvTheme.tvTextPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '登录后可同步播放历史、追番、动态与大会员权益',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: TvTheme.tvTextSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 20),
                  DpadFocusable(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: TvTheme.tvSurfaceLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        '刷新二维码',
                        style: TextStyle(
                          color: TvTheme.tvTextPrimary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            flex: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOptionItem(
                  icon: Icons.history_rounded,
                  title: '历史记录',
                  subtitle: '查看最近在大屏与各端观看的视频',
                ),
                const SizedBox(height: 16),
                _buildOptionItem(
                  icon: Icons.star_border_rounded,
                  title: '我的收藏',
                  subtitle: '浏览个人收藏夹视频',
                ),
                const SizedBox(height: 16),
                _buildOptionItem(
                  icon: Icons.watch_later_outlined,
                  title: '稍后再看',
                  subtitle: '标记并在大屏空闲时继续播放',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionItem({
    required IconData icon,
    required String title,
    required String subtitle,
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
            Icon(icon, size: 28, color: TvTheme.biliPink),
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

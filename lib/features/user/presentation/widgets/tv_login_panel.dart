import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dpad/dpad.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../core/theme/tv_theme.dart';
import '../providers/auth_provider.dart';

/// TV 扫码登录面板
class TvLoginPanel extends ConsumerWidget {
  const TvLoginPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 左侧：高清二维码与扫码状态
        Expanded(
          flex: 5,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
            decoration: BoxDecoration(
              color: TvTheme.tvSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: TvTheme.tvDivider),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 二维码容器
                Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (authState.qrUrl.isNotEmpty)
                          QrImageView(
                            data: authState.qrUrl,
                            version: QrVersions.auto,
                            size: 220,
                            padding: const EdgeInsets.all(12),
                            backgroundColor: Colors.white,
                          )
                        else
                          const CircularProgressIndicator(
                            color: TvTheme.biliPink,
                          ),

                        // 二维码过期遮罩
                        if (authState.isQrExpired)
                          Container(
                            color: Colors.black.withValues(alpha: 0.78),
                            child: const Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.refresh_rounded,
                                    size: 40,
                                    color: Colors.white,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    '二维码已过期',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 22),

                // 扫码状态提示
                Text(
                  authState.qrMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: authState.isQrExpired
                        ? Colors.amberAccent
                        : TvTheme.tvTextPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '打开哔哩哔哩手机客户端，点击右上角扫一扫',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: TvTheme.tvTextSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 22),

                // 刷新二维码按键
                DpadFocusable(
                  autofocus: true,
                  onSelect: () =>
                      ref.read(authProvider.notifier).startQrLogin(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: TvTheme.tvSurfaceLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.refresh_rounded,
                          size: 18,
                          color: TvTheme.tvTextPrimary,
                        ),
                        SizedBox(width: 8),
                        Text(
                          '刷新二维码',
                          style: TextStyle(
                            color: TvTheme.tvTextPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: 32),

        // 右侧：大屏登录权益说明
        Expanded(
          flex: 6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '登录畅享完整大屏体验',
                style: TextStyle(
                  color: TvTheme.tvTextPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              _buildFeatureItem(
                icon: Icons.hd_rounded,
                title: '解锁 1080P60 / 4K 超清画质',
                desc: '登录账号后自动适配电视屏幕最高支持的高清码率与原画画质',
              ),
              const SizedBox(height: 16),
              _buildFeatureItem(
                icon: Icons.history_rounded,
                title: '云端多端同步历史记录',
                desc: '在手机、电脑观看的视频，随时在电视大屏无缝断点续播',
              ),
              const SizedBox(height: 16),
              _buildFeatureItem(
                icon: Icons.star_rounded,
                title: '同步个人收藏夹与稍后再看',
                desc: '在大屏一键浏览播放个人收藏视频，大屏享受更沉浸',
              ),
              const SizedBox(height: 16),
              _buildFeatureItem(
                icon: Icons.movie_filter_rounded,
                title: '追番追剧追番剧集动态更新',
                desc: '大屏快速追踪关注的番剧连载与影视最新剧集',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String desc,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TvTheme.tvSurface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: TvTheme.biliPink.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: TvTheme.biliPink, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: TvTheme.tvTextPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: const TextStyle(
                    color: TvTheme.tvTextSecondary,
                    fontSize: 12.5,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

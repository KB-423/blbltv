import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dpad/dpad.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../core/theme/tv_theme.dart';
import '../providers/auth_provider.dart';

/// TV 扫码登录面板
/// 遵守规范：
/// 1. 仅当用户真正进入此登录界面时才发起二维码请求，退出界面时自动注销轮询
/// 2. 深度自适应电视屏幕比例，使用紧凑弹性布局避免文字组件挤压溢出
class TvLoginPanel extends ConsumerStatefulWidget {
  const TvLoginPanel({super.key});

  @override
  ConsumerState<TvLoginPanel> createState() => _TvLoginPanelState();
}

class _TvLoginPanelState extends ConsumerState<TvLoginPanel> {
  @override
  void initState() {
    super.initState();
    // 仅在打开登录界面且未拉取过有效二维码时按需发起请求
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = ref.read(authProvider);
      if (!auth.isLoggedIn && (auth.qrUrl.isEmpty || auth.isQrExpired)) {
        ref.read(authProvider.notifier).startQrLogin();
      }
    });
  }

  @override
  void dispose() {
    // 离开登录界面时停止后台无谓轮询
    ref.read(authProvider.notifier).stopPolling();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final size = MediaQuery.of(context).size;
    final bool isCompact = size.height <= 650;
    final double qrBoxSize = isCompact ? 168.0 : 200.0;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 左侧：高清二维码与扫码状态
          Expanded(
            flex: 5,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isCompact ? 20 : 28,
                vertical: isCompact ? 16 : 22,
              ),
              decoration: BoxDecoration(
                color: TvTheme.tvSurface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: TvTheme.tvDivider),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 二维码容器
                  Container(
                    width: qrBoxSize,
                    height: qrBoxSize,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          if (authState.qrUrl.isNotEmpty)
                            QrImageView(
                              data: authState.qrUrl,
                              version: QrVersions.auto,
                              size: qrBoxSize,
                              padding: const EdgeInsets.all(10),
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
                                      size: 36,
                                      color: Colors.white,
                                    ),
                                    SizedBox(height: 6),
                                    Text(
                                      '二维码已过期',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
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
                  SizedBox(height: isCompact ? 12 : 18),

                  // 扫码状态提示
                  Text(
                    authState.qrMessage.isNotEmpty
                        ? authState.qrMessage
                        : '请使用 哔哩哔哩手机客户端 扫码登录',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: authState.isQrExpired
                          ? Colors.amberAccent
                          : TvTheme.tvTextPrimary,
                      fontSize: isCompact ? 13.5 : 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '打开哔哩哔哩手机客户端，点击右上角扫一扫',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: TvTheme.tvTextSecondary,
                      fontSize: isCompact ? 11.5 : 12.5,
                    ),
                  ),
                  SizedBox(height: isCompact ? 14 : 18),

                  // 刷新二维码按键
                  DpadFocusable(
                    autofocus: true,
                    onSelect: () =>
                        ref.read(authProvider.notifier).startQrLogin(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 9,
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
                            size: 16,
                            color: TvTheme.tvTextPrimary,
                          ),
                          SizedBox(width: 6),
                          Text(
                            '刷新二维码',
                            style: TextStyle(
                              color: TvTheme.tvTextPrimary,
                              fontSize: 13,
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

          const SizedBox(width: 24),

          // 右侧：大屏登录权益说明
          Expanded(
            flex: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '登录畅享完整大屏体验',
                  style: TextStyle(
                    color: TvTheme.tvTextPrimary,
                    fontSize: isCompact ? 17 : 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: isCompact ? 12 : 16),
                _buildFeatureItem(
                  icon: Icons.hd_rounded,
                  title: '解锁 1080P60 / 4K 超清画质',
                  desc: '登录账号后自动适配电视屏幕最高支持的高清码率与原画画质',
                  isCompact: isCompact,
                ),
                SizedBox(height: isCompact ? 10 : 14),
                _buildFeatureItem(
                  icon: Icons.history_rounded,
                  title: '云端多端同步历史记录',
                  desc: '在手机、电脑观看的视频，随时在电视大屏无缝断点续播',
                  isCompact: isCompact,
                ),
                SizedBox(height: isCompact ? 10 : 14),
                _buildFeatureItem(
                  icon: Icons.star_rounded,
                  title: '同步个人收藏夹与稍后再看',
                  desc: '在大屏一键浏览播放个人收藏视频，大屏享受更沉浸',
                  isCompact: isCompact,
                ),
                SizedBox(height: isCompact ? 10 : 14),
                _buildFeatureItem(
                  icon: Icons.movie_filter_rounded,
                  title: '追番追剧追番剧集动态更新',
                  desc: '大屏快速追踪关注的番剧连载与影视最新剧集',
                  isCompact: isCompact,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String desc,
    required bool isCompact,
  }) {
    return Container(
      padding: EdgeInsets.all(isCompact ? 11 : 14),
      decoration: BoxDecoration(
        color: TvTheme.tvSurface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: TvTheme.biliPink.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: TvTheme.biliPink, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: TvTheme.tvTextPrimary,
                    fontSize: isCompact ? 13.5 : 14.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  desc,
                  style: TextStyle(
                    color: TvTheme.tvTextSecondary,
                    fontSize: isCompact ? 11.5 : 12,
                    height: 1.3,
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

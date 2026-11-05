import 'package:flutter/material.dart';
import 'package:dpad/dpad.dart';
import '../../../../core/theme/tv_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../models/video/video_item_model.dart';
import '../../../../widgets/tv_image.dart';

/// TV 视频大屏毛玻璃宽卡片组件 (Apple TV 纯净排布 2 风格)
/// 14px 大圆角、纯白微光边框、柔和白色漫反射光晕、彻底净化人工修饰词
class TvVideoCard extends StatelessWidget {
  final VideoItemModel video;
  final VoidCallback? onPlay;
  final ValueChanged<bool>? onFocusChange;
  final DpadDirectionCallback? onDirection;
  final bool autofocus;
  final FocusNode? focusNode;

  const TvVideoCard({
    super.key,
    required this.video,
    this.onPlay,
    this.onFocusChange,
    this.onDirection,
    this.autofocus = false,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return DpadFocusable(
      focusNode: focusNode,
      autofocus: autofocus,
      onSelect: onPlay,
      onFocusChange: onFocusChange,
      onDirection: onDirection,
      builder: (context, state, child) {
        final isFocused = state.focused;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          transform: isFocused
              ? Matrix4.diagonal3Values(1.03, 1.03, 1.0)
              : Matrix4.identity(),
          transformAlignment: Alignment.center,
          decoration: BoxDecoration(
            color: isFocused
                ? const Color(0xFF1E2130)
                : const Color(0xFF141622),
            borderRadius: BorderRadius.circular(TvTheme.radiusCard),
            border: Border.all(
              color: isFocused ? Colors.white : TvTheme.tvGlassBorder,
              width: isFocused ? 2.0 : 0.8,
            ),
            boxShadow: isFocused
                ? [
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.22),
                      blurRadius: 18,
                      spreadRadius: 1,
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.32),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          clipBehavior: Clip.antiAlias,
          child: child,
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 封面图 + 时长徽章 + 播放量浮层
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              fit: StackFit.expand,
              children: [
                TvNetworkImage(imageUrl: video.pic),

                // 底部暗色渐变遮罩 (确保白色数据文字在任何背景封面下清晰可见)
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.2),
                          Colors.black.withValues(alpha: 0.85),
                        ],
                        stops: const [0.4, 0.7, 1.0],
                      ),
                    ),
                  ),
                ),

                // 封面底部数据浮层 (播放量、弹幕数与时长)
                Positioned(
                  left: 8,
                  right: 8,
                  bottom: 6,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // 播放量与弹幕
                      Row(
                        children: [
                          if (video.stat != null) ...[
                            const Icon(
                              Icons.play_arrow_rounded,
                              size: 15,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              Formatters.formatCount(video.stat!.view),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (video.stat!.danmaku > 0) ...[
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.subtitles_rounded,
                                size: 12,
                                color: Colors.white70,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                Formatters.formatCount(video.stat!.danmaku),
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ],
                        ],
                      ),

                      // 时长标签
                      if (video.duration > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.75),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            Formatters.formatDuration(video.duration),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              fontFeatures: [FontFeature.tabularFigures()],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 标题与 UP 主信息
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 标题 (最多 2 行)
                  Expanded(
                    child: Text(
                      video.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: TvTheme.tvTextPrimary,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        height: 1.35,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // UP 主信息
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.white10,
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: const Icon(
                          Icons.person_rounded,
                          size: 12,
                          color: TvTheme.tvTextSecondary,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          video.owner?.name ?? '未知UP主',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: TvTheme.tvTextSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

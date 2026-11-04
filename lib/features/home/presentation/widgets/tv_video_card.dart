import 'package:flutter/material.dart';
import 'package:dpad/dpad.dart';
import '../../../../core/theme/tv_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../models/video/video_item_model.dart';
import '../../../../widgets/tv_image.dart';

/// TV 视频大屏卡片组件
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
      child: Container(
        decoration: BoxDecoration(
          color: TvTheme.tvSurface,
          borderRadius: BorderRadius.circular(10),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 封面图 + 时长徽章 + 推荐标签
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  TvNetworkImage(imageUrl: video.pic),
                  // 时长标签
                  if (video.duration > 0)
                    Positioned(
                      right: 8,
                      bottom: 8,
                      child: Container(
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
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  // 推荐理由徽章 (如: 热门精选)
                  if (video.rcmdReason != null && video.rcmdReason!.isNotEmpty)
                    Positioned(
                      left: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: TvTheme.biliPink.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          video.rcmdReason!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // 标题与 UP 主信息
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
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
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          height: 1.3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    // UP 主 & 播放量
                    Row(
                      children: [
                        const Icon(
                          Icons.person_outline_rounded,
                          size: 14,
                          color: TvTheme.tvTextSecondary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            video.owner?.name ?? '未知UP主',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: TvTheme.tvTextSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        if (video.stat != null) ...[
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.play_arrow_outlined,
                            size: 14,
                            color: TvTheme.tvTextSecondary,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            Formatters.formatCount(video.stat!.view),
                            style: const TextStyle(
                              color: TvTheme.tvTextSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

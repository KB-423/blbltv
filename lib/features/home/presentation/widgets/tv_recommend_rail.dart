import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dpad/dpad.dart';

import '../../../../core/theme/tv_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../models/video/video_item_model.dart';
import '../../../../widgets/tv_image.dart';
import '../../../main/presentation/providers/nav_rail_focus_provider.dart';
import '../providers/home_provider.dart';
import '../providers/recommend_player_provider.dart';

/// 推荐页左侧悬浮视频卡片导轨列表
/// 特性：
/// - 悬浮在全屏背景视频播放器左侧
/// - 竖向滚动，展示封面缩略图、标题、时长与UP主
/// - 正在播放项金色/粉色微光高亮
/// - 向下移动超过首屏时，触发顶部栏第二行隐藏、第一行精简为图标
/// - OK 确定直接起播并隐藏导轨进入纯享播放
/// - 保留 DpadEnterBehavior.restore 焦点记忆
class TvRecommendRail extends ConsumerStatefulWidget {
  final FocusNode? activeCardFocusNode;

  const TvRecommendRail({
    super.key,
    this.activeCardFocusNode,
  });

  @override
  ConsumerState<TvRecommendRail> createState() => _TvRecommendRailState();
}

class _TvRecommendRailState extends ConsumerState<TvRecommendRail> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final feedState = ref.watch(homeFeedProvider);
    final playerState = ref.watch(recommendPlayerProvider);
    final notifier = ref.read(recommendPlayerProvider.notifier);
    final videos = feedState.videos;

    if (videos.isEmpty) {
      return const SizedBox.shrink();
    }

    final displayMode = ref.watch(topBarDisplayModeProvider);
    final isCompact = displayMode == TopBarDisplayMode.compact;
    final double topMargin = isCompact ? 64.0 : 118.0;

    return DpadRegion(
      enter: DpadEnterBehavior.restore,
      horizontalEdge: DpadEdgeBehavior.stop,
      verticalEdge: DpadEdgeBehavior.leave,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        width: 330,
        margin: EdgeInsets.only(left: 36, top: topMargin, bottom: 28),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.65),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.12),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 28,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 顶栏微小标题指示
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                children: [
                  const Icon(
                    Icons.auto_awesome_rounded,
                    size: 15,
                    color: TvTheme.biliPink,
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    '推荐视频流',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${playerState.currentIndex + 1}/${videos.length}',
                    style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white10, height: 12),

            // 视频卡片列表
            Expanded(
              child: ListView.separated(
                controller: _scrollController,
                itemCount: videos.length,
                separatorBuilder: (context, index) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final video = videos[index];
                  final isCurrentlyPlaying = index == playerState.currentIndex;

                  return _RecommendRailCard(
                    video: video,
                    index: index,
                    isPlaying: isCurrentlyPlaying,
                    focusNode: isCurrentlyPlaying
                        ? widget.activeCardFocusNode
                        : null,
                    onFocusChanged: (focused) {
                      if (focused) {
                        notifier.resetIdleTimer();
                        // 当焦点向下移出第 0 项时，通知顶部栏精简为图标模式
                        if (index > 0) {
                          ref
                              .read(topBarDisplayModeProvider.notifier)
                              .showCompact();
                        } else {
                          ref
                              .read(topBarDisplayModeProvider.notifier)
                              .showFull();
                        }
                      }
                    },
                    onSelect: () {
                      notifier.playAt(index);
                      notifier.enterPurePlayback();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecommendRailCard extends StatelessWidget {
  final VideoItemModel video;
  final int index;
  final bool isPlaying;
  final FocusNode? focusNode;
  final ValueChanged<bool> onFocusChanged;
  final VoidCallback onSelect;

  const _RecommendRailCard({
    required this.video,
    required this.index,
    required this.isPlaying,
    this.focusNode,
    required this.onFocusChanged,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return DpadFocusable(
      focusNode: focusNode,
      onFocusChange: onFocusChanged,
      onSelect: onSelect,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        height: 78,
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isPlaying
              ? TvTheme.biliPink.withValues(alpha: 0.16)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isPlaying
                ? TvTheme.biliPink.withValues(alpha: 0.8)
                : Colors.white.withValues(alpha: 0.06),
            width: isPlaying ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            // 封面缩略图与时长
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: AspectRatio(
                    aspectRatio: 16 / 10,
                    child: TvImage(imageUrl: video.pic),
                  ),
                ),
                // 正在播放微光角标或时长
                Positioned(
                  right: 4,
                  bottom: 4,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutCubic,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      isPlaying ? '播放中' : Formatters.formatDuration(video.duration),
                      style: TextStyle(
                        color: isPlaying ? TvTheme.biliPink : Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 10),

            // 标题与 UP 主
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    video.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isPlaying ? Colors.white : Colors.white.withValues(alpha: 0.85),
                      fontSize: 12,
                      fontWeight: isPlaying ? FontWeight.w600 : FontWeight.normal,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.account_circle_outlined,
                        size: 11,
                        color: Colors.white38,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          video.owner?.name ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

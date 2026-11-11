import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dpad/dpad.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../models/video/video_item_model.dart';
import '../../../../widgets/tv_image.dart';
import '../../../main/presentation/providers/nav_rail_focus_provider.dart';
import '../providers/popular_player_provider.dart';
import '../providers/popular_provider.dart';

/// TV 全站热门视频流左侧悬浮导轨
class TvPopularRail extends ConsumerStatefulWidget {
  final FocusNode? activeCardFocusNode;

  const TvPopularRail({
    super.key,
    this.activeCardFocusNode,
  });

  @override
  ConsumerState<TvPopularRail> createState() => _TvPopularRailState();
}

class _TvPopularRailState extends ConsumerState<TvPopularRail> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      if (maxScroll - currentScroll <= 300) {
        ref.read(popularFeedProvider.notifier).loadMore();
      }
    }
  }

  @override
  void deactivate() {
    ref.read(popularPlayerProvider.notifier).cancelHoverPlay();
    super.deactivate();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final feedState = ref.watch(popularFeedProvider);
    final playerState = ref.watch(popularPlayerProvider);
    final notifier = ref.read(popularPlayerProvider.notifier);
    final videos = feedState.videos;

    if (videos.isEmpty) {
      return const SizedBox.shrink();
    }

    return DpadRegion(
      enter: DpadEnterBehavior.restore,
      horizontalEdge: DpadEdgeBehavior.stop,
      verticalEdge: DpadEdgeBehavior.leave,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        width: 330,
        margin: const EdgeInsets.only(left: 36, top: 12, bottom: 28),
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
                    Icons.whatshot_rounded,
                    size: 16,
                    color: Color(0xFFFF6699),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    '全站热门榜',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${playerState.currentIndex + 1}/${videos.length}',
                    style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),

            // 卡片纵向列表
            Expanded(
              child: ListView.separated(
                controller: _scrollController,
                itemCount: videos.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final video = videos[index];
                  final isCurrentPlaying = index == playerState.currentIndex;

                  return _PopularRailCard(
                    video: video,
                    rank: index + 1,
                    isPlaying: isCurrentPlaying,
                    focusNode:
                        isCurrentPlaying ? widget.activeCardFocusNode : null,
                    onFocusChange: (focused) {
                      if (focused) {
                        notifier.resetIdleTimer();
                        notifier.scheduleHoverPlay(index);
                        // 当焦点向下移出第 0 项 (进入第 2 个及以后) 时，通知顶部栏精简为图标模式
                        if (index > 0) {
                          ref
                              .read(topBarDisplayModeProvider.notifier)
                              .showCompact();
                        } else {
                          ref
                              .read(topBarDisplayModeProvider.notifier)
                              .showFull();
                        }
                      } else {
                        notifier.cancelHoverPlay();
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

class _PopularRailCard extends ConsumerWidget {
  final VideoItemModel video;
  final int rank;
  final bool isPlaying;
  final FocusNode? focusNode;
  final ValueChanged<bool> onFocusChange;
  final VoidCallback onSelect;

  const _PopularRailCard({
    required this.video,
    required this.rank,
    required this.isPlaying,
    this.focusNode,
    required this.onFocusChange,
    required this.onSelect,
  });

  Color _getRankColor() {
    if (rank == 1) return const Color(0xFFFFD700); // 金牌
    if (rank == 2) return const Color(0xFFC0C0C0); // 银牌
    if (rank == 3) return const Color(0xFFCD7F32); // 铜牌
    return Colors.white54;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ownerName = video.owner?.name.isNotEmpty == true ? video.owner!.name : 'UP主';
    final viewCount = video.stat?.view ?? 0;

    return DpadFocusable(
      focusNode: focusNode,
      onFocusChange: onFocusChange,
      onDirection: (direction) {
        if (direction == TraversalDirection.left) {
          return ref.read(navRailFocusServiceProvider).focusSelected();
        }
        return false;
      },
      onSelect: onSelect,
      child: const SizedBox.shrink(),
      builder: (context, state, child) {
        final isFocused = state.focused;

        final Color borderColor;
        final double borderWidth;
        final List<BoxShadow>? boxShadow;
        final Color bgColor;

        if (isFocused) {
          borderColor = Colors.white;
          borderWidth = 2.0;
          bgColor = Colors.white.withValues(alpha: 0.16);
          boxShadow = [
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.35),
              blurRadius: 16,
              spreadRadius: 1,
            ),
          ];
        } else if (isPlaying) {
          borderColor = const Color(0xFFFF6699).withValues(alpha: 0.7);
          borderWidth = 1.4;
          bgColor = const Color(0xFFFF6699).withValues(alpha: 0.08);
          boxShadow = [
            BoxShadow(
              color: const Color(0xFFFF6699).withValues(alpha: 0.25),
              blurRadius: 10,
            ),
          ];
        } else {
          borderColor = Colors.white.withValues(alpha: 0.08);
          borderWidth = 1.0;
          bgColor = Colors.white.withValues(alpha: 0.04);
          boxShadow = null;
        }

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: borderWidth),
            boxShadow: boxShadow,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 缩略图与时长 + 排名徽章
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      width: 104,
                      height: 64,
                      child: video.pic.isNotEmpty
                          ? TvImage(
                              imageUrl: video.pic,
                              fit: BoxFit.cover,
                            )
                          : Container(color: Colors.white10),
                    ),
                  ),

                  // 排名标识
                  Positioned(
                    left: 4,
                    top: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 1.5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: _getRankColor().withValues(alpha: 0.8),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        'TOP $rank',
                        style: TextStyle(
                          color: _getRankColor(),
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),

                  // 时长标签
                  if (video.duration > 0)
                    Positioned(
                      right: 4,
                      bottom: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 1.5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.75),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          Formatters.formatDuration(video.duration),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 10),

              // 视频信息
              Expanded(
                child: SizedBox(
                  height: 64,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        video.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isFocused
                              ? Colors.white
                              : (isPlaying
                                  ? const Color(0xFFFF85AD)
                                  : Colors.white.withValues(alpha: 0.88)),
                          fontSize: 12.5,
                          fontWeight:
                              isFocused || isPlaying ? FontWeight.w600 : FontWeight.w400,
                          height: 1.25,
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              ownerName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: isFocused ? Colors.white70 : Colors.white38,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          if (viewCount > 0) ...[
                            const SizedBox(width: 4),
                            Text(
                              Formatters.formatCount(viewCount),
                              style: const TextStyle(
                                color: Colors.white38,
                                fontSize: 10,
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
        );
      },
    );
  }
}

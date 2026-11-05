import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dpad/dpad.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/tv_theme.dart';
import '../../../../widgets/tv_scaffold.dart';
import '../../../../widgets/tv_status_view.dart';
import '../../../home/presentation/widgets/tv_video_card.dart';
import '../../../main/presentation/providers/nav_rail_focus_provider.dart';
import '../providers/popular_provider.dart';

/// TV 全站热门专区屏幕 (全量真实官方接口，零Mock)
class TvPopularScreen extends ConsumerStatefulWidget {
  const TvPopularScreen({super.key});

  @override
  ConsumerState<TvPopularScreen> createState() => _TvPopularScreenState();
}

class _TvPopularScreenState extends ConsumerState<TvPopularScreen> {
  final ScrollController _scrollController = ScrollController();
  final FocusNode _firstCardFocusNode =
      FocusNode(debugLabel: 'PopularFirstCardFocus');
  bool _hasInitialFocused = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tryInitialFocus();
    });
  }

  void _tryInitialFocus() {
    if (!_hasInitialFocused && mounted) {
      final videos = ref.read(popularFeedProvider).videos;
      if (videos.isNotEmpty && _firstCardFocusNode.canRequestFocus) {
        _hasInitialFocused = true;
        _firstCardFocusNode.requestFocus();
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _firstCardFocusNode.dispose();
    super.dispose();
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(popularFeedProvider, (previous, next) {
      if (!_hasInitialFocused && next.videos.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _tryInitialFocus();
        });
      }
    });

    final feedState = ref.watch(popularFeedProvider);

    return TvScaffold(
      header: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '全站热门',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          DpadRegion(
            horizontalEdge: DpadEdgeBehavior.stop,
            verticalEdge: DpadEdgeBehavior.leave,
            child: Row(
              children: [
                DpadFocusable(
                  onDirection: (direction) {
                    if (direction == TraversalDirection.left) {
                      return ref
                          .read(navRailFocusServiceProvider)
                          .focusSelected();
                    }
                    return false;
                  },
                  onSelect: () =>
                      ref.read(popularFeedProvider.notifier).refresh(),
                  builder: (context, state, child) {
                    final isFocused = state.focused;
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isFocused
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isFocused ? Colors.white : Colors.white12,
                          width: 1.2,
                        ),
                        boxShadow: isFocused
                            ? [
                                BoxShadow(
                                  color: Colors.white.withValues(alpha: 0.28),
                                  blurRadius: 14,
                                  spreadRadius: 1,
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        children: [
                          if (feedState.isRefreshing)
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.black),
                              ),
                            )
                          else
                            Icon(
                              Icons.refresh_rounded,
                              size: 17,
                              color: isFocused ? Colors.black : Colors.white,
                            ),
                          const SizedBox(width: 6),
                          Text(
                            feedState.isRefreshing ? '正在刷新...' : '换一批',
                            style: TextStyle(
                              color: isFocused ? Colors.black : Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const SizedBox.shrink(),
                ),
                const SizedBox(width: 12),
                DpadFocusable(
                  onSelect: _scrollToTop,
                  builder: (context, state, child) {
                    final isFocused = state.focused;
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isFocused
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isFocused ? Colors.white : Colors.white12,
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.vertical_align_top_rounded,
                            size: 17,
                            color: isFocused
                                ? Colors.black
                                : TvTheme.tvTextSecondary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '顶部',
                            style: TextStyle(
                              color: isFocused
                                  ? Colors.black
                                  : TvTheme.tvTextSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ],
      ),
      body: _buildBody(feedState),
    );
  }

  Widget _buildBody(PopularState feedState) {
    if (feedState.isLoading && feedState.videos.isEmpty) {
      return const TvLoadingView(message: '正在获取全站热门视频...');
    }

    if (feedState.error != null && feedState.videos.isEmpty) {
      return TvErrorView(
        error: feedState.error!,
        onRetry: () => ref.read(popularFeedProvider.notifier).refresh(),
      );
    }

    final videos = feedState.videos;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        const double spacing = 16.0;

        int crossAxisCount = 4;
        if (width < 900) {
          crossAxisCount = 2;
        } else if (width < 1250) {
          crossAxisCount = 3;
        }

        final double totalHorizontalPadding = spacing * (crossAxisCount - 1);
        final double cardWidth =
            (width - totalHorizontalPadding) / crossAxisCount;
        final double coverHeight = cardWidth * 9 / 16;
        final double textHeight = 74.0;
        final double cardHeight = coverHeight + textHeight;
        final double childAspectRatio = cardWidth / cardHeight;

        return NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification is ScrollEndNotification) {
              if (notification.metrics.extentAfter < 500) {
                ref.read(popularFeedProvider.notifier).loadMore();
              }
            }
            return false;
          },
          child: DpadRegion(
            enter: DpadEnterBehavior.restore,
            child: GridView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.only(bottom: 40),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: spacing,
                mainAxisSpacing: spacing,
                childAspectRatio: childAspectRatio,
              ),
              itemCount: videos.length +
                  (feedState.isLoadingMore ? crossAxisCount : 0),
              itemBuilder: (context, index) {
                if (index >= videos.length) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(TvTheme.radiusCard),
                    ),
                    child: const Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white38),
                        ),
                      ),
                    ),
                  );
                }

                final video = videos[index];
                final isFirstCard = index == 0;
                final isLeftCol = (index % crossAxisCount) == 0;
                final isLastRow = index >= (videos.length - crossAxisCount);

                return TvVideoCard(
                  video: video,
                  autofocus: isFirstCard,
                  focusNode: isFirstCard ? _firstCardFocusNode : null,
                  onDirection: (direction) {
                    if (isLeftCol && direction == TraversalDirection.left) {
                      return ref
                          .read(navRailFocusServiceProvider)
                          .focusSelected();
                    }
                    return false;
                  },
                  onFocusChange: (focused) {
                    if (focused && isLastRow) {
                      ref.read(popularFeedProvider.notifier).loadMore();
                    }
                  },
                  onPlay: () {
                    context.push('/player/${video.bvid}');
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}

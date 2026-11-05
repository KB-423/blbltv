import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dpad/dpad.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/tv_theme.dart';
import '../../../../widgets/tv_image.dart';
import '../../../../widgets/tv_scaffold.dart';
import '../../../../widgets/tv_status_view.dart';
import '../../../main/presentation/providers/nav_rail_focus_provider.dart';
import '../../data/models/bangumi_season_model.dart';
import '../../data/repositories/bangumi_repository.dart';
import '../providers/bangumi_provider.dart';

/// TV 追番 / 影视专区屏幕 (全量真实官方接口，零Mock)
class TvBangumiScreen extends ConsumerStatefulWidget {
  const TvBangumiScreen({super.key});

  @override
  ConsumerState<TvBangumiScreen> createState() => _TvBangumiScreenState();
}

class _TvBangumiScreenState extends ConsumerState<TvBangumiScreen> {
  final ScrollController _scrollController = ScrollController();
  final FocusNode _firstCardFocusNode =
      FocusNode(debugLabel: 'BangumiFirstCardFocus');
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
      final seasons = ref.read(bangumiFeedProvider).seasons;
      if (seasons.isNotEmpty && _firstCardFocusNode.canRequestFocus) {
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
    ref.listen(bangumiFeedProvider, (previous, next) {
      if (!_hasInitialFocused && next.seasons.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _tryInitialFocus();
        });
      }
    });

    final feedState = ref.watch(bangumiFeedProvider);

    return TvScaffold(
      header: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '追番 / 影视',
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
                      ref.read(bangumiFeedProvider.notifier).refresh(),
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
                            feedState.isRefreshing ? '正在刷新...' : '刷新',
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

  Widget _buildBody(BangumiState feedState) {
    if (feedState.isLoading && feedState.seasons.isEmpty) {
      return const TvLoadingView(message: '正在获取新番与影视列表...');
    }

    if (feedState.error != null && feedState.seasons.isEmpty) {
      return TvErrorView(
        error: feedState.error!,
        onRetry: () => ref.read(bangumiFeedProvider.notifier).refresh(),
      );
    }

    final seasons = feedState.seasons;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        const double spacing = 16.0;

        int crossAxisCount = 5;
        if (width < 900) {
          crossAxisCount = 3;
        } else if (width < 1250) {
          crossAxisCount = 4;
        }

        final double totalHorizontalPadding = spacing * (crossAxisCount - 1);
        final double cardWidth =
            (width - totalHorizontalPadding) / crossAxisCount;
        final double coverHeight = cardWidth * 4 / 3;
        final double textHeight = 64.0;
        final double cardHeight = coverHeight + textHeight;
        final double childAspectRatio = cardWidth / cardHeight;

        return NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification is ScrollEndNotification) {
              if (notification.metrics.extentAfter < 500) {
                ref.read(bangumiFeedProvider.notifier).loadMore();
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
              itemCount: seasons.length +
                  (feedState.isLoadingMore ? crossAxisCount : 0),
              itemBuilder: (context, index) {
                if (index >= seasons.length) {
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

                final season = seasons[index];
                final isFirstCard = index == 0;
                final isLeftCol = (index % crossAxisCount) == 0;
                final isLastRow = index >= (seasons.length - crossAxisCount);

                return _TvBangumiCard(
                  season: season,
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
                      ref.read(bangumiFeedProvider.notifier).loadMore();
                    }
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

class _TvBangumiCard extends ConsumerWidget {
  final BangumiSeasonModel season;
  final bool autofocus;
  final FocusNode? focusNode;
  final DpadDirectionCallback? onDirection;
  final ValueChanged<bool>? onFocusChange;

  const _TvBangumiCard({
    required this.season,
    this.autofocus = false,
    this.focusNode,
    this.onDirection,
    this.onFocusChange,
  });

  Future<void> _handlePlayBangumi(BuildContext context, WidgetRef ref) async {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '正在加载《${season.title}》剧集列表...',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 4),
      ),
    );

    try {
      final repo = ref.read(bangumiRepositoryProvider);
      final detail = await repo.fetchSeasonDetail(season.seasonId);
      final dynamic episodes = detail['episodes'];

      if (episodes is List && episodes.isNotEmpty) {
        final firstEp = episodes.first as Map;
        final String bvid = firstEp['bvid']?.toString() ?? '';

        if (context.mounted) {
          ScaffoldMessenger.of(context).removeCurrentSnackBar();
          if (bvid.isNotEmpty) {
            context.push('/player/$bvid');
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('未找到该番剧的播放资源 (bvid为空)'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).removeCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('该番剧暂无可用剧集'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('获取番剧剧集失败: $e'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DpadFocusable(
      focusNode: focusNode,
      autofocus: autofocus,
      onDirection: onDirection,
      onFocusChange: onFocusChange,
      onSelect: () => _handlePlayBangumi(context, ref),
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
            color: isFocused ? const Color(0xFF1E2130) : const Color(0xFF141622),
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
          // 竖版海报图 + 评分 + 更新状态
          AspectRatio(
            aspectRatio: 3 / 4,
            child: Stack(
              fit: StackFit.expand,
              children: [
                TvNetworkImage(imageUrl: season.cover),
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
                        stops: const [0.5, 0.75, 1.0],
                      ),
                    ),
                  ),
                ),
                // 评分
                if (season.score.isNotEmpty)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.white24, width: 0.6),
                      ),
                      child: Text(
                        '${season.score}分',
                        style: const TextStyle(
                          color: Color(0xFFFFB027),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                // 更新集数
                Positioned(
                  left: 6,
                  right: 6,
                  bottom: 6,
                  child: Text(
                    season.indexShow.isNotEmpty
                        ? season.indexShow
                        : season.order,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 标题
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
              child: Text(
                season.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: TvTheme.tvTextPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

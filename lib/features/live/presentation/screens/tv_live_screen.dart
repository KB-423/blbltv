import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dpad/dpad.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/tv_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../router/route_paths.dart';
import '../../../../widgets/tv_image.dart';
import '../../../../widgets/tv_scaffold.dart';
import '../../../../widgets/tv_status_view.dart';
import '../../../main/presentation/providers/nav_rail_focus_provider.dart';
import '../../data/models/live_room_item_model.dart';
import '../providers/live_provider.dart';

/// TV 直播专区屏幕 (全量真实官方接口，零Mock)
class TvLiveScreen extends ConsumerStatefulWidget {
  const TvLiveScreen({super.key});

  @override
  ConsumerState<TvLiveScreen> createState() => _TvLiveScreenState();
}

class _TvLiveScreenState extends ConsumerState<TvLiveScreen> {
  final ScrollController _scrollController = ScrollController();
  final FocusNode _firstCardFocusNode =
      FocusNode(debugLabel: 'LiveFirstCardFocus');
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
      final rooms = ref.read(liveFeedProvider).rooms;
      if (rooms.isNotEmpty && _firstCardFocusNode.canRequestFocus) {
        _hasInitialFocused = true;
        _firstCardFocusNode.requestFocus();
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _firstCardFocusNode.dispose();
    try {
      ref.read(topBarDisplayModeProvider.notifier).showFull();
    } catch (_) {}
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
    ref.listen(liveFeedProvider, (previous, next) {
      if (!_hasInitialFocused && next.rooms.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _tryInitialFocus();
        });
      }
    });

    final feedState = ref.watch(liveFeedProvider);

    return TvScaffold(
      header: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '直播专区',
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
                      ref.read(liveFeedProvider.notifier).refresh(),
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

  Widget _buildBody(LiveState feedState) {
    if (feedState.isLoading && feedState.rooms.isEmpty) {
      return const TvLoadingView(message: '正在获取直播大厅精彩内容...');
    }

    if (feedState.error != null && feedState.rooms.isEmpty) {
      return TvErrorView(
        error: feedState.error!,
        onRetry: () => ref.read(liveFeedProvider.notifier).refresh(),
      );
    }

    final rooms = feedState.rooms;

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
                ref.read(liveFeedProvider.notifier).loadMore();
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
              itemCount: rooms.length +
                  (feedState.isLoadingMore ? crossAxisCount : 0),
              itemBuilder: (context, index) {
                if (index >= rooms.length) {
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

                final room = rooms[index];
                final isFirstCard = index == 0;
                final isLeftCol = (index % crossAxisCount) == 0;
                final isLastRow = index >= (rooms.length - crossAxisCount);

                return _TvLiveCard(
                  room: room,
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
                    if (focused) {
                      if (index >= crossAxisCount) {
                        ref
                            .read(topBarDisplayModeProvider.notifier)
                            .showCompact();
                      } else {
                        ref
                            .read(topBarDisplayModeProvider.notifier)
                            .showFull();
                      }
                      if (isLastRow) {
                        ref.read(liveFeedProvider.notifier).loadMore();
                      }
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

class _TvLiveCard extends StatelessWidget {
  final LiveRoomItemModel room;
  final bool autofocus;
  final FocusNode? focusNode;
  final DpadDirectionCallback? onDirection;
  final ValueChanged<bool>? onFocusChange;

  const _TvLiveCard({
    required this.room,
    this.autofocus = false,
    this.focusNode,
    this.onDirection,
    this.onFocusChange,
  });

  @override
  Widget build(BuildContext context) {
    final coverUrl = room.cover.isNotEmpty ? room.cover : room.userCover;
    final area = room.areaName.isNotEmpty ? room.areaName : room.areaV2Name;

    return DpadFocusable(
      focusNode: focusNode,
      autofocus: autofocus,
      onDirection: onDirection,
      onFocusChange: onFocusChange,
      onSelect: () {
        context.push(
          RoutePaths.livePlayerWithRoomId(room.roomId),
          extra: room,
        );
      },
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
          // 封面图 + 人气徽章 + 分区
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              fit: StackFit.expand,
              children: [
                TvNetworkImage(imageUrl: coverUrl),
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
                Positioned(
                  left: 8,
                  right: 8,
                  bottom: 6,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // 在线人气
                      Row(
                        children: [
                          const Icon(Icons.whatshot_rounded,
                              size: 14, color: Colors.orangeAccent),
                          const SizedBox(width: 3),
                          Text(
                            Formatters.formatCount(room.online),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      // 分区标签
                      if (area.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            area,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // 标题与主播
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      room.title,
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
                  Row(
                    children: [
                      ClipOval(
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: TvImage(imageUrl: room.face),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          room.uname,
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

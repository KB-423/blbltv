import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dpad/dpad.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/tv_theme.dart';
import '../../../../widgets/tv_scaffold.dart';
import '../../../../widgets/tv_status_view.dart';
import '../../../main/presentation/providers/nav_rail_focus_provider.dart';
import '../../../user/presentation/providers/auth_provider.dart';
import '../providers/home_provider.dart';
import '../widgets/tv_video_card.dart';
import 'tv_immersive_home_screen.dart';

/// TV 首页推荐屏幕
/// 双模态支持：
/// 1. 默认沉浸纯享开播流 (TvImmersiveHomeScreen)：开屏即开播、上下切流、5秒自动隐退纯享
/// 2. 常规推荐网格模式 (Apple TV 纯白微光大圆角卡片瀑布流)
class TvHomeScreen extends ConsumerStatefulWidget {
  const TvHomeScreen({super.key});

  @override
  ConsumerState<TvHomeScreen> createState() => _TvHomeScreenState();
}

class _TvHomeScreenState extends ConsumerState<TvHomeScreen> {
  // 默认进入全新沉浸式开播流 (开屏即播、导航旁边浮空推荐流、上下切流、5秒自动纯享)
  bool _isImmersiveMode = true;
  final ScrollController _scrollController = ScrollController();
  final FocusNode _firstCardFocusNode =
      FocusNode(debugLabel: 'HomeFirstCardFocus');
  bool _hasInitialFocused = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isImmersiveMode) {
        _tryInitialFocus();
      }
    });
  }

  void _setImmersiveMode(bool immersive) {
    setState(() {
      _isImmersiveMode = immersive;
      _hasInitialFocused = false;
    });
    ref.read(navRailVisibilityProvider.notifier).setVisible(true);
    if (!immersive) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _tryInitialFocus();
      });
    }
  }

  void _tryInitialFocus() {
    if (!_hasInitialFocused && mounted) {
      final videos = ref.read(homeFeedProvider).videos;
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
    if (_isImmersiveMode) {
      return TvImmersiveHomeScreen(
        onSwitchToGrid: () => _setImmersiveMode(false),
      );
    }

    final feedState = ref.watch(homeFeedProvider);
    final authState = ref.watch(authProvider);

    return TvScaffold(
      header: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 左侧：纯粹优雅的推荐标题 (已彻底清除生硬人工修饰标签)
          Row(
            children: [
              Text('推荐视频',
                  style: Theme.of(context).textTheme.headlineMedium),
              if (authState.isLoggedIn && authState.user != null) ...[
                const SizedBox(width: 14),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.person_rounded,
                          size: 13, color: Colors.white70),
                      const SizedBox(width: 5),
                      Text(
                        authState.user!.uname,
                        style: const TextStyle(
                          color: TvTheme.tvTextPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),

          // 右侧：大屏遥控器操作工具栏 (独立 DpadRegion 区域隔离，横向停止逃逸)
          DpadRegion(
            horizontalEdge: DpadEdgeBehavior.stop,
            verticalEdge: DpadEdgeBehavior.leave,
            child: Row(
              children: [
                // “沉浸开播”切换按钮
                DpadFocusable(
                  onDirection: (direction) {
                    if (direction == TraversalDirection.left) {
                      return ref
                          .read(navRailFocusServiceProvider)
                          .focusSelected();
                    }
                    return false;
                  },
                  onSelect: () => _setImmersiveMode(true),
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
                          Icon(
                            Icons.play_circle_outline_rounded,
                            size: 17,
                            color: isFocused ? Colors.black : Colors.white,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '沉浸开播',
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

                // “换一批”按钮 (刷新操作)
                DpadFocusable(
                  onSelect: () =>
                      ref.read(homeFeedProvider.notifier).refresh(),
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
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  isFocused ? Colors.black : Colors.white,
                                ),
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

                // “返回顶部”按钮
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

  Widget _buildBody(dynamic feedState) {
    if (feedState.isLoading && feedState.videos.isEmpty) {
      return const TvLoadingView(message: '正在为您加载推荐内容...');
    }

    if (feedState.error != null && feedState.videos.isEmpty) {
      return TvErrorView(
        error: feedState.error!,
        onRetry: () => ref.read(homeFeedProvider.notifier).refresh(),
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
        final double cardWidth = (width - totalHorizontalPadding) / crossAxisCount;
        final double coverHeight = cardWidth * 9 / 16;
        final double textHeight = 74.0;
        final double cardHeight = coverHeight + textHeight;
        final double childAspectRatio = cardWidth / cardHeight;

        return NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification is ScrollEndNotification) {
              if (notification.metrics.extentAfter < 500) {
                ref.read(homeFeedProvider.notifier).loadMore();
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
              itemCount: videos.length + (feedState.isLoadingMore ? crossAxisCount : 0),
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
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white38),
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
                      return ref.read(navRailFocusServiceProvider).focusSelected();
                    }
                    return false;
                  },
                  onFocusChange: (focused) {
                    if (focused && isLastRow) {
                      ref.read(homeFeedProvider.notifier).loadMore();
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

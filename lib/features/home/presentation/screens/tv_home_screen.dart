import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dpad/dpad.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/tv_theme.dart';
import '../../../../router/route_paths.dart';
import '../../../../widgets/tv_scaffold.dart';
import '../../../../widgets/tv_status_view.dart';
import '../../../main/presentation/providers/nav_rail_focus_provider.dart';
import '../../../user/presentation/providers/auth_provider.dart';
import '../providers/home_provider.dart';
import '../widgets/tv_video_card.dart';

/// TV 首页推荐屏幕
/// 全面适配大屏遥控器交互：
/// - 顶部【换一批】按钮承接遥控器向上刷新体验
/// - 列表使用 DpadRegion 保持焦点记忆 (DpadEnterBehavior.restore)
/// - 焦点触底 (最后一行) 自动触发无缝预加载下一页
/// - 最左列支持遥控器左键平滑切回左侧导轨
class TvHomeScreen extends ConsumerStatefulWidget {
  const TvHomeScreen({super.key});

  @override
  ConsumerState<TvHomeScreen> createState() => _TvHomeScreenState();
}

class _TvHomeScreenState extends ConsumerState<TvHomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final FocusNode _firstCardFocusNode = FocusNode(debugLabel: 'HomeFirstCardFocus');
  bool _hasInitialFocused = false;

  @override
  void initState() {
    super.initState();
    // 首次进入若已存在缓存数据，下一帧立即将焦点请求给第一张推荐卡片
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tryInitialFocus();
    });
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
    // 监听推荐视频数据返回：一旦异步数据到位且尚未获得首焦，下一帧立刻主动请求焦点给第一张卡片
    ref.listen(homeFeedProvider, (previous, next) {
      if (!_hasInitialFocused && next.videos.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _tryInitialFocus();
        });
      }
    });

    final feedState = ref.watch(homeFeedProvider);
    final authState = ref.watch(authProvider);

    return TvScaffold(
      header: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 左侧：精致标题与用户个性化标识
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  gradient: TvTheme.biliPinkGradient,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: TvTheme.biliPink.withValues(alpha: 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome_rounded, size: 15, color: Colors.white),
                    SizedBox(width: 5),
                    Text(
                      '精彩推荐',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Text('推荐视频', style: Theme.of(context).textTheme.headlineMedium),
              if (authState.isLoggedIn && authState.user != null) ...[
                const SizedBox(width: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.person_rounded, size: 13, color: TvTheme.biliPinkLight),
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

          // 右侧：大屏遥控器操作工具栏 (独立 DpadRegion 区域隔离，横向停止逃逸，竖向受控交接)
          DpadRegion(
            horizontalEdge: DpadEdgeBehavior.stop,
            verticalEdge: DpadEdgeBehavior.leave,
            child: Row(
              children: [
                // “换一批”按钮 (对应电视的刷新操作，向左时切回左侧导轨)
              DpadFocusable(
                onDirection: (direction) {
                  if (direction == TraversalDirection.left) {
                    return ref.read(navRailFocusServiceProvider).focusSelected();
                  }
                  return false;
                },
                onSelect: () => ref.read(homeFeedProvider.notifier).refresh(),
                builder: (context, state, child) {
                  final isFocused = state.focused;
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isFocused ? Colors.white : Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isFocused ? Colors.white : Colors.white12,
                        width: 1.2,
                      ),
                      boxShadow: isFocused
                          ? [
                              BoxShadow(
                                color: Colors.white.withValues(alpha: 0.35),
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
                                isFocused ? Colors.black : TvTheme.biliPink,
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
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
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
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isFocused ? Colors.white : Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isFocused ? Colors.white : Colors.white12,
                        width: 1.2,
                      ),
                      boxShadow: isFocused
                          ? [
                              BoxShadow(
                                color: Colors.white.withValues(alpha: 0.35),
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
                          color: isFocused ? Colors.black : TvTheme.tvTextSecondary,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '顶部',
                          style: TextStyle(
                            color: isFocused ? Colors.black : TvTheme.tvTextSecondary,
                            fontSize: 13.5,
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
    if (feedState.isLoading) {
      return const TvLoadingView(message: '正在拉取推荐视频...');
    }

    if (feedState.error != null && feedState.videos.isEmpty) {
      return TvErrorView(
        error: feedState.error.toString(),
        onRetry: () => ref.read(homeFeedProvider.notifier).retry(),
      );
    }

    if (feedState.videos.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.inbox_rounded, size: 56, color: TvTheme.tvTextDisabled),
            const SizedBox(height: 12),
            const Text('暂无推荐内容', style: TextStyle(color: TvTheme.tvTextSecondary, fontSize: 16)),
            const SizedBox(height: 16),
            DpadFocusable(
              autofocus: true,
              onDirection: (direction) {
                if (direction == TraversalDirection.left) {
                  return ref.read(navRailFocusServiceProvider).focusSelected();
                }
                return false;
              },
              onSelect: () => ref.read(homeFeedProvider.notifier).refresh(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  color: TvTheme.tvSurfaceLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('重新加载', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      );
    }

    final videos = feedState.videos;

    // 采用 DpadRegion 保持焦点记忆，离开并返回时恢复之前浏览的卡片位置
    return DpadRegion(
      enter: DpadEnterBehavior.restore,
      horizontalEdge: DpadEdgeBehavior.leave,
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.only(top: 8, bottom: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 1.15,
                crossAxisSpacing: 18,
                mainAxisSpacing: 18,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                final video = videos[index];

                return TvVideoCard(
                  video: video,
                  autofocus: index == 0,
                  focusNode: index == 0 ? _firstCardFocusNode : null,
                  onDirection: (direction) {
                    // 位于每行最左列 (第 0 列) 时按左方向键，平滑切回左侧导轨
                    if (direction == TraversalDirection.left && index % 4 == 0) {
                      return ref.read(navRailFocusServiceProvider).focusSelected();
                    }
                    return false;
                  },
                  onFocusChange: (focused) {
                    // TV 触底/上拉加载逻辑：当焦点移动至倒数一行 (最后 4 个) 且获得焦点时，自动无缝加载下一页
                    if (focused && index >= videos.length - 4) {
                      ref.read(homeFeedProvider.notifier).loadMore();
                    }
                  },
                  onPlay: () {
                    context.push(RoutePaths.playerWithBvid(video.bvid));
                  },
                );
              }, childCount: videos.length),
            ),
          ),

          // 底部追加加载指示器与错误重试卡片
          SliverToBoxAdapter(child: _buildBottomStatus(feedState)),
        ],
      ),
    );
  }

  Widget _buildBottomStatus(dynamic feedState) {
    if (feedState.isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(TvTheme.biliPink),
              ),
            ),
            SizedBox(width: 12),
            Text('正在加载更多精彩视频...', style: TextStyle(color: TvTheme.tvTextSecondary, fontSize: 14)),
          ],
        ),
      );
    }

    if (feedState.error != null && feedState.videos.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: DpadFocusable(
            onSelect: () => ref.read(homeFeedProvider.notifier).loadMore(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: TvTheme.tvSurface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: TvTheme.biliPink.withValues(alpha: 0.5)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.refresh_rounded, size: 18, color: TvTheme.biliPink),
                  SizedBox(width: 8),
                  Text(
                    '加载失败，按确定键重试',
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
        ),
      );
    }

    if (!feedState.hasMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text('—— 已经到底啦 ——', style: TextStyle(color: TvTheme.tvTextDisabled, fontSize: 13)),
        ),
      );
    }

    return const SizedBox(height: 24);
  }
}

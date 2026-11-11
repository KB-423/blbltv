import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dpad/dpad.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/back_navigation_debounce.dart';
import '../../../../router/route_paths.dart';
import '../../../../widgets/tv_status_view.dart';
import '../../../home/presentation/widgets/tv_video_card.dart';
import '../../../main/presentation/providers/nav_rail_focus_provider.dart';
import '../../data/models/channel_item_model.dart';
import '../providers/channel_provider.dart';

/// TV 频道与细分专区卡片屏幕 (全量真实官方接口，零Mock)
/// 架构设计：
/// 1. 左侧板块：拉取并展示一级主频道与细分频道（子分区），支持 D-Pad 上下切换与左右联动
/// 2. 右侧板块：对应细分频道的视频选择卡片网格 (4列)
/// 3. 焦点流转与隔离：主频道 -> 细分频道 -> 视频卡片，按返回键分级向左自愈回退
class TvChannelScreen extends ConsumerStatefulWidget {
  const TvChannelScreen({super.key});

  @override
  ConsumerState<TvChannelScreen> createState() => _TvChannelScreenState();
}

class _TvChannelScreenState extends ConsumerState<TvChannelScreen> {
  final FocusNode _firstMainFocusNode =
      FocusNode(debugLabel: 'ChannelFirstMainCategory');
  final FocusNode _firstSubFocusNode =
      FocusNode(debugLabel: 'ChannelFirstSubCategory');
  final FocusNode _firstCardFocusNode =
      FocusNode(debugLabel: 'ChannelFirstVideoCard');

  final ScrollController _mainScrollController = ScrollController();
  final ScrollController _subScrollController = ScrollController();
  final ScrollController _gridScrollController = ScrollController();

  bool _isGridFocused = false;
  bool _isSubFocused = false;

  @override
  void dispose() {
    _firstMainFocusNode.dispose();
    _firstSubFocusNode.dispose();
    _firstCardFocusNode.dispose();
    _mainScrollController.dispose();
    _subScrollController.dispose();
    _gridScrollController.dispose();
    super.dispose();
  }

  void _handleBack() {
    if (!BackNavigationDebounce.shouldHandle()) return;

    final navService = ref.read(navRailFocusServiceProvider);

    // 1. 若当前在右侧视频卡片网格，返回键回到左侧细分频道列表
    if (_isGridFocused) {
      if (_firstSubFocusNode.canRequestFocus) {
        _firstSubFocusNode.requestFocus();
      }
      return;
    }

    // 2. 若当前在细分频道列表，返回键回到一级主频道列表
    if (_isSubFocused) {
      if (_firstMainFocusNode.canRequestFocus) {
        _firstMainFocusNode.requestFocus();
      }
      return;
    }

    // 3. 若当前在主频道列表，返回键交接回顶部分类栏「频道」Tab
    ref.read(topBarDisplayModeProvider.notifier).showFull();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        navService.focusSelected();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final channelState = ref.watch(channelProvider);
    final notifier = ref.read(channelProvider.notifier);
    final navService = ref.read(navRailFocusServiceProvider);

    final canPopToShell =
        !_isGridFocused && !_isSubFocused && navService.isNavRailFocused;

    return PopScope(
      canPop: canPopToShell,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBack();
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Padding(
          padding: const EdgeInsets.fromLTRB(48, 8, 48, 24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ================= 左侧：细分频道导轨面板 =================
              _buildLeftChannelsPanel(channelState, notifier),

              const SizedBox(width: 24),

              // ================= 右侧：细分频道视频选择卡片网格 =================
              Expanded(
                child: _buildRightVideoGrid(channelState, notifier),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建左侧细分频道面板 (包含一级分类 + 二级细分频道)
  Widget _buildLeftChannelsPanel(
    ChannelState state,
    ChannelNotifier notifier,
  ) {
    final mainChannels = MainChannel.defaultChannels;
    final activeMain = state.currentMainChannel;
    final subChannels = activeMain.subChannels;

    return Container(
      width: 268,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.10),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. 一级主频道紧凑图标列表 (动画、游戏、科技、影视等)
          DpadRegion(
            enter: DpadEnterBehavior.restore,
            horizontalEdge: DpadEdgeBehavior.stop,
            verticalEdge: DpadEdgeBehavior.leave,
            child: SizedBox(
              width: 104,
              child: ListView.builder(
                controller: _mainScrollController,
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                itemCount: mainChannels.length,
                itemBuilder: (context, index) {
                  final ch = mainChannels[index];
                  final isSelected = index == state.selectedMainIndex;

                  return DpadFocusable(
                    focusNode: index == 0 ? _firstMainFocusNode : null,
                    onFocusChange: (focused) {
                      if (focused) {
                        notifier.selectMainChannel(index);
                      }
                    },
                    onSelect: () => notifier.selectMainChannel(index),
                    onDirection: (direction) {
                      if (direction == TraversalDirection.left) {
                        return ref
                            .read(navRailFocusServiceProvider)
                            .focusSelected();
                      }
                      return false;
                    },
                    child: const SizedBox.shrink(),
                    builder: (context, focusState, child) {
                      final isFocused = focusState.focused;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOutCubic,
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 8),
                        decoration: BoxDecoration(
                          color: isFocused
                              ? Colors.white.withValues(alpha: 0.22)
                              : (isSelected
                                  ? Colors.white.withValues(alpha: 0.12)
                                  : Colors.transparent),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isFocused
                                ? Colors.white
                                : (isSelected
                                    ? Colors.white38
                                    : Colors.transparent),
                            width: isFocused ? 1.5 : 0.8,
                          ),
                          boxShadow: isFocused
                              ? [
                                  BoxShadow(
                                    color: Colors.white.withValues(alpha: 0.25),
                                    blurRadius: 10,
                                  ),
                                ]
                              : null,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              ch.icon,
                              size: 20,
                              color: isFocused
                                  ? Colors.white
                                  : (isSelected
                                      ? const Color(0xFFFF6699)
                                      : Colors.white60),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              ch.name,
                              style: TextStyle(
                                color: isFocused || isSelected
                                    ? Colors.white
                                    : Colors.white54,
                                fontSize: 12,
                                fontWeight: isSelected || isFocused
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),

          // 分割线
          Container(
            width: 1,
            color: Colors.white.withValues(alpha: 0.08),
          ),

          // 2. 二级细分频道列表 (拉取出来的细分频道，如单机游戏、电竞、手游...)
          Expanded(
            child: DpadRegion(
              enter: DpadEnterBehavior.restore,
              horizontalEdge: DpadEdgeBehavior.stop,
              verticalEdge: DpadEdgeBehavior.leave,
              child: ListView.builder(
                controller: _subScrollController,
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                itemCount: subChannels.length,
                itemBuilder: (context, index) {
                  final sub = subChannels[index];
                  final isSelected = index == state.selectedSubIndex;

                  return DpadFocusable(
                    autofocus: index == 0 && state.selectedMainIndex == 0,
                    focusNode: index == 0 ? _firstSubFocusNode : null,
                    onFocusChange: (focused) {
                      setState(() {
                        _isSubFocused = focused;
                      });
                      if (focused) {
                        notifier.selectSubChannel(index);
                      }
                    },
                    onSelect: () => notifier.selectSubChannel(index),
                    child: const SizedBox.shrink(),
                    builder: (context, focusState, child) {
                      final isFocused = focusState.focused;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOutCubic,
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: isFocused
                              ? Colors.white
                              : (isSelected
                                  ? const Color(0xFFFF6699).withValues(alpha: 0.22)
                                  : Colors.white.withValues(alpha: 0.04)),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isFocused
                                ? Colors.white
                                : (isSelected
                                    ? const Color(0xFFFF6699)
                                    : Colors.transparent),
                            width: isFocused ? 1.5 : 0.8,
                          ),
                          boxShadow: isFocused
                              ? [
                                  BoxShadow(
                                    color: Colors.white.withValues(alpha: 0.35),
                                    blurRadius: 12,
                                  ),
                                ]
                              : null,
                        ),
                        child: Text(
                          sub.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isFocused
                                ? Colors.black
                                : (isSelected
                                    ? const Color(0xFFFF85AD)
                                    : Colors.white70),
                            fontSize: 12.5,
                            fontWeight: isFocused || isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建右侧对应细分频道的视频选择卡片网格
  Widget _buildRightVideoGrid(
    ChannelState state,
    ChannelNotifier notifier,
  ) {
    return state.videos.when(
      loading: () => const Center(
        child: TvLoadingView(message: '正在拉取细分频道视频...'),
      ),
      error: (error, stack) => Center(
        child: TvErrorView(
          error: error.toString(),
          onRetry: notifier.refresh,
        ),
      ),
      data: (videos) {
        if (videos.isEmpty) {
          return Center(
            child: TvEmptyView(
              message: '该细分频道暂无视频',
              onRefresh: notifier.refresh,
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 细分频道标题与数量指示
            Padding(
              padding: const EdgeInsets.only(bottom: 12, left: 4),
              child: Row(
                children: [
                  Text(
                    '${state.currentMainChannel.name} · ${state.currentSubChannel.name}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${videos.length} 个视频',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 视频卡片网格 (4列)
            Expanded(
              child: DpadRegion(
                enter: DpadEnterBehavior.restore,
                horizontalEdge: DpadEdgeBehavior.stop,
                verticalEdge: DpadEdgeBehavior.leave,
                child: GridView.builder(
                  controller: _gridScrollController,
                  padding: const EdgeInsets.only(bottom: 24),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 18,
                    mainAxisSpacing: 18,
                    childAspectRatio: 16 / 13.8,
                  ),
                  itemCount: videos.length,
                  itemBuilder: (context, index) {
                    final video = videos[index];
                    final isCol0 = (index % 4) == 0;

                    return TvVideoCard(
                      video: video,
                      focusNode: index == 0 ? _firstCardFocusNode : null,
                      onFocusChange: (focused) {
                        if (focused != _isGridFocused) {
                          setState(() {
                            _isGridFocused = focused;
                          });
                        }
                      },
                      onDirection: (direction) {
                        // 在第 0 列按向左方向键时，平滑交接回左侧细分频道列表
                        if (direction == TraversalDirection.left && isCol0) {
                          if (_firstSubFocusNode.canRequestFocus) {
                            _firstSubFocusNode.requestFocus();
                            return true;
                          }
                        }
                        return false;
                      },
                      onPlay: () {
                        // 进入全屏播放器
                        context.push(RoutePaths.playerWithBvid(video.bvid));
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dpad/dpad.dart';

import '../../../../core/theme/tv_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../models/video/video_part_model.dart';

/// 统一的播放器剧集/分P项通用模型
class TvEpisodeItem {
  final int index;
  final String title;
  final String subtitle;
  final String? badge;
  final int? durationSeconds;
  final String? bvid;
  final int? cid;

  const TvEpisodeItem({
    required this.index,
    required this.title,
    required this.subtitle,
    this.badge,
    this.durationSeconds,
    this.bvid,
    this.cid,
  });

  factory TvEpisodeItem.fromPart(VideoPartItem part, int index) {
    return TvEpisodeItem(
      index: index,
      title: 'P${part.page}',
      subtitle: part.part.isNotEmpty ? part.part : 'P${part.page}',
      durationSeconds: part.duration,
      cid: part.cid,
    );
  }
}

/// TV 播放器通用选集/分 P 侧边抽屉
/// 支持：
/// - 普通多 P 视频分集选择
/// - 番剧 / 影视季度集数选择 (含会员标、限免标)
/// - 自动居中定位当前播放集数，挂载首帧即落焦当前正在播放的项目
class TvEpisodeDrawer extends StatefulWidget {
  final String drawerTitle;
  final String? countLabel;
  final List<TvEpisodeItem> episodes;
  final int currentIndex;
  final ValueChanged<int> onSelectEpisode;
  final VoidCallback onClose;

  const TvEpisodeDrawer({
    super.key,
    this.drawerTitle = '选集播放',
    this.countLabel,
    required this.episodes,
    required this.currentIndex,
    required this.onSelectEpisode,
    required this.onClose,
  });

  @override
  State<TvEpisodeDrawer> createState() => _TvEpisodeDrawerState();
}

class _TvEpisodeDrawerState extends State<TvEpisodeDrawer> {
  final Map<int, FocusNode> _episodeFocusNodes = {};
  final ScrollController _scrollController = ScrollController();
  final FocusNode _drawerRootFocusNode =
      FocusNode(debugLabel: 'TvEpisodeDrawerRoot');

  @override
  void initState() {
    super.initState();
    _initFocusNodes();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _focusCurrentEpisode();
    });
  }

  void _initFocusNodes() {
    for (int i = 0; i < widget.episodes.length; i++) {
      _episodeFocusNodes[i] = FocusNode(debugLabel: 'EpisodeItem_$i');
    }
  }

  void _focusCurrentEpisode() {
    final targetNode = _episodeFocusNodes[widget.currentIndex] ??
        _episodeFocusNodes.values.firstOrNull;
    targetNode?.requestFocus();
    if (widget.currentIndex > 2 && _scrollController.hasClients) {
      _scrollController.animateTo(
        (widget.currentIndex - 2) * 64.0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void didUpdateWidget(TvEpisodeDrawer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.episodes.length != widget.episodes.length) {
      for (int i = 0; i < widget.episodes.length; i++) {
        _episodeFocusNodes.putIfAbsent(
          i,
          () => FocusNode(debugLabel: 'EpisodeItem_$i'),
        );
      }
    }
  }

  @override
  void dispose() {
    _drawerRootFocusNode.dispose();
    _scrollController.dispose();
    for (final node in _episodeFocusNodes.values) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FocusScope(
      autofocus: true,
      child: Focus(
        focusNode: _drawerRootFocusNode,
        onKeyEvent: (node, event) {
          if (event.logicalKey == LogicalKeyboardKey.arrowLeft ||
              event.logicalKey == LogicalKeyboardKey.escape ||
              event.logicalKey == LogicalKeyboardKey.goBack) {
            if (event is KeyDownEvent) {
              widget.onClose();
            }
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        child: Container(
          width: 420,
          height: double.infinity,
          color: TvTheme.tvSurface.withValues(alpha: 0.96),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 抽屉头部标题与关闭按钮
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        widget.drawerTitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.countLabel ?? '(${widget.episodes.length})',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  DpadFocusable(
                    onSelect: widget.onClose,
                    builder: (context, state, child) {
                      final isFocused = state.focused;
                      return Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: isFocused
                              ? Colors.white
                              : TvTheme.tvSurfaceLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          color: isFocused ? Colors.black : Colors.white70,
                          size: 18,
                        ),
                      );
                    },
                    child: const SizedBox.shrink(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                '使用遥控器上下键浏览，按确定键切换',
                style: TextStyle(
                  color: TvTheme.tvTextSecondary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 16),

              // 剧集/分 P 列表
              Expanded(
                child: DpadRegion(
                  verticalEdge: DpadEdgeBehavior.stop,
                  horizontalEdge: DpadEdgeBehavior.stop,
                  onEdge: (direction) {
                    if (direction == TraversalDirection.left) {
                      widget.onClose();
                    }
                  },
                  child: ListView.separated(
                    controller: _scrollController,
                    itemCount: widget.episodes.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final item = widget.episodes[index];
                      final isCurrent = index == widget.currentIndex;
                      final focusNode = _episodeFocusNodes[index];

                      return DpadFocusable(
                        focusNode: focusNode,
                        autofocus: isCurrent,
                        onSelect: () {
                          widget.onSelectEpisode(index);
                        },
                        builder: (context, state, child) {
                          final isFocused = state.focused;
                          return Container(
                            height: 56,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isCurrent
                                  ? TvTheme.biliPink.withValues(alpha: 0.22)
                                  : (isFocused
                                      ? Colors.white
                                      : TvTheme.tvSurfaceLight),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isFocused
                                    ? Colors.white
                                    : (isCurrent
                                        ? TvTheme.biliPink
                                        : Colors.transparent),
                                width: isFocused ? 2.0 : 1.2,
                              ),
                              boxShadow: isFocused
                                  ? [
                                      BoxShadow(
                                        color: Colors.white
                                            .withValues(alpha: 0.35),
                                        blurRadius: 14,
                                        spreadRadius: 1,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Row(
                              children: [
                                // 集数 / P 数编号标签
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isFocused
                                        ? Colors.black.withValues(alpha: 0.1)
                                        : (isCurrent
                                            ? TvTheme.biliPink
                                            : Colors.white12),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    item.title,
                                    style: TextStyle(
                                      color: isFocused
                                          ? Colors.black
                                          : (isCurrent
                                              ? Colors.white
                                              : Colors.white70),
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),

                                // 标题内容
                                Expanded(
                                  child: Text(
                                    item.subtitle,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: isFocused
                                          ? Colors.black
                                          : (isCurrent
                                              ? TvTheme.biliPinkLight
                                              : Colors.white),
                                      fontSize: 14,
                                      fontWeight: isCurrent || isFocused
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),

                                // 专属角标 (会员/限免)
                                if (item.badge != null &&
                                    item.badge!.isNotEmpty) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: TvTheme.biliPink
                                          .withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(
                                        color: TvTheme.biliPink,
                                        width: 0.8,
                                      ),
                                    ),
                                    child: Text(
                                      item.badge!,
                                      style: const TextStyle(
                                        color: TvTheme.biliPink,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],

                                // 时长
                                if (item.durationSeconds != null &&
                                    item.durationSeconds! > 0) ...[
                                  const SizedBox(width: 8),
                                  Text(
                                    Formatters.formatDuration(
                                        item.durationSeconds!),
                                    style: TextStyle(
                                      color: isFocused
                                          ? Colors.black54
                                          : Colors.white38,
                                      fontSize: 12,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        },
                        child: const SizedBox.shrink(),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

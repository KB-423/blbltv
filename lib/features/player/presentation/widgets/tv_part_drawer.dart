import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dpad/dpad.dart';
import '../../../../core/theme/tv_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../models/video/video_part_model.dart';

/// TV 播放器多 P 选集抽屉组件
/// 采用 Apple TV 纯净毛玻璃微光容器，支持遥控器左右键快速切集与返回键自愈
class TvPartDrawer extends StatefulWidget {
  final List<VideoPartItem> parts;
  final int currentPartIndex;
  final ValueChanged<int> onSelectPart;
  final VoidCallback onClose;

  const TvPartDrawer({
    super.key,
    required this.parts,
    required this.currentPartIndex,
    required this.onSelectPart,
    required this.onClose,
  });

  @override
  State<TvPartDrawer> createState() => _TvPartDrawerState();
}

class _TvPartDrawerState extends State<TvPartDrawer> {
  final Map<int, FocusNode> _partFocusNodes = {};
  final FocusNode _drawerFocusNode = FocusNode(debugLabel: 'TvPartDrawerRoot');

  @override
  void initState() {
    super.initState();
    _initFocusNodes();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _focusCurrentPart();
    });
  }

  void _initFocusNodes() {
    for (int i = 0; i < widget.parts.length; i++) {
      _partFocusNodes[i] = FocusNode(debugLabel: 'PartItem_$i');
    }
  }

  void _focusCurrentPart() {
    final targetNode = _partFocusNodes[widget.currentPartIndex] ??
        _partFocusNodes.values.firstOrNull;
    targetNode?.requestFocus();
  }

  @override
  void dispose() {
    _drawerFocusNode.dispose();
    for (final node in _partFocusNodes.values) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FocusScope(
      autofocus: true,
      child: Focus(
        focusNode: _drawerFocusNode,
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.escape ||
                event.logicalKey == LogicalKeyboardKey.goBack ||
                event.logicalKey == LogicalKeyboardKey.arrowLeft) {
              widget.onClose();
              return KeyEventResult.handled;
            }
          }
          return KeyEventResult.ignored;
        },
        child: Container(
          width: 380,
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
                      const Text(
                        '选集播放',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white12,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '共${widget.parts.length}P',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                  DpadFocusable(
                    onSelect: widget.onClose,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: TvTheme.tvSurfaceLight,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: Colors.white70,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                '遥控器上下移动选择分P，按OK键立即切换起播',
                style: TextStyle(
                  color: TvTheme.tvTextSecondary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 16),

              // 分 P 列表
              Expanded(
                child: DpadRegion(
                  verticalEdge: DpadEdgeBehavior.stop,
                  horizontalEdge: DpadEdgeBehavior.stop,
                  child: ListView.separated(
                    itemCount: widget.parts.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = widget.parts[index];
                      final isCurrent = index == widget.currentPartIndex;
                      final focusNode = _partFocusNodes[index];

                      return DpadFocusable(
                        focusNode: focusNode,
                        autofocus: isCurrent,
                        onSelect: () => widget.onSelectPart(index),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: isCurrent
                                ? Colors.white.withValues(alpha: 0.16)
                                : TvTheme.tvSurfaceLight,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isCurrent
                                  ? Colors.white
                                  : Colors.transparent,
                              width: 1.2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: isCurrent
                                      ? Colors.white
                                      : Colors.white12,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'P${item.page}',
                                  style: TextStyle(
                                    color: isCurrent
                                        ? Colors.black
                                        : Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  item.part.isNotEmpty
                                      ? item.part
                                      : '第 ${item.page} 集',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: isCurrent
                                        ? Colors.white
                                        : TvTheme.tvTextPrimary,
                                    fontSize: 14,
                                    fontWeight: isCurrent
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                              if (item.duration > 0) ...[
                                const SizedBox(width: 8),
                                Text(
                                  Formatters.formatDuration(item.duration),
                                  style: const TextStyle(
                                    color: Colors.white38,
                                    fontSize: 11,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
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

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dpad/dpad.dart';

import '../../../../core/theme/tv_theme.dart';

/// TV 播放器顶部信息栏组件
/// - 返回按钮 (支持遥控器落焦与轻触)
/// - 标题与标签 (番剧话数、分P号、直播状态)
/// - 实时在看人数
/// - 实时时间时钟
class TvPlayerHeader extends StatefulWidget {
  final String title;
  final String? subtitle;
  final String? badgeText;
  final Color? badgeColor;
  final String? onlineCount;
  final VoidCallback onBack;
  final FocusNode? backButtonFocusNode;

  const TvPlayerHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.badgeText,
    this.badgeColor,
    this.onlineCount,
    required this.onBack,
    this.backButtonFocusNode,
  });

  @override
  State<TvPlayerHeader> createState() => _TvPlayerHeaderState();
}

class _TvPlayerHeaderState extends State<TvPlayerHeader> {
  late String _currentTimeString;
  Timer? _clockTimer;

  @override
  void initState() {
    super.initState();
    _updateClock();
    _clockTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      if (mounted) {
        setState(_updateClock);
      }
    });
  }

  void _updateClock() {
    final now = DateTime.now();
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    _currentTimeString = '$hour:$minute';
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.90),
            Colors.transparent,
          ],
        ),
      ),
      child: Row(
        children: [
          // 遥控器可聚焦返回按钮
          DpadFocusable(
            focusNode: widget.backButtonFocusNode,
            onSelect: widget.onBack,
            builder: (context, state, child) {
              final isFocused = state.focused;
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isFocused
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.12),
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
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.arrow_back_rounded,
                      size: 16,
                      color: isFocused ? Colors.black : Colors.white,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '返回',
                      style: TextStyle(
                        color: isFocused ? Colors.black : Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            },
            child: const SizedBox.shrink(),
          ),
          const SizedBox(width: 18),

          // 标题与标签
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    if (widget.badgeText != null &&
                        widget.badgeText!.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: (widget.badgeColor ?? TvTheme.biliPink)
                              .withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: widget.badgeColor ?? TvTheme.biliPink,
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          widget.badgeText!,
                          style: TextStyle(
                            color: widget.badgeColor ?? TvTheme.biliPink,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                    Expanded(
                      child: Text(
                        widget.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                if (widget.subtitle != null && widget.subtitle!.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    widget.subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 16),

          // 在线在看人数
          if (widget.onlineCount != null && widget.onlineCount!.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.visibility_rounded,
                    size: 13,
                    color: Colors.white70,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    '${widget.onlineCount} 人在看',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
          ],

          // 实时时钟
          Text(
            _currentTimeString,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}

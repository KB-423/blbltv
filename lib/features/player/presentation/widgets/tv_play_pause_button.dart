import 'package:flutter/material.dart';
import 'package:dpad/dpad.dart';

/// TV 播放器专用的播放/暂停控制按钮
/// - 支持 D-Pad 遥控器落焦与白光拟态
/// - 优雅的播放/暂停图标过渡
class TvPlayPauseButton extends StatelessWidget {
  final bool isPlaying;
  final VoidCallback onTogglePlay;
  final FocusNode? focusNode;
  final bool autofocus;
  final double size;

  const TvPlayPauseButton({
    super.key,
    required this.isPlaying,
    required this.onTogglePlay,
    this.focusNode,
    this.autofocus = false,
    this.size = 46.0,
  });

  @override
  Widget build(BuildContext context) {
    return DpadFocusable(
      focusNode: focusNode,
      autofocus: autofocus,
      onSelect: onTogglePlay,
      builder: (context, state, child) {
        final isFocused = state.focused;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isFocused
                ? Colors.white
                : Colors.white.withValues(alpha: 0.12),
            border: Border.all(
              color: isFocused ? Colors.white : Colors.white12,
              width: 1.5,
            ),
            boxShadow: isFocused
                ? [
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.4),
                      blurRadius: 18,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, animation) =>
                  ScaleTransition(scale: animation, child: child),
              child: Icon(
                isPlaying
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded,
                key: ValueKey<bool>(isPlaying),
                size: size * 0.58,
                color: isFocused ? Colors.black : Colors.white,
              ),
            ),
          ),
        );
      },
      child: const SizedBox.shrink(),
    );
  }
}

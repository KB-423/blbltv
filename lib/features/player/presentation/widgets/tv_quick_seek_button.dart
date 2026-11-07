import 'package:flutter/material.dart';
import 'package:dpad/dpad.dart';

/// TV 播放器快进/快退按钮 (-10s 或 +10s)
class TvQuickSeekButton extends StatelessWidget {
  final bool isForward;
  final int seconds;
  final VoidCallback onSeek;
  final VoidCallback? onLongSeek;
  final FocusNode? focusNode;
  final double size;

  const TvQuickSeekButton({
    super.key,
    required this.isForward,
    this.seconds = 10,
    required this.onSeek,
    this.onLongSeek,
    this.focusNode,
    this.size = 42.0,
  });

  @override
  Widget build(BuildContext context) {
    final icon = isForward
        ? (seconds == 10
            ? Icons.forward_10_rounded
            : Icons.fast_forward_rounded)
        : (seconds == 10
            ? Icons.replay_10_rounded
            : Icons.fast_rewind_rounded);

    return DpadFocusable(
      focusNode: focusNode,
      onSelect: onSeek,
      onLongSelect: onLongSeek,
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
                : Colors.white.withValues(alpha: 0.08),
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
          child: Center(
            child: Icon(
              icon,
              size: size * 0.52,
              color: isFocused ? Colors.black : Colors.white,
            ),
          ),
        );
      },
      child: const SizedBox.shrink(),
    );
  }
}

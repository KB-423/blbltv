import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dpad/dpad.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/tv_theme.dart';

/// TV 全屏视频播放器屏幕骨架
class TvPlayerScreen extends StatelessWidget {
  final String bvid;

  const TvPlayerScreen({
    super.key,
    required this.bvid,
  });

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.escape): const DismissIntent(),
        LogicalKeySet(LogicalKeyboardKey.goBack): const DismissIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          DismissIntent: CallbackAction<DismissIntent>(
            onInvoke: (intent) => context.pop(),
          ),
        },
        child: Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            fit: StackFit.expand,
            children: [
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.play_circle_outline_rounded,
                      size: 80,
                      color: TvTheme.biliPink,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '正在准备大屏播放: $bvid',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Dash / FLV 高清流解析与遥控器控制条集成中',
                      style: TextStyle(
                        color: TvTheme.tvTextSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              Positioned(
                top: 32,
                left: 36,
                right: 36,
                child: Row(
                  children: [
                    DpadFocusable(
                      autofocus: true,
                      onSelect: () => context.pop(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                            SizedBox(width: 8),
                            Text(
                              '返回',
                              style: TextStyle(color: Colors.white, fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      '稿件号: $bvid',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),

              Positioned(
                left: 36,
                right: 36,
                bottom: 32,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      DpadFocusable(
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: const Icon(
                            Icons.pause_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        '00:00 / 12:34',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: LinearProgressIndicator(
                          value: 0.35,
                          backgroundColor: Colors.white24,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            TvTheme.biliPink,
                          ),
                          minHeight: 4,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 16),
                      DpadFocusable(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white38),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            '1080P 高清',
                            style: TextStyle(color: Colors.white, fontSize: 13),
                          ),
                        ),
                      ),
                    ],
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../../../../core/player/global_player_manager.dart';
import '../../../../core/player/playback_session.dart';
import '../../../../widgets/tv_image.dart';

/// 全局单例视频播放器视窗组件
/// 核心特性：
/// 1. 挂载全局唯一 VideoController，避免反复创建 Surface 产生黑屏与显存暴涨
/// 2. 顶层叠加「冻结帧快照」过渡层：切页再切回时，视频就绪前立即呈现离开时的画面快照，实现 0ms 视觉黑屏
/// 3. 当视频首帧渲染就绪后，通过 AnimatedOpacity 在 280ms 内平滑隐去快照，丝滑恢复动态播放
class GlobalTvVideoSurface extends ConsumerWidget {
  const GlobalTvVideoSurface({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final manager = ref.read(globalPlayerManagerProvider.notifier);
    final kernelState = ref.watch(globalPlayerManagerProvider);
    final controller = manager.videoController;
    final activeSession = kernelState.activeSession;

    final bool showSnapshot = !kernelState.isFirstFrameRendered;

    return Stack(
      fit: StackFit.expand,
      children: [
        // 1. 底层原生硬件加速视频渲染 Surface
        if (controller != null)
          Video(
            controller: controller,
            controls: NoVideoControls,
            fit: BoxFit.cover,
          )
        else
          const ColoredBox(color: Colors.black),

        // 2. 顶层冻结快照平滑过渡层 (0ms 黑屏核心保障)
        Positioned.fill(
          child: AnimatedOpacity(
            opacity: showSnapshot ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            child: _buildSnapshotPlaceholder(activeSession),
          ),
        ),
      ],
    );
  }

  Widget _buildSnapshotPlaceholder(PlaybackSession? session) {
    if (session == null) {
      return const ColoredBox(color: Colors.black);
    }

    // 优先展示离开时截取的真实进度画面冻结快照
    if (session.lastFrameBytes != null && session.lastFrameBytes!.isNotEmpty) {
      return Image.memory(
        session.lastFrameBytes!,
        fit: BoxFit.cover,
      );
    }

    // 兜底展示视频网络高清封面图，依然杜绝黑屏
    if (session.coverUrl != null && session.coverUrl!.isNotEmpty) {
      return TvImage(
        imageUrl: session.coverUrl!,
        fit: BoxFit.cover,
      );
    }

    return const ColoredBox(color: Colors.black);
  }
}

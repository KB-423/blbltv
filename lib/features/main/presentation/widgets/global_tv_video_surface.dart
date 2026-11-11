import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../../../../core/player/global_player_manager.dart';
import '../../../../core/player/playback_session.dart';
import '../../../../widgets/tv_image.dart';

/// 全局单例视频播放器视窗组件
/// 核心特性：
/// 1. 挂载全局唯一 VideoController，避免反复创建 Surface 产生黑屏与显存暴涨
/// 2. 多租户状态获知：当被其他组件借调或换流时，自动展示「原点快照」或「封面降级兜底」，杜绝黑屏
/// 3. 当视频首帧渲染就绪后，通过 AnimatedOpacity 在 280ms 内平滑隐去快照，丝滑恢复动态播放
class GlobalTvVideoSurface extends ConsumerWidget {
  final String? expectedOwnerId;

  const GlobalTvVideoSurface({
    super.key,
    this.expectedOwnerId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final manager = ref.read(globalPlayerManagerProvider.notifier);
    final kernelState = ref.watch(globalPlayerManagerProvider);
    final controller = manager.videoController;
    final activeSession = kernelState.activeSession;

    // 是否应该显示实时视频画面：首帧已渲染 且 没有报错 (且若指定了 expectedOwnerId，需匹配)
    final bool isLiveVideoReady = kernelState.isFirstFrameRendered &&
        kernelState.error == null &&
        (expectedOwnerId == null ||
            kernelState.activeOwnerId.isEmpty ||
            kernelState.activeOwnerId == expectedOwnerId);

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

        // 2. 顶层冻结快照 / 封面预览平滑过渡层 (0ms 黑屏与降级兜底)
        Positioned.fill(
          child: AnimatedOpacity(
            opacity: isLiveVideoReady ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            child: _buildSnapshotOrCover(activeSession, kernelState),
          ),
        ),
      ],
    );
  }

  Widget _buildSnapshotOrCover(
    PlaybackSession? session,
    GlobalPlayerKernelState kernelState,
  ) {
    // 优先 1：展示当前会话保存的最后一帧快照数据 (0ms 原点快照)
    final snapshotBytes = kernelState.snapshotBytes ?? session?.lastFrameBytes;
    if (snapshotBytes != null && snapshotBytes.isNotEmpty) {
      return Image.memory(
        snapshotBytes,
        fit: BoxFit.cover,
      );
    }

    // 优先 2：降级展示高清封面预览图 (Cover Image Fallback)
    final cover = session?.coverUrl ?? session?.currentVideo?.pic;
    if (cover != null && cover.isNotEmpty) {
      return TvImage(
        imageUrl: cover,
        fit: BoxFit.cover,
      );
    }

    // 优先 3：纯色质感黑底
    return const ColoredBox(color: Colors.black);
  }
}

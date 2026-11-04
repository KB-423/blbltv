import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../../../../core/theme/tv_theme.dart';
import '../../../../widgets/tv_status_view.dart';
import '../providers/player_provider.dart';
import '../widgets/tv_player_controls.dart';
import '../widgets/tv_quality_panel.dart';

/// TV 全屏视频播放器屏幕
class TvPlayerScreen extends ConsumerStatefulWidget {
  final String bvid;

  const TvPlayerScreen({
    super.key,
    required this.bvid,
  });

  @override
  ConsumerState<TvPlayerScreen> createState() => _TvPlayerScreenState();
}

class _TvPlayerScreenState extends ConsumerState<TvPlayerScreen> {
  void _handleBack(BuildContext context, dynamic playerState, dynamic notifier) {
    if (playerState.showQualityPanel) {
      notifier.closeQualityPanel();
    } else if (playerState.showControls) {
      notifier.toggleControls();
    } else {
      context.pop();
    }
  }

  KeyEventResult _handleKeyEvent(KeyEvent event, dynamic state, dynamic notifier) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    // 如果画质面板打开，优先让其内部 ListView 处理上下键
    if (state.showQualityPanel) {
      if (event.logicalKey == LogicalKeyboardKey.escape ||
          event.logicalKey == LogicalKeyboardKey.goBack) {
        notifier.closeQualityPanel();
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    }

    // 遥控器方向左键 -> 快退 10 秒
    if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      notifier.seekBackward(seconds: 10);
      return KeyEventResult.handled;
    }

    // 遥控器方向右键 -> 快进 10 秒
    if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      notifier.seekForward(seconds: 10);
      return KeyEventResult.handled;
    }

    // 遥控器方向上/下键 -> 唤醒控制栏
    if (event.logicalKey == LogicalKeyboardKey.arrowUp ||
        event.logicalKey == LogicalKeyboardKey.arrowDown) {
      notifier.showControlsTemporarily();
      return KeyEventResult.handled;
    }

    // 遥控器返回键
    if (event.logicalKey == LogicalKeyboardKey.escape ||
        event.logicalKey == LogicalKeyboardKey.goBack) {
      _handleBack(context, state, notifier);
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final playerState = ref.watch(playerProvider(widget.bvid));
    final notifier = ref.read(playerProvider(widget.bvid).notifier);
    final videoController = notifier.videoController;

    return Focus(
      autofocus: true,
      onKeyEvent: (_, event) => _handleKeyEvent(event, playerState, notifier),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            // 视频渲染层 (MediaKit Video 引擎，硬解大屏支持)
            GestureDetector(
              onTap: notifier.toggleControls,
              child: Center(
                child: videoController != null
                    ? Video(
                        controller: videoController,
                        controls: NoVideoControls,
                      )
                    : const SizedBox.shrink(),
              ),
            ),

            // 加载中指示器 (解析流或切换清晰度)
            if (playerState.isLoading || playerState.isBuffering)
              Container(
                color: playerState.isLoading
                    ? Colors.black.withValues(alpha: 0.85)
                    : Colors.transparent,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 48,
                        height: 48,
                        child: CircularProgressIndicator(
                          strokeWidth: 3.5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            TvTheme.biliPink,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        playerState.isLoading ? '正在获取高清视频流...' : '缓冲中...',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // 错误重试界面
            if (playerState.error != null && !playerState.isLoading)
              Center(
                child: TvErrorView(
                  error: playerState.error!,
                  onRetry: () => notifier.retry(),
                ),
              ),

            // 播放器控制栏浮层 (顶部标题 + 底部进度条 + 播放/快进/画质按钮)
            if (playerState.showControls && !playerState.isLoading)
              TvPlayerControls(
                title: playerState.title,
                bvid: widget.bvid,
                isPlaying: playerState.isPlaying,
                position: playerState.position,
                duration: playerState.duration,
                currentQn: playerState.currentQn,
                qualities: playerState.qualities,
                onTogglePlay: notifier.togglePlay,
                onSeekBackward: () => notifier.seekBackward(seconds: 10),
                onSeekForward: () => notifier.seekForward(seconds: 10),
                onOpenQuality: notifier.openQualityPanel,
                onBack: () => context.pop(),
              ),

            // 侧边弹出式画质选择面板
            if (playerState.showQualityPanel) ...[
              // 背景半透明遮罩，点击可关闭
              GestureDetector(
                onTap: notifier.closeQualityPanel,
                child: Container(
                  color: Colors.black45,
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                bottom: 0,
                child: TvQualityPanel(
                  qualities: playerState.qualities,
                  currentQn: playerState.currentQn,
                  onSelectQuality: (qn) => notifier.changeQuality(qn),
                  onClose: notifier.closeQualityPanel,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

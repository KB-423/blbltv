import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:dpad/dpad.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../widgets/tv_image.dart';
import '../../../../widgets/tv_status_view.dart';
import '../../data/models/live_room_item_model.dart';
import '../../data/repositories/live_repository.dart';

/// TV 全屏直播播放器界面
/// 遵循 10-foot TV 大屏规范：
/// - 纯 C 原生 opensles 音频驱动，杜绝 CheckJNI CheckMethodID 崩溃
/// - 动态控制条 4 秒自动淡出
/// - 遥控器单次返回键平滑出栈，彻底杜绝黑屏与重复按键
/// - 优雅退出生命周期，组件 unmount 时停止流，保护视频纹理
class TvLivePlayerScreen extends ConsumerStatefulWidget {
  final int roomId;
  final LiveRoomItemModel? room;

  const TvLivePlayerScreen({
    super.key,
    required this.roomId,
    this.room,
  });

  @override
  ConsumerState<TvLivePlayerScreen> createState() => _TvLivePlayerScreenState();
}

class _TvLivePlayerScreenState extends ConsumerState<TvLivePlayerScreen> {
  Player? _player;
  VideoController? _videoController;

  bool _isLoading = true;
  String? _errorMessage;
  bool _showControls = true;
  Timer? _hideControlsTimer;

  final FocusNode _rootFocusNode = FocusNode();
  final FocusNode _backButtonFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _initLivePlayer();
    _resetHideControlsTimer();
  }

  Future<void> _initLivePlayer() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final repository = ref.read(liveRepositoryProvider);
      final playUrl = await repository.fetchLivePlayUrl(widget.roomId);

      if (!mounted) return;

      final player = Player(
        configuration: const PlayerConfiguration(
          bufferSize: 32 * 1024 * 1024,
        ),
      );
      _player = player;
      _videoController = VideoController(player);

      final dynamic platform = player.platform;
      if (Platform.isAndroid) {
        await platform?.setProperty('volume-max', '100');
        await platform?.setProperty('ao', 'opensles');
        await platform?.setProperty('hwdec', 'auto-safe');
      }
      await platform?.setProperty('video-sync', 'audio');

      player.stream.error.listen((error) {
        debugPrint('[LivePlayer] 播放错误: $error');
      });

      await player.open(
        Media(
          playUrl,
          httpHeaders: {
            'Referer': 'https://live.bilibili.com',
            'User-Agent': ApiConstants.defaultUserAgent,
          },
        ),
        play: true,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
    if (_showControls) {
      _resetHideControlsTimer();
      _backButtonFocusNode.requestFocus();
    } else {
      _rootFocusNode.requestFocus();
    }
  }

  void _resetHideControlsTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 4), () {
      if (mounted && _showControls) {
        setState(() {
          _showControls = false;
        });
        _rootFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _hideControlsTimer?.cancel();
    _rootFocusNode.dispose();
    _backButtonFocusNode.dispose();
    final p = _player;
    _player = null;
    _videoController = null;
    if (p != null) {
      try {
        p.stop();
        p.dispose();
      } catch (e) {
        debugPrint('[LivePlayer] 停止播放器异常: $e');
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Focus(
          focusNode: _rootFocusNode,
          autofocus: true,
          onKeyEvent: (node, event) {
            if (event is KeyDownEvent) {
              if (event.logicalKey == LogicalKeyboardKey.select ||
                  event.logicalKey == LogicalKeyboardKey.enter ||
                  event.logicalKey == LogicalKeyboardKey.arrowUp ||
                  event.logicalKey == LogicalKeyboardKey.arrowDown) {
                _toggleControls();
                return KeyEventResult.handled;
              }
            }
            return KeyEventResult.ignored;
          },
          child: GestureDetector(
            onTap: _toggleControls,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // 1. 视频画面
                if (_videoController != null)
                  Center(
                    child: Video(
                      controller: _videoController!,
                      controls: NoVideoControls,
                    ),
                  ),

                // 2. 加载与错误状态
                if (_isLoading)
                  const ColoredBox(
                    color: Colors.black54,
                    child: TvLoadingView(message: '正在连接直播流...'),
                  )
                else if (_errorMessage != null)
                  ColoredBox(
                    color: Colors.black87,
                    child: TvErrorView(
                      error: _errorMessage!,
                      onRetry: _initLivePlayer,
                    ),
                  ),

                // 3. 顶部信息栏与控制栏 (平滑动效)
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  top: _showControls ? 0 : -110,
                  left: 0,
                  right: 0,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: _showControls ? 1.0 : 0.0,
                    child: _buildTopHeader(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopHeader(BuildContext context) {
    final room = widget.room;
    final title = room?.title ?? '直播间 ${widget.roomId}';
    final uname = room?.uname ?? '';
    final area = room?.areaName.isNotEmpty == true
        ? room!.areaName
        : (room?.areaV2Name ?? '');
    final online = room?.online ?? 0;

    return Container(
      padding: const EdgeInsets.only(top: 24, left: 32, right: 32, bottom: 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black87,
            Colors.black54,
            Colors.transparent,
          ],
        ),
      ),
      child: DpadRegion(
        child: Row(
          children: [
            // 返回按钮
            DpadFocusable(
              focusNode: _backButtonFocusNode,
              autofocus: true,
              onSelect: () => context.pop(),
              builder: (context, state, child) {
                final isFocused = state.focused;
                return Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isFocused ? Colors.white : Colors.black45,
                    shape: BoxShape.circle,
                    boxShadow: isFocused
                        ? [
                            BoxShadow(
                              color: Colors.white.withValues(alpha: 0.4),
                              blurRadius: 12,
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    Icons.arrow_back_rounded,
                    color: isFocused ? Colors.black : Colors.white,
                    size: 24,
                  ),
                );
              },
              child: const SizedBox.shrink(),
            ),
            const SizedBox(width: 20),

            // 主播头像
            if (room != null && room.face.isNotEmpty) ...[
              ClipOval(
                child: SizedBox(
                  width: 42,
                  height: 42,
                  child: TvImage(
                    imageUrl: room.face,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 14),
            ],

            // 直播间标题与主播名
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      // LIVE 标识红点
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF4684),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.circle, color: Colors.white, size: 6),
                            SizedBox(width: 4),
                            Text(
                              'LIVE',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (area.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            area,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 10.5,
                            ),
                          ),
                        ),
                      ],
                      if (uname.isNotEmpty) ...[
                        const SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            uname,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // 在线人气
            if (online > 0) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white24, width: 0.8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.local_fire_department_rounded,
                      color: Color(0xFFFF5252),
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${Formatters.formatCount(online)} 人气',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

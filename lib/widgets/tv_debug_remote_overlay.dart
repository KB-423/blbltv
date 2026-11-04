// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dpad/dpad.dart';

import '../core/theme/tv_theme.dart';
import '../router/app_router.dart';

/// TV 调试虚拟遥控器浮层 (Debug Remote Overlay)
/// 专门用于在平板 (Pad) 或 PC 调试 TV 应用时，无需物理遥控器即可通过触控/鼠标全方位测试大屏焦点、按键交互与长按快进快退。
///
/// 仅在 [kDebugMode] 模式下生效，Release 打包零开销完全移除。
class TvDebugRemoteOverlay extends StatefulWidget {
  final Widget child;

  const TvDebugRemoteOverlay({
    super.key,
    required this.child,
  });

  @override
  State<TvDebugRemoteOverlay> createState() => _TvDebugRemoteOverlayState();
}

class _TvDebugRemoteOverlayState extends State<TvDebugRemoteOverlay> {
  // 是否展开遥控器完整面板 (默认收起为小胶囊)
  bool _isExpanded = false;

  // 浮动面板相对于屏幕右下角的偏移量 (支持任意拖拽移动)
  Offset _offset = const Offset(20, 20);

  // 长按连续触发计时器 (模拟物理遥控器持续按住)
  Timer? _repeatTimer;

  // 当前正在按下的键名（用于拟物化即时高亮反馈）
  LogicalKeyboardKey? _pressedKey;

  @override
  void dispose() {
    _repeatTimer?.cancel();
    super.dispose();
  }

  /// 向底层焦点系统与硬件按键总线投递按键事件
  bool _dispatchKeyEvent(
    LogicalKeyboardKey logicalKey, {
    bool isDown = true,
    bool isRepeat = false,
  }) {
    final physicalKey = _getPhysicalKey(logicalKey);
    final now = Duration(microseconds: DateTime.now().microsecondsSinceEpoch);

    final KeyEvent event = isRepeat
        ? KeyRepeatEvent(
            physicalKey: physicalKey,
            logicalKey: logicalKey,
            timeStamp: now,
          )
        : (isDown
            ? KeyDownEvent(
                physicalKey: physicalKey,
                logicalKey: logicalKey,
                timeStamp: now,
              )
            : KeyUpEvent(
                physicalKey: physicalKey,
                logicalKey: logicalKey,
                timeStamp: now,
              ));

    // 1. 同步更新 HardwareKeyboard 按键状态
    HardwareKeyboard.instance.handleKeyEvent(event);

    // 2. 将按键直接注入 Flutter 根按键消息分发通道 (驱动当前 primaryFocus 及 FocusNode.onKeyEvent)
    try {
      final handler =
          ServicesBinding.instance.keyEventManager.keyMessageHandler;
      if (handler != null) {
        return handler(KeyMessage([event], null));
      }
    } catch (e) {
      debugPrint('[TvDebugRemote] 按键分发异常: $e');
    }

    return false;
  }

  /// 单次轻触按键 (生成精确的物理 Down + 50ms 延时 Up 事件)
  bool _sendTapKey(LogicalKeyboardKey key) {
    _ensureFocus();
    final handled = _dispatchKeyEvent(key, isDown: true);
    Future.delayed(const Duration(milliseconds: 50), () {
      _dispatchKeyEvent(key, isDown: false);
    });
    return handled;
  }

  /// 确保应用内有焦点目标；若当前因触控等原因丢失焦点，让 Dpad 恢复焦点
  void _ensureFocus() {
    final primary = FocusManager.instance.primaryFocus;
    if (primary == null || primary is FocusScopeNode) {
      final dpad = Dpad.maybeOf(context);
      dpad?.moveDown();
    }
  }

  /// 单次触发方向键：仅分发一次物理按键，绝不重复调用 dpad.move，彻底消除“左右跳两下”
  void _triggerDirection(LogicalKeyboardKey key) {
    setState(() => _pressedKey = key);
    _sendTapKey(key);
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted && _pressedKey == key) {
        setState(() => _pressedKey = null);
      }
    });
  }

  /// 开始按住按键 (长按快进/快退/持续连击)
  void _startHoldKey(LogicalKeyboardKey key) {
    _repeatTimer?.cancel();
    _ensureFocus();
    setState(() => _pressedKey = key);

    // 1. 立即投递 KeyDown
    _dispatchKeyEvent(key, isDown: true);

    // 2. 220ms 后若未松手，进入连续 Repeat 状态 (周期 120ms)
    _repeatTimer = Timer(const Duration(milliseconds: 220), () {
      _repeatTimer = Timer.periodic(const Duration(milliseconds: 120), (_) {
        _dispatchKeyEvent(key, isRepeat: true);
      });
    });
  }

  /// 结束按住按键 (松手)
  void _endHoldKey(LogicalKeyboardKey key) {
    _repeatTimer?.cancel();
    _repeatTimer = null;
    setState(() => _pressedKey = null);

    // 投递 KeyUp 结束物理按键状态 (播放器接收到 KeyUp 会执行松手 seek 跳转)
    _dispatchKeyEvent(key, isDown: false);
  }

  /// 触发 OK / 确定键 (同时触发 DpadFocusable 脉冲激活与原生 Select 键分发)
  void _triggerSelect() {
    _ensureFocus();
    setState(() => _pressedKey = LogicalKeyboardKey.select);
    final dpad = Dpad.maybeOf(context);

    // 1. 尝试使用 DpadController.select() 触发 DpadFocusable.onSelect
    dpad?.select();

    // 2. 同时投递真实的物理按键 Down + Up，以触发任何监听 select/enter 的 Focus/TextField/Player
    _sendTapKey(LogicalKeyboardKey.select);

    Future.delayed(const Duration(milliseconds: 120), () {
      if (mounted && _pressedKey == LogicalKeyboardKey.select) {
        setState(() => _pressedKey = null);
      }
    });
  }

  /// 触发返回按键：优先由当前界面 (如播放器) 拦截处理，未拦截则通过全局根 Navigator 退出
  void _triggerBack() {
    setState(() => _pressedKey = LogicalKeyboardKey.escape);

    // 1. 发送硬件 escape 键 (当前获得焦点的页面如播放器优先拦截)
    final handled = _sendTapKey(LogicalKeyboardKey.escape);

    // 2. 如果未被当前焦点组件消费，通过全局根导航器安全 Pop
    if (!handled) {
      final nav = rootNavigatorKey.currentState;
      if (nav != null && nav.canPop()) {
        nav.maybePop();
      } else {
        final dpad = Dpad.maybeOf(context);
        dpad?.back();
      }
    }

    Future.delayed(const Duration(milliseconds: 120), () {
      if (mounted && _pressedKey == LogicalKeyboardKey.escape) {
        setState(() => _pressedKey = null);
      }
    });
  }

  PhysicalKeyboardKey _getPhysicalKey(LogicalKeyboardKey key) {
    if (key == LogicalKeyboardKey.arrowUp) return PhysicalKeyboardKey.arrowUp;
    if (key == LogicalKeyboardKey.arrowDown) {
      return PhysicalKeyboardKey.arrowDown;
    }
    if (key == LogicalKeyboardKey.arrowLeft) {
      return PhysicalKeyboardKey.arrowLeft;
    }
    if (key == LogicalKeyboardKey.arrowRight) {
      return PhysicalKeyboardKey.arrowRight;
    }
    if (key == LogicalKeyboardKey.select || key == LogicalKeyboardKey.enter) {
      return PhysicalKeyboardKey.enter;
    }
    if (key == LogicalKeyboardKey.escape ||
        key == LogicalKeyboardKey.goBack) {
      return PhysicalKeyboardKey.escape;
    }
    if (key == LogicalKeyboardKey.keyD) return PhysicalKeyboardKey.keyD;
    if (key == LogicalKeyboardKey.contextMenu) {
      return PhysicalKeyboardKey.contextMenu;
    }
    return PhysicalKeyboardKey.space;
  }

  @override
  Widget build(BuildContext context) {
    // 严格限制：仅在 Debug 模式下启用虚拟遥控器
    if (!kDebugMode) {
      return widget.child;
    }

    final dpad = Dpad.maybeOf(context);
    final focusedLabel = dpad?.focused?.debugLabel;

    return Stack(
      fit: StackFit.expand,
      children: [
        // 核心主应用界面
        widget.child,

        // 浮动虚拟遥控器控制层
        // 关键：外层使用 ExcludeFocus 包裹，彻底杜绝触摸遥控器时抢占/清除应用内真实 TV 组件的焦点！
        Positioned(
          right: _offset.dx,
          bottom: _offset.dy,
          child: ExcludeFocus(
            excluding: true,
            child: _isExpanded
                ? _buildRemotePad(focusedLabel)
                : _buildMiniTrigger(),
          ),
        ),
      ],
    );
  }

  /// 最小化悬浮胶囊把手 (支持拖动与一键展开)
  Widget _buildMiniTrigger() {
    return GestureDetector(
      onPanUpdate: (details) {
        setState(() {
          _offset = Offset(
            (_offset.dx - details.delta.dx).clamp(10.0, 600.0),
            (_offset.dy - details.delta.dy).clamp(10.0, 1000.0),
          );
        });
      },
      onTap: () {
        setState(() {
          _isExpanded = true;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF16161D).withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: TvTheme.biliPink.withValues(alpha: 0.9),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: TvTheme.biliPink.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.settings_remote_rounded,
              color: TvTheme.biliPink,
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
              'TV 遥控器',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 展开的大屏拟物化虚拟遥控器面板
  Widget _buildRemotePad(String? currentFocusedLabel) {
    return Container(
      width: 228,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF181822).withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: TvTheme.biliPink.withValues(alpha: 0.8),
          width: 1.6,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.7),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 顶部标题栏与收起按钮 (支持按住拖拽移动整个面板)
          GestureDetector(
            onPanUpdate: (details) {
              setState(() {
                _offset = Offset(
                  (_offset.dx - details.delta.dx).clamp(10.0, 500.0),
                  (_offset.dy - details.delta.dy).clamp(10.0, 900.0),
                );
              });
            },
            child: Container(
              color: Colors.transparent,
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.drag_indicator_rounded,
                        color: Colors.white38,
                        size: 16,
                      ),
                      SizedBox(width: 4),
                      Text(
                        '模拟 TV 遥控器',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isExpanded = false;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white12,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        size: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: Colors.white12),
          const SizedBox(height: 10),

          // 快捷功能按键栏 (返回、极客信息 D、菜单)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionBtn(
                icon: Icons.arrow_back_rounded,
                label: '返回',
                isPressed: _pressedKey == LogicalKeyboardKey.escape,
                onTap: _triggerBack,
              ),
              _buildActionBtn(
                icon: Icons.terminal_rounded,
                label: '极客D',
                highlight: true,
                isPressed: _pressedKey == LogicalKeyboardKey.keyD,
                onTap: () {
                  setState(() => _pressedKey = LogicalKeyboardKey.keyD);
                  _sendTapKey(LogicalKeyboardKey.keyD);
                  Future.delayed(const Duration(milliseconds: 120), () {
                    if (mounted) setState(() => _pressedKey = null);
                  });
                },
              ),
              _buildActionBtn(
                icon: Icons.menu_rounded,
                label: '菜单',
                isPressed: _pressedKey == LogicalKeyboardKey.contextMenu,
                onTap: () {
                  setState(() => _pressedKey = LogicalKeyboardKey.contextMenu);
                  _sendTapKey(LogicalKeyboardKey.contextMenu);
                  Future.delayed(const Duration(milliseconds: 120), () {
                    if (mounted) setState(() => _pressedKey = null);
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 核心圆形导航盘 (D-Pad)
          _buildDPadDisk(),
          const SizedBox(height: 12),

          // 实时焦点监控与长按提示
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: TvTheme.biliBlue,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '当前落焦: ${currentFocusedLabel ?? "未获取到焦点 (按方向键寻焦)"}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 10.5,
                          fontFamily: 'monospace',
                          decoration: TextDecoration.none,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                const Text(
                  '※ 提示：长按左/右键可连续快退快进',
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 9.5,
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 拟物化圆形 D-Pad 方向圆盘 (支持长按连续触发与触感即时动效)
  Widget _buildDPadDisk() {
    return Container(
      width: 160,
      height: 160,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF242430),
        border: Border.all(
          color: Colors.white24,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 10,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 上键
          Positioned(
            top: 4,
            child: _buildDirectionArrow(
              icon: Icons.arrow_drop_up_rounded,
              keyName: LogicalKeyboardKey.arrowUp,
            ),
          ),

          // 下键
          Positioned(
            bottom: 4,
            child: _buildDirectionArrow(
              icon: Icons.arrow_drop_down_rounded,
              keyName: LogicalKeyboardKey.arrowDown,
            ),
          ),

          // 左键 (支持普通点击与长按连续触发快退)
          Positioned(
            left: 4,
            child: _buildDirectionArrow(
              icon: Icons.arrow_left_rounded,
              keyName: LogicalKeyboardKey.arrowLeft,
              supportLongPress: true,
            ),
          ),

          // 右键 (支持普通点击与长按连续触发快进)
          Positioned(
            right: 4,
            child: _buildDirectionArrow(
              icon: Icons.arrow_right_rounded,
              keyName: LogicalKeyboardKey.arrowRight,
              supportLongPress: true,
            ),
          ),

          // 中央 OK / 确定键 (带触控脉冲反馈)
          Listener(
            onPointerDown: (_) => _triggerSelect(),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: _pressedKey == LogicalKeyboardKey.select
                      ? [
                          TvTheme.biliPink.withValues(alpha: 0.7),
                          const Color(0xFFFF4D79),
                        ]
                      : [
                          TvTheme.biliPink,
                          const Color(0xFFFF85A1),
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: TvTheme.biliPink.withValues(
                      alpha: _pressedKey == LogicalKeyboardKey.select ? 0.7 : 0.4,
                    ),
                    blurRadius: _pressedKey == LogicalKeyboardKey.select ? 14 : 8,
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  'OK',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    letterSpacing: 0.5,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 方向键构建器 (采用原生 Listener 彻底避免 GestureArena 延迟，实现 0ms 触控响应)
  Widget _buildDirectionArrow({
    required IconData icon,
    required LogicalKeyboardKey keyName,
    bool supportLongPress = false,
  }) {
    final isDown = _pressedKey == keyName;

    return Listener(
      onPointerDown: (_) {
        if (supportLongPress) {
          _startHoldKey(keyName);
        } else {
          _triggerDirection(keyName);
        }
      },
      onPointerUp: (_) {
        if (supportLongPress) {
          _endHoldKey(keyName);
        }
      },
      onPointerCancel: (_) {
        if (supportLongPress) {
          _endHoldKey(keyName);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: 48,
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isDown ? TvTheme.biliPink.withValues(alpha: 0.3) : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 34,
          color: isDown ? Colors.white : Colors.white70,
        ),
      ),
    );
  }

  /// 顶部小功能按键
  Widget _buildActionBtn({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool highlight = false,
    bool isPressed = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isPressed
              ? TvTheme.biliPink.withValues(alpha: 0.4)
              : (highlight
                  ? TvTheme.biliPink.withValues(alpha: 0.2)
                  : Colors.white10),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isPressed || highlight
                ? TvTheme.biliPink.withValues(alpha: 0.7)
                : Colors.white12,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 13,
              color: highlight || isPressed ? TvTheme.biliPink : Colors.white70,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: highlight || isPressed ? TvTheme.biliPink : Colors.white70,
                fontSize: 11,
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

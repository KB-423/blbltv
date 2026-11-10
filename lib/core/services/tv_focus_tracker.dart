import 'dart:collection';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:logging/logging.dart';

/// 记录单次按键或焦点变动的动作快照
class TvActionSnapshot {
  final DateTime timestamp;
  final String actionType; // 'KEY' 或 'FOCUS'
  final String details;

  const TvActionSnapshot({
    required this.timestamp,
    required this.actionType,
    required this.details,
  });

  @override
  String toString() {
    final t = '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}:${timestamp.second.toString().padLeft(2, '0')}.${timestamp.millisecond.toString().padLeft(3, '0')}';
    return '[$t] [$actionType] $details';
  }
}

/// TV 全局焦点移动与物理按键追踪器 (TvFocusTracker)
///
/// 职责：
/// 1. 深度追踪 TV 遥控器与键盘焦点流转，定位焦点当前停留在哪一个组件上；
/// 2. 全局拦截遥控器/物理按键事件（方向键、确定键、返回键、菜单键等），将按键与焦点变化按时序全量记录进日志；
/// 3. 当出现【失焦 (primaryFocus == null)】时，自动导出最近操作时序快照，一键获取精准复现路径；
/// 4. 使用 `package:logging`（Logger: `TvFocus` 与 `TvKey`）结构化输出。
class TvFocusTracker {
  TvFocusTracker._();

  static final Logger _focusLogger = Logger('TvFocus');
  static final Logger _keyLogger = Logger('TvKey');

  static FocusNode? _lastFocusedNode;
  static bool _isListening = false;

  // 保存最近 30 条操作时序快照（按键 + 焦点），用于失焦时回溯复现路径
  static const int _maxTrailSize = 30;
  static final ListQueue<TvActionSnapshot> _actionTrail =
      ListQueue<TvActionSnapshot>();

  /// 获取当前已记录的操作快照复现路径
  static List<TvActionSnapshot> get actionTrail => _actionTrail.toList();

  /// 初始化全局焦点与按键监听器
  static void init() {
    if (_isListening) return;
    _isListening = true;

    // 1. 挂接 Flutter 全局焦点管理器
    FocusManager.instance.addListener(_onGlobalFocusChanged);

    // 2. 挂接 Flutter 全局硬件/遥控器物理按键拦截器
    HardwareKeyboard.instance.addHandler(_onKeyEvent);

    _focusLogger.info('TV 全局焦点与遥控器按键追踪器已挂接 (Focus & HardwareKeyboard Active)');
  }

  /// 停止监听并清理
  static void dispose() {
    if (!_isListening) return;
    FocusManager.instance.removeListener(_onGlobalFocusChanged);
    HardwareKeyboard.instance.removeHandler(_onKeyEvent);
    _isListening = false;
    _lastFocusedNode = null;
    _actionTrail.clear();
  }

  /// 清空当前复现路径轨迹
  static void clearTrail() {
    _actionTrail.clear();
  }

  static void _onGlobalFocusChanged() {
    final primary = FocusManager.instance.primaryFocus;
    logFocus(primary);
  }

  static bool _onKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent || event is KeyRepeatEvent) {
      logKey(event);
    }
    // 严禁吞掉按键，必须返回 false 保证系统 traversal policy 和业务组件正常消费按键
    return false;
  }

  /// 记录遥控器/键盘按键事件
  static void logKey(KeyEvent event) {
    final keyType = event is KeyRepeatEvent ? 'KeyRepeat' : 'KeyDown';
    final keyName = _formatLogicalKey(event.logicalKey);

    final currentFocus = FocusManager.instance.primaryFocus;
    final currentLabel = currentFocus?.debugLabel ?? '(无焦点)';
    final currentWidget =
        currentFocus?.context?.widget.runtimeType.toString() ?? 'None';

    final details =
        '[$keyName] ($keyType) | 当前获得焦点: [$currentLabel] (Widget: $currentWidget)';

    _recordSnapshot('KEY', details);
    _keyLogger.info('⌨ 遥控器按键: $details');
  }

  /// 记录焦点变动
  /// 支持由 `FocusManager` 自动触发，或由 `Dpad.wrap(onFocusChange: ...)` 显式触发
  static void logFocus(FocusNode? node) {
    if (identical(node, _lastFocusedNode)) {
      return;
    }
    _lastFocusedNode = node;

    // 焦点丢失 (null)
    if (node == null) {
      _recordSnapshot('FOCUS', '⚠ 焦点丢失: (primaryFocus == null)');
      final trailDump = dumpReproductionTrail();
      _focusLogger.warning(
        '⚠ 焦点丢失: 当前页面无活动焦点节点 (primaryFocus == null)！\n'
        '═══════════════════ 焦点丢失前操作复现路径 ═══════════════════\n'
        '$trailDump\n'
        '══════════════════════════════════════════════════════════════',
      );
      return;
    }

    final debugLabel = node.debugLabel ?? '(无debugLabel)';
    final widgetName =
        node.context?.widget.runtimeType.toString() ?? 'UnmountedWidget';
    final rect = _extractRect(node);
    final rectInfo = rect != null
        ? ' | 坐标: [x=${rect.left.toInt()}, y=${rect.top.toInt()}, w=${rect.width.toInt()}, h=${rect.height.toInt()}]'
        : '';
    final parentLabel = node.parent?.debugLabel;
    final parentInfo = parentLabel != null && parentLabel.isNotEmpty
        ? ' | 父级: [$parentLabel]'
        : '';

    final details =
        '🎯 焦点移入 -> [$debugLabel] (Widget: $widgetName)$parentInfo$rectInfo';

    _recordSnapshot('FOCUS', '[$debugLabel] (Widget: $widgetName)$parentInfo');
    _focusLogger.info(details);
  }

  static void _recordSnapshot(String actionType, String details) {
    if (_actionTrail.length >= _maxTrailSize) {
      _actionTrail.removeFirst();
    }
    _actionTrail.add(
      TvActionSnapshot(
        timestamp: DateTime.now(),
        actionType: actionType,
        details: details,
      ),
    );
  }

  /// 生成格式化的失焦操作复现路径文本
  static String dumpReproductionTrail() {
    if (_actionTrail.isEmpty) {
      return '  (暂无前序操作快照)';
    }

    final buffer = StringBuffer();
    int index = 1;
    for (final snapshot in _actionTrail) {
      buffer.writeln('  $index. $snapshot');
      index++;
    }
    return buffer.toString().trimRight();
  }

  static Rect? _extractRect(FocusNode node) {
    if (node.context == null) return null;
    try {
      final context = node.context;
      if (context != null && context.findRenderObject() is RenderBox) {
        final renderBox = context.findRenderObject() as RenderBox;
        if (renderBox.hasSize && renderBox.attached) {
          final offset = renderBox.localToGlobal(Offset.zero);
          return offset & renderBox.size;
        }
      }
      return node.rect;
    } catch (_) {
      return null;
    }
  }

  static String _formatLogicalKey(LogicalKeyboardKey key) {
    if (key == LogicalKeyboardKey.arrowUp) return 'DPAD_UP';
    if (key == LogicalKeyboardKey.arrowDown) return 'DPAD_DOWN';
    if (key == LogicalKeyboardKey.arrowLeft) return 'DPAD_LEFT';
    if (key == LogicalKeyboardKey.arrowRight) return 'DPAD_RIGHT';
    if (key == LogicalKeyboardKey.select ||
        key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.gameButtonA) {
      return 'OK/SELECT';
    }
    if (key == LogicalKeyboardKey.escape || key == LogicalKeyboardKey.goBack) {
      return 'BACK';
    }
    if (key == LogicalKeyboardKey.contextMenu) {
      return 'MENU';
    }
    return key.debugName ?? key.keyLabel;
  }
}

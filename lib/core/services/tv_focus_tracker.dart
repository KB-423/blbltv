import 'package:flutter/widgets.dart';
import 'package:logging/logging.dart';

/// TV 全局焦点移动监听与追踪器 (TvFocusTracker)
///
/// 职责：
/// 1. 深度追踪 TV 遥控器与键盘焦点流转，定位焦点当前停留在哪一个组件上；
/// 2. 使用 `package:logging`（Logger: `TvFocus`）统一输出结构化日志；
/// 3. 输出信息包括：
///    - `debugLabel`：焦点节点的标签名；
///    - `widget`：宿主 Widget 的具体类型（如 `DpadFocusable`, `_ProgressBarItem`, `_CategoryTabItem` 等）；
///    - `rect`：大屏物理坐标与尺寸（x, y, w, h）；
///    - `parent`：父级焦点节点或所属 DpadRegion；
/// 4. 自动捕获【焦点丢失】异常（`primaryFocus == null`），便于快速排查大屏按键失灵与焦点掉落。
class TvFocusTracker {
  TvFocusTracker._();

  static final Logger _logger = Logger('TvFocus');
  static FocusNode? _lastFocusedNode;
  static bool _isListening = false;

  /// 初始化全局焦点追踪监听器
  static void init() {
    if (_isListening) return;
    _isListening = true;

    FocusManager.instance.addListener(_onGlobalFocusChanged);
    _logger.info('TV 全局焦点监听器已挂接 (FocusManager Listener Active)');
  }

  /// 停止监听
  static void dispose() {
    if (!_isListening) return;
    FocusManager.instance.removeListener(_onGlobalFocusChanged);
    _isListening = false;
    _lastFocusedNode = null;
  }

  static void _onGlobalFocusChanged() {
    final primary = FocusManager.instance.primaryFocus;
    logFocus(primary);
  }

  /// 记录焦点变动
  /// 支持从 `FocusManager` 或 `Dpad.wrap(onFocusChange: ...)` 显式调用
  static void logFocus(FocusNode? node) {
    if (identical(node, _lastFocusedNode)) {
      return;
    }
    _lastFocusedNode = node;

    if (node == null) {
      _logger.warning('⚠ 焦点丢失: 当前页面无活动焦点节点 (primaryFocus == null)');
      return;
    }

    final debugLabel = node.debugLabel ?? '(无debugLabel)';
    final widgetName = node.context?.widget.runtimeType.toString() ?? 'UnmountedWidget';
    final rect = _extractRect(node);
    final rectInfo = rect != null
        ? ' | 坐标: [x=${rect.left.toInt()}, y=${rect.top.toInt()}, w=${rect.width.toInt()}, h=${rect.height.toInt()}]'
        : '';
    final parentLabel = node.parent?.debugLabel;

    final parentInfo = parentLabel != null && parentLabel.isNotEmpty
        ? ' | 父级: [$parentLabel]'
        : '';

    _logger.info(
      '🎯 焦点移入 -> [$debugLabel] (Widget: $widgetName)$parentInfo$rectInfo',
    );
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
}

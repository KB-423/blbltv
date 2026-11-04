import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// TV 侧边栏导轨全局焦点服务
/// 管理左侧导航栏的选中项焦点，支持右侧内容区通过向左键或返回键随时平滑切回
class NavRailFocusService {
  FocusNode? _selectedNode;
  bool isNavRailFocused = false;

  /// 注册当前选中导航 Tab 的 FocusNode
  void registerSelectedNode(FocusNode? node) {
    _selectedNode = node;
  }

  /// 侧边栏任意项焦点变更通知
  void notifyFocusChange(bool focused) {
    isNavRailFocused = focused;
  }

  /// 将遥控器焦点平滑切换回左侧导轨当前选中的项
  bool focusSelected() {
    if (_selectedNode != null && _selectedNode!.canRequestFocus) {
      _selectedNode!.requestFocus();
      isNavRailFocused = true;
      return true;
    }
    return false;
  }
}

/// Riverpod Provider
final navRailFocusServiceProvider = Provider<NavRailFocusService>((ref) {
  return NavRailFocusService();
});


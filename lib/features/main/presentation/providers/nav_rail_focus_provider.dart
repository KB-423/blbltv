import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 顶部导航栏展示模式
enum TopBarDisplayMode {
  full, // 第一行（功能/账号）与第二行（分类）均完全可见
  compact, // 第二行隐藏，第一行精简为极简图标
  hidden, // 两行全部淡出隐藏（纯享播放模式）
}

/// 控制 TV 顶部导航栏展示模式的 Notifier
class TopBarDisplayModeNotifier extends Notifier<TopBarDisplayMode> {
  @override
  TopBarDisplayMode build() => TopBarDisplayMode.full;

  void showFull() => state = TopBarDisplayMode.full;
  void showCompact() => state = TopBarDisplayMode.compact;
  void hide() => state = TopBarDisplayMode.hidden;
  void setMode(TopBarDisplayMode mode) => state = mode;
}

final topBarDisplayModeProvider =
    NotifierProvider<TopBarDisplayModeNotifier, TopBarDisplayMode>(
  TopBarDisplayModeNotifier.new,
);

/// TV 顶部导航栏全局焦点服务
/// 管理顶部分类栏与工具栏焦点，支持内容区通过向上键或返回键随时平滑切回
class NavRailFocusService {
  FocusNode? _selectedCategoryNode;
  FocusNode? _recommendTabNode;
  bool isNavRailFocused = false;

  /// 注册当前选中导航 Tab 的 FocusNode
  void registerSelectedNode(FocusNode? node) {
    _selectedCategoryNode = node;
  }

  /// 注册「推荐」Tab 专属 FocusNode（用于初始默认落焦）
  void registerRecommendNode(FocusNode? node) {
    _recommendTabNode = node;
  }

  /// 侧边栏/顶栏任意项焦点变更通知
  void notifyFocusChange(bool focused) {
    isNavRailFocused = focused;
  }

  /// 将遥控器焦点平滑切换回顶部导轨当前选中的项（优先当前选中，否则落焦推荐）
  bool focusSelected() {
    final target = _selectedCategoryNode ?? _recommendTabNode;
    if (target != null && target.canRequestFocus) {
      target.requestFocus();
      isNavRailFocused = true;
      return true;
    }
    return false;
  }

  /// 强制落焦「推荐」Tab
  bool focusRecommend() {
    if (_recommendTabNode != null && _recommendTabNode!.canRequestFocus) {
      _recommendTabNode!.requestFocus();
      isNavRailFocused = true;
      return true;
    }
    return focusSelected();
  }
}

/// Riverpod Provider
final navRailFocusServiceProvider = Provider<NavRailFocusService>((ref) {
  return NavRailFocusService();
});

/// 兼容老代码的导轨显隐 Provider (映射至 topBarDisplayModeProvider)
class NavRailVisibilityNotifier extends Notifier<bool> {
  @override
  bool build() {
    final mode = ref.watch(topBarDisplayModeProvider);
    return mode != TopBarDisplayMode.hidden;
  }

  void show() =>
      ref.read(topBarDisplayModeProvider.notifier).showFull();
  void hide() => ref.read(topBarDisplayModeProvider.notifier).hide();
  void setVisible(bool visible) {
    if (visible) {
      show();
    } else {
      hide();
    }
  }
}

final navRailVisibilityProvider =
    NotifierProvider<NavRailVisibilityNotifier, bool>(
  NavRailVisibilityNotifier.new,
);

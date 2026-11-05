/// 全局返回导航防抖锁
/// 彻底防止 Android 系统级物理返回键、遥控器 Back 键与手势连跳两次
class BackNavigationDebounce {
  static DateTime? _lastHandledTime;

  /// 检查当前返回操作是否应该被放行
  /// 默认 400 毫秒内重复触发的返回事件一律过滤丢弃
  static bool shouldHandle({int debounceMilliseconds = 400}) {
    final now = DateTime.now();
    if (_lastHandledTime != null &&
        now.difference(_lastHandledTime!).inMilliseconds < debounceMilliseconds) {
      return false;
    }
    _lastHandledTime = now;
    return true;
  }

  /// 重置防抖锁 (用于强制允许下次返回)
  static void reset() {
    _lastHandledTime = null;
  }
}

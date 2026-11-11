import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Main Shell 背景类型
enum ShellBackgroundType {
  player, // 全屏视频播放器 (挂载全局单例播放内核视窗)
  image, // Tab 指定底图 (如当前视频高斯模糊大图、番剧海报等)
  defaultDark, // 系统默认 TV 暗色渐变质感底图
}

/// Main Shell 纯数据背景状态
class ShellBackgroundState {
  final ShellBackgroundType type;
  final String? imageUrl;

  const ShellBackgroundState.player()
      : type = ShellBackgroundType.player,
        imageUrl = null;

  const ShellBackgroundState.image(this.imageUrl)
      : type = ShellBackgroundType.image;

  const ShellBackgroundState.defaultDark()
      : type = ShellBackgroundType.defaultDark,
        imageUrl = null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShellBackgroundState &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          imageUrl == other.imageUrl;

  @override
  int get hashCode => type.hashCode ^ imageUrl.hashCode;
}

final shellBackgroundProvider =
    NotifierProvider<ShellBackgroundNotifier, ShellBackgroundState>(
  ShellBackgroundNotifier.new,
);

class ShellBackgroundNotifier extends Notifier<ShellBackgroundState> {
  @override
  ShellBackgroundState build() => const ShellBackgroundState.player();

  /// 展示全屏视频播放器背景
  void showPlayer() {
    state = const ShellBackgroundState.player();
  }

  /// 展示由 Tab 页面指定的底图
  void showImage(String url) {
    state = ShellBackgroundState.image(url);
  }

  /// 展示默认 TV 暗色质感底图
  void showDefaultDark() {
    state = const ShellBackgroundState.defaultDark();
  }
}

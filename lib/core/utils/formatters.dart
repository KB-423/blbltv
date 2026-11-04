/// 格式化工具集
class Formatters {
  Formatters._();

  /// 格式化播放数与弹幕数：如 1.2万、345.6万、1.2亿
  static String formatCount(int? count) {
    if (count == null || count < 0) return '0';
    if (count < 10000) {
      return count.toString();
    } else if (count < 100000000) {
      final double val = count / 10000.0;
      return '${val.toStringAsFixed(1)}万';
    } else {
      final double val = count / 100000000.0;
      return '${val.toStringAsFixed(1)}亿';
    }
  }

  /// 格式化时长秒数为 00:00 或 00:00:00
  static String formatDuration(int? totalSeconds) {
    if (totalSeconds == null || totalSeconds <= 0) return '00:00';
    final int hours = totalSeconds ~/ 3600;
    final int minutes = (totalSeconds % 3600) ~/ 60;
    final int seconds = totalSeconds % 60;

    final String minStr = minutes.toString().padLeft(2, '0');
    final String secStr = seconds.toString().padLeft(2, '0');

    if (hours > 0) {
      final String hourStr = hours.toString().padLeft(2, '0');
      return '$hourStr:$minStr:$secStr';
    }
    return '$minStr:$secStr';
  }

  /// 格式化历史播放进度
  static String formatProgress(int progress, int duration) {
    if (progress == -1) return '已看完';
    if (progress <= 0) return '未播放';
    if (duration > 0) {
      final percent = ((progress / duration) * 100).clamp(0, 100).toInt();
      return '看到 $percent%';
    }
    return '看到 ${formatDuration(progress)}';
  }
}


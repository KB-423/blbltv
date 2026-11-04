import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/play_url_model.freezed.dart';
part 'generated/play_url_model.g.dart';

/// 视频清晰度条目
@freezed
abstract class VideoQualityItem with _$VideoQualityItem {
  const factory VideoQualityItem({
    required int qn,
    required String desc,
  }) = _VideoQualityItem;

  factory VideoQualityItem.fromJson(Map<String, dynamic> json) =>
      _$VideoQualityItemFromJson(json);
}

/// 播放流核心信息模型
@freezed
abstract class VideoPlayInfo with _$VideoPlayInfo {
  const factory VideoPlayInfo({
    @Default('') String bvid,
    @Default(0) int cid,
    @Default('') String title,
    @Default('') String playUrl,
    @Default('') String audioUrl,
    @Default(80) int currentQn,
    @Default(<VideoQualityItem>[]) List<VideoQualityItem> qualities,
    @Default(0) int durationSeconds,
  }) = _VideoPlayInfo;

  factory VideoPlayInfo.fromJson(Map<String, dynamic> json) =>
      _$VideoPlayInfoFromJson(json);
}

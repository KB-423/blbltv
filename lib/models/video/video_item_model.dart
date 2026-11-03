import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/video_item_model.freezed.dart';
part 'generated/video_item_model.g.dart';

/// 视频创作者/UP主信息
@freezed
abstract class VideoOwner with _$VideoOwner {
  const factory VideoOwner({
    @Default(0) int mid,
    @Default('') String name,
    @Default('') String face,
  }) = _VideoOwner;

  factory VideoOwner.fromJson(Map<String, dynamic> json) =>
      _$VideoOwnerFromJson(json);
}

/// 视频统计数据（播放数、弹幕数等）
@freezed
abstract class VideoStat with _$VideoStat {
  const factory VideoStat({
    @Default(0) int view,
    @Default(0) int danmaku,
    @Default(0) int reply,
    @Default(0) int favorite,
    @Default(0) int coin,
    @Default(0) int share,
    @Default(0) int like,
  }) = _VideoStat;

  factory VideoStat.fromJson(Map<String, dynamic> json) =>
      _$VideoStatFromJson(json);
}

/// TV 视频卡片核心数据模型
@freezed
abstract class VideoItemModel with _$VideoItemModel {
  const factory VideoItemModel({
    @Default(0) int id,
    @Default('') String bvid,
    @Default(0) int cid,
    @Default('') String title,
    @Default('') String pic,
    @Default(0) int duration,
    @Default(0) int pubdate,
    @Default('') String uri,
    VideoOwner? owner,
    VideoStat? stat,
    @JsonKey(name: 'rcmd_reason') String? rcmdReason,
  }) = _VideoItemModel;

  factory VideoItemModel.fromJson(Map<String, dynamic> json) =>
      _$VideoItemModelFromJson(json);
}


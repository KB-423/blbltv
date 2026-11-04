import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/user_favorite_model.freezed.dart';
part 'generated/user_favorite_model.g.dart';

/// 用户收藏夹模型
@freezed
abstract class UserFavFolder with _$UserFavFolder {
  const factory UserFavFolder({
    @Default(0) int id,
    @Default(0) int fid,
    @Default(0) int mid,
    @Default('') String title,
    @Default('') String cover,
    @Default(0) @JsonKey(name: 'media_count') int mediaCount,
  }) = _UserFavFolder;

  factory UserFavFolder.fromJson(Map<String, dynamic> json) =>
      _$UserFavFolderFromJson(json);
}

/// 收藏夹内视频模型
@freezed
abstract class UserFavItem with _$UserFavItem {
  const factory UserFavItem({
    @Default(0) int id,
    @Default('') String title,
    @Default('') String cover,
    @Default('') String bvid,
    @Default('') @JsonKey(name: 'upper_name') String upperName,
    @Default(0) int duration,
    @Default(0) @JsonKey(name: 'fav_time') int favTime,
    @Default(0) @JsonKey(name: 'play_count') int playCount,
    @Default(0) @JsonKey(name: 'danmaku_count') int danmakuCount,
  }) = _UserFavItem;

  factory UserFavItem.fromJson(Map<String, dynamic> json) {
    final upper = json['upper'] as Map<String, dynamic>?;
    final cntInfo = json['cnt_info'] as Map<String, dynamic>?;

    return UserFavItem(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      cover: json['pic'] as String? ?? (json['cover'] as String? ?? ''),
      bvid: json['bvid'] as String? ?? (json['bv_id'] as String? ?? ''),
      upperName: upper?['name'] as String? ?? '',
      duration: json['duration'] as int? ?? 0,
      favTime: json['fav_time'] as int? ?? 0,
      playCount: cntInfo?['play'] as int? ?? 0,
      danmakuCount: cntInfo?['danmaku'] as int? ?? 0,
    );
  }
}

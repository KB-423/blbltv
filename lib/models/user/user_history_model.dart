import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/user_history_model.freezed.dart';

/// 用户历史记录项模型
@freezed
abstract class UserHistoryItem with _$UserHistoryItem {
  const factory UserHistoryItem({
    @Default('') String title,
    @Default('') String cover,
    @Default('') String bvid,
    @Default(0) int cid,
    @Default(0) int progress, // 播放进度(秒)，-1 为已看完
    @Default(0) int duration, // 总时长(秒)
    @Default('') @JsonKey(name: 'author_name') String authorName,
    @Default('') @JsonKey(name: 'author_face') String authorFace,
    @Default(0) @JsonKey(name: 'author_mid') int authorMid,
    @Default(0) @JsonKey(name: 'view_at') int viewAt,
    @Default('') @JsonKey(name: 'show_title') String showTitle,
    @Default('') String badge,
  }) = _UserHistoryItem;

  factory UserHistoryItem.fromJson(Map<String, dynamic> json) {
    final history = json['history'] as Map<String, dynamic>?;
    final bvid =
        (history?['bvid'] as String?) ?? (json['bvid'] as String? ?? '');
    final cid = (history?['cid'] as int?) ?? (json['cid'] as int? ?? 0);
    final cover =
        (json['cover'] as String?) ?? (json['pic'] as String? ?? '');

    return UserHistoryItem(
      title: json['title'] as String? ?? '',
      cover: cover,
      bvid: bvid,
      cid: cid,
      progress: json['progress'] as int? ?? 0,
      duration: json['duration'] as int? ?? 0,
      authorName: json['author_name'] as String? ?? '',
      authorFace: json['author_face'] as String? ?? '',
      authorMid: json['author_mid'] as int? ?? 0,
      viewAt: json['view_at'] as int? ?? 0,
      showTitle: json['show_title'] as String? ?? '',
      badge: json['badge'] as String? ?? '',
    );
  }
}

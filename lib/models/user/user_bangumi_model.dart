import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/user_bangumi_model.freezed.dart';

/// 用户追番/追剧模型
@freezed
abstract class UserBangumiItem with _$UserBangumiItem {
  const factory UserBangumiItem({
    @Default(0) @JsonKey(name: 'season_id') int seasonId,
    @Default('') String title,
    @Default('') String cover,
    @Default('') @JsonKey(name: 'total_count') String totalCount,
    @Default('') @JsonKey(name: 'new_ep_title') String newEpTitle,
    @Default('') @JsonKey(name: 'progress') String progress,
    @Default('') String badge,
    @Default('') String evaluate,
  }) = _UserBangumiItem;

  factory UserBangumiItem.fromJson(Map<String, dynamic> json) {
    final newEp = json['new_ep'] as Map<String, dynamic>?;
    return UserBangumiItem(
      seasonId: json['season_id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      cover: json['cover'] as String? ?? '',
      totalCount: json['total_count']?.toString() ?? '',
      newEpTitle: newEp?['index_show']?.toString() ?? '',
      progress: json['progress']?.toString() ?? '',
      badge: json['badge'] as String? ?? '',
      evaluate: json['evaluate'] as String? ?? '',
    );
  }
}

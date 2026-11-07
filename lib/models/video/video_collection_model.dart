import 'package:freezed_annotation/freezed_annotation.dart';
import 'video_item_model.dart';

part 'generated/video_collection_model.freezed.dart';

/// 视频合集 / 系列模型 (UGC Season / Series)
@freezed
abstract class VideoCollectionModel with _$VideoCollectionModel {
  const factory VideoCollectionModel({
    @Default(0) int id,
    @Default('') String title,
    @Default('') String cover,
    @Default('') String intro,
    @Default(0) int epCount,
    @Default([]) List<VideoItemModel> items,
  }) = _VideoCollectionModel;

  factory VideoCollectionModel.fromJson(Map<String, dynamic> json) {
    final list = json['items'] ?? json['archives'] ?? json['episodes'];
    return VideoCollectionModel(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      title: json['title']?.toString() ?? '',
      cover: json['cover']?.toString() ?? '',
      intro: json['intro']?.toString() ?? '',
      epCount: json['ep_count'] is int
          ? json['ep_count'] as int
          : (list is List ? list.length : 0),
      items: list is List
          ? list
              .whereType<Map<String, dynamic>>()
              .map(VideoItemModel.fromJson)
              .toList()
          : const [],
    );
  }
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../bangumi_episode_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BangumiEpisodeModel _$BangumiEpisodeModelFromJson(Map<String, dynamic> json) =>
    _BangumiEpisodeModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      aid: (json['aid'] as num?)?.toInt() ?? 0,
      bvid: json['bvid'] as String? ?? '',
      cid: (json['cid'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? '',
      longTitle: json['long_title'] as String? ?? '',
      badge: json['badge'] as String? ?? '',
      duration: (json['duration'] as num?)?.toInt() ?? 0,
      cover: json['cover'] as String? ?? '',
      status: (json['status'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$BangumiEpisodeModelToJson(
  _BangumiEpisodeModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'aid': instance.aid,
  'bvid': instance.bvid,
  'cid': instance.cid,
  'title': instance.title,
  'long_title': instance.longTitle,
  'badge': instance.badge,
  'duration': instance.duration,
  'cover': instance.cover,
  'status': instance.status,
};

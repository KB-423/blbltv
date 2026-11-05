// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../bangumi_season_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BangumiSeasonModel _$BangumiSeasonModelFromJson(Map<String, dynamic> json) =>
    _BangumiSeasonModel(
      seasonId: (json['season_id'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? '',
      cover: json['cover'] as String? ?? '',
      badge: json['badge'] as String? ?? '',
      score: json['score'] as String? ?? '',
      order: json['order'] as String? ?? '',
      indexShow: json['index_show'] as String? ?? '',
      desc: json['desc'] as String? ?? '',
    );

Map<String, dynamic> _$BangumiSeasonModelToJson(_BangumiSeasonModel instance) =>
    <String, dynamic>{
      'season_id': instance.seasonId,
      'title': instance.title,
      'cover': instance.cover,
      'badge': instance.badge,
      'score': instance.score,
      'order': instance.order,
      'index_show': instance.indexShow,
      'desc': instance.desc,
    };

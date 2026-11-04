// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../user_favorite_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserFavFolder _$UserFavFolderFromJson(Map<String, dynamic> json) =>
    _UserFavFolder(
      id: (json['id'] as num?)?.toInt() ?? 0,
      fid: (json['fid'] as num?)?.toInt() ?? 0,
      mid: (json['mid'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? '',
      cover: json['cover'] as String? ?? '',
      mediaCount: (json['media_count'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$UserFavFolderToJson(_UserFavFolder instance) =>
    <String, dynamic>{
      'id': instance.id,
      'fid': instance.fid,
      'mid': instance.mid,
      'title': instance.title,
      'cover': instance.cover,
      'media_count': instance.mediaCount,
    };

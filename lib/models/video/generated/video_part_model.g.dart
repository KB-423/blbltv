// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../video_part_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_VideoPartItem _$VideoPartItemFromJson(Map<String, dynamic> json) =>
    _VideoPartItem(
      cid: (json['cid'] as num).toInt(),
      page: (json['page'] as num).toInt(),
      from: json['from'] as String? ?? '',
      part: json['part'] as String,
      duration: (json['duration'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$VideoPartItemToJson(_VideoPartItem instance) =>
    <String, dynamic>{
      'cid': instance.cid,
      'page': instance.page,
      'from': instance.from,
      'part': instance.part,
      'duration': instance.duration,
    };

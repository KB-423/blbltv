// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../play_url_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_VideoQualityItem _$VideoQualityItemFromJson(Map<String, dynamic> json) =>
    _VideoQualityItem(
      qn: (json['qn'] as num).toInt(),
      desc: json['desc'] as String,
      isHardwareSupported: json['isHardwareSupported'] as bool? ?? true,
    );

Map<String, dynamic> _$VideoQualityItemToJson(_VideoQualityItem instance) =>
    <String, dynamic>{
      'qn': instance.qn,
      'desc': instance.desc,
      'isHardwareSupported': instance.isHardwareSupported,
    };

_VideoPlayInfo _$VideoPlayInfoFromJson(Map<String, dynamic> json) =>
    _VideoPlayInfo(
      bvid: json['bvid'] as String? ?? '',
      cid: (json['cid'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? '',
      playUrl: json['playUrl'] as String? ?? '',
      audioUrl: json['audioUrl'] as String? ?? '',
      currentQn: (json['currentQn'] as num?)?.toInt() ?? 80,
      qualities:
          (json['qualities'] as List<dynamic>?)
              ?.map((e) => VideoQualityItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <VideoQualityItem>[],
      durationSeconds: (json['durationSeconds'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$VideoPlayInfoToJson(_VideoPlayInfo instance) =>
    <String, dynamic>{
      'bvid': instance.bvid,
      'cid': instance.cid,
      'title': instance.title,
      'playUrl': instance.playUrl,
      'audioUrl': instance.audioUrl,
      'currentQn': instance.currentQn,
      'qualities': instance.qualities,
      'durationSeconds': instance.durationSeconds,
    };

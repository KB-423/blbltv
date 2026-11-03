// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../video_item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_VideoOwner _$VideoOwnerFromJson(Map<String, dynamic> json) => _VideoOwner(
  mid: (json['mid'] as num?)?.toInt() ?? 0,
  name: json['name'] as String? ?? '',
  face: json['face'] as String? ?? '',
);

Map<String, dynamic> _$VideoOwnerToJson(_VideoOwner instance) =>
    <String, dynamic>{
      'mid': instance.mid,
      'name': instance.name,
      'face': instance.face,
    };

_VideoStat _$VideoStatFromJson(Map<String, dynamic> json) => _VideoStat(
  view: (json['view'] as num?)?.toInt() ?? 0,
  danmaku: (json['danmaku'] as num?)?.toInt() ?? 0,
  reply: (json['reply'] as num?)?.toInt() ?? 0,
  favorite: (json['favorite'] as num?)?.toInt() ?? 0,
  coin: (json['coin'] as num?)?.toInt() ?? 0,
  share: (json['share'] as num?)?.toInt() ?? 0,
  like: (json['like'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$VideoStatToJson(_VideoStat instance) =>
    <String, dynamic>{
      'view': instance.view,
      'danmaku': instance.danmaku,
      'reply': instance.reply,
      'favorite': instance.favorite,
      'coin': instance.coin,
      'share': instance.share,
      'like': instance.like,
    };

_VideoItemModel _$VideoItemModelFromJson(Map<String, dynamic> json) =>
    _VideoItemModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      bvid: json['bvid'] as String? ?? '',
      cid: (json['cid'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? '',
      pic: json['pic'] as String? ?? '',
      duration: (json['duration'] as num?)?.toInt() ?? 0,
      pubdate: (json['pubdate'] as num?)?.toInt() ?? 0,
      uri: json['uri'] as String? ?? '',
      owner: json['owner'] == null
          ? null
          : VideoOwner.fromJson(json['owner'] as Map<String, dynamic>),
      stat: json['stat'] == null
          ? null
          : VideoStat.fromJson(json['stat'] as Map<String, dynamic>),
      rcmdReason: json['rcmd_reason'] as String?,
    );

Map<String, dynamic> _$VideoItemModelToJson(_VideoItemModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'bvid': instance.bvid,
      'cid': instance.cid,
      'title': instance.title,
      'pic': instance.pic,
      'duration': instance.duration,
      'pubdate': instance.pubdate,
      'uri': instance.uri,
      'owner': instance.owner,
      'stat': instance.stat,
      'rcmd_reason': instance.rcmdReason,
    };

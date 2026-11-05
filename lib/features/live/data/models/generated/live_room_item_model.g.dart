// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../live_room_item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LiveRoomItemModel _$LiveRoomItemModelFromJson(Map<String, dynamic> json) =>
    _LiveRoomItemModel(
      roomId: (json['roomid'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? '',
      uname: json['uname'] as String? ?? '',
      cover: json['cover'] as String? ?? '',
      userCover: json['user_cover'] as String? ?? '',
      face: json['face'] as String? ?? '',
      online: (json['online'] as num?)?.toInt() ?? 0,
      areaName: json['area_name'] as String? ?? '',
      areaV2Name: json['area_v2_name'] as String? ?? '',
    );

Map<String, dynamic> _$LiveRoomItemModelToJson(_LiveRoomItemModel instance) =>
    <String, dynamic>{
      'roomid': instance.roomId,
      'title': instance.title,
      'uname': instance.uname,
      'cover': instance.cover,
      'user_cover': instance.userCover,
      'face': instance.face,
      'online': instance.online,
      'area_name': instance.areaName,
      'area_v2_name': instance.areaV2Name,
    };

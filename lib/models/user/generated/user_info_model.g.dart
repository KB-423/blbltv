// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../user_info_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserInfoModel _$UserInfoModelFromJson(Map<String, dynamic> json) =>
    _UserInfoModel(
      mid: (json['mid'] as num?)?.toInt() ?? 0,
      uname: json['uname'] as String? ?? '',
      face: json['face'] as String? ?? '',
      isLogin: json['isLogin'] as bool? ?? false,
      currentLevel: (json['level_info_current_level'] as num?)?.toInt() ?? 0,
      money: (json['money'] as num?)?.toDouble() ?? 0,
      vipType: (json['vipType'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$UserInfoModelToJson(_UserInfoModel instance) =>
    <String, dynamic>{
      'mid': instance.mid,
      'uname': instance.uname,
      'face': instance.face,
      'isLogin': instance.isLogin,
      'level_info_current_level': instance.currentLevel,
      'money': instance.money,
      'vipType': instance.vipType,
    };

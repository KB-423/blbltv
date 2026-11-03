// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../api_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ApiResponseModel<T> _$ApiResponseModelFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) => _ApiResponseModel<T>(
  code: (json['code'] as num?)?.toInt() ?? 0,
  message: json['message'] as String? ?? '',
  ttl: (json['ttl'] as num?)?.toInt() ?? 0,
  data: _$nullableGenericFromJson(json['data'], fromJsonT),
);

Map<String, dynamic> _$ApiResponseModelToJson<T>(
  _ApiResponseModel<T> instance,
  Object? Function(T value) toJsonT,
) => <String, dynamic>{
  'code': instance.code,
  'message': instance.message,
  'ttl': instance.ttl,
  'data': _$nullableGenericToJson(instance.data, toJsonT),
};

T? _$nullableGenericFromJson<T>(
  Object? input,
  T Function(Object? json) fromJson,
) => input == null ? null : fromJson(input);

Object? _$nullableGenericToJson<T>(
  T? input,
  Object? Function(T value) toJson,
) => input == null ? null : toJson(input);

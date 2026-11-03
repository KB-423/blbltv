import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/api_response_model.freezed.dart';
part 'generated/api_response_model.g.dart';

/// Bilibili 统一响应包装模型
@Freezed(genericArgumentFactories: true)
abstract class ApiResponseModel<T> with _$ApiResponseModel<T> {
  const factory ApiResponseModel({
    @Default(0) int code,
    @Default('') String message,
    @Default(0) int ttl,
    T? data,
  }) = _ApiResponseModel<T>;

  factory ApiResponseModel.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$ApiResponseModelFromJson(json, fromJsonT);
}


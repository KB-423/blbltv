import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/user_info_model.freezed.dart';
part 'generated/user_info_model.g.dart';

/// 用户个人信息模型
@freezed
abstract class UserInfoModel with _$UserInfoModel {
  const factory UserInfoModel({
    @Default(0) int mid,
    @Default('') String uname,
    @Default('') String face,
    @Default(false) @JsonKey(name: 'isLogin') bool isLogin,
    @Default(0) @JsonKey(name: 'level_info_current_level') int currentLevel,
    @Default(0) double money,
    @Default(0) @JsonKey(name: 'vipType') int vipType,
  }) = _UserInfoModel;

  factory UserInfoModel.fromJson(Map<String, dynamic> json) =>
      _$UserInfoModelFromJson(json);
}


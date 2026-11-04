import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/user_info_model.freezed.dart';

/// 用户个人信息模型
@freezed
abstract class UserInfoModel with _$UserInfoModel {
  const factory UserInfoModel({
    @Default(0) int mid,
    @Default('') String uname,
    @Default('') String face,
    @Default(false) @JsonKey(name: 'isLogin') bool isLogin,
    @Default(0) @JsonKey(name: 'current_level') int currentLevel,
    @Default(0.0) double money,
    @Default(0) @JsonKey(name: 'vipType') int vipType,
    @Default(0) @JsonKey(name: 'vipStatus') int vipStatus,
    @Default('') @JsonKey(name: 'vip_label_text') String vipLabelText,
  }) = _UserInfoModel;

  factory UserInfoModel.fromJson(Map<String, dynamic> json) {
    final levelInfo = json['level_info'] as Map<String, dynamic>?;
    final vip = json['vip'] as Map<String, dynamic>?;
    final vipLabel = json['vip_label'] as Map<String, dynamic>?;

    return UserInfoModel(
      mid: json['mid'] as int? ?? 0,
      uname: json['uname'] as String? ?? '',
      face: json['face'] as String? ?? '',
      isLogin: json['isLogin'] as bool? ?? false,
      currentLevel: levelInfo?['current_level'] as int? ??
          (json['current_level'] as int? ?? 0),
      money: (json['money'] as num?)?.toDouble() ?? 0.0,
      vipType: json['vipType'] as int? ?? (vip?['type'] as int? ?? 0),
      vipStatus: json['vipStatus'] as int? ?? (vip?['status'] as int? ?? 0),
      vipLabelText: vipLabel?['text'] as String? ?? '',
    );
  }
}

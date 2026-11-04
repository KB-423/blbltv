import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../models/user/user_info_model.dart';

part 'generated/auth_state.freezed.dart';

@freezed
abstract class AuthState with _$AuthState {
  const factory AuthState({
    @Default(true) bool isCheckingLogin,
    @Default(false) bool isLoggedIn,
    UserInfoModel? user,
    @Default('') String qrUrl,
    @Default('') String qrKey,
    @Default('请使用 哔哩哔哩手机客户端 扫码登录') String qrMessage,
    @Default(false) bool isPolling,
    @Default(false) bool isQrExpired,
    String? error,
  }) = _AuthState;
}

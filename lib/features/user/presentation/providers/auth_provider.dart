import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../home/presentation/providers/home_provider.dart';
import '../../data/repositories/user_repository.dart';
import 'auth_state.dart';

/// 认证与会话状态管理
class AuthNotifier extends Notifier<AuthState> {
  Timer? _pollTimer;

  @override
  AuthState build() {
    ref.onDispose(() {
      _pollTimer?.cancel();
    });

    // 应用启动时仅静默核验已有会话 Cookie，严禁在未进入登录页前预拉取二维码
    Future.microtask(checkLoginStatus);
    return const AuthState();
  }

  UserRepository get _repository => ref.read(userRepositoryProvider);

  /// 检查本地会话有效性
  Future<void> checkLoginStatus() async {
    state = state.copyWith(isCheckingLogin: true, error: null);

    try {
      final user = await _repository.fetchUserInfo();
      if (user != null && user.isLogin) {
        state = state.copyWith(
          isCheckingLogin: false,
          isLoggedIn: true,
          user: user,
          error: null,
        );
        return;
      }
    } catch (e) {
      debugPrint('[AuthNotifier] 检查登录状态异常: $e');
    }

    state = state.copyWith(
      isCheckingLogin: false,
      isLoggedIn: false,
      user: null,
    );
  }

  /// 停止轮询（离开登录页面时释放资源）
  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
    if (state.isPolling) {
      state = state.copyWith(isPolling: false);
    }
  }

  /// 发起 TV 扫码登录流程 (仅在用户主动进入登录页面时按需调用)
  Future<void> startQrLogin() async {
    _pollTimer?.cancel();
    state = state.copyWith(
      qrMessage: '正在获取登录二维码...',
      isQrExpired: false,
      isPolling: false,
      error: null,
    );

    try {
      final qrInfo = await _repository.getQrCode();
      state = state.copyWith(
        qrUrl: qrInfo.url,
        qrKey: qrInfo.qrcodeKey,
        qrMessage: '请使用 哔哩哔哩手机客户端 扫码登录',
        isPolling: true,
        isQrExpired: false,
        error: null,
      );

      _beginPolling(qrInfo.qrcodeKey);
    } catch (e) {
      debugPrint('[AuthNotifier] 获取二维码失败: $e');
      state = state.copyWith(
        qrMessage: '获取二维码失败，请按确定重试',
        error: '获取二维码失败: $e',
        isPolling: false,
      );
    }
  }

  /// 启动轮询检查移动端扫码状态
  void _beginPolling(String qrcodeKey) {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      try {
        final pollRes = await _repository.pollQrCode(qrcodeKey);

        switch (pollRes.code) {
          case 0:
            // 登录成功
            timer.cancel();
            state = state.copyWith(
              qrMessage: '登录成功，正在同步账号...',
              isPolling: false,
              isQrExpired: false,
            );

            // 获取最新用户信息并持久化
            final user = await _repository.fetchUserInfo();
            state = state.copyWith(
              isLoggedIn: true,
              user: user,
              error: null,
            );

            // 登录成功后，立即触发首页个性化推荐流刷新
            ref.read(homeFeedProvider.notifier).refresh();
            break;

          case 86090:
            // 已扫码未确认
            state = state.copyWith(
              qrMessage: '手机已扫描，请在手机上确认登录',
            );
            break;

          case 86038:
            // 二维码已失效
            timer.cancel();
            state = state.copyWith(
              qrMessage: '二维码已过期，请按确定键刷新',
              isQrExpired: true,
              isPolling: false,
            );
            break;

          case 86101:
          default:
            // 等待扫码中
            break;
        }
      } catch (e) {
        debugPrint('[AuthNotifier] 轮询异常: $e');
      }
    });
  }

  /// 退出登录
  Future<void> logout() async {
    stopPolling();
    try {
      await _repository.logout();
    } catch (e) {
      debugPrint('[AuthNotifier] 退出登录异常: $e');
    }

    state = const AuthState(
      isCheckingLogin: false,
      isLoggedIn: false,
      user: null,
      qrUrl: '',
      qrKey: '',
      qrMessage: '',
      isPolling: false,
      isQrExpired: false,
    );

    // 退出后刷新首页回退至游客热门流
    ref.read(homeFeedProvider.notifier).refresh();
  }
}

/// Riverpod Provider
final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

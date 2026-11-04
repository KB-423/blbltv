import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dpad/dpad.dart';
import 'package:bili_tv/models/user/user_info_model.dart';
import 'package:bili_tv/features/user/presentation/providers/auth_provider.dart';
import 'package:bili_tv/features/user/presentation/providers/auth_state.dart';
import 'package:bili_tv/features/user/presentation/screens/tv_user_screen.dart';
import 'package:media_kit/media_kit.dart';

class _FakeAuthNotifier extends AuthNotifier {
  final AuthState initialState;

  _FakeAuthNotifier(this.initialState);

  @override
  AuthState build() {
    return initialState;
  }
}

void main() {
  MediaKit.ensureInitialized();

  group('TvUserScreen Tests', () {
    testWidgets('Displays QR Login panel when not logged in',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      const unloggedState = AuthState(
        isCheckingLogin: false,
        isLoggedIn: false,
        qrUrl: 'https://passport.bilibili.com/test_qr',
        qrMessage: '请使用 哔哩哔哩手机客户端 扫码登录',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith(() => _FakeAuthNotifier(unloggedState)),
          ],
          child: MaterialApp(
            builder: Dpad.wrap(),
            home: const TvUserScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('个人中心'), findsOneWidget);
      expect(find.text('请使用 哔哩哔哩手机客户端 扫码登录'), findsOneWidget);
      expect(find.text('刷新二维码'), findsOneWidget);
      expect(find.text('登录畅享完整大屏体验'), findsOneWidget);
    });

    testWidgets('Displays User Profile and Tabs when logged in',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      const loggedState = AuthState(
        isCheckingLogin: false,
        isLoggedIn: true,
        user: UserInfoModel(
          mid: 123456,
          uname: '大屏极客UP',
          face: '',
          isLogin: true,
          currentLevel: 6,
          money: 88.0,
          vipStatus: 1,
          vipLabelText: '年度大会员',
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith(() => _FakeAuthNotifier(loggedState)),
          ],
          child: MaterialApp(
            builder: Dpad.wrap(),
            home: const TvUserScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // 验证用户信息栏
      expect(find.text('大屏极客UP'), findsAtLeastNWidgets(1));
      expect(find.text('LV6'), findsOneWidget);
      expect(find.text('年度大会员'), findsOneWidget);
      expect(find.text('UID: 123456'), findsOneWidget);
      expect(find.text('退出登录'), findsOneWidget);

      // 验证三大内容选项卡
      expect(find.text('观看历史'), findsOneWidget);
      expect(find.text('我的收藏'), findsOneWidget);
      expect(find.text('我的追番'), findsOneWidget);
    });
  });
}

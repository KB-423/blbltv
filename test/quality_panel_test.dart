import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dpad/dpad.dart';
import 'package:bili_tv/core/services/display_capability_service.dart';
import 'package:bili_tv/core/storage/storage_service.dart';
import 'package:bili_tv/models/user/user_info_model.dart';
import 'package:bili_tv/models/video/play_url_model.dart';
import 'package:bili_tv/features/user/presentation/providers/auth_provider.dart';
import 'package:bili_tv/features/user/presentation/providers/auth_state.dart';
import 'package:bili_tv/features/player/presentation/widgets/tv_quality_panel.dart';

class _FakeAuthNotifier extends AuthNotifier {
  final AuthState initialState;
  _FakeAuthNotifier(this.initialState);

  @override
  AuthState build() => initialState;
}

void main() {
  const qualities = [
    VideoQualityItem(qn: 125, desc: 'HDR 真彩'),
    VideoQualityItem(qn: 120, desc: '4K 超清'),
    VideoQualityItem(qn: 80, desc: '1080P 高清'),
    VideoQualityItem(qn: 64, desc: '720P 高清'),
  ];

  testWidgets('TvQualityPanel handles unlogged status correctly',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final storage = StorageService(prefs);

    int selectedQn = 0;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          storageServiceProvider.overrideWithValue(storage),
          authProvider.overrideWith(
            () => _FakeAuthNotifier(
              const AuthState(isLoggedIn: false, user: null),
            ),
          ),
        ],
        child: MaterialApp(
          builder: Dpad.wrap(),
          home: Scaffold(
            body: TvQualityPanel(
              qualities: qualities,
              currentQn: 64,
              onSelectQuality: (qn) => selectedQn = qn,
              onClose: () {},
            ),
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // 验证未登录下 1080P 和 4K 均具有 [需登录] 标识，HDR 具有 [设备不支持] 标识
    expect(find.text('需登录'), findsNWidgets(2));
    expect(find.text('设备不支持'), findsOneWidget);

    // 点击 1080P 需登录项，不触发切换，弹出提示
    await tester.tap(find.text('1080P 高清'));
    await tester.pump();
    expect(selectedQn, 0);
    expect(find.textContaining('1080P 及以上画质需登录后使用'), findsOneWidget);

    // 点击 HDR 设备不支持项，不触发切换，弹出设备不支持提示
    await tester.tap(find.text('HDR 真彩'));
    await tester.pump();
    expect(selectedQn, 0);
    expect(find.textContaining('当前设备或显示屏不支持'), findsOneWidget);

    // 点击可用画质 720P，正常切换
    await tester.tap(find.text('720P 高清'));
    await tester.pump();
    expect(selectedQn, 64);
  });

  testWidgets('TvQualityPanel handles logged-in non-VIP and VIP correctly',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final storage = StorageService(prefs);

    int selectedQn = 0;

    // 普通登录用户 (vipStatus = 0)
    final normalUser = const UserInfoModel(
      mid: 10001,
      uname: '普通用户',
      isLogin: true,
      vipStatus: 0,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          storageServiceProvider.overrideWithValue(storage),
          authProvider.overrideWith(
            () => _FakeAuthNotifier(
              AuthState(isLoggedIn: true, user: normalUser),
            ),
          ),
        ],
        child: MaterialApp(
          builder: Dpad.wrap(),
          home: Scaffold(
            body: TvQualityPanel(
              qualities: qualities,
              currentQn: 64,
              onSelectQuality: (qn) => selectedQn = qn,
              onClose: () {},
            ),
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // 普通用户 1080P 可选，4K 需 [大会员]
    expect(find.text('需登录'), findsNothing);
    expect(find.text('大会员'), findsOneWidget);

    // 点击 4K 超清弹出大会员专享提示
    await tester.tap(find.text('4K 超清'));
    await tester.pump();
    expect(selectedQn, 0);
    expect(find.textContaining('哔哩哔哩大会员专享'), findsOneWidget);

    // 点击 1080P 高清允许正常切换
    await tester.tap(find.text('1080P 高清'));
    await tester.pump();
    expect(selectedQn, 80);
  });

  testWidgets(
      'TvQualityPanel allows HDR selection when display supports HDR and user is VIP',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final storage = StorageService(prefs);

    int selectedQn = 0;

    final vipUser = const UserInfoModel(
      mid: 10002,
      uname: '大会员用户',
      isLogin: true,
      vipStatus: 1,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          storageServiceProvider.overrideWithValue(storage),
          displayCapabilityProvider.overrideWithValue(
            const DisplayHdrCapability(
              isHdrSupported: true,
              hasHdr10: true,
            ),
          ),
          authProvider.overrideWith(
            () => _FakeAuthNotifier(
              AuthState(isLoggedIn: true, user: vipUser),
            ),
          ),
        ],
        child: MaterialApp(
          builder: Dpad.wrap(),
          home: Scaffold(
            body: TvQualityPanel(
              qualities: qualities,
              currentQn: 64,
              onSelectQuality: (qn) => selectedQn = qn,
              onClose: () {},
            ),
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // 设备支持 HDR 且用户为 VIP，HDR 既无 [设备不支持] 也无 [大会员] 锁标
    expect(find.text('设备不支持'), findsNothing);
    expect(find.text('大会员'), findsNothing);

    // 点击 HDR 真彩，成功选中并返回 125
    await tester.tap(find.text('HDR 真彩'));
    await tester.pump();
    expect(selectedQn, 125);
  });

  testWidgets(
      'TvQualityPanel marks 8K (qn: 127) as unsupported by hardware and shows warning on tap',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final storage = StorageService(prefs);

    int selectedQn = 0;

    const testQualities = [
      VideoQualityItem(qn: 127, desc: '超高清 8K'),
      VideoQualityItem(qn: 120, desc: '4K 超清'),
      VideoQualityItem(qn: 80, desc: '1080P 高清'),
    ];

    final vipUser = const UserInfoModel(
      mid: 10002,
      uname: '大会员用户',
      isLogin: true,
      vipStatus: 1,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          storageServiceProvider.overrideWithValue(storage),
          authProvider.overrideWith(
            () => _FakeAuthNotifier(
              AuthState(isLoggedIn: true, user: vipUser),
            ),
          ),
        ],
        child: MaterialApp(
          builder: Dpad.wrap(),
          home: Scaffold(
            body: TvQualityPanel(
              qualities: testQualities,
              currentQn: 120,
              onSelectQuality: (qn) => selectedQn = qn,
              onClose: () {},
            ),
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // 8K 必须带有 [设备不支持] 标识
    expect(find.text('设备不支持'), findsOneWidget);

    // 点击 8K 不会触发切换，弹出电视芯片不支持 8K 硬解提示
    await tester.tap(find.text('超高清 8K'));
    await tester.pump();
    expect(selectedQn, 0);
    expect(find.textContaining('暂不支持8K超高清解码'), findsOneWidget);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dpad/dpad.dart';

import 'package:bili_tv/core/services/display_capability_service.dart';
import 'package:bili_tv/core/storage/storage_service.dart';
import 'package:bili_tv/features/settings/presentation/screens/tv_settings_screen.dart';

void main() {
  testWidgets('TvSettingsScreen displays HDR capability and cycles preferred quality',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    SharedPreferences.setMockInitialValues({
      'key_preferred_qn': 120,
    });
    final prefs = await SharedPreferences.getInstance();
    final storage = StorageService(prefs);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          storageServiceProvider.overrideWithValue(storage),
          displayCapabilityProvider.overrideWithValue(
            const DisplayHdrCapability(
              isHdrSupported: false,
              hasHdr10: false,
            ),
          ),
        ],
        child: MaterialApp(
          builder: Dpad.wrap(),
          home: const TvSettingsScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // 初始状态验证：在 SDR 设备下展示 [仅 SDR]，默认画质为 [4K 超清]
    expect(find.text('仅 SDR'), findsOneWidget);
    expect(find.text('4K 超清'), findsOneWidget);
    expect(storage.preferredQuality, 120);

    // 点击默认视频清晰度卡片，循环切换画质到 1080P 高码率 (112)
    await tester.tap(find.text('默认视频清晰度'));
    await tester.pumpAndSettle();

    expect(storage.preferredQuality, 112);
    expect(find.text('1080P 高码率'), findsOneWidget);

    // 再次点击，切换到 1080P 高清 (80)
    await tester.tap(find.text('默认视频清晰度'));
    await tester.pumpAndSettle();

    expect(storage.preferredQuality, 80);
    expect(find.text('1080P 高清'), findsOneWidget);

    // 点击 PC 调试模拟开关，切换为模拟开启
    await tester.tap(find.text('PC 调试模拟：强制支持 HDR'));
    await tester.pumpAndSettle();

    expect(storage.debugSimulateHdrSupport, true);
    expect(find.text('模拟开启'), findsOneWidget);
  });

  testWidgets('TvSettingsScreen displays active HDR badge when device supports HDR',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    SharedPreferences.setMockInitialValues({
      'key_preferred_qn': 120,
    });
    final prefs = await SharedPreferences.getInstance();
    final storage = StorageService(prefs);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          storageServiceProvider.overrideWithValue(storage),
          displayCapabilityProvider.overrideWithValue(
            const DisplayHdrCapability(
              isHdrSupported: true,
              hasHdr10: true,
              hasDolbyVision: true,
              maxLuminance: 1200.0,
            ),
          ),
        ],
        child: MaterialApp(
          builder: Dpad.wrap(),
          home: const TvSettingsScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // 验证展示 [支持 HDR] 且副标题标明硬件直通已就绪
    expect(find.text('支持 HDR'), findsOneWidget);
    expect(find.textContaining('硬件支持: 杜比视界'), findsOneWidget);
    expect(find.textContaining('1200 nits'), findsOneWidget);
  });
}

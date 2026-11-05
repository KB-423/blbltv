import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dpad/dpad.dart';
import 'package:bili_tv/core/storage/storage_service.dart';
import 'package:bili_tv/models/video/play_url_model.dart';
import 'package:bili_tv/features/player/presentation/providers/player_provider.dart';
import 'package:bili_tv/features/player/presentation/providers/player_state.dart';
import 'package:bili_tv/features/player/presentation/screens/tv_player_screen.dart';
import 'package:media_kit/media_kit.dart' hide PlayerState;
import 'package:shared_preferences/shared_preferences.dart';

class _FakePlayerNotifier extends PlayerNotifier {
  int changedQn = 0;

  _FakePlayerNotifier(super.bvid);

  @override
  PlayerState build() {
    return const PlayerState(
      bvid: 'BVtest123',
      title: '测试播放器大屏视频',
      isLoading: false,
      isPlaying: true,
      currentQn: 80,
      showControls: true,
      duration: Duration(minutes: 5),
      position: Duration(minutes: 1),
      qualities: [
        VideoQualityItem(qn: 80, desc: '1080P 高清'),
        VideoQualityItem(qn: 64, desc: '720P 高清'),
        VideoQualityItem(qn: 32, desc: '480P 清晰'),
      ],
    );
  }

  @override
  Future<void> changeQuality(int targetQn) async {
    changedQn = targetQn;
    state = state.copyWith(
      currentQn: targetQn,
      showQualityPanel: false,
    );
  }
}

void main() {
  MediaKit.ensureInitialized();
  testWidgets('TvPlayerScreen controls and quality selection test',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final storageService = StorageService(prefs);

    final fakeNotifier = _FakePlayerNotifier('BVtest123');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          storageServiceProvider.overrideWithValue(storageService),
          playerProvider('BVtest123').overrideWith(() => fakeNotifier),
        ],
        child: MaterialApp(
          builder: Dpad.wrap(),
          home: const TvPlayerScreen(bvid: 'BVtest123'),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    // 验证控制栏标题与当前清晰度按钮
    expect(find.text('测试播放器大屏视频'), findsOneWidget);
    expect(find.text('1080P 高清'), findsOneWidget);

    // 点击当前画质按钮唤醒画质选择面板
    await tester.tap(find.text('1080P 高清'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    // 验证画质面板弹出
    expect(find.text('画质选择'), findsOneWidget);
    expect(find.text('720P 高清'), findsOneWidget);
    expect(find.text('480P 清晰'), findsOneWidget);

    // 点击 720P 高清切换画质
    await tester.tap(find.text('720P 高清'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    // 验证触发了画质切换并且画质面板关闭
    expect(fakeNotifier.changedQn, 64);
    expect(find.text('画质选择'), findsNothing);

    // 触发系统返回键：优先关闭控制栏，绝不跳过控制栏直接退出播放器
    await tester.binding.handlePopRoute();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(fakeNotifier.state.showControls, false);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dpad/dpad.dart';
import 'package:media_kit/media_kit.dart' hide PlayerState;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bili_tv/core/storage/storage_service.dart';
import 'package:bili_tv/models/video/play_url_model.dart';
import 'package:bili_tv/features/bangumi/data/models/bangumi_episode_model.dart';
import 'package:bili_tv/features/bangumi/presentation/providers/bangumi_player_provider.dart';
import 'package:bili_tv/features/bangumi/presentation/providers/bangumi_player_state.dart';
import 'package:bili_tv/features/bangumi/presentation/screens/tv_bangumi_player_screen.dart';

class _FakeBangumiPlayerNotifier extends BangumiPlayerNotifier {
  int changedEpIndex = -1;
  int changedQn = 0;
  bool audioStopped = false;

  _FakeBangumiPlayerNotifier(super.seasonId);

  @override
  BangumiPlayerState build() {
    return const BangumiPlayerState(
      seasonId: 1001,
      seasonTitle: '葬送的芙莉莲',
      currentEpIndex: 0,
      isLoading: false,
      isPlaying: true,
      showControls: true,
      duration: Duration(minutes: 24),
      position: Duration(minutes: 3),
      currentQn: 80,
      qualities: [
        VideoQualityItem(qn: 80, desc: '1080P 高清'),
        VideoQualityItem(qn: 64, desc: '720P 高清'),
      ],
      episodes: [
        BangumiEpisodeModel(
          id: 1,
          bvid: 'BVep1',
          cid: 1001,
          title: '第1话',
          longTitle: '冒险的终点',
          duration: 1440,
        ),
        BangumiEpisodeModel(
          id: 2,
          bvid: 'BVep2',
          cid: 1002,
          title: '第2话',
          longTitle: '这不是真正的魔法',
          duration: 1440,
        ),
      ],
    );
  }

  @override
  void pauseAndStopAudio() {
    audioStopped = true;
  }

  @override
  void openEpisodeDrawer() {
    state = state.copyWith(showEpisodeDrawer: true, showControls: true);
  }

  @override
  void closeEpisodeDrawer() {
    state = state.copyWith(showEpisodeDrawer: false);
  }

  @override
  void openQualityPanel() {
    state = state.copyWith(showQualityPanel: true, showControls: true);
  }

  @override
  void closeQualityPanel() {
    state = state.copyWith(showQualityPanel: false);
  }

  @override
  Future<void> changeEpisode(int index) async {
    changedEpIndex = index;
    state = state.copyWith(
      currentEpIndex: index,
      showEpisodeDrawer: false,
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

  testWidgets('TvBangumiPlayerScreen renders episodes, drawer and quality panel',
      (tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final storageService = StorageService(prefs);

    final fakeNotifier = _FakeBangumiPlayerNotifier(1001);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          storageServiceProvider.overrideWithValue(storageService),
          bangumiPlayerProvider(1001).overrideWith(() => fakeNotifier),
        ],
        child: MaterialApp(
          builder: (context, child) =>
              Dpad.wrap()(context, child ?? const SizedBox.shrink()),
          home: const TvBangumiPlayerScreen(seasonId: 1001),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // 验证标题与当前话数渲染
    expect(find.text('葬送的芙莉莲'), findsOneWidget);
    expect(find.text('第1话 冒险的终点'), findsOneWidget);

    // 验证选集按钮
    expect(find.text('选集 (第1话)'), findsOneWidget);

    // 打开选集抽屉
    await tester.tap(find.text('选集 (第1话)'));
    await tester.pumpAndSettle();

    expect(find.text('剧集列表'), findsOneWidget);
    expect(find.text('共2集'), findsOneWidget);
    expect(find.text('这不是真正的魔法'), findsOneWidget);

    // 点击第2话切换
    await tester.tap(find.text('这不是真正的魔法'));
    await tester.pumpAndSettle();

    expect(fakeNotifier.changedEpIndex, 1);
    expect(find.text('第2话 这不是真正的魔法'), findsOneWidget);

    // 打开画质面板
    expect(find.text('1080P 高清'), findsOneWidget);
    await tester.tap(find.text('1080P 高清'));
    await tester.pumpAndSettle();

    expect(find.text('画质选择'), findsOneWidget);
    expect(find.text('720P 高清'), findsOneWidget);

    // 切换到 720P
    await tester.tap(find.text('720P 高清'));
    await tester.pumpAndSettle();

    expect(fakeNotifier.changedQn, 64);
  });
}

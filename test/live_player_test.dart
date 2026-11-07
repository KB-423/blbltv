import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dpad/dpad.dart';
import 'package:media_kit/media_kit.dart' hide PlayerState;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bili_tv/core/storage/storage_service.dart';
import 'package:bili_tv/features/live/presentation/providers/live_player_provider.dart';
import 'package:bili_tv/features/live/presentation/providers/live_player_state.dart';
import 'package:bili_tv/features/live/presentation/screens/tv_live_player_screen.dart';
import 'package:bili_tv/features/player/presentation/widgets/tv_progress_bar.dart';

class _FakeLivePlayerNotifier extends LivePlayerNotifier {
  bool toggledPlay = false;
  bool audioStopped = false;

  _FakeLivePlayerNotifier(super.roomId);

  @override
  LivePlayerState build() {
    return const LivePlayerState(
      roomId: 88888,
      title: '哔哩哔哩游戏官方直播间',
      uname: '哔哩哔哩电竞',
      onlineCount: '12.8万',
      isLoading: false,
      isPlaying: true,
      showControls: true,
      streamUrl: 'https://live-test.bilivideo.com/live/stream.m3u8',
    );
  }

  @override
  void pauseAndStopAudio() {
    audioStopped = true;
  }

  @override
  void togglePlay() {
    toggledPlay = true;
    state = state.copyWith(isPlaying: !state.isPlaying);
  }
}

void main() {
  MediaKit.ensureInitialized();

  testWidgets('TvLivePlayerScreen renders live badge, controls and lifecycle cleanup',
      (tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final storageService = StorageService(prefs);

    final fakeNotifier = _FakeLivePlayerNotifier(88888);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          storageServiceProvider.overrideWithValue(storageService),
          livePlayerProvider(88888).overrideWith(() => fakeNotifier),
        ],
        child: MaterialApp(
          builder: (context, child) =>
              Dpad.wrap()(context, child ?? const SizedBox.shrink()),
          home: const TvLivePlayerScreen(roomId: 88888),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // 验证直播间标题、主播名与在线人数
    expect(find.text('哔哩哔哩游戏官方直播间'), findsOneWidget);
    expect(find.text('主播: 哔哩哔哩电竞'), findsOneWidget);
    expect(find.text('12.8万 人在看'), findsOneWidget);

    // 验证直播中徽章
    expect(find.text('🔴 直播中'), findsOneWidget);

    // 验证直播模式下绝无进度条和快进快退
    expect(find.byType(TvProgressBar), findsNothing);
    expect(find.text('-10s'), findsNothing);
    expect(find.text('+10s'), findsNothing);

    // 验证播放/暂停按钮
    expect(find.byIcon(Icons.pause_rounded), findsOneWidget);
    await tester.tap(find.byIcon(Icons.pause_rounded));
    await tester.pumpAndSettle();

    expect(fakeNotifier.toggledPlay, isTrue);
    expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);

    // 验证返回键退出并调用资源掐断
    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();

    expect(fakeNotifier.audioStopped, isTrue);
  });
}

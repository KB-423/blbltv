import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';

import 'package:bili_tv/core/player/global_player_manager.dart';
import 'package:bili_tv/core/player/playback_session.dart';
import 'package:bili_tv/features/main/presentation/providers/nav_rail_focus_provider.dart';
import 'package:bili_tv/features/main/presentation/widgets/global_tv_video_surface.dart';
import 'package:bili_tv/models/video/video_item_model.dart';
import 'package:bili_tv/widgets/tv_image.dart';

// Valid 1x1 transparent PNG
final Uint8List kTransparentPng = Uint8List.fromList([
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49,
  0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x06,
  0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44,
  0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00, 0x05, 0x00, 0x01, 0x0D,
  0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE, 0x42,
  0x60, 0x82,
]);

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('com.alexmercerind/media_kit_video'),
      (call) async {
        if (call.method == 'VideoOutputManager.Create') {
          return {'id': 0, 'rect': {'top': 0, 'bottom': 0, 'left': 0, 'right': 0}};
        }
        return null;
      },
    );
    MediaKit.ensureInitialized();
  });

  group('GlobalPlayerManager Encapsulation & Multi-Tenant Tests', () {
    test('PlaybackSession properly tracks ownerId, speed and headers', () {
      final session = PlaybackSession(
        sessionId: 'test_session_1',
        ownerId: 'recommend',
        speed: 1.25,
        videoUrl: 'https://example.com/video.mp4',
        audioUrl: 'https://example.com/audio.m4s',
        coverUrl: 'https://example.com/cover.jpg',
        lastPosition: const Duration(seconds: 45),
        httpHeaders: {'Custom-Header': 'TestValue'},
      );

      expect(session.sessionId, 'test_session_1');
      expect(session.ownerId, 'recommend');
      expect(session.speed, 1.25);
      expect(session.lastPosition.inSeconds, 45);
      expect(session.httpHeaders['Custom-Header'], 'TestValue');
    });

    test('GlobalPlayerManager claims, caches and releases player ownership across components',
        () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final manager = container.read(globalPlayerManagerProvider.notifier);

      // Component A (recommend) claims the player without external URL call
      final sessionA = PlaybackSession(
        sessionId: 'rec_video_1',
        ownerId: 'recommend',
        videoUrl: '',
        lastPosition: const Duration(seconds: 30),
      );

      await manager.claimPlayer(ownerId: 'recommend', session: sessionA, autoPlay: false);

      var state = container.read(globalPlayerManagerProvider);
      expect(state.activeOwnerId, 'recommend');
      expect(state.isOwnerActive('recommend'), isTrue);
      expect(state.isOwnerActive('popular'), isFalse);
      expect(state.activeSession?.sessionId, 'rec_video_1');

      // Test encapsulated control calls
      await manager.setRate(1.5);
      state = container.read(globalPlayerManagerProvider);
      expect(state.speed, 1.5);

      await manager.setVolume(80.0);
      state = container.read(globalPlayerManagerProvider);
      expect(state.volume, 80.0);

      // Component B (popular) claims the player -> Component A's session should be cached
      final sessionB = PlaybackSession(
        sessionId: 'pop_video_2',
        ownerId: 'popular',
        videoUrl: '',
        lastPosition: const Duration(seconds: 10),
      );

      await manager.claimPlayer(ownerId: 'popular', session: sessionB, autoPlay: false);

      state = container.read(globalPlayerManagerProvider);
      expect(state.activeOwnerId, 'popular');
      expect(state.isOwnerActive('popular'), isTrue);
      expect(state.isOwnerActive('recommend'), isFalse);
      expect(state.activeSession?.sessionId, 'pop_video_2');

      // Verify that Component A's previous session was cached in manager
      final cachedA = manager.getCachedSession('recommend');
      expect(cachedA, isNotNull);
      expect(cachedA!.sessionId, 'rec_video_1');

      // Component B releases player
      final releasedB = await manager.releasePlayer('popular');
      expect(releasedB, isNotNull);
      expect(releasedB!.sessionId, 'pop_video_2');
      expect(container.read(globalPlayerManagerProvider).activeOwnerId, '');
    });
  });

  group('GlobalTvVideoSurface Snapshot & Fallback Tests', () {
    testWidgets('GlobalTvVideoSurface displays snapshot image when lastFrameBytes is present',
        (tester) async {
      final sessionWithSnapshot = PlaybackSession(
        sessionId: 'test_snap',
        ownerId: 'recommend',
        lastFrameBytes: kTransparentPng,
        coverUrl: 'https://example.com/cover.jpg',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            globalPlayerManagerProvider.overrideWith(() {
              return _MockGlobalPlayerManager(
                GlobalPlayerKernelState(
                  activeOwnerId: 'recommend',
                  activeSession: sessionWithSnapshot,
                  snapshotBytes: kTransparentPng,
                  isFirstFrameRendered: false, // In transition/snapshot mode
                ),
              );
            }),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: GlobalTvVideoSurface(expectedOwnerId: 'recommend'),
            ),
          ),
        ),
      );

      await tester.pump();

      // Verify Image is rendered for snapshot
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('GlobalTvVideoSurface gracefully degrades to TvImage cover when snapshot is null',
        (tester) async {
      final sessionWithoutSnapshot = const PlaybackSession(
        sessionId: 'test_cover',
        ownerId: 'popular',
        lastFrameBytes: null,
        coverUrl: 'https://example.com/fallback_cover.jpg',
        currentVideo: VideoItemModel(
          bvid: 'BV_TEST',
          pic: 'https://example.com/fallback_cover.jpg',
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            globalPlayerManagerProvider.overrideWith(() {
              return _MockGlobalPlayerManager(
                GlobalPlayerKernelState(
                  activeOwnerId: 'popular',
                  activeSession: sessionWithoutSnapshot,
                  snapshotBytes: null,
                  isFirstFrameRendered: false, // Fallback mode
                ),
              );
            }),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: GlobalTvVideoSurface(expectedOwnerId: 'popular'),
            ),
          ),
        ),
      );

      await tester.pump();

      // Verify TvImage is rendered as fallback
      expect(find.byType(TvImage), findsOneWidget);
    });
  });

  group('TopBarDisplayMode Adaptation Tests', () {
    test('TopBarDisplayMode transitions smoothly between full, compact and hidden', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(topBarDisplayModeProvider), TopBarDisplayMode.full);

      // Moving to row 1 / item 2 triggers compact
      container.read(topBarDisplayModeProvider.notifier).showCompact();
      expect(container.read(topBarDisplayModeProvider), TopBarDisplayMode.compact);

      // Entering pure playback triggers hidden
      container.read(topBarDisplayModeProvider.notifier).hide();
      expect(container.read(topBarDisplayModeProvider), TopBarDisplayMode.hidden);

      // Returning to row 0 / item 0 triggers showFull
      container.read(topBarDisplayModeProvider.notifier).showFull();
      expect(container.read(topBarDisplayModeProvider), TopBarDisplayMode.full);
    });
  });
}

class _MockGlobalPlayerManager extends GlobalPlayerManager {
  final GlobalPlayerKernelState _mockState;
  _MockGlobalPlayerManager(this._mockState);

  @override
  GlobalPlayerKernelState build() {
    return _mockState;
  }
}

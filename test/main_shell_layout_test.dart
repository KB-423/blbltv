import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:media_kit/media_kit.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bili_tv/core/player/playback_session.dart';
import 'package:bili_tv/core/storage/storage_service.dart';
import 'package:bili_tv/features/main/presentation/providers/nav_rail_focus_provider.dart';
import 'package:bili_tv/features/main/presentation/providers/shell_background_provider.dart';
import 'package:bili_tv/features/main/presentation/screens/tv_main_shell.dart';
import 'package:bili_tv/features/main/presentation/widgets/tv_top_bar.dart';

void main() {
  MediaKit.ensureInitialized();

  group('PlaybackSession Model Tests', () {
    test('creates PlaybackSession with snapshot bytes and position', () {
      final session = PlaybackSession(
        sessionId: 'test_session_1',
        videoUrl: 'https://example.com/video.m4s',
        audioUrl: 'https://example.com/audio.m4s',
        coverUrl: 'https://example.com/cover.jpg',
        lastPosition: const Duration(seconds: 45),
        lastFrameBytes: Uint8List.fromList([1, 2, 3, 4]),
      );

      expect(session.sessionId, 'test_session_1');
      expect(session.lastPosition, const Duration(seconds: 45));
      expect(session.lastFrameBytes, isNotNull);
      expect(session.lastFrameBytes!.length, 4);
    });
  });

  group('ShellBackgroundProvider Tests', () {
    test('transitions between player, image, and defaultDark correctly', () {
      final container = ProviderContainer();
      expect(container.read(shellBackgroundProvider).type,
          ShellBackgroundType.player);

      container.read(shellBackgroundProvider.notifier).showImage('https://img.com/pic.jpg');
      expect(container.read(shellBackgroundProvider).type,
          ShellBackgroundType.image);
      expect(container.read(shellBackgroundProvider).imageUrl,
          'https://img.com/pic.jpg');

      container.read(shellBackgroundProvider.notifier).showDefaultDark();
      expect(container.read(shellBackgroundProvider).type,
          ShellBackgroundType.defaultDark);

      container.read(shellBackgroundProvider.notifier).showPlayer();
      expect(container.read(shellBackgroundProvider).type,
          ShellBackgroundType.player);

      container.dispose();
    });
  });

  group('TvMainShell Layout & Animated Collapse Tests', () {
    testWidgets(
        'renders Stack with background and Column([TvTopHeader, TvCategoryBar, Expanded]) and animates on compact mode',
        (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storageService = StorageService(prefs);

      final router = GoRouter(
        initialLocation: '/home',
        routes: [
          ShellRoute(
            builder: (context, state, child) => TvMainShell(
              state: state,
              child: child,
            ),
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const SizedBox(
                  key: Key('home_child_content'),
                  child: Text('Home Content'),
                ),
              ),
            ],
          ),
        ],
      );

      final container = ProviderContainer(
        overrides: [
          storageServiceProvider.overrideWithValue(storageService),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // 验证头栏与分类栏均展示
      expect(find.byType(TvTopHeader), findsOneWidget);
      expect(find.byType(TvCategoryBar), findsOneWidget);
      expect(find.byKey(const Key('home_child_content')), findsOneWidget);
      expect(find.text('推荐'), findsOneWidget);
      expect(find.text('搜索'), findsOneWidget);

      // 触发 compact 模式：分类栏坍缩为 0，下方的 Expanded 区域平滑向上扩展
      container.read(topBarDisplayModeProvider.notifier).showCompact();

      // 在动画中途检查
      await tester.pump(const Duration(milliseconds: 140));
      // 动画完全结束 (280ms)
      await tester.pump(const Duration(milliseconds: 200));

      // 验证分类栏已坍缩
      final categoryBarFinder = find.byType(TvCategoryBar);
      expect(categoryBarFinder, findsNothing);

      // 验证下方内容依然正常渲染且上移
      expect(find.byKey(const Key('home_child_content')), findsOneWidget);

      // 触发 hidden 模式：头栏与分类栏全部隐藏
      container.read(topBarDisplayModeProvider.notifier).hide();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(TvTopHeader), findsNothing);
      expect(find.byType(TvCategoryBar), findsNothing);
      expect(find.byKey(const Key('home_child_content')), findsOneWidget);

      container.dispose();
    });
  });
}

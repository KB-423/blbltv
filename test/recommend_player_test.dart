import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bili_tv/core/utils/back_navigation_debounce.dart';
import 'package:bili_tv/features/home/presentation/providers/home_provider.dart';
import 'package:bili_tv/features/home/presentation/providers/home_state.dart';
import 'package:bili_tv/features/home/presentation/providers/recommend_player_provider.dart';
import 'package:bili_tv/features/home/presentation/providers/recommend_player_state.dart';
import 'package:bili_tv/features/home/presentation/widgets/tv_recommend_control_overlay.dart';
import 'package:bili_tv/features/main/presentation/providers/nav_rail_focus_provider.dart';
import 'package:bili_tv/models/video/video_collection_model.dart';
import 'package:bili_tv/models/video/video_item_model.dart';

class _TestRecommendPlayerNotifier extends RecommendPlayerNotifier {
  final RecommendPlayerState _initial;

  _TestRecommendPlayerNotifier([this._initial = const RecommendPlayerState()]);

  @override
  RecommendPlayerState build() => _initial;

  @override
  void togglePlay() {
    state = state.copyWith(isPlaying: !state.isPlaying);
  }

  @override
  Future<void> toggleLike() async {
    state = state.copyWith(hasLike: !state.hasLike);
  }
}

class _TestHomeFeedNotifier extends HomeFeedNotifier {
  @override
  HomeFeedState build() => const HomeFeedState(videos: [
        VideoItemModel(bvid: 'BVTest1', title: '推荐测试视频 1'),
      ]);
}

void main() {
  group('TopBarDisplayModeNotifier Tests', () {
    test('transitions between full, compact and hidden correctly', () {
      final container = ProviderContainer();
      expect(container.read(topBarDisplayModeProvider), TopBarDisplayMode.full);

      container.read(topBarDisplayModeProvider.notifier).showCompact();
      expect(container.read(topBarDisplayModeProvider), TopBarDisplayMode.compact);

      container.read(topBarDisplayModeProvider.notifier).hide();
      expect(container.read(topBarDisplayModeProvider), TopBarDisplayMode.hidden);

      container.read(topBarDisplayModeProvider.notifier).showFull();
      expect(container.read(topBarDisplayModeProvider), TopBarDisplayMode.full);

      container.dispose();
    });
  });

  group('RecommendPlayerState Tests', () {
    test('default state values and copyWith behaviors', () {
      const state = RecommendPlayerState();
      expect(state.currentIndex, 0);
      expect(state.isLoading, true);
      expect(state.isPlaying, false);
      expect(state.isPurePlayback, false);
      expect(state.showControls, false);
      expect(state.hasLike, false);
      expect(state.danmakuEnabled, true);
      expect(state.speed, 1.0);
      expect(state.playMode, TvPlayMode.sequence);

      final pureState = state.copyWith(
        isLoading: false,
        isPurePlayback: true,
        showControls: false,
        currentIndex: 2,
        hasLike: true,
        speed: 1.5,
        playMode: TvPlayMode.loopSingle,
      );

      expect(pureState.isLoading, false);
      expect(pureState.isPurePlayback, true);
      expect(pureState.showControls, false);
      expect(pureState.currentIndex, 2);
      expect(pureState.hasLike, true);
      expect(pureState.speed, 1.5);
      expect(pureState.playMode, TvPlayMode.loopSingle);
    });
  });

  group('VideoCollectionModel Tests', () {
    test('parses ugc_season JSON with archives and episodes polymorphic structure', () {
      final json = {
        'id': 1001,
        'title': '鬼灭之刃 动画合集',
        'cover': 'https://i0.hdslb.com/bfs/season/cover.jpg',
        'mid': 123456,
        'ep_count': 26,
        'archives': [
          {
            'aid': 55501,
            'bvid': 'BV1ugc01',
            'cid': 66601,
            'title': '第1话 残酷',
            'pic': 'https://i0.hdslb.com/bfs/archive/01.jpg',
            'duration': 1420,
          },
          {
            'aid': 55502,
            'bvid': 'BV1ugc02',
            'cid': 66602,
            'title': '第2话 育手 鳞泷左近次',
            'pic': 'https://i0.hdslb.com/bfs/archive/02.jpg',
            'duration': 1435,
          },
        ],
      };

      final collection = VideoCollectionModel.fromJson(json);
      expect(collection.id, 1001);
      expect(collection.title, '鬼灭之刃 动画合集');
      expect(collection.items.length, 2);
      expect(collection.items[0].bvid, 'BV1ugc01');
      expect(collection.items[0].title, '第1话 残酷');
      expect(collection.items[1].bvid, 'BV1ugc02');
    });

    test('parses fallback empty payload without throwing', () {
      final collection = VideoCollectionModel.fromJson(const {});
      expect(collection.id, 0);
      expect(collection.title, '');
      expect(collection.items, isEmpty);
    });
  });

  group('Single Persistent Player & CurrentVideo State Tests', () {
    test('currentVideo holds active video metadata independently of feed index', () {
      const original = RecommendPlayerState(currentIndex: 0);
      expect(original.currentVideo, isNull);

      const target = VideoItemModel(
        bvid: 'BV1TargetTest',
        cid: 123456,
        title: '合集选集目标视频',
      );

      final updated = original.copyWith(
        currentVideo: target,
        isPurePlayback: true,
        showControls: false,
      );

      expect(updated.currentVideo, isNotNull);
      expect(updated.currentVideo!.bvid, 'BV1TargetTest');
      expect(updated.currentVideo!.title, '合集选集目标视频');
      expect(updated.isPurePlayback, true);
      expect(updated.showControls, false);
    });
  });

  group('TvRecommendControlOverlay Widget Tests', () {
    testWidgets('renders controls block with title, like button, progress bar, and peek bar',
        (tester) async {
      bool closed = false;
      VideoItemModel? selectedVideo;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            recommendPlayerProvider.overrideWith(
              () => _TestRecommendPlayerNotifier(
                const RecommendPlayerState(
                  isLoading: false,
                  isPlaying: true,
                  duration: Duration(minutes: 5),
                  position: Duration(seconds: 45),
                  relatedVideos: [
                    VideoItemModel(bvid: 'BVRelated1', title: '相关视频 1'),
                  ],
                ),
              ),
            ),
            homeFeedProvider.overrideWith(() => _TestHomeFeedNotifier()),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: TvRecommendControlOverlay(
                onClose: () => closed = true,
                onSelectVideo: (v) => selectedVideo = v,
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      // 验证标题与基本控制元素存在
      expect(find.text('推荐测试视频 1'), findsOneWidget);
      expect(find.text('点赞'), findsOneWidget);
      expect(find.text('点踩'), findsOneWidget);
      expect(find.text('投币'), findsOneWidget);
      expect(find.text('收藏'), findsOneWidget);
      expect(find.text('弹幕: 开'), findsOneWidget);

      // 验证露头条显示
      expect(find.byType(TvRecommendControlOverlay), findsOneWidget);
      expect(find.textContaining('展开'), findsOneWidget);

      // 验证返回键触发 onClose
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));
      expect(selectedVideo, isNull);
      expect(closed, true);
    });

    testWidgets('expanding collections drawer covers controls block and back collapses it',
        (tester) async {
      bool closed = false;
      VideoItemModel? selectedVideo;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            recommendPlayerProvider.overrideWith(
              () => _TestRecommendPlayerNotifier(
                const RecommendPlayerState(
                  isLoading: false,
                  isPlaying: true,
                  duration: Duration(minutes: 5),
                  position: Duration(seconds: 45),
                  relatedVideos: [
                    VideoItemModel(bvid: 'BVRelated1', title: '相关视频 1'),
                  ],
                ),
              ),
            ),
            homeFeedProvider.overrideWith(() => _TestHomeFeedNotifier()),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: TvRecommendControlOverlay(
                onClose: () => closed = true,
                onSelectVideo: (v) => selectedVideo = v,
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      // 展开抽屉
      await tester.tap(find.textContaining('展开'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      // 验证收起按钮和合集卡片出现
      expect(find.text('收起 (返回键)'), findsOneWidget);
      expect(find.text('相关视频 1'), findsOneWidget);

      // 点击视频卡片，触发 onSelectVideo
      await tester.tap(find.text('相关视频 1'));
      await tester.pump();
      expect(selectedVideo, isNotNull);
      expect(selectedVideo!.bvid, 'BVRelated1');

      // 按返回键收起抽屉
      BackNavigationDebounce.reset();
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      // 抽屉收起后，再次按返回键关闭浮层
      BackNavigationDebounce.reset();
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));
      expect(closed, true);
    });
  });
}

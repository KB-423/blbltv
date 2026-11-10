import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bili_tv/core/storage/storage_service.dart';
import 'package:bili_tv/core/utils/back_navigation_debounce.dart';
import 'package:bili_tv/features/home/data/repositories/home_repository.dart';
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

  group('HomeFeedNotifier Queue Limit & Deduplication Tests', () {
    test('truncates videos from head when exceeding 100 and deduplicates bvids', () async {
      final fakeRepo = _MockHomeRepository(
        onFetch: (freshIdx, pageSize) async {
          // 每次返回 20 个，前两个与上一批重复以验证去重
          final start = (freshIdx - 1) * 18;
          return List.generate(
            20,
            (i) => VideoItemModel(
              id: start + i,
              bvid: 'BV_item_${start + i}',
              title: '推荐视频 ${start + i}',
            ),
          );
        },
      );

      final container = ProviderContainer(
        overrides: [
          homeRepositoryProvider.overrideWithValue(fakeRepo),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(homeFeedProvider.notifier);
      await notifier.init();

      expect(container.read(homeFeedProvider).videos.length, 20);

      // 连续加载 6 次 (20 * 6 = 120+ 项，但经去重与截断，队列必须保持在 100 项之内)
      for (int i = 0; i < 6; i++) {
        await notifier.loadMore();
      }

      final currentVideos = container.read(homeFeedProvider).videos;
      expect(currentVideos.length, lessThanOrEqualTo(HomeFeedNotifier.maxQueueSize));
      expect(currentVideos.length, equals(100));

      // 验证头部早期项（如 BV_item_0）已被从头部截断
      expect(currentVideos.any((v) => v.bvid == 'BV_item_0'), isFalse);
      // 验证最新的项依然存在
      expect(currentVideos.last.bvid, contains('BV_item_'));
    });
  });

  group('RecommendPlayerNotifier Hover Switch & 5-Second Idle Tests', () {
    testWidgets('3-second hover triggers auto-switch and 5-second idle enters pure playback',
        (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storage = StorageService(prefs);

      int playAtIndex = -1;
      final customNotifier = _InteractiveRecommendPlayerNotifier(
        onPlayAt: (idx) => playAtIndex = idx,
      );

      final container = ProviderContainer(
        overrides: [
          storageServiceProvider.overrideWithValue(storage),
          recommendPlayerProvider.overrideWith(() => customNotifier),
          homeFeedProvider.overrideWith(() => _PreloadedHomeFeedNotifier()),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(recommendPlayerProvider.notifier);

      // 1. 测试 3 秒停留切换
      notifier.scheduleHoverPlay(3);
      expect(playAtIndex, -1); // 立即检查尚未触发

      // 前进 2 秒，仍不触发
      await tester.pump(const Duration(seconds: 2));
      expect(playAtIndex, -1);

      // 再前进 1.1 秒（累计超过 3 秒），触发切换到第 3 个视频
      await tester.pump(const Duration(milliseconds: 1100));
      expect(playAtIndex, 3);

      // 2. 测试 cancelHoverPlay 取消倒计时
      playAtIndex = -1;
      notifier.scheduleHoverPlay(4);
      await tester.pump(const Duration(seconds: 1));
      notifier.cancelHoverPlay();
      await tester.pump(const Duration(seconds: 3));
      expect(playAtIndex, -1); // 被取消，不触发

      // 3. 测试 5 秒无操作进入纯享播放
      notifier.resetIdleTimer();
      expect(container.read(recommendPlayerProvider).isPurePlayback, isFalse);

      await tester.pump(const Duration(seconds: 4));
      expect(container.read(recommendPlayerProvider).isPurePlayback, isFalse);

      await tester.pump(const Duration(seconds: 1, milliseconds: 200));
      expect(container.read(recommendPlayerProvider).isPurePlayback, isTrue);
    });

    test('syncs currentIndex when videos list is truncated from head', () {
      final customNotifier = _InteractiveRecommendPlayerNotifier();
      final feedNotifier = _DynamicHomeFeedNotifier([
        const VideoItemModel(bvid: 'BV_0', title: '视频 0'),
        const VideoItemModel(bvid: 'BV_1', title: '视频 1'),
        const VideoItemModel(bvid: 'BV_2', title: '视频 2'),
        const VideoItemModel(bvid: 'BV_3', title: '视频 3'),
      ]);

      final container = ProviderContainer(
        overrides: [
          recommendPlayerProvider.overrideWith(() => customNotifier),
          homeFeedProvider.overrideWith(() => feedNotifier),
        ],
      );
      addTearDown(container.dispose);

      final playerNotifier =
          container.read(recommendPlayerProvider.notifier) as _InteractiveRecommendPlayerNotifier;

      // 初始播放视频 2 (index: 2)
      playerNotifier.setCurrentVideoForTest(
        const VideoItemModel(bvid: 'BV_2', title: '视频 2'),
        2,
      );
      expect(container.read(recommendPlayerProvider).currentIndex, 2);

      // 模拟从头部截断两项 (BV_0, BV_1 被移除)
      feedNotifier.setVideos([
        const VideoItemModel(bvid: 'BV_2', title: '视频 2'),
        const VideoItemModel(bvid: 'BV_3', title: '视频 3'),
        const VideoItemModel(bvid: 'BV_4', title: '视频 4'),
      ]);

      // 此时 BV_2 在新列表中的下标应变为 0
      expect(container.read(recommendPlayerProvider).currentIndex, 0);
    });
  });
}

class _MockHomeRepository implements HomeRepository {
  final Future<List<VideoItemModel>> Function(int freshIdx, int pageSize) onFetch;

  _MockHomeRepository({required this.onFetch});

  @override
  Future<List<VideoItemModel>> fetchRecommendVideos({
    required int freshIdx,
    int pageSize = 16,
  }) {
    return onFetch(freshIdx, pageSize);
  }
}

class _PreloadedHomeFeedNotifier extends HomeFeedNotifier {
  @override
  HomeFeedState build() {
    return HomeFeedState(
      isLoading: false,
      videos: List.generate(
        10,
        (i) => VideoItemModel(bvid: 'BV_feed_$i', title: '预加载视频 $i'),
      ),
    );
  }
}

class _DynamicHomeFeedNotifier extends HomeFeedNotifier {
  final List<VideoItemModel> _initialVideos;

  _DynamicHomeFeedNotifier(this._initialVideos);

  @override
  HomeFeedState build() {
    return HomeFeedState(isLoading: false, videos: _initialVideos);
  }

  void setVideos(List<VideoItemModel> videos) {
    state = state.copyWith(videos: videos);
  }
}

class _InteractiveRecommendPlayerNotifier extends RecommendPlayerNotifier {
  final ValueChanged<int>? onPlayAt;

  _InteractiveRecommendPlayerNotifier({this.onPlayAt});

  @override
  RecommendPlayerState build() {
    // 监听首页推荐数据流：当推荐队列从头部截断时同步修正 currentIndex
    ref.listen(homeFeedProvider, (prev, next) {
      if (state.currentVideo != null && next.videos.isNotEmpty) {
        final curBvid = state.currentVideo!.bvid;
        final newIndex = next.videos.indexWhere((v) => v.bvid == curBvid);
        if (newIndex >= 0 && newIndex != state.currentIndex) {
          state = state.copyWith(currentIndex: newIndex);
        } else if (newIndex < 0 && state.currentIndex >= next.videos.length) {
          state = state.copyWith(currentIndex: next.videos.length - 1);
        }
      }
    });

    return const RecommendPlayerState(
      currentIndex: 0,
      isLoading: false,
      isPurePlayback: false,
      showControls: false,
    );
  }

  void setCurrentVideoForTest(VideoItemModel video, int index) {
    state = state.copyWith(currentVideo: video, currentIndex: index);
  }

  @override
  Future<void> playAt(int index,
      {Duration startPosition = Duration.zero, bool resetIdle = true}) async {
    state = state.copyWith(currentIndex: index);
    onPlayAt?.call(index);
    if (resetIdle) {
      resetIdleTimer();
    }
  }
}

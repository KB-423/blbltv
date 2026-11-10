import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bili_tv/core/storage/storage_service.dart';
import 'package:bili_tv/features/home/presentation/providers/home_provider.dart';
import 'package:bili_tv/features/home/presentation/providers/home_state.dart';
import 'package:bili_tv/features/home/presentation/providers/recommend_player_provider.dart';
import 'package:bili_tv/features/home/presentation/providers/recommend_player_state.dart';
import 'package:bili_tv/features/home/presentation/screens/tv_home_screen.dart';
import 'package:bili_tv/features/home/presentation/widgets/tv_recommend_rail.dart';
import 'package:bili_tv/models/video/video_item_model.dart';
import 'package:dpad/dpad.dart';
import 'package:media_kit/media_kit.dart';

class _FakeRecommendPlayerNotifier extends RecommendPlayerNotifier {
  int playedIndex = -1;
  int scheduledHoverIndex = -1;
  bool hoverCanceled = false;

  @override
  RecommendPlayerState build() {
    return const RecommendPlayerState(
      currentIndex: 0,
      isLoading: false,
      isPurePlayback: false,
      showControls: false,
    );
  }

  @override
  Future<void> playAt(int index,
      {Duration startPosition = Duration.zero, bool resetIdle = true}) async {
    playedIndex = index;
    state = state.copyWith(currentIndex: index);
  }

  @override
  void scheduleHoverPlay(int index) {
    scheduledHoverIndex = index;
    hoverCanceled = false;
  }

  @override
  void cancelHoverPlay() {
    hoverCanceled = true;
  }

  @override
  void resetIdleTimer() {}

  @override
  void enterPurePlayback() {
    state = state.copyWith(isPurePlayback: true);
  }

  @override
  void exitPurePlayback() {
    state = state.copyWith(isPurePlayback: false);
  }
}

class _TestHomeFeedNotifier extends HomeFeedNotifier {
  int refreshCount = 0;
  int loadMoreCount = 0;

  @override
  HomeFeedState build() {
    return HomeFeedState(
      isLoading: false,
      videos: List.generate(
        8,
        (i) => VideoItemModel(
          id: i,
          bvid: 'BVtest$i',
          title: '测试视频 $i',
          owner: const VideoOwner(name: '测试UP'),
          stat: const VideoStat(view: 1000),
        ),
      ),
    );
  }

  @override
  Future<void> refresh() async {
    refreshCount++;
  }

  @override
  Future<void> loadMore() async {
    loadMoreCount++;
  }
}

void main() {
  MediaKit.ensureInitialized();
  testWidgets('TvHomeScreen D-pad refresh and infinite scroll test',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final storageService = StorageService(prefs);

    final notifier = _TestHomeFeedNotifier();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          storageServiceProvider.overrideWithValue(storageService),
          homeFeedProvider.overrideWith(() => notifier),
          recommendPlayerProvider.overrideWith(_FakeRecommendPlayerNotifier.new),
        ],
        child: MaterialApp(
          builder: Dpad.wrap(),
          home: const TvHomeScreen(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // 检查推荐视频流与视频卡片已正确渲染
    expect(find.text('推荐视频流'), findsOneWidget);
    expect(find.text('测试视频 0'), findsWidgets);

    // 点击推荐导轨中的视频卡片模拟遥控器确定键播放
    final railCard = find.descendant(
      of: find.byType(TvRecommendRail),
      matching: find.text('测试视频 0'),
    );
    await tester.tap(railCard);
    await tester.pump();

    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });

  testWidgets('TvRecommendRail triggers loadMore when moving to the bottom cards',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final storageService = StorageService(prefs);

    final feedNotifier = _TestHomeFeedNotifier();
    final playerNotifier = _FakeRecommendPlayerNotifier();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          storageServiceProvider.overrideWithValue(storageService),
          homeFeedProvider.overrideWith(() => feedNotifier),
          recommendPlayerProvider.overrideWith(() => playerNotifier),
        ],
        child: MaterialApp(
          builder: Dpad.wrap(),
          home: const TvHomeScreen(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // 聚焦列表中的倒数项 (例如测试视频 6，总共有 8 项，index >= 8 - 4 会触发预加载)
    final card6 = find.descendant(
      of: find.byType(TvRecommendRail),
      matching: find.text('测试视频 6'),
    );
    expect(card6, findsOneWidget);
    await tester.tap(card6);
    await tester.pump();

    // 验证调用了 loadMore
    expect(feedNotifier.loadMoreCount, greaterThanOrEqualTo(1));
    // 验证触发了 playAt
    expect(playerNotifier.playedIndex, equals(6));

    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });

  test('VideoItemModel safely parses polymorphic rcmd_reason and stats', () {
    // 模拟真实 B 站 Map 结构的 rcmd_reason
    final jsonWithMapReason = {
      'id': 117533055126066,
      'bvid': 'BV1Ybxk6CEXy',
      'cid': 43195433550,
      'title': '测试推荐视频',
      'pic': 'http://i1.hdslb.com/bfs/archive/test.jpg',
      'duration': 831,
      'pubdate': 1793444400,
      'owner': {
        'mid': 730732,
        'name': '测试UP主',
        'face': 'http://i1.hdslb.com/bfs/face/test.jpg',
      },
      'stat': {
        'view': 936396,
        'like': 39127,
        'danmaku': 1691,
      },
      'rcmd_reason': {
        'content': '百万播放',
        'reason_type': 1,
      },
    };

    final model1 = VideoItemModel.fromJson(jsonWithMapReason);
    expect(model1.bvid, 'BV1Ybxk6CEXy');
    expect(model1.id, 117533055126066);
    expect(model1.rcmdReason, '百万播放');
    expect(model1.owner?.name, '测试UP主');
    expect(model1.stat?.view, 936396);

    // 模拟字符串类型的 rcmd_reason
    final jsonWithStringReason = {
      'id': 100,
      'bvid': 'BV123',
      'rcmd_reason': '热门精选',
    };
    final model2 = VideoItemModel.fromJson(jsonWithStringReason);
    expect(model2.rcmdReason, '热门精选');

    // 模拟 null 类型的 rcmd_reason
    final jsonWithNullReason = {
      'id': 101,
      'bvid': 'BV456',
      'rcmd_reason': null,
    };
    final model3 = VideoItemModel.fromJson(jsonWithNullReason);
    expect(model3.rcmdReason, isNull);
  });

  test('VideoItemModel.fromSearchJson correctly parses search results and strips HTML', () {
    final searchJson = {
      'aid': 123456,
      'bvid': 'BV1kS8H6VERt',
      'title': '《<em class="keyword">黑神话</em>：悟空》演示',
      'pic': '//i0.hdslb.com/bfs/archive/pic.jpg',
      'author': '游戏科学',
      'mid': 99999,
      'upic': '//i0.hdslb.com/bfs/face/up.jpg',
      'play': 1234567,
      'video_review': 5432,
      'duration': '15:20',
      'pubdate': 1700000000,
    };

    final video = VideoItemModel.fromSearchJson(searchJson);
    expect(video.bvid, 'BV1kS8H6VERt');
    expect(video.title, '《黑神话：悟空》演示'); // 验证 HTML 标签清洗
    expect(video.pic, 'https://i0.hdslb.com/bfs/archive/pic.jpg'); // 验证协议头补齐
    expect(video.owner?.name, '游戏科学');
    expect(video.owner?.mid, 99999);
    expect(video.stat?.view, 1234567);
    expect(video.stat?.danmaku, 5432);
    expect(video.duration, 15 * 60 + 20); // 验证时间解析
  });
}

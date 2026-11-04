import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bili_tv/core/storage/storage_service.dart';
import 'package:bili_tv/features/home/presentation/providers/home_provider.dart';
import 'package:bili_tv/features/home/presentation/providers/home_state.dart';
import 'package:bili_tv/features/home/presentation/screens/tv_home_screen.dart';
import 'package:bili_tv/models/video/video_item_model.dart';
import 'package:dpad/dpad.dart';

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
        ],
        child: MaterialApp(
          builder: Dpad.wrap(),
          home: const TvHomeScreen(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // 检查推荐视频列表和换一批按钮已正确渲染
    expect(find.text('换一批'), findsOneWidget);
    expect(find.text('测试视频 0'), findsOneWidget);

    // 点击“换一批”按钮模拟遥控器确定键刷新
    await tester.tap(find.text('换一批'));
    await tester.pump();
    expect(notifier.refreshCount, 1);
  });
}

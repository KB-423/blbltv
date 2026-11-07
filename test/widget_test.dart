import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bili_tv/core/storage/storage_service.dart';
import 'package:bili_tv/features/home/presentation/providers/home_provider.dart';
import 'package:bili_tv/features/home/presentation/providers/home_state.dart';
import 'package:bili_tv/main.dart';
import 'package:media_kit/media_kit.dart';

class _FakeHomeFeedNotifier extends HomeFeedNotifier {
  @override
  HomeFeedState build() {
    return const HomeFeedState(
      isLoading: false,
      videos: [],
    );
  }
}

void main() {
  MediaKit.ensureInitialized();
  testWidgets('BiliTvApp smoke test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final storageService = StorageService(prefs);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          storageServiceProvider.overrideWithValue(storageService),
          homeFeedProvider.overrideWith(_FakeHomeFeedNotifier.new),
        ],
        child: const BiliTvApp(),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // 顶部双层悬浮导航栏分类 Tab 与会员状态检查
    expect(find.text('推荐'), findsOneWidget);
    expect(find.text('直播'), findsOneWidget);
    expect(find.text('热门'), findsOneWidget);
    expect(find.text('番剧'), findsOneWidget);
    expect(find.text('未登录'), findsNWidgets(2));

    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });
}

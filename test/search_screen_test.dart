import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dpad/dpad.dart';
import 'package:bili_tv/models/video/video_item_model.dart';
import 'package:bili_tv/features/search/presentation/providers/search_provider.dart';
import 'package:bili_tv/features/search/presentation/providers/search_state.dart';
import 'package:bili_tv/features/search/presentation/screens/tv_search_screen.dart';

class _FakeSearchNotifier extends SearchNotifier {
  final SearchState initialState;
  int searchCallCount = 0;
  String lastQuery = '';
  int loadMoreCount = 0;

  _FakeSearchNotifier(this.initialState);

  @override
  SearchState build() => initialState;

  @override
  Future<void> search(String keyword, {String? order}) async {
    searchCallCount++;
    lastQuery = keyword;
    state = state.copyWith(
      keyword: keyword,
      hasSearched: true,
      videos: List.generate(
        8,
        (i) => VideoItemModel(
          id: i,
          bvid: 'BVsearch$i',
          title: '$keyword 结果视频 $i',
          owner: const VideoOwner(name: '测试UP主'),
          stat: const VideoStat(view: 12000),
        ),
      ),
      numPages: 3,
      numResults: 24,
      page: 1,
    );
  }

  @override
  Future<void> loadMore() async {
    loadMoreCount++;
  }
}

void main() {
  testWidgets('TvSearchScreen input, hot words and video results test',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final fakeNotifier = _FakeSearchNotifier(
      const SearchState(
        hotWords: ['黑神话悟空', '2026新番', '4K风景演示'],
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          searchProvider.overrideWith(() => fakeNotifier),
        ],
        child: MaterialApp(
          builder: Dpad.wrap(),
          home: const TvSearchScreen(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // 验证搜索标题、输入框、热搜推荐词
    expect(find.text('全站搜索'), findsOneWidget);
    expect(find.text('黑神话悟空'), findsOneWidget);
    expect(find.text('2026新番'), findsOneWidget);
    expect(find.text('探索精彩视频'), findsOneWidget);

    // 点击热搜推荐词 “黑神话悟空”
    await tester.tap(find.text('黑神话悟空'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // 验证触发了 search 并展示搜索结果
    expect(fakeNotifier.searchCallCount, 1);
    expect(fakeNotifier.lastQuery, '黑神话悟空');
    expect(find.textContaining('共找到约 24 个相关视频'), findsOneWidget);
    expect(find.text('黑神话悟空 结果视频 0'), findsOneWidget);
    expect(find.text('黑神话悟空 结果视频 7'), findsOneWidget);

    // 测试输入框设置关键词与点击搜索按钮提交
    final textField = tester.widget<TextField>(find.byType(TextField));
    textField.controller?.text = 'Flutter大屏';
    await tester.tap(find.text('搜索'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(fakeNotifier.searchCallCount, 2);
    expect(fakeNotifier.lastQuery, 'Flutter大屏');
  });
}

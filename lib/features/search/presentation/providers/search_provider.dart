import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/search_repository.dart';
import 'search_state.dart';

/// TV 搜索功能控制器
class SearchNotifier extends Notifier<SearchState> {
  @override
  SearchState build() {
    // 异步拉取真实热搜词列表
    Future.microtask(loadHotWords);
    return const SearchState();
  }

  SearchRepository get _repository => ref.read(searchRepositoryProvider);

  /// 加载真实热搜榜
  Future<void> loadHotWords() async {
    try {
      final words = await _repository.fetchHotSearchWords();
      state = state.copyWith(hotWords: words);
    } catch (_) {
      // 容错处理，热搜获取失败不阻塞主流程
    }
  }

  /// 发起搜索
  Future<void> search(String keyword, {String? order}) async {
    final trimmed = keyword.trim();
    if (trimmed.isEmpty) return;

    final targetOrder = order ?? state.order;

    state = state.copyWith(
      keyword: trimmed,
      order: targetOrder,
      isLoading: true,
      hasSearched: true,
      error: null,
      page: 1,
      videos: [],
    );

    try {
      final res = await _repository.searchVideos(
        keyword: trimmed,
        page: 1,
        order: targetOrder,
      );

      state = state.copyWith(
        videos: res.videos,
        numPages: res.numPages,
        numResults: res.numResults,
        isLoading: false,
        page: 1,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '搜索失败: $e',
      );
    }
  }

  /// 错误重试
  Future<void> retry() async {
    if (state.keyword.isNotEmpty) {
      await search(state.keyword, order: state.order);
    } else {
      await loadHotWords();
    }
  }

  /// 遥控器触底加载更多搜索结果
  Future<void> loadMore() async {
    if (state.isLoadingMore || state.isLoading || !state.hasMore) {
      return;
    }

    state = state.copyWith(isLoadingMore: true);
    final nextPage = state.page + 1;

    try {
      final res = await _repository.searchVideos(
        keyword: state.keyword,
        page: nextPage,
        order: state.order,
      );

      state = state.copyWith(
        videos: [...state.videos, ...res.videos],
        numPages: res.numPages,
        numResults: res.numResults,
        page: nextPage,
        isLoadingMore: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        error: '加载更多失败: $e',
      );
    }
  }

  /// 清空搜索
  void clear() {
    state = state.copyWith(
      keyword: '',
      videos: [],
      hasSearched: false,
      page: 1,
      numPages: 0,
      numResults: 0,
      error: null,
    );
  }
}

/// Riverpod Provider
final searchProvider = NotifierProvider<SearchNotifier, SearchState>(() {
  return SearchNotifier();
});

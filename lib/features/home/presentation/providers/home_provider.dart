import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/home_repository.dart';
import 'home_state.dart';

/// 首页推荐流状态管理
class HomeFeedNotifier extends Notifier<HomeFeedState> {
  @override
  HomeFeedState build() {
    // 异步加载第一批数据
    Future.microtask(init);
    return const HomeFeedState();
  }

  HomeRepository get _repository => ref.read(homeRepositoryProvider);

  /// 首次加载
  Future<void> init() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final videos = await _repository.fetchRecommendVideos(
        freshIdx: 1,
        pageSize: 16,
      );
      state = state.copyWith(
        videos: videos,
        isLoading: false,
        freshIdx: 1,
        hasMore: true,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '加载失败: $e',
      );
    }
  }

  /// 换一批 / 刷新 (TV 顶部“换一批”按钮或顶部按键刷新)
  Future<void> refresh() async {
    if (state.isRefreshing || state.isLoading) return;

    state = state.copyWith(isRefreshing: true, error: null);
    final nextIdx = state.freshIdx + 1;

    try {
      final newVideos = await _repository.fetchRecommendVideos(
        freshIdx: nextIdx,
        pageSize: 16,
      );
      state = state.copyWith(
        videos: newVideos,
        isRefreshing: false,
        freshIdx: nextIdx,
        hasMore: true,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isRefreshing: false,
        error: '刷新失败: $e',
      );
    }
  }

  /// 遥控器触底自动追加加载 (TV Infinite Scroll)
  Future<void> loadMore() async {
    if (state.isLoadingMore || state.isRefreshing || state.isLoading || !state.hasMore) {
      return;
    }

    state = state.copyWith(isLoadingMore: true);
    final nextIdx = state.freshIdx + 1;

    try {
      final nextVideos = await _repository.fetchRecommendVideos(
        freshIdx: nextIdx,
        pageSize: 12,
      );

      if (nextVideos.isEmpty) {
        state = state.copyWith(
          isLoadingMore: false,
          hasMore: false,
        );
      } else {
        state = state.copyWith(
          videos: [...state.videos, ...nextVideos],
          isLoadingMore: false,
          freshIdx: nextIdx,
          hasMore: true,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        error: '加载更多失败: $e',
      );
    }
  }

  /// 重试
  Future<void> retry() async {
    if (state.videos.isEmpty) {
      await init();
    } else {
      await loadMore();
    }
  }
}

final homeFeedProvider =
    NotifierProvider<HomeFeedNotifier, HomeFeedState>(
  HomeFeedNotifier.new,
);

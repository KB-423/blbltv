import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/video/video_item_model.dart';
import '../../data/repositories/popular_repository.dart';

class PopularState {
  final List<VideoItemModel> videos;
  final int page;
  final bool isLoading;
  final bool isRefreshing;
  final bool isLoadingMore;
  final String? error;

  const PopularState({
    this.videos = const [],
    this.page = 1,
    this.isLoading = false,
    this.isRefreshing = false,
    this.isLoadingMore = false,
    this.error,
  });

  PopularState copyWith({
    List<VideoItemModel>? videos,
    int? page,
    bool? isLoading,
    bool? isRefreshing,
    bool? isLoadingMore,
    String? error,
  }) {
    return PopularState(
      videos: videos ?? this.videos,
      page: page ?? this.page,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
    );
  }
}

class PopularNotifier extends Notifier<PopularState> {
  @override
  PopularState build() {
    Future.microtask(() => loadInitial());
    return const PopularState(isLoading: true);
  }

  PopularRepository get _repository => ref.read(popularRepositoryProvider);

  Future<void> loadInitial() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final list = await _repository.fetchPopularVideos(pn: 1);
      state = state.copyWith(
        videos: list,
        page: 1,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '获取全站热门视频失败: $e',
      );
    }
  }

  Future<void> refresh() async {
    state = state.copyWith(isRefreshing: true, error: null);
    try {
      final list = await _repository.fetchPopularVideos(pn: 1);
      state = state.copyWith(
        videos: list,
        page: 1,
        isRefreshing: false,
      );
    } catch (e) {
      state = state.copyWith(
        isRefreshing: false,
        error: '刷新热门视频失败: $e',
      );
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || state.isLoading) return;
    state = state.copyWith(isLoadingMore: true);
    final nextPage = state.page + 1;
    try {
      final list = await _repository.fetchPopularVideos(pn: nextPage);
      state = state.copyWith(
        videos: [...state.videos, ...list],
        page: nextPage,
        isLoadingMore: false,
      );
    } catch (_) {
      state = state.copyWith(isLoadingMore: false);
    }
  }
}

final popularFeedProvider =
    NotifierProvider<PopularNotifier, PopularState>(PopularNotifier.new);

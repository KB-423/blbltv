import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/bangumi_season_model.dart';
import '../../data/repositories/bangumi_repository.dart';

class BangumiState {
  final List<BangumiSeasonModel> seasons;
  final int page;
  final bool isLoading;
  final bool isRefreshing;
  final bool isLoadingMore;
  final String? error;

  const BangumiState({
    this.seasons = const [],
    this.page = 1,
    this.isLoading = false,
    this.isRefreshing = false,
    this.isLoadingMore = false,
    this.error,
  });

  BangumiState copyWith({
    List<BangumiSeasonModel>? seasons,
    int? page,
    bool? isLoading,
    bool? isRefreshing,
    bool? isLoadingMore,
    String? error,
  }) {
    return BangumiState(
      seasons: seasons ?? this.seasons,
      page: page ?? this.page,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
    );
  }
}

class BangumiNotifier extends Notifier<BangumiState> {
  @override
  BangumiState build() {
    Future.microtask(() => loadInitial());
    return const BangumiState(isLoading: true);
  }

  BangumiRepository get _repository => ref.read(bangumiRepositoryProvider);

  Future<void> loadInitial() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final list = await _repository.fetchSeasonList(page: 1);
      state = state.copyWith(
        seasons: list,
        page: 1,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '获取番剧列表失败: $e',
      );
    }
  }

  Future<void> refresh() async {
    state = state.copyWith(isRefreshing: true, error: null);
    try {
      final list = await _repository.fetchSeasonList(page: 1);
      state = state.copyWith(
        seasons: list,
        page: 1,
        isRefreshing: false,
      );
    } catch (e) {
      state = state.copyWith(
        isRefreshing: false,
        error: '刷新番剧列表失败: $e',
      );
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || state.isLoading) return;
    state = state.copyWith(isLoadingMore: true);
    final nextPage = state.page + 1;
    try {
      final list = await _repository.fetchSeasonList(page: nextPage);
      state = state.copyWith(
        seasons: [...state.seasons, ...list],
        page: nextPage,
        isLoadingMore: false,
      );
    } catch (_) {
      state = state.copyWith(isLoadingMore: false);
    }
  }
}

final bangumiFeedProvider =
    NotifierProvider<BangumiNotifier, BangumiState>(BangumiNotifier.new);

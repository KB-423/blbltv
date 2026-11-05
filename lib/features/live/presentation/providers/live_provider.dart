import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/live_room_item_model.dart';
import '../../data/repositories/live_repository.dart';

class LiveState {
  final List<LiveRoomItemModel> rooms;
  final int page;
  final bool isLoading;
  final bool isRefreshing;
  final bool isLoadingMore;
  final String? error;

  const LiveState({
    this.rooms = const [],
    this.page = 1,
    this.isLoading = false,
    this.isRefreshing = false,
    this.isLoadingMore = false,
    this.error,
  });

  LiveState copyWith({
    List<LiveRoomItemModel>? rooms,
    int? page,
    bool? isLoading,
    bool? isRefreshing,
    bool? isLoadingMore,
    String? error,
  }) {
    return LiveState(
      rooms: rooms ?? this.rooms,
      page: page ?? this.page,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
    );
  }
}

class LiveNotifier extends Notifier<LiveState> {
  @override
  LiveState build() {
    Future.microtask(() => loadInitial());
    return const LiveState(isLoading: true);
  }

  LiveRepository get _repository => ref.read(liveRepositoryProvider);

  Future<void> loadInitial() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final list = await _repository.fetchLiveRooms(page: 1);
      state = state.copyWith(
        rooms: list,
        page: 1,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '获取直播大厅数据失败: $e',
      );
    }
  }

  Future<void> refresh() async {
    state = state.copyWith(isRefreshing: true, error: null);
    try {
      final list = await _repository.fetchLiveRooms(page: 1);
      state = state.copyWith(
        rooms: list,
        page: 1,
        isRefreshing: false,
      );
    } catch (e) {
      state = state.copyWith(
        isRefreshing: false,
        error: '刷新直播大厅失败: $e',
      );
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || state.isLoading) return;
    state = state.copyWith(isLoadingMore: true);
    final nextPage = state.page + 1;
    try {
      final list = await _repository.fetchLiveRooms(page: nextPage);
      state = state.copyWith(
        rooms: [...state.rooms, ...list],
        page: nextPage,
        isLoadingMore: false,
      );
    } catch (_) {
      state = state.copyWith(isLoadingMore: false);
    }
  }
}

final liveFeedProvider =
    NotifierProvider<LiveNotifier, LiveState>(LiveNotifier.new);

import '../../../../models/video/video_item_model.dart';

/// 搜索功能状态定义
class SearchState {
  final String keyword;
  final List<String> hotWords;
  final List<VideoItemModel> videos;
  final int page;
  final int numPages;
  final int numResults;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final bool hasSearched;
  final String order;

  const SearchState({
    this.keyword = '',
    this.hotWords = const [],
    this.videos = const [],
    this.page = 1,
    this.numPages = 0,
    this.numResults = 0,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.hasSearched = false,
    this.order = 'totalrank',
  });

  bool get hasMore => page < numPages;

  SearchState copyWith({
    String? keyword,
    List<String>? hotWords,
    List<VideoItemModel>? videos,
    int? page,
    int? numPages,
    int? numResults,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    bool? hasSearched,
    String? order,
  }) {
    return SearchState(
      keyword: keyword ?? this.keyword,
      hotWords: hotWords ?? this.hotWords,
      videos: videos ?? this.videos,
      page: page ?? this.page,
      numPages: numPages ?? this.numPages,
      numResults: numResults ?? this.numResults,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      hasSearched: hasSearched ?? this.hasSearched,
      order: order ?? this.order,
    );
  }
}

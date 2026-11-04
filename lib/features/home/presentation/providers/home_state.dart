import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../models/video/video_item_model.dart';

part 'generated/home_state.freezed.dart';

/// 首页推荐流状态模型
@freezed
abstract class HomeFeedState with _$HomeFeedState {
  const factory HomeFeedState({
    @Default(<VideoItemModel>[]) List<VideoItemModel> videos,
    @Default(true) bool isLoading,
    @Default(false) bool isRefreshing,
    @Default(false) bool isLoadingMore,
    @Default(true) bool hasMore,
    String? error,
    @Default(1) int freshIdx,
  }) = _HomeFeedState;
}

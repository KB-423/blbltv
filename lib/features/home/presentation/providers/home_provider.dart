import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/video/video_item_model.dart';
import '../../data/repositories/home_repository.dart';

/// 首页推荐视频状态管理器
class HomeFeedNotifier extends AsyncNotifier<List<VideoItemModel>> {
  @override
  Future<List<VideoItemModel>> build() async {
    final repository = ref.read(homeRepositoryProvider);
    return repository.fetchRecommendVideos();
  }

  /// 刷新推荐流
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(homeRepositoryProvider);
      return repository.fetchRecommendVideos();
    });
  }
}

final homeFeedProvider =
    AsyncNotifierProvider<HomeFeedNotifier, List<VideoItemModel>>(
  HomeFeedNotifier.new,
);


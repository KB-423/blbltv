import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../models/video/video_item_model.dart';

/// 首页推荐数据仓库
class HomeRepository {
  final ApiClient _apiClient;

  HomeRepository(this._apiClient);

  /// 获取首页推荐视频列表 (分页/刷新)
  Future<List<VideoItemModel>> fetchRecommendVideos({
    required int freshIdx,
    int pageSize = 16,
  }) async {
    try {
      final response = await _apiClient.getWbi<Map<String, dynamic>>(
        ApiConstants.recommendFeedWeb,
        queryParameters: {
          'version': 1,
          'feed_version': 'V8',
          'homepage_ver': 1,
          'ps': pageSize,
          'fresh_idx': freshIdx,
          'brush': freshIdx,
          'fresh_type': 4,
        },
      );

      final data = response.data;
      if (data != null && data['code'] == 0 && data['data'] != null) {
        final List<dynamic> items = data['data']['item'] ?? [];
        final List<VideoItemModel> result = [];

        for (final item in items) {
          if (item is Map<String, dynamic>) {
            // 过滤常规视频稿件 (av)
            final String goto = item['goto']?.toString() ?? '';
            final String bvid = item['bvid']?.toString() ?? '';
            if ((goto == 'av' || goto.isEmpty) && bvid.isNotEmpty) {
              result.add(VideoItemModel.fromJson(item));
            }
          }
        }

        if (result.isNotEmpty) {
          return result;
        }
      }
    } catch (e) {
      debugPrint('[HomeRepository] 获取真实推荐失败, 启用大屏演示数据: $e');
    }

    // 网络不可达或未登录时，生成高质量演示数据保证 TV 端流畅调试
    return _getFallbackVideos(freshIdx: freshIdx, count: pageSize);
  }

  /// 本地演示兜底视频列表（根据 freshIdx 生成不同批次内容）
  List<VideoItemModel> _getFallbackVideos({
    required int freshIdx,
    required int count,
  }) {
    final baseOffset = (freshIdx - 1) * count;
    final List<String> sampleCovers = [
      'https://i0.hdslb.com/bfs/archive/4b6da93c0429712a326ff1faef844a47ef00195e.jpg',
      'https://i0.hdslb.com/bfs/archive/cb22f25fcdddc8930b2089694e9f5509ca8ae101.jpg',
      'https://i0.hdslb.com/bfs/archive/84370df44fcbfa5c7b39a3f2db7265ca5957d341.jpg',
      'https://i0.hdslb.com/bfs/archive/33918b9cebb0ec538965ef82bcfa73c2a37f2fae.jpg',
    ];

    return List.generate(count, (index) {
      final itemIndex = baseOffset + index + 1;
      final coverUrl = sampleCovers[index % sampleCovers.length];

      return VideoItemModel(
        id: 10000 + itemIndex,
        bvid: 'BV1${freshIdx}x411c$index',
        cid: 20000 + itemIndex,
        title: '【第 $freshIdx 批推荐】Bili for TV 大屏沉浸式体验精选视频 #$itemIndex',
        pic: coverUrl,
        duration: 120 + (index * 37) % 600,
        owner: VideoOwner(
          mid: 10000 + (index % 5),
          name: 'TV演示创作者_${(index % 5) + 1}',
          face: '',
        ),
        stat: VideoStat(
          view: itemIndex * 15420,
          danmaku: itemIndex * 112,
          like: itemIndex * 890,
        ),
        rcmdReason: freshIdx == 1 && index < 2 ? '热门精选' : null,
      );
    });
  }
}

/// Riverpod Provider
final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return HomeRepository(client);
});

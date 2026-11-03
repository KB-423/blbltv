import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../models/video/video_item_model.dart';

/// 首页数据仓库
class HomeRepository {
  final ApiClient _apiClient;

  HomeRepository(this._apiClient);

  /// 获取首页推荐视频列表
  Future<List<VideoItemModel>> fetchRecommendVideos({int pageSize = 16}) async {
    try {
      final response = await _apiClient.getWbi<Map<String, dynamic>>(
        ApiConstants.recommendFeedWeb,
        queryParameters: {
          'ps': pageSize,
          'fresh_type': 3,
        },
      );

      final data = response.data;
      if (data != null && data['code'] == 0 && data['data'] != null) {
        final List<dynamic> items = data['data']['item'] ?? [];
        return items
            .map((item) => VideoItemModel.fromJson(item as Map<String, dynamic>))
            .where((v) => v.bvid.isNotEmpty)
            .toList();
      }
    } catch (e) {
      debugPrint('[HomeRepository] 获取推荐失败: $e');
    }

    // 若网络不可达或接口限制，返回演示数据保证 TV UI 可正常浏览
    return _getFallbackVideos();
  }

  /// 本地演示兜底视频列表
  List<VideoItemModel> _getFallbackVideos() {
    return List.generate(
      12,
      (index) => VideoItemModel(
        id: 1000 + index,
        bvid: 'BV1xx411c7m$index',
        cid: 2000 + index,
        title: '【技术交流演示】Bili for TV 大屏沉浸式客户端体验 第 ${index + 1} 期',
        pic: 'https://i0.hdslb.com/bfs/archive/4b6da93c0429712a326ff1faef844a47ef00195e.jpg',
        duration: 180 + index * 45,
        owner: VideoOwner(
          mid: 10001,
          name: 'BiliTV爱好者_${index + 1}',
          face: '',
        ),
        stat: VideoStat(
          view: (index + 1) * 35000,
          danmaku: (index + 1) * 230,
          like: (index + 1) * 1200,
        ),
      ),
    );
  }
}

/// Riverpod Provider
final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return HomeRepository(client);
});


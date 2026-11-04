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
      // 请求数量留有冗余 (例如申请 24 条以对冲直播/推广广告过滤损耗)，确保填满完整行
      final int requestPs = (pageSize <= 12) ? 18 : 24;

      final response = await _apiClient.getWbi<Map<String, dynamic>>(
        ApiConstants.recommendFeedWeb,
        queryParameters: {
          'version': 1,
          'feed_version': 'V8',
          'homepage_ver': 1,
          'ps': requestPs,
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

        // 动态计算完整行卡片数：大屏 4 列网格必须保证数量为 4 的整数倍，消除最后一行半截排版缺陷
        final int alignedCount = (result.length ~/ 4) * 4;
        final int targetCount =
            alignedCount >= pageSize ? pageSize : alignedCount;

        return targetCount > 0 ? result.take(targetCount).toList() : result;
      }

      throw Exception(
        data?['message'] ?? '获取推荐失败: 接口返回异常状态 (code: ${data?['code']})',
      );
    } catch (e) {
      debugPrint('[HomeRepository] 获取真实推荐失败: $e');
      rethrow;
    }
  }
}

/// Riverpod Provider
final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return HomeRepository(client);
});

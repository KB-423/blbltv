import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../models/video/video_item_model.dart';

/// 热门视频数据仓库 (全量真实官方接口，零Mock)
class PopularRepository {
  final ApiClient _apiClient;

  PopularRepository(this._apiClient);

  /// 分页获取综合热门视频流
  Future<List<VideoItemModel>> fetchPopularVideos({
    int pn = 1,
    int ps = 20,
  }) async {
    try {
      final res = await _apiClient.get<Map<String, dynamic>>(
        ApiConstants.popularVideos,
        queryParameters: {
          'pn': pn,
          'ps': ps,
        },
      );

      final data = res.data;
      if (data != null && data['code'] == 0 && data['data'] != null) {
        final list = data['data']['list'] as List<dynamic>? ?? [];
        return list
            .map((item) => VideoItemModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      throw Exception(
        data?['message'] ?? '获取热门视频失败 (code: ${data?['code']})',
      );
    } catch (e) {
      debugPrint('[PopularRepository] 获取热门视频流失败: $e');
      rethrow;
    }
  }
}

final popularRepositoryProvider = Provider<PopularRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return PopularRepository(client);
});

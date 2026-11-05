import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/bangumi_season_model.dart';

/// 追番与影视数据仓库 (全量真实官方接口，零Mock)
class BangumiRepository {
  final ApiClient _apiClient;

  BangumiRepository(this._apiClient);

  /// 分页获取番剧/影视季度索引列表
  Future<List<BangumiSeasonModel>> fetchSeasonList({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final res = await _apiClient.get<Map<String, dynamic>>(
        ApiConstants.bangumiSeasonIndex,
        queryParameters: {
          'season_type': 1, // 1: 番剧
          'pagesize': pageSize,
          'page': page,
          'order': 3, // 追番人数排序
          'st': 1,
          'type': 1,
        },
      );

      final data = res.data;
      if (data != null && data['code'] == 0 && data['data'] != null) {
        final list = data['data']['list'] as List<dynamic>? ?? [];
        return list
            .map((item) =>
                BangumiSeasonModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      throw Exception(
        data?['message'] ?? '获取番剧列表失败 (code: ${data?['code']})',
      );
    } catch (e) {
      debugPrint('[BangumiRepository] 获取番剧索引失败: $e');
      rethrow;
    }
  }
}

final bangumiRepositoryProvider = Provider<BangumiRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return BangumiRepository(client);
});

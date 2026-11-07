import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/bangumi_episode_model.dart';
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

  /// 获取番剧季度明细 (解析剧集列表与第一集 bvid，用于一键起播)
  Future<Map<String, dynamic>> fetchSeasonDetail(int seasonId) async {
    try {
      final res = await _apiClient.get<Map<String, dynamic>>(
        ApiConstants.bangumiSeasonInfo,
        queryParameters: {
          'season_id': seasonId,
        },
      );

      final data = res.data;
      if (data != null && data['code'] == 0 && data['result'] != null) {
        return Map<String, dynamic>.from(data['result'] as Map);
      }

      throw Exception(
        data?['message'] ?? '获取番剧详情失败 (code: ${data?['code']})',
      );
    } catch (e) {
      debugPrint('[BangumiRepository] 获取番剧详情失败: $e');
      rethrow;
    }
  }

  /// 获取番剧剧集列表与季度标题
  Future<(String, List<BangumiEpisodeModel>)> fetchSeasonEpisodes(
      int seasonId) async {
    final detail = await fetchSeasonDetail(seasonId);
    final seasonTitle = detail['season_title'] as String? ??
        detail['title'] as String? ??
        '番剧播放';
    final rawList = detail['episodes'] as List<dynamic>? ?? [];
    final episodes = rawList
        .map((e) =>
            BangumiEpisodeModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    return (seasonTitle, episodes);
  }
}

final bangumiRepositoryProvider = Provider<BangumiRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return BangumiRepository(client);
});

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../models/video/video_item_model.dart';

/// 搜索功能数据仓库
class SearchRepository {
  final ApiClient _apiClient;

  SearchRepository(this._apiClient);

  /// 获取实时热搜关键词列表
  Future<List<String>> fetchHotSearchWords() async {
    try {
      final res = await _apiClient.dio.get<Map<String, dynamic>>(
        ApiConstants.hotSearchList,
      );

      final data = res.data;
      if (data != null && data['code'] == 0 && data['list'] != null) {
        final List<dynamic> list = data['list'];
        return list
            .map((item) {
              if (item is Map) {
                return (item['show_name'] ?? item['keyword'])?.toString() ?? '';
              }
              return '';
            })
            .where((w) => w.isNotEmpty)
            .take(12)
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('[SearchRepository] 获取热搜词失败: $e');
      return [];
    }
  }

  /// 搜索视频
  /// [page] 分页页码，从 1 开始
  /// [order] 排序方式：totalrank (综合排序), click (最多点击), pubdate (最新发布), dm (最多弹幕)
  Future<({List<VideoItemModel> videos, int numPages, int numResults})>
      searchVideos({
    required String keyword,
    int page = 1,
    String order = 'totalrank',
  }) async {
    try {
      final res = await _apiClient.getWbi<Map<String, dynamic>>(
        ApiConstants.searchByType,
        queryParameters: {
          'search_type': 'video',
          'keyword': keyword,
          'page': page,
          'order': order,
        },
      );

      final data = res.data;
      if (data != null && data['code'] == 0 && data['data'] != null) {
        final searchData = data['data'] as Map<String, dynamic>;
        final int numPages = searchData['numPages'] as int? ?? 0;
        final int numResults = searchData['numResults'] as int? ?? 0;

        final List<dynamic> resultList = searchData['result'] ?? [];
        final List<VideoItemModel> videos = [];

        for (final item in resultList) {
          if (item is Map<String, dynamic>) {
            final bvid = item['bvid']?.toString() ?? '';
            if (bvid.isNotEmpty) {
              videos.add(VideoItemModel.fromSearchJson(item));
            }
          }
        }

        // 4 列大屏网格对齐：如果是中间分页，确保是 4 的整数倍
        final int alignedCount = (videos.length ~/ 4) * 4;
        final finalVideos = (alignedCount > 0 && page < numPages)
            ? videos.take(alignedCount).toList()
            : videos;

        return (
          videos: finalVideos,
          numPages: numPages,
          numResults: numResults,
        );
      }

      throw Exception(
        data?['message'] ?? '搜索失败: 接口返回异常状态 (code: ${data?['code']})',
      );
    } catch (e) {
      debugPrint('[SearchRepository] 搜索视频失败: $e');
      rethrow;
    }
  }
}

/// Riverpod Provider
final searchRepositoryProvider = Provider<SearchRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return SearchRepository(client);
});

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/live_room_item_model.dart';

/// 直播大厅数据仓库 (真实 B 站官方接口，零 Mock)
class LiveRepository {
  final ApiClient _apiClient;

  LiveRepository(this._apiClient);

  /// 获取直播大厅推荐直播间列表
  Future<List<LiveRoomItemModel>> fetchLiveRooms({
    int page = 1,
  }) async {
    try {
      final res = await _apiClient.getWbi<Map<String, dynamic>>(
        ApiConstants.liveList,
        queryParameters: {
          'platform': 'web',
          'page': page,
          'page_size': 30,
        },
      );

      final data = res.data;
      if (data != null && data['code'] == 0 && data['data'] != null) {
        final list = data['data']['list'] as List<dynamic>? ?? [];
        return list
            .map((item) =>
                LiveRoomItemModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      throw Exception(
        data?['message'] ?? '获取直播列表失败 (code: ${data?['code']})',
      );
    } catch (e) {
      debugPrint('[LiveRepository] 获取直播列表异常: $e');
      rethrow;
    }
  }
}

final liveRepositoryProvider = Provider<LiveRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return LiveRepository(client);
});

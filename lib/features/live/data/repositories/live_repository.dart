import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/live_room_item_model.dart';

/// 直播大厅数据仓库 (真实 B 站官方接口，零 Mock)
class LiveRepository {
  final ApiClient _apiClient;

  LiveRepository(this._apiClient);

  /// 获取直播大厅推荐直播间列表 (聚合推荐房间与各大分区热门房间，去重呈现)
  Future<List<LiveRoomItemModel>> fetchLiveRooms({
    int page = 1,
  }) async {
    try {
      final res = await _apiClient.getWbi<Map<String, dynamic>>(
        ApiConstants.liveList,
        queryParameters: {
          'platform': 'web',
          'web_location': '444.7',
          'page': page,
          'page_size': 30,
        },
      );

      final data = res.data;
      if (data != null && data['code'] == 0 && data['data'] != null) {
        final d = data['data'];
        final List<dynamic> rawList = [];

        // 1. 提取推荐直播间流
        final dynamic recommend = d['recommend_room_list'];
        if (recommend is List) {
          rawList.addAll(recommend);
        }

        // 2. 提取各大分区（网游、手游、单机、娱乐等）的直播间列表
        final dynamic modules = d['room_list'];
        if (modules is List) {
          for (final dynamic module in modules) {
            if (module is Map && module['list'] is List) {
              rawList.addAll(module['list'] as List);
            }
          }
        }

        final List<LiveRoomItemModel> results = [];
        final Set<int> seenRoomIds = {};

        for (final dynamic item in rawList) {
          if (item is Map) {
            final map = Map<String, dynamic>.from(item);
            final rawRoomId = map['roomid'] ?? map['room_id'];
            final int rId = rawRoomId is int
                ? rawRoomId
                : (int.tryParse(rawRoomId?.toString() ?? '') ?? 0);

            if (rId > 0 && seenRoomIds.add(rId)) {
              map['roomid'] = rId;
              results.add(LiveRoomItemModel.fromJson(map));
            }
          }
        }

        return results;
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

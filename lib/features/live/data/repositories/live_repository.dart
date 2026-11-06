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
      dynamic res;
      try {
        res = await _apiClient.getWbi<Map<String, dynamic>>(
          ApiConstants.liveList,
          queryParameters: {
            'platform': 'web',
            'web_location': '444.7',
          },
        );
      } catch (wbiErr) {
        debugPrint('[LiveRepository] Wbi 获取直播列表超时/异常，平滑降级标准直连: $wbiErr');
        res = await _apiClient.get<Map<String, dynamic>>(
          ApiConstants.liveList,
          queryParameters: {
            'platform': 'web',
            'web_location': '444.7',
          },
        );
      }

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

  /// 获取直播间播放流直链 (优先选取 HLS/fmp4，其次 FLV)
  Future<String> fetchLivePlayUrl(int roomId, {int? qn}) async {
    try {
      final res = await _apiClient.get<Map<String, dynamic>>(
        ApiConstants.livePlayInfo,
        queryParameters: {
          'room_id': roomId,
          'protocol': '0,1',
          'format': '0,1,2',
          'codec': '0,1',
          'qn': qn ?? 10000,
          'platform': 'web',
          'ptype': 8,
          'dolby': 5,
          'panorama': 1,
        },
      );

      final data = res.data;
      if (data != null && data['code'] == 0 && data['data'] != null) {
        final playurlInfo = data['data']['playurl_info'];
        if (playurlInfo != null && playurlInfo['playurl'] != null) {
          final streamList =
              playurlInfo['playurl']['stream'] as List<dynamic>? ?? [];

          String? hlsUrl;
          String? flvUrl;

          for (final stream in streamList) {
            if (stream is! Map) continue;
            final protocol = stream['protocol_name']?.toString() ?? '';
            final formatList = stream['format'] as List<dynamic>? ?? [];

            for (final format in formatList) {
              if (format is! Map) continue;
              final formatName = format['format_name']?.toString() ?? '';
              final codecList = format['codec'] as List<dynamic>? ?? [];

              for (final codec in codecList) {
                if (codec is! Map) continue;
                final baseUrl = codec['base_url']?.toString() ?? '';
                final urlInfoList = codec['url_info'] as List<dynamic>? ?? [];

                if (urlInfoList.isNotEmpty && urlInfoList[0] is Map) {
                  final urlInfo = urlInfoList[0] as Map;
                  final host = urlInfo['host']?.toString() ?? '';
                  final extra = urlInfo['extra']?.toString() ?? '';
                  final fullUrl = '$host$baseUrl$extra';

                  if (protocol == 'http_hls' ||
                      formatName == 'fmp4' ||
                      formatName == 'ts') {
                    hlsUrl ??= fullUrl;
                  } else {
                    flvUrl ??= fullUrl;
                  }
                }
              }
            }
          }

          final finalUrl = hlsUrl ?? flvUrl;
          if (finalUrl != null && finalUrl.isNotEmpty) {
            return finalUrl;
          }
        }
      }

      throw Exception(
        data?['message'] ?? '获取直播间播放流失败 (code: ${data?['code']})',
      );
    } catch (e) {
      debugPrint('[LiveRepository] 获取直播流异常: $e');
      rethrow;
    }
  }
}

final liveRepositoryProvider = Provider<LiveRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return LiveRepository(client);
});

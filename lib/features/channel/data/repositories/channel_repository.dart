import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../models/video/video_item_model.dart';

/// 频道与细分频道视频数据仓库 (全量真实官方接口，零Mock)
class ChannelRepository {
  final ApiClient _apiClient;

  ChannelRepository(this._apiClient);

  static int _parseDuration(dynamic duration) {
    if (duration == null) return 0;
    if (duration is int) return duration;
    if (duration is num) return duration.toInt();
    if (duration is String) {
      final parts = duration.split(':');
      if (parts.length == 2) {
        final m = int.tryParse(parts[0]) ?? 0;
        final s = int.tryParse(parts[1]) ?? 0;
        return m * 60 + s;
      } else if (parts.length == 3) {
        final h = int.tryParse(parts[0]) ?? 0;
        final m = int.tryParse(parts[1]) ?? 0;
        final s = int.tryParse(parts[2]) ?? 0;
        return h * 3600 + m * 60 + s;
      }
      return int.tryParse(duration) ?? 0;
    }
    return 0;
  }

  /// 获取指定分区/细分频道的视频列表 (官方 ranking/region 接口)
  Future<List<VideoItemModel>> fetchChannelVideos({
    required int rid,
    int day = 3,
  }) async {
    try {
      final res = await _apiClient.get<Map<String, dynamic>>(
        ApiConstants.channelRankingRegion,
        queryParameters: {
          'rid': rid,
          'day': day,
        },
      );

      final data = res.data;
      if (data != null && data['code'] == 0 && data['data'] != null) {
        final rawList = data['data'] as List<dynamic>? ?? [];
        return rawList.map((raw) {
          final item = raw as Map<String, dynamic>;
          final durationSec = _parseDuration(item['duration']);
          final play = item['play'] as int? ?? 0;
          final favorites = item['favorites'] as int? ?? 0;
          final coins = item['coins'] as int? ?? 0;
          final review = item['review'] as int? ?? 0;

          return VideoItemModel(
            id: int.tryParse(item['aid']?.toString() ?? '0') ?? 0,
            bvid: item['bvid']?.toString() ?? '',
            title: item['title']?.toString() ?? '',
            pic: item['pic']?.toString() ?? '',
            duration: durationSec,
            owner: VideoOwner(
              mid: item['mid'] as int? ?? 0,
              name: item['author']?.toString() ?? '',
              face: '',
            ),
            stat: VideoStat(
              view: play,
              favorite: favorites,
              coin: coins,
              reply: review,
            ),
            rcmdReason: item['typename']?.toString(),
          );
        }).toList();
      }

      throw Exception(
        data?['message'] ?? '获取频道视频失败 (code: ${data?['code']})',
      );
    } catch (e) {
      debugPrint('[ChannelRepository] 获取细分频道(rid: $rid)视频失败: $e');
      rethrow;
    }
  }
}

final channelRepositoryProvider = Provider<ChannelRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return ChannelRepository(client);
});

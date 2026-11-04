import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../models/video/play_url_model.dart';

/// 视频播放器数据仓库
class PlayerRepository {
  final ApiClient _apiClient;

  PlayerRepository(this._apiClient);

  /// 获取视频详情及首 P 的 cid
  Future<({String title, int cid, int durationSeconds})> fetchVideoDetail(
    String bvid,
  ) async {
    try {
      final res = await _apiClient.get<Map<String, dynamic>>(
        ApiConstants.videoDetail,
        queryParameters: {'bvid': bvid},
      );

      final data = res.data;
      if (data != null && data['code'] == 0 && data['data'] != null) {
        final detail = data['data'];
        final title = detail['title'] as String? ?? 'Bilibili 视频';
        final cid = detail['cid'] as int? ??
            (detail['pages'] != null && (detail['pages'] as List).isNotEmpty
                ? detail['pages'][0]['cid'] as int
                : 0);
        final duration = detail['duration'] as int? ?? 0;

        if (cid == 0) {
          throw Exception('该稿件未包含有效的分P/CID信息');
        }

        return (title: title, cid: cid, durationSeconds: duration);
      }

      throw Exception(
        data?['message'] ?? '获取视频详情失败: 接口返回异常状态 (code: ${data?['code']})',
      );
    } catch (e) {
      debugPrint('[PlayerRepository] 获取视频详情失败: $e');
      rethrow;
    }
  }

  /// 获取指定清晰度的视频流播放链接与支持的清晰度列表
  /// [fnval: 4048] 开启 B 站 DASH 全规格视频流 (支持 8K, 4K, HDR, 1080P高码率, 杜比视界等)
  Future<VideoPlayInfo> fetchPlayUrl({
    required String bvid,
    required int cid,
    int qn = 120, // 默认申请高规格画质，由服务端根据会员身份自动协商下发
  }) async {
    try {
      final res = await _apiClient.getWbi<Map<String, dynamic>>(
        ApiConstants.videoPlayUrl,
        queryParameters: {
          'bvid': bvid,
          'cid': cid,
          'qn': qn,
          'fnval': 4048, // 16(DASH) + 64(HDR) + 128(4K) + 256(8K) + 512(杜比视界) + 1024(杜比全景声) + 2048(8K HDR)
          'fourk': 1,
          'fnver': 0,
        },
      );

      final data = res.data;
      if (data != null && data['code'] == 0 && data['data'] != null) {
        final playData = data['data'];
        final int currentQn = playData['quality'] as int? ?? qn;

        // 解析支持的全部清晰度列表 (按服务端排序或降序排列)
        final List<dynamic> acceptQnList = playData['accept_quality'] ?? [];
        final List<dynamic> acceptDescList =
            playData['accept_description'] ?? [];

        final List<VideoQualityItem> qualities = [];
        for (int i = 0; i < acceptQnList.length; i++) {
          final int q = acceptQnList[i] as int;
          final String desc = i < acceptDescList.length
              ? acceptDescList[i].toString()
              : _mapQnToDescription(q);
          qualities.add(VideoQualityItem(qn: q, desc: desc));
        }

        String playUrl = '';
        String audioUrl = '';
        Map<String, dynamic>? selectedVideo;

        // 1. 优先提取 DASH 音视频分离流
        if (playData['dash'] != null) {
          final dash = playData['dash'] as Map<String, dynamic>;
          final List<dynamic> videoList = dash['video'] ?? [];
          final List<dynamic> audioList = dash['audio'] ?? [];

          // 匹配与目标清晰度最贴合的视频轨
          for (final v in videoList) {
            if (v is Map<String, dynamic> && v['id'] == qn) {
              selectedVideo = v;
              break;
            }
          }
          // 若无精确匹配（如非大会员降级），选择当前可用的第一条流（通常为最高权限流）
          selectedVideo ??= videoList.isNotEmpty
              ? (videoList.first as Map<String, dynamic>)
              : null;

          if (selectedVideo != null) {
            playUrl = (selectedVideo['baseUrl'] ??
                    selectedVideo['base_url'] ??
                    (selectedVideo['backupUrl'] != null &&
                            (selectedVideo['backupUrl'] as List).isNotEmpty
                        ? selectedVideo['backupUrl'][0]
                        : ''))
                .toString();
          }

          // 提取最高品质音轨
          if (audioList.isNotEmpty && audioList.first is Map<String, dynamic>) {
            final firstAudio = audioList.first as Map<String, dynamic>;
            audioUrl = (firstAudio['baseUrl'] ??
                    firstAudio['base_url'] ??
                    (firstAudio['backupUrl'] != null &&
                            (firstAudio['backupUrl'] as List).isNotEmpty
                        ? firstAudio['backupUrl'][0]
                        : ''))
                .toString();
          }
        }

        // 2. 兜底提取 DURL 单文件流 (兼容老稿件)
        if (playUrl.isEmpty) {
          final List<dynamic>? durlList = playData['durl'];
          if (durlList != null && durlList.isNotEmpty) {
            playUrl = durlList[0]['url'] as String? ?? '';
          }
        }

        if (playUrl.isNotEmpty) {
          final int actualQn = (selectedVideo != null && selectedVideo['id'] is int)
              ? (selectedVideo['id'] as int)
              : currentQn;

          return VideoPlayInfo(
            bvid: bvid,
            cid: cid,
            playUrl: playUrl,
            audioUrl: audioUrl,
            currentQn: actualQn,
            qualities: qualities,
          );
        }

        throw Exception('接口未返回可用的视频播放流地址 (dash/durl 为空)');
      }

      throw Exception(
        data?['message'] ?? '获取视频播放地址失败: 接口返回异常状态 (code: ${data?['code']})',
      );
    } catch (e) {
      debugPrint('[PlayerRepository] 获取播放链接失败: $e');
      rethrow;
    }
  }

  /// 清晰度数值映射描述
  String _mapQnToDescription(int qn) {
    switch (qn) {
      case 127:
        return '8K 超高清';
      case 126:
        return '杜比视界';
      case 125:
        return 'HDR 真彩';
      case 120:
        return '4K 超清';
      case 116:
        return '1080P60 高帧率';
      case 112:
        return '1080P 高码率';
      case 80:
        return '1080P 高清';
      case 74:
        return '720P60 高帧率';
      case 64:
        return '720P 高清';
      case 32:
        return '480P 清晰';
      case 16:
        return '360P 流畅';
      default:
        return '${qn}P';
    }
  }
}

/// Riverpod Provider
final playerRepositoryProvider = Provider<PlayerRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return PlayerRepository(client);
});

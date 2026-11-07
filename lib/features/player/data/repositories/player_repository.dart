import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/video_url_resolver.dart';
import '../../../../models/video/play_url_model.dart';
import '../../../../models/video/video_part_model.dart';

/// 视频播放器数据仓库
class PlayerRepository {
  final ApiClient _apiClient;

  PlayerRepository(this._apiClient);

  /// 获取多 P 选集分 P 列表
  Future<List<VideoPartItem>> fetchPageList(String bvid) async {
    try {
      final res = await _apiClient.get<Map<String, dynamic>>(
        ApiConstants.playerPageList,
        queryParameters: {'bvid': bvid},
      );
      final data = res.data;
      if (data != null && data['code'] == 0 && data['data'] is List) {
        final list = data['data'] as List;
        return list
            .map((item) => VideoPartItem.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('[PlayerRepository] 获取分P列表异常: $e');
      return [];
    }
  }

  /// 获取实时在线观看人数统计
  Future<String> fetchOnlineTotal({
    required String bvid,
    required int cid,
  }) async {
    try {
      final res = await _apiClient.get<Map<String, dynamic>>(
        ApiConstants.onlineTotal,
        queryParameters: {'bvid': bvid, 'cid': cid},
      );
      final data = res.data;
      if (data != null && data['code'] == 0 && data['data'] != null) {
        final total = data['data']['total'] ?? data['data']['count'];
        if (total != null) {
          return total.toString();
        }
      }
      return '';
    } catch (e) {
      debugPrint('[PlayerRepository] 获取在线人数失败: $e');
      return '';
    }
  }

  /// 查询用户是否已对该视频点赞
  Future<bool> fetchHasLike(String bvid) async {
    try {
      final res = await _apiClient.get<Map<String, dynamic>>(
        ApiConstants.hasLikeVideo,
        queryParameters: {'bvid': bvid},
      );
      final data = res.data;
      if (data != null && data['code'] == 0) {
        return (data['data'] as int? ?? 0) == 1;
      }
      return false;
    } catch (e) {
      debugPrint('[PlayerRepository] 获取点赞状态失败: $e');
      return false;
    }
  }

  /// 点赞 / 取消点赞操作
  Future<bool> toggleLike({
    required String bvid,
    required bool currentLiked,
  }) async {
    try {
      final csrf = await _apiClient.getCsrfToken();
      final res = await _apiClient.post<Map<String, dynamic>>(
        ApiConstants.likeVideo,
        queryParameters: {
          'bvid': bvid,
          'like': currentLiked ? 2 : 1, // 1点赞，2取消点赞
          if (csrf.isNotEmpty) 'csrf': csrf,
        },
      );
      final data = res.data;
      return data != null && data['code'] == 0;
    } catch (e) {
      debugPrint('[PlayerRepository] 点赞操作失败: $e');
      return false;
    }
  }

  /// 一键三连操作 (点赞 + 投币 + 收藏)
  Future<bool> doTriple(String bvid) async {
    try {
      final csrf = await _apiClient.getCsrfToken();
      final res = await _apiClient.post<Map<String, dynamic>>(
        ApiConstants.tripleLike,
        queryParameters: {
          'bvid': bvid,
          if (csrf.isNotEmpty) 'csrf': csrf,
        },
      );
      final data = res.data;
      return data != null && data['code'] == 0;
    } catch (e) {
      debugPrint('[PlayerRepository] 一键三连失败: $e');
      return false;
    }
  }

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
  /// [fnval: 3024] 开启 DASH(16) + HDR(64) + 4K(128) + 杜比音效(256) + 杜比视界(512) + AV1(2048)
  /// 彻底排除 bit 1024 (8K)，避免电视硬件解码器因显存限制 (4096x2304) 报 ERROR_NO_MEMORY 导致黑屏
  Future<VideoPlayInfo> fetchPlayUrl({
    required String bvid,
    required int cid,
    int qn = 120, // 默认申请高规格画质，由服务端根据会员身份自动协商下发
  }) async {
    // 电视 SOC 硬件硬解上限为 4K (4096x2304)，超出部分强制安全限制在 120(4K) / 125(HDR)
    final int safeQn = (qn == 127) ? 120 : qn;
    try {
      final res = await _apiClient.getWbi<Map<String, dynamic>>(
        ApiConstants.videoPlayUrl,
        queryParameters: {
          'bvid': bvid,
          'cid': cid,
          'qn': safeQn,
          'fnval': 3024, // 16(DASH) + 64(HDR) + 128(4K) + 256(杜比音效) + 512(杜比视界) + 2048(AV1) - 排除 1024(8K)
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

        // 提取全部可用 DASH 轨
        final List<dynamic> rawVideoList =
            (playData['dash'] != null && playData['dash']['video'] is List)
                ? (playData['dash']['video'] as List)
                : const [];

        // 统计各清晰度是否有硬件支持的流轨 (排除超过 4K 60fps 硬件硬解吞吐极限的超规格轨)
        final Set<int> hardwareSupportedQns = {};
        for (final v in rawVideoList) {
          if (v is Map<String, dynamic> && isHardwareSupported(v)) {
            final id = v['id'] as int? ?? 0;
            if (id > 0) {
              hardwareSupportedQns.add(id);
            }
          }
        }

        final List<VideoQualityItem> qualities = [];
        for (int i = 0; i < acceptQnList.length; i++) {
          final int q = acceptQnList[i] as int;
          final String desc = i < acceptDescList.length
              ? acceptDescList[i].toString()
              : _mapQnToDescription(q);

          // 8K(127) 或该清晰度无电视硬件硬解轨时标记为不支持
          final bool isSupported = q != 127 &&
              (hardwareSupportedQns.isEmpty || hardwareSupportedQns.contains(q));
          qualities.add(VideoQualityItem(
            qn: q,
            desc: desc,
            isHardwareSupported: isSupported,
          ));
        }

        String playUrl = '';
        String audioUrl = '';
        Map<String, dynamic>? selectedVideo;

        // 1. 优先提取 DASH 音视频分离流
        if (playData['dash'] != null) {
          final dash = playData['dash'] as Map<String, dynamic>;
          final List<dynamic> videoList = dash['video'] ?? [];
          final List<dynamic> audioList = dash['audio'] ?? [];

          // 核心优化：按硬件解码友好度选择最佳编码轨 (HEVC > AVC > AV1)
          // 彻底解决 B 站 4K 默认下发 AV1 导致移动端/电视因缺少 AV1 硬解走 CPU 软解严重掉帧的问题
          selectedVideo = _selectBestCodecTrack(videoList, qn);

          if (selectedVideo != null) {
            // 通过 VideoUrlResolver 剔除并过滤 MCDN / PCDN 节点，重写为官方高速镜像
            playUrl = VideoUrlResolver.resolveUrl(selectedVideo);
          }

          // 提取最高品质音轨并过滤 MCDN
          if (audioList.isNotEmpty && audioList.first is Map<String, dynamic>) {
            final firstAudio = audioList.first as Map<String, dynamic>;
            audioUrl = VideoUrlResolver.resolveUrl(firstAudio);
          }
        }

        // 2. 兜底提取 DURL 单文件流 (兼容老稿件)
        if (playUrl.isEmpty) {
          final List<dynamic>? durlList = playData['durl'];
          if (durlList != null && durlList.isNotEmpty) {
            final raw = durlList[0]['url'] as String? ?? '';
            playUrl = VideoUrlResolver.cleanUrl(raw);
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

  /// 解析 B 站 DASH 流的帧率 (例如 "120.000", "60.000", "30.000", "120000/1000")
  static double _parseFrameRate(dynamic frameRate) {
    if (frameRate == null) return 0.0;
    if (frameRate is num) return frameRate.toDouble();
    final str = frameRate.toString().trim();
    if (str.isEmpty) return 0.0;
    if (str.contains('/')) {
      final parts = str.split('/');
      final num = double.tryParse(parts[0]) ?? 0.0;
      final den = double.tryParse(parts[1]) ?? 1.0;
      return den > 0 ? num / den : 0.0;
    }
    return double.tryParse(str) ?? 0.0;
  }

  /// 校验视频轨是否在电视芯片硬件硬解能力范围内 (MediaTek Pentonic MT5877/MT9655)
  /// 1. 分辨率上限: 4096x2304 (超出将导致 MediaCodec 显存耗尽报 ERROR_NO_MEMORY)
  /// 2. 硬件吞吐量上限: 2,211,840 宏块/秒 (blocks/sec)
  ///    - 4K (3840x2160) 单帧 32,400 宏块，在 60fps 下为 1,944,000 blocks/sec (完全硬件解码流畅支持)
  ///    - 4K 120fps (如 8K 降采稿件) 达到 3,888,000 blocks/sec，硬件驱动报 ERR_CODE_FRMRATE_NOT_SUPPORT 崩溃黑屏 (过滤)
  ///    - 1080P (1920x1080) 单帧 8,160 宏块，在 120fps 下为 979,200 blocks/sec (完全硬件解码支持)
  static bool isHardwareSupported(Map<String, dynamic> track) {
    final width = track['width'] as int? ?? 0;
    final height = track['height'] as int? ?? 0;
    if (width <= 0 || height <= 0) return true;

    // 1. 分辨率硬解上限
    if (width > 4096 || height > 2304) return false;

    // 2. 吞吐性能点校验
    final fps = _parseFrameRate(track['frameRate'] ?? track['frame_rate']);
    if (fps > 0) {
      final blocksPerFrame = ((width + 15) ~/ 16) * ((height + 15) ~/ 16);
      final blocksPerSec = blocksPerFrame * fps;
      if (blocksPerSec > 2211840) {
        return false;
      }
    }
    return true;
  }

  /// 从满足目标清晰度的多个轨中，智能优选具备最高硬件硬解兼容性的编码轨
  /// 优先级策略：
  /// 1. HEVC (H.265, codecid: 12 / hvc1 / hev1 / dvh1)：得分最高 (300分)。
  ///    电视 SOC (如联发科 Pentonic MT5877/MT9655、晶晨、海思等) 具备成熟的 4K 60fps/120fps HEVC 硬解流水线。
  /// 2. 4K / 8K / HDR / 1080P60 (targetQn >= 116)：
  ///    AV1 (codecid: 13 / av01) -> 250分，AVC (codecid: 7 / avc1) -> 100分。
  ///    【核心避坑】：现代 Android TV (Android 10+) 均强制配备 4K 60fps AV1 硬件解码器 (c2.mtk.av1.decoder)，
  ///    而 AVC (H.264) 硬件解码模块上限为 Level 5.2，在 4K 60fps 超大码率下会造成高达 70%+ 的灾难性丢帧！
  /// 3. 常规清晰度 (targetQn < 116，如 1080P 30fps 及以下)：
  ///    AVC (codecid: 7) -> 250分，AV1 (codecid: 13) -> 100分，兼顾老款无 AV1 硬解的电视盒子。
  Map<String, dynamic>? _selectBestCodecTrack(
    List<dynamic> videoList,
    int targetQn,
  ) {
    for (final v in videoList) {
      if (v is Map<String, dynamic>) {
        debugPrint(
          '[PlayerRepository] 候选轨: id=${v['id']}, codecid=${v['codecid']}, frameRate=${v['frameRate'] ?? v['frame_rate']}, ${v['width']}x${v['height']}, codecs=${v['codecs']}, bandwidth=${v['bandwidth']}',
        );
      }
    }

    // 关键硬件保护：过滤超过电视芯片硬解极限 (4096x2304 / 4K 120fps 超吞吐) 的超规格视频轨
    // 彻底避免 MediaCodec 报 ERROR_NO_MEMORY 或 ERR_CODE_FRMRATE_NOT_SUPPORT 崩溃导致黑屏
    final List<Map<String, dynamic>> validTracks = [];
    for (final v in videoList) {
      if (v is Map<String, dynamic>) {
        if (!isHardwareSupported(v)) {
          debugPrint(
            '[PlayerRepository] 过滤超出硬件解码极限的超规格轨: id=${v['id']}, ${v['width']}x${v['height']}, frameRate=${v['frameRate'] ?? v['frame_rate']}, codecs=${v['codecs']}',
          );
          continue;
        }
        validTracks.add(v);
      }
    }

    if (validTracks.isEmpty) {
      // 极端兜底：如果全部轨都被过滤，回退至原列表
      for (final v in videoList) {
        if (v is Map<String, dynamic>) {
          validTracks.add(v);
        }
      }
    }

    final List<Map<String, dynamic>> matchedTracks = [];
    for (final v in validTracks) {
      if (v['id'] == targetQn) {
        matchedTracks.add(v);
      }
    }

    if (matchedTracks.isEmpty) {
      // 若无精确匹配画质，在全部可用有效轨中降级回退
      matchedTracks.addAll(validTracks);
    }

    if (matchedTracks.isEmpty) return null;

    // 评分机制：优先保障硬件解码流畅度与电视 SOC 硬解兼容性
    int getCodecScore(Map<String, dynamic> track) {
      final codecid = track['codecid'] as int? ?? 0;
      final codecs = (track['codecs'] as String? ?? '').toLowerCase();
      final trackQn = track['id'] as int? ?? targetQn;

      // 1. HEVC (H.265 / 杜比视界) -> 任何分辨率下均优先 (300分)
      if (codecid == 12 ||
          codecs.startsWith('hev') ||
          codecs.startsWith('hvc') ||
          codecs.startsWith('dvh')) {
        return 300;
      }

      // 2. 超高清 / 高帧率 (4K, 8K, HDR, 1080P60: qn >= 116)
      // 必须优先使用 AV1 硬件解码 (250分)，严禁使用 4K AVC (100分)
      if (trackQn >= 116) {
        if (codecid == 13 ||
            codecs.startsWith('av01') ||
            codecs.startsWith('av1')) {
          return 250;
        }
        if (codecid == 7 || codecid == 1 || codecs.startsWith('avc')) {
          return 100;
        }
      } else {
        // 3. 常规清晰度 (1080P 及以下)：AVC 硬解成熟轻量 (250分)，AV1 为 100分
        if (codecid == 7 || codecid == 1 || codecs.startsWith('avc')) {
          return 250;
        }
        if (codecid == 13 ||
            codecs.startsWith('av01') ||
            codecs.startsWith('av1')) {
          return 100;
        }
      }
      return 0;
    }

    matchedTracks.sort((a, b) {
      final scoreA = getCodecScore(a);
      final scoreB = getCodecScore(b);
      if (scoreA != scoreB) {
        return scoreB.compareTo(scoreA);
      }
      final bwA = a['bandwidth'] as int? ?? 0;
      final bwB = b['bandwidth'] as int? ?? 0;
      return bwB.compareTo(bwA);
    });

    final bestTrack = matchedTracks.first;
    debugPrint(
      '[PlayerRepository] 优选解码轨: qn=${bestTrack['id']}, codecid=${bestTrack['codecid']}, codecs=${bestTrack['codecs']}, bandwidth=${bestTrack['bandwidth']}',
    );
    return bestTrack;
  }

  /// 供单元测试验证解码轨优选评分策略
  @visibleForTesting
  Map<String, dynamic>? selectBestCodecTrack(
    List<dynamic> videoList,
    int targetQn,
  ) =>
      _selectBestCodecTrack(videoList, targetQn);

  /// 向 B 站官方上报播放进度与心跳，使视频正式进入用户的观看历史记录
  Future<void> reportHeartbeat({
    required String bvid,
    required int cid,
    required int playedTime,
    int duration = 0,
  }) async {
    try {
      final csrf = await _apiClient.getCsrfToken();

      await _apiClient.post<Map<String, dynamic>>(
        ApiConstants.videoHeartbeat,
        queryParameters: {
          'bvid': bvid,
          'cid': cid,
          'played_time': playedTime,
          'realtime': playedTime,
          'start_ts': DateTime.now().millisecondsSinceEpoch ~/ 1000,
          'type': 3,
          'sub_type': 0,
          if (csrf.isNotEmpty) 'csrf': csrf,
        },
        options: Options(
          sendTimeout: const Duration(seconds: 4),
          receiveTimeout: const Duration(seconds: 4),
        ),
      );
      debugPrint(
          '[PlayerRepository] 成功上报播放心跳: bvid=$bvid, playedTime=$playedTime');
    } catch (e) {
      debugPrint('[PlayerRepository] 上报播放心跳失败 (不影响播放): $e');
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

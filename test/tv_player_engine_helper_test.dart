import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:media_kit/media_kit.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bili_tv/core/constants/api_constants.dart';
import 'package:bili_tv/core/network/api_client.dart';
import 'package:bili_tv/core/storage/storage_service.dart';
import 'package:bili_tv/core/utils/tv_player_engine_helper.dart';
import 'package:bili_tv/features/player/data/repositories/player_repository.dart';

class _MockHttpAdapter implements HttpClientAdapter {
  final Future<ResponseBody> Function(RequestOptions options) handler;
  _MockHttpAdapter(this.handler);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}

class _MockPlatform {
  final Map<String, String> properties = {};

  Future<void> setProperty(String key, String value) async {
    properties[key] = value;
  }

  Future<String?> getProperty(String key) async {
    return properties[key];
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();

  group('TvPlayerEngineHelper Tests', () {
    test('configurePlatformProperties applies hardware decoding and video sync settings', () async {
      final mockPlatform = _MockPlatform();
      await TvPlayerEngineHelper.configurePlatformProperties(
        mockPlatform,
        audioUrl: 'https://test.bilivideo.cn/audio.m4s',
        isLive: false,
      );

      // 验证暂停初始化
      expect(mockPlatform.properties['pause'], 'yes');

      // 验证音画同步与丢帧模式
      expect(mockPlatform.properties['video-sync'], 'audio');
      expect(mockPlatform.properties['framedrop'], 'vo');
      expect(mockPlatform.properties['hr-seek'], 'yes');
      expect(mockPlatform.properties['hr-seek-framedrop'], 'yes');

      // 验证外挂音轨挂载
      expect(mockPlatform.properties['audio-files'], isNotNull);
      expect(mockPlatform.properties['audio-files'], contains('audio.m4s'));

      if (Platform.isAndroid) {
        // 验证 Android TV 专属 MediaCodec 直通硬解与 OpenSL ES 音频驱动
        expect(mockPlatform.properties['hwdec'], 'mediacodec');
        expect(mockPlatform.properties['hwdec-codecs'], 'all');
        expect(mockPlatform.properties['ao'], 'opensles');
        expect(mockPlatform.properties['profile'], 'fast');
        expect(mockPlatform.properties['scale'], 'bilinear');
        expect(mockPlatform.properties['deband'], 'no');
        expect(mockPlatform.properties['dither'], 'no');
      } else {
        expect(mockPlatform.properties['hwdec'], 'auto');
      }
    });

    test('configurePlatformProperties for live applies appropriate live buffer constraints', () async {
      final mockPlatform = _MockPlatform();
      await TvPlayerEngineHelper.configurePlatformProperties(
        mockPlatform,
        isLive: true,
      );

      expect(mockPlatform.properties.containsKey('pause'), isFalse);
      expect(mockPlatform.properties['demuxer-readahead-secs'], '10');
      expect(mockPlatform.properties['cache-secs'], '10');
    });

    test('createPlayer initializes player with custom bufferSize', () {
      final player = TvPlayerEngineHelper.createPlayer(bufferSize: 64 * 1024 * 1024);
      expect(player, isNotNull);
      TvPlayerEngineHelper.safeDisposePlayer(player);
    });
  });

  group('Bangumi PGC PlayUrl & Codec Parsing Tests', () {
    late StorageService storageService;
    late ApiClient apiClient;
    late PlayerRepository playerRepository;

    setUp(() async {
      SharedPreferences.setMockInitialValues({
        'key_wbi_img': 'test_img',
        'key_wbi_sub': 'test_sub',
      });
      final prefs = await SharedPreferences.getInstance();
      storageService = StorageService(prefs);
      apiClient = ApiClient(storageService);
      playerRepository = PlayerRepository(apiClient);
    });

    test('fetchPlayUrl with isBangumi=true requests bangumi endpoint and parses result payload', () async {
      apiClient.dio.httpClientAdapter = _MockHttpAdapter((options) async {
        // 验证番剧请求命中 PGC 专用端点且包含 ep_id
        expect(options.path, contains(ApiConstants.bangumiPlayUrl));
        expect(options.queryParameters['ep_id'], 752432);
        expect(options.queryParameters['cid'], 1154635809);
        expect(options.queryParameters['bvid'], 'BV1qh4y1d74E');

        // 模拟 B 站番剧真实返回结构 (嵌套在 result 中而非 data 中，且包含 HEVC 4K 流)
        final pgcMockResponse = {
          'code': 0,
          'message': 'success',
          'result': {
            'quality': 120,
            'format': 'mp4720 4k',
            'timelength': 1420000,
            'accept_format': 'hdflv2,flv,flv720,flv480,mp4',
            'accept_description': ['超清 4K', '高清 1080P60', '高清 1080P', '高清 720P'],
            'accept_quality': [120, 116, 80, 64],
            'dash': {
              'duration': 1420,
              'minBufferTime': 1.5,
              'video': [
                {
                  'id': 120,
                  'baseUrl': 'https://cn-gdfs-cmcc-01.bilivideo.cn/upgcxcode/hevc_4k.m4s',
                  'codecid': 12, // HEVC
                  'codecs': 'hev1.1.6.L153.90',
                  'width': 3840,
                  'height': 2160,
                  'frameRate': '24.000',
                  'bandwidth': 6000000,
                },
                {
                  'id': 120,
                  'baseUrl': 'https://cn-gdfs-cmcc-01.bilivideo.cn/upgcxcode/avc_4k.m4s',
                  'codecid': 7, // AVC
                  'codecs': 'avc1.640033',
                  'width': 3840,
                  'height': 2160,
                  'frameRate': '24.000',
                  'bandwidth': 8000000,
                },
                {
                  'id': 80,
                  'baseUrl': 'https://cn-gdfs-cmcc-01.bilivideo.cn/upgcxcode/hevc_1080p.m4s',
                  'codecid': 12,
                  'codecs': 'hev1.1.6.L120.90',
                  'width': 1920,
                  'height': 1080,
                  'frameRate': '24.000',
                  'bandwidth': 2000000,
                },
              ],
              'audio': [
                {
                  'id': 30280,
                  'baseUrl': 'https://cn-gdfs-cmcc-01.bilivideo.cn/upgcxcode/audio_high.m4s',
                  'bandwidth': 320000,
                  'codecid': 0,
                }
              ],
            }
          }
        };

        return ResponseBody.fromString(
          jsonEncode(pgcMockResponse),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      final playInfo = await playerRepository.fetchPlayUrl(
        bvid: 'BV1qh4y1d74E',
        cid: 1154635809,
        epId: 752432,
        isBangumi: true,
        qn: 120,
      );

      // 验证正确解析清晰度与音视频流链接
      expect(playInfo.currentQn, 120);
      expect(playInfo.audioUrl, contains('audio_high.m4s'));
      // 验证优先调度 HEVC (codecid: 12) 流轨
      expect(playInfo.playUrl, contains('hevc_4k.m4s'));
      expect(playInfo.qualities.length, 4);
      expect(playInfo.qualities.first.qn, 120);
      expect(playInfo.qualities.first.desc, '超清 4K');
    });
  });
}

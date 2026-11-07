import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bili_tv/core/network/api_client.dart';
import 'package:bili_tv/core/storage/storage_service.dart';
import 'package:bili_tv/features/popular/data/repositories/popular_repository.dart';
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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late StorageService storageService;
  late ApiClient apiClient;
  late PopularRepository popularRepository;
  late PlayerRepository playerRepository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'key_wbi_img': 'test_img_key',
      'key_wbi_sub': 'test_sub_key',
      'key_buvid': 'test_buvid',
    });
    final prefs = await SharedPreferences.getInstance();
    storageService = StorageService(prefs);
    apiClient = ApiClient(storageService);
    popularRepository = PopularRepository(apiClient);
    playerRepository = PlayerRepository(apiClient);
  });

  group('PopularRepository Tests', () {
    test('fetchPopularVideos successfully parses popular list', () async {
      apiClient.dio.httpClientAdapter = _MockHttpAdapter((options) async {
        expect(options.path.contains('/x/web-interface/popular'), isTrue);
        final mockData = {
          'code': 0,
          'message': '0',
          'data': {
            'list': [
              {
                'bvid': 'BV1xx411c7mD',
                'cid': 123456,
                'title': '测试热门视频',
                'pic': 'http://i0.hdslb.com/bfs/archive/test.jpg',
                'owner': {'name': 'UP主小明'},
                'stat': {'view': 100000, 'danmaku': 2000},
                'duration': 300,
              }
            ],
            'no_more': false,
          }
        };
        final bytes = utf8.encode(jsonEncode(mockData));
        return ResponseBody.fromBytes(
          bytes,
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      final list = await popularRepository.fetchPopularVideos(pn: 1);
      expect(list.length, 1);
      expect(list.first.bvid, 'BV1xx411c7mD');
      expect(list.first.title, '测试热门视频');
    });
  });

  group('PlayerRepository Extra Endpoints Tests', () {
    test('fetchPageList successfully parses pagelist', () async {
      apiClient.dio.httpClientAdapter = _MockHttpAdapter((options) async {
        expect(options.path.contains('/x/player/pagelist'), isTrue);
        final mockData = {
          'code': 0,
          'message': '0',
          'data': [
            {'cid': 1001, 'page': 1, 'part': 'P1 第一集', 'duration': 1200},
            {'cid': 1002, 'page': 2, 'part': 'P2 第二集', 'duration': 1300},
          ]
        };
        final bytes = utf8.encode(jsonEncode(mockData));
        return ResponseBody.fromBytes(
          bytes,
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      final parts = await playerRepository.fetchPageList('BV1xx411c7mD');
      expect(parts.length, 2);
      expect(parts[0].part, 'P1 第一集');
      expect(parts[1].cid, 1002);
    });

    test('fetchOnlineTotal successfully parses online count string', () async {
      apiClient.dio.httpClientAdapter = _MockHttpAdapter((options) async {
        expect(options.path.contains('/x/player/online/total'), isTrue);
        final mockData = {
          'code': 0,
          'message': '0',
          'data': {
            'total': '1.2万',
            'count': '12345',
          }
        };
        final bytes = utf8.encode(jsonEncode(mockData));
        return ResponseBody.fromBytes(
          bytes,
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      final online = await playerRepository.fetchOnlineTotal(
        bvid: 'BV1xx411c7mD',
        cid: 1001,
      );
      expect(online, '1.2万');
    });

    test('selectBestCodecTrack prioritizes HEVC when available across all resolutions', () async {
      final tracks = [
        {'id': 120, 'codecid': 7, 'codecs': 'avc1.640034', 'bandwidth': 5000000},
        {'id': 120, 'codecid': 13, 'codecs': 'av01.0.08M.08', 'bandwidth': 3000000},
        {'id': 120, 'codecid': 12, 'codecs': 'hev1.1.6.L120.90', 'bandwidth': 3500000},
      ];
      final selected = await playerRepository.selectBestCodecTrack(tracks, 120);
      expect(selected?['codecid'], 12);
      expect(selected?['codecs'], 'hev1.1.6.L120.90');
    });

    test('selectBestCodecTrack prioritizes AV1 over AVC for 4K (id: 120)', () async {
      final tracks = [
        {'id': 120, 'codecid': 7, 'codecs': 'avc1.640034', 'bandwidth': 8000000},
        {'id': 120, 'codecid': 13, 'codecs': 'av01.0.08M.08', 'bandwidth': 3000000},
      ];
      final selected = await playerRepository.selectBestCodecTrack(tracks, 120);
      expect(selected?['codecid'], 13);
      expect(selected?['codecs'], 'av01.0.08M.08');
    });

    test('selectBestCodecTrack prioritizes AVC over AV1 for 1080P (id: 80)', () async {
      final tracks = [
        {'id': 80, 'codecid': 13, 'codecs': 'av01.0.08M.08', 'bandwidth': 1500000},
        {'id': 80, 'codecid': 7, 'codecs': 'avc1.640033', 'bandwidth': 2000000},
      ];
      final selected = await playerRepository.selectBestCodecTrack(tracks, 80);
      expect(selected?['codecid'], 7);
      expect(selected?['codecs'], 'avc1.640033');
    });

    test('selectBestCodecTrack uses bandwidth as tie-breaker for identical codecs', () async {
      final tracks = [
        {'id': 120, 'codecid': 12, 'codecs': 'hev1.1.6.L120.90', 'bandwidth': 3000000},
        {'id': 120, 'codecid': 12, 'codecs': 'hev1.1.6.L120.90', 'bandwidth': 6000000},
      ];
      final selected = await playerRepository.selectBestCodecTrack(tracks, 120);
      expect(selected?['bandwidth'], 6000000);
    });

    test('selectBestCodecTrack filters out tracks exceeding hardware limits (4096x2304) such as 8K', () async {
      final tracks = [
        {'id': 127, 'codecid': 12, 'codecs': 'hev1.1.6.L120.90', 'width': 7680, 'height': 4320, 'bandwidth': 20000000},
        {'id': 120, 'codecid': 12, 'codecs': 'hev1.1.6.L120.90', 'width': 3840, 'height': 2160, 'bandwidth': 8000000},
      ];
      final selected = await playerRepository.selectBestCodecTrack(tracks, 127);
      expect(selected?['id'], 120);
      expect(selected?['width'], 3840);
    });

    test('selectBestCodecTrack filters out 4K 120fps tracks that exceed hardware blocks-per-second limit', () async {
      final tracks = [
        {'id': 120, 'codecid': 12, 'codecs': 'hvc1.1.6.L156.90', 'width': 3840, 'height': 2160, 'frameRate': '120.000', 'bandwidth': 4128114},
        {'id': 116, 'codecid': 12, 'codecs': 'hvc1.1.6.L150.90', 'width': 1920, 'height': 1080, 'frameRate': '60.000', 'bandwidth': 1109528},
      ];
      final selected = await playerRepository.selectBestCodecTrack(tracks, 120);
      expect(selected?['id'], 116);
      expect(selected?['width'], 1920);
      expect(selected?['frameRate'], '60.000');
    });
  });
}

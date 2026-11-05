import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bili_tv/core/network/api_client.dart';
import 'package:bili_tv/core/storage/storage_service.dart';
import 'package:bili_tv/features/live/data/repositories/live_repository.dart';
import 'package:bili_tv/features/bangumi/data/repositories/bangumi_repository.dart';

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
  late LiveRepository liveRepository;
  late BangumiRepository bangumiRepository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'key_wbi_img': 'test_img_key',
      'key_wbi_sub': 'test_sub_key',
      'key_buvid': 'test_buvid',
    });
    final prefs = await SharedPreferences.getInstance();
    storageService = StorageService(prefs);
    apiClient = ApiClient(storageService);
    liveRepository = LiveRepository(apiClient);
    bangumiRepository = BangumiRepository(apiClient);
  });

  group('LiveRepository Tests', () {
    test('fetchLiveRooms aggregates recommend_room_list and room_list correctly', () async {
      apiClient.dio.httpClientAdapter = _MockHttpAdapter((options) async {
        expect(options.path.contains('/xlive/web-interface/v1/index/getList'), isTrue);
        final mockData = {
          'code': 0,
          'message': '0',
          'data': {
            'recommend_room_list': [
              {
                'roomid': 10001,
                'title': '推荐直播间1',
                'uname': '主播A',
                'cover': 'http://example.com/cover1.jpg',
                'online': 5000,
                'area_name': '单机游戏',
              }
            ],
            'room_list': [
              {
                'module_title': '网游',
                'list': [
                  {
                    'roomid': 10002,
                    'title': '分区直播间2',
                    'uname': '主播B',
                    'cover': 'http://example.com/cover2.jpg',
                    'online': 3200,
                    'area_name': '英雄联盟',
                  },
                  // 重复房间，应被去重
                  {
                    'roomid': 10001,
                    'title': '推荐直播间1',
                    'uname': '主播A',
                    'cover': 'http://example.com/cover1.jpg',
                    'online': 5000,
                    'area_name': '单机游戏',
                  }
                ]
              }
            ]
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

      final rooms = await liveRepository.fetchLiveRooms(page: 1);
      expect(rooms.length, 2);
      expect(rooms[0].roomId, 10001);
      expect(rooms[0].title, '推荐直播间1');
      expect(rooms[1].roomId, 10002);
      expect(rooms[1].title, '分区直播间2');
    });
  });

  group('BangumiRepository Tests', () {
    test('fetchSeasonDetail retrieves episodes and first bvid', () async {
      apiClient.dio.httpClientAdapter = _MockHttpAdapter((options) async {
        expect(options.path.contains('/pgc/view/web/season'), isTrue);
        final mockData = {
          'code': 0,
          'message': '0',
          'result': {
            'season_id': 2001,
            'title': '测试新番',
            'episodes': [
              {
                'id': 9901,
                'aid': 1234567,
                'bvid': 'BV1TestEpisode1',
                'cid': 55501,
                'title': '1',
                'long_title': '第一话 启程',
              },
              {
                'id': 9902,
                'aid': 1234567,
                'bvid': 'BV1TestEpisode1',
                'cid': 55502,
                'title': '2',
                'long_title': '第二话 决意',
              }
            ]
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

      final detail = await bangumiRepository.fetchSeasonDetail(2001);
      expect(detail['season_id'], 2001);
      final episodes = detail['episodes'] as List;
      expect(episodes.length, 2);
      expect(episodes.first['bvid'], 'BV1TestEpisode1');
    });
  });
}

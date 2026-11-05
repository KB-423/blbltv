import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bili_tv/core/network/api_client.dart';
import 'package:bili_tv/core/storage/storage_service.dart';
import 'package:bili_tv/features/search/data/repositories/search_repository.dart';

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
  late SearchRepository searchRepository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'key_wbi_img': 'test_img_key',
      'key_wbi_sub': 'test_sub_key',
      'key_buvid': 'test_buvid',
    });
    final prefs = await SharedPreferences.getInstance();
    storageService = StorageService(prefs);
    apiClient = ApiClient(storageService);
    searchRepository = SearchRepository(apiClient);
  });

  group('SearchRepository Tests', () {
    test(
        'fetchHotSearchWords successfully parses string JSON when Content-Type header is omitted',
        () async {
      // 模拟 B 站 hotword 接口响应：未返回 content-type 响应头，数据为 JSON 字符串
      apiClient.dio.httpClientAdapter = _MockHttpAdapter((options) async {
        const jsonString = '''
        {
          "code": 0,
          "list": [
            {"keyword": "文班亚马52分", "show_name": "文班亚马52分24板8帽"},
            {"keyword": "黑神话悟空"},
            {"keyword": "4K风景演示"}
          ]
        }
        ''';
        return ResponseBody.fromString(
          jsonString,
          200,
          headers: {}, // 故意留空，无 content-type
        );
      });

      final hotWords = await searchRepository.fetchHotSearchWords();
      expect(hotWords, isNotEmpty);
      expect(hotWords.length, 3);
      expect(hotWords[0], '文班亚马52分24板8帽');
      expect(hotWords[1], '黑神话悟空');
      expect(hotWords[2], '4K风景演示');
    });

    test('searchVideos successfully parses search results', () async {
      apiClient.dio.httpClientAdapter = _MockHttpAdapter((options) async {
        const jsonString = '''
        {
          "code": 0,
          "data": {
            "numPages": 5,
            "numResults": 20,
            "result": [
              {
                "id": 101,
                "bvid": "BV1test001",
                "title": "Flutter TV 开发实战",
                "author": "测试UP主",
                "play": 5000,
                "pic": "http://example.com/pic1.jpg"
              },
              {
                "id": 102,
                "bvid": "BV1test002",
                "title": "4K 60帧杜比视界演示",
                "author": "科技UP主",
                "play": 12000,
                "pic": "http://example.com/pic2.jpg"
              },
              {
                "id": 103,
                "bvid": "BV1test003",
                "title": "大屏焦点系统深度解析",
                "author": "架构师UP",
                "play": 8800,
                "pic": "http://example.com/pic3.jpg"
              },
              {
                "id": 104,
                "bvid": "BV1test004",
                "title": "遥控器 Dpad 最优解",
                "author": "极客UP",
                "play": 9999,
                "pic": "http://example.com/pic4.jpg"
              }
            ]
          }
        }
        ''';
        return ResponseBody.fromString(
          jsonString,
          200,
          headers: {},
        );
      });

      final result = await searchRepository.searchVideos(keyword: 'Flutter');
      expect(result.numPages, 5);
      expect(result.numResults, 20);
      expect(result.videos.length, 4);
      expect(result.videos[0].bvid, 'BV1test001');
      expect(result.videos[0].title, 'Flutter TV 开发实战');
    });
  });
}

import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:media_kit/media_kit.dart';

import 'package:bili_tv/core/network/api_client.dart';
import 'package:bili_tv/core/storage/storage_service.dart';
import 'package:bili_tv/features/channel/data/models/channel_item_model.dart';
import 'package:bili_tv/features/channel/data/repositories/channel_repository.dart';
import 'package:bili_tv/features/channel/presentation/providers/channel_provider.dart';
import 'package:bili_tv/features/channel/presentation/screens/tv_channel_screen.dart';
import 'package:bili_tv/features/popular/presentation/screens/tv_popular_screen.dart';
import 'package:bili_tv/features/popular/presentation/providers/popular_provider.dart';
import 'package:bili_tv/models/video/video_item_model.dart';

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
  setUpAll(() {
    MediaKit.ensureInitialized();
  });

  group('Channel Architecture & Repository Tests', () {
    test('Default channels contain standard primary and sub-channels', () {
      final channels = MainChannel.defaultChannels;
      expect(channels.isNotEmpty, isTrue);

      final gameChannel = channels.firstWhere((c) => c.name == '游戏');
      expect(gameChannel.rid, 4);
      expect(gameChannel.subChannels.any((s) => s.name == '单机游戏' && s.rid == 17), isTrue);
      expect(gameChannel.subChannels.any((s) => s.name == '电子竞技' && s.rid == 171), isTrue);

      final animeChannel = channels.firstWhere((c) => c.name == '动画');
      expect(animeChannel.rid, 1);
      expect(animeChannel.subChannels.any((s) => s.name == 'MAD·AMV' && s.rid == 24), isTrue);
    });

    test('ChannelRepository parses ranking/region API JSON into VideoItemModel', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storage = StorageService(prefs);
      final apiClient = ApiClient(storage);

      final mockData = {
        'code': 0,
        'message': 'OK',
        'data': [
          {
            'aid': '114296830825819',
            'bvid': 'BV1EvRUY1Edb',
            'typename': '单机游戏',
            'title': '“他是国王吗？”“不，他是传奇”',
            'play': 7843815,
            'review': 2159,
            'favorites': 136718,
            'coins': 9522,
            'mid': 333896150,
            'author': '擦擦玩游戏',
            'pic': 'http://i2.hdslb.com/bfs/archive/test.jpg',
            'duration': '1:16',
          },
          {
            'aid': '999888',
            'bvid': 'BV1xx411c7mD',
            'typename': '单机游戏',
            'title': '测试长视频',
            'play': 12000,
            'review': 50,
            'favorites': 800,
            'coins': 300,
            'mid': 12345,
            'author': '测试UP',
            'pic': 'http://i2.hdslb.com/test2.jpg',
            'duration': '1:02:15',
          }
        ]
      };

      apiClient.dio.httpClientAdapter = _MockHttpAdapter((options) async {
        return ResponseBody.fromString(
          jsonEncode(mockData),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      final repository = ChannelRepository(apiClient);
      final videos = await repository.fetchChannelVideos(rid: 17);

      expect(videos.length, 2);
      expect(videos[0].bvid, 'BV1EvRUY1Edb');
      expect(videos[0].title, '“他是国王吗？”“不，他是传奇”');
      expect(videos[0].owner?.name, '擦擦玩游戏');
      expect(videos[0].stat?.view, 7843815);
      expect(videos[0].duration, 76); // 1:16 -> 76 seconds
      expect(videos[0].rcmdReason, '单机游戏');

      expect(videos[1].duration, 3735); // 1:02:15 -> 3600 + 120 + 15 = 3735 seconds
    });
  });

  group('ChannelProvider State Machine Tests', () {
    test('ChannelNotifier updates main and sub channels properly', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storage = StorageService(prefs);
      final apiClient = ApiClient(storage);

      apiClient.dio.httpClientAdapter = _MockHttpAdapter((options) async {
        final rid = options.queryParameters['rid'];
        return ResponseBody.fromString(
          jsonEncode({
            'code': 0,
            'data': [
              {
                'bvid': 'BV_TEST_$rid',
                'title': 'Test Video for rid $rid',
                'play': 500,
                'author': 'UP',
                'pic': '',
                'duration': '2:30',
              }
            ],
          }),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      final container = ProviderContainer(
        overrides: [
          channelRepositoryProvider.overrideWithValue(ChannelRepository(apiClient)),
        ],
      );

      addTearDown(container.dispose);

      // Initial state
      final initial = container.read(channelProvider);
      expect(initial.selectedMainIndex, 0);
      expect(initial.selectedSubIndex, 0);
      expect(initial.currentMainChannel.name, '游戏');

      // Wait for initial fetch
      await container.pump();
      await Future.delayed(const Duration(milliseconds: 50));
      final loadedInitial = container.read(channelProvider);
      expect(loadedInitial.videos.hasValue, isTrue);
      expect(loadedInitial.videos.value!.first.bvid, 'BV_TEST_4');

      // Switch to sub-channel index 1 (单机游戏, rid: 17)
      await container.read(channelProvider.notifier).selectSubChannel(1);
      final subState = container.read(channelProvider);
      expect(subState.selectedSubIndex, 1);
      expect(subState.currentSubChannel.name, '单机游戏');
      expect(subState.videos.value!.first.bvid, 'BV_TEST_17');

      // Switch to main channel index 1 (动画, rid: 1)
      await container.read(channelProvider.notifier).selectMainChannel(1);
      final mainState = container.read(channelProvider);
      expect(mainState.selectedMainIndex, 1);
      expect(mainState.selectedSubIndex, 0);
      expect(mainState.currentMainChannel.name, '动画');
      expect(mainState.videos.value!.first.bvid, 'BV_TEST_1');
    });
  });

  group('TvChannelScreen Widget Rendering Tests', () {
    testWidgets('TvChannelScreen renders left sub-channels and right video card grid',
        (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final mockVideos = [
        const VideoItemModel(
          bvid: 'BV_TEST_CARD_1',
          title: '精选视频 1',
          pic: 'https://example.com/pic1.jpg',
          duration: 180,
          owner: VideoOwner(name: '测试UP 1'),
          stat: VideoStat(view: 10000),
          rcmdReason: '单机游戏',
        ),
        const VideoItemModel(
          bvid: 'BV_TEST_CARD_2',
          title: '精选视频 2',
          pic: 'https://example.com/pic2.jpg',
          duration: 300,
          owner: VideoOwner(name: '测试UP 2'),
          stat: VideoStat(view: 25000),
          rcmdReason: '单机游戏',
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            channelProvider.overrideWith(() {
              return _MockChannelNotifier(mockVideos);
            }),
          ],
          child: const MaterialApp(
            home: TvChannelScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check left channels panel
      expect(find.text('游戏'), findsWidgets);
      expect(find.text('动画'), findsWidgets);
      expect(find.text('科技'), findsWidgets);
      expect(find.text('全部游戏'), findsWidgets);
      expect(find.text('单机游戏'), findsWidgets);

      // Check right selection cards
      expect(find.text('精选视频 1'), findsOneWidget);
      expect(find.text('精选视频 2'), findsOneWidget);
      expect(find.text('2 个视频'), findsOneWidget);
    });
  });

  group('TvPopularScreen Video Stream Widget Tests', () {
    testWidgets('TvPopularScreen renders stream rail with medals and video badges',
        (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final mockPopularVideos = [
        const VideoItemModel(
          bvid: 'BV_POP_1',
          title: '全站热门第一名',
          pic: 'https://example.com/p1.jpg',
          duration: 240,
          owner: VideoOwner(name: '百大UP主'),
          stat: VideoStat(view: 5000000),
        ),
        const VideoItemModel(
          bvid: 'BV_POP_2',
          title: '全站热门第二名',
          pic: 'https://example.com/p2.jpg',
          duration: 150,
          owner: VideoOwner(name: '热门UP主'),
          stat: VideoStat(view: 3200000),
        ),
      ];

      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storage = StorageService(prefs);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            storageServiceProvider.overrideWithValue(storage),
            popularFeedProvider.overrideWith(() {
              return _MockPopularNotifier(mockPopularVideos);
            }),
          ],
          child: const MaterialApp(
            home: TvPopularScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Check left floating rail (title appears in both rail card and HUD)
      expect(find.text('全站热门榜'), findsOneWidget);
      expect(find.text('全站热门第一名'), findsWidgets);
      expect(find.text('全站热门第二名'), findsOneWidget);
      expect(find.text('TOP 1'), findsWidgets);
      expect(find.text('TOP 2'), findsOneWidget);
    });
  });
}

class _MockChannelNotifier extends ChannelNotifier {
  final List<VideoItemModel> _preset;
  _MockChannelNotifier(this._preset);

  @override
  ChannelState build() {
    return ChannelState(
      selectedMainIndex: 0,
      selectedSubIndex: 0,
      videos: AsyncValue.data(_preset),
    );
  }

  @override
  Future<void> selectSubChannel(int subIndex) async {}

  @override
  Future<void> selectMainChannel(int mainIndex) async {}
}

class _MockPopularNotifier extends PopularNotifier {
  final List<VideoItemModel> _preset;
  _MockPopularNotifier(this._preset);

  @override
  PopularState build() {
    return PopularState(videos: _preset, isLoading: false);
  }
}

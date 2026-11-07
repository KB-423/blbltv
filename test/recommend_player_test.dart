import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bili_tv/features/home/presentation/providers/recommend_player_state.dart';
import 'package:bili_tv/features/main/presentation/providers/nav_rail_focus_provider.dart';
import 'package:bili_tv/models/video/video_collection_model.dart';

void main() {
  group('TopBarDisplayModeNotifier Tests', () {
    test('transitions between full, compact and hidden correctly', () {
      final container = ProviderContainer();
      expect(container.read(topBarDisplayModeProvider), TopBarDisplayMode.full);

      container.read(topBarDisplayModeProvider.notifier).showCompact();
      expect(container.read(topBarDisplayModeProvider), TopBarDisplayMode.compact);

      container.read(topBarDisplayModeProvider.notifier).hide();
      expect(container.read(topBarDisplayModeProvider), TopBarDisplayMode.hidden);

      container.read(topBarDisplayModeProvider.notifier).showFull();
      expect(container.read(topBarDisplayModeProvider), TopBarDisplayMode.full);

      container.dispose();
    });
  });

  group('RecommendPlayerState Tests', () {
    test('default state values and copyWith behaviors', () {
      const state = RecommendPlayerState();
      expect(state.currentIndex, 0);
      expect(state.isLoading, true);
      expect(state.isPlaying, false);
      expect(state.isPurePlayback, false);
      expect(state.showControls, false);
      expect(state.hasLike, false);
      expect(state.danmakuEnabled, true);
      expect(state.speed, 1.0);
      expect(state.playMode, TvPlayMode.sequence);

      final pureState = state.copyWith(
        isLoading: false,
        isPurePlayback: true,
        showControls: false,
        currentIndex: 2,
        hasLike: true,
        speed: 1.5,
        playMode: TvPlayMode.loopSingle,
      );

      expect(pureState.isLoading, false);
      expect(pureState.isPurePlayback, true);
      expect(pureState.showControls, false);
      expect(pureState.currentIndex, 2);
      expect(pureState.hasLike, true);
      expect(pureState.speed, 1.5);
      expect(pureState.playMode, TvPlayMode.loopSingle);
    });
  });

  group('VideoCollectionModel Tests', () {
    test('parses ugc_season JSON with archives and episodes polymorphic structure', () {
      final json = {
        'id': 1001,
        'title': '鬼灭之刃 动画合集',
        'cover': 'https://i0.hdslb.com/bfs/season/cover.jpg',
        'mid': 123456,
        'ep_count': 26,
        'archives': [
          {
            'aid': 55501,
            'bvid': 'BV1ugc01',
            'cid': 66601,
            'title': '第1话 残酷',
            'pic': 'https://i0.hdslb.com/bfs/archive/01.jpg',
            'duration': 1420,
          },
          {
            'aid': 55502,
            'bvid': 'BV1ugc02',
            'cid': 66602,
            'title': '第2话 育手 鳞泷左近次',
            'pic': 'https://i0.hdslb.com/bfs/archive/02.jpg',
            'duration': 1435,
          },
        ],
      };

      final collection = VideoCollectionModel.fromJson(json);
      expect(collection.id, 1001);
      expect(collection.title, '鬼灭之刃 动画合集');
      expect(collection.items.length, 2);
      expect(collection.items[0].bvid, 'BV1ugc01');
      expect(collection.items[0].title, '第1话 残酷');
      expect(collection.items[1].bvid, 'BV1ugc02');
    });

    test('parses fallback empty payload without throwing', () {
      final collection = VideoCollectionModel.fromJson(const {});
      expect(collection.id, 0);
      expect(collection.title, '');
      expect(collection.items, isEmpty);
    });
  });
}

import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../models/video/play_url_model.dart';
import '../../../../models/video/video_collection_model.dart';
import '../../../../models/video/video_item_model.dart';

part 'generated/recommend_player_state.freezed.dart';

/// 播放循环模式
enum TvPlayMode {
  sequence, // 顺序连播
  loopSingle, // 单集循环
}

/// 推荐流全屏背景播放器及控制状态
@freezed
abstract class RecommendPlayerState with _$RecommendPlayerState {
  const factory RecommendPlayerState({
    @Default(0) int currentIndex,
    @Default('') String currentPlayUrl,
    @Default('') String currentAudioUrl,
    @Default(80) int currentQn,
    @Default([]) List<VideoQualityItem> qualities,
    @Default(true) bool isLoading,
    @Default(false) bool isBuffering,
    @Default(false) bool isPlaying,
    @Default(Duration.zero) Duration position,
    @Default(Duration.zero) Duration duration,
    @Default(1.0) double speed,
    @Default(false) bool isPurePlayback, // 纯享播放（左侧卡片与顶栏隐藏）
    @Default(false) bool showControls, // 播放控制浮层唤出
    @Default('') String onlineCount, // 在线观看人数
    @Default(false) bool hasLike,
    @Default(false) bool hasDislike,
    @Default(false) bool hasCoin,
    @Default(false) bool hasFav,
    @Default(TvPlayMode.sequence) TvPlayMode playMode,
    @Default(true) bool danmakuEnabled,
    @Default(1.0) double danmakuSize,
    @Default(1.0) double danmakuSpeed,
    @Default(1.0) double danmakuArea,
    VideoCollectionModel? ugcSeason, // 合集 (如果存在)
    @Default([]) List<VideoItemModel> upWorks, // UP主作品
    @Default([]) List<VideoItemModel> relatedVideos, // 相关推荐
    String? error,
  }) = _RecommendPlayerState;
}

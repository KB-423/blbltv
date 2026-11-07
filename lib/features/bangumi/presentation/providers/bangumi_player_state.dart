import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../models/video/play_url_model.dart';
import '../../data/models/bangumi_episode_model.dart';

part 'generated/bangumi_player_state.freezed.dart';

@freezed
abstract class BangumiPlayerState with _$BangumiPlayerState {
  const factory BangumiPlayerState({
    @Default(0) int seasonId,
    @Default('') String seasonTitle,
    @Default([]) List<BangumiEpisodeModel> episodes,
    @Default(0) int currentEpIndex,
    @Default(true) bool isLoading,
    @Default(false) bool isPlaying,
    @Default(false) bool isBuffering,
    String? error,
    @Default(Duration.zero) Duration position,
    @Default(Duration.zero) Duration duration,
    @Default(80) int currentQn,
    @Default([]) List<VideoQualityItem> qualities,
    @Default(true) bool showControls,
    @Default(false) bool showEpisodeDrawer,
    @Default(false) bool showQualityPanel,
    @Default('') String currentPlayUrl,
    @Default('') String currentAudioUrl,
  }) = _BangumiPlayerState;
}

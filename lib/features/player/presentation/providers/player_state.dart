import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../models/video/play_url_model.dart';
import '../../../../models/video/video_part_model.dart';

part 'generated/player_state.freezed.dart';

/// TV 播放器状态模型
@freezed
abstract class PlayerState with _$PlayerState {
  const factory PlayerState({
    @Default('') String bvid,
    @Default(0) int cid,
    @Default('') String title,
    @Default('') String currentUrl,
    @Default('') String currentAudioUrl,
    @Default(80) int currentQn,
    @Default(<VideoQualityItem>[]) List<VideoQualityItem> qualities,
    @Default(<VideoPartItem>[]) List<VideoPartItem> parts,
    @Default(0) int currentPartIndex,
    @Default('') String onlineCount,
    @Default(false) bool isLiked,
    @Default(false) bool showPartDrawer,
    @Default(true) bool isLoading,
    @Default(false) bool isPlaying,
    @Default(false) bool isBuffering,
    @Default(Duration.zero) Duration position,
    @Default(Duration.zero) Duration duration,
    @Default(true) bool showControls,
    @Default(false) bool showQualityPanel,
    String? error,
  }) = _PlayerState;
}

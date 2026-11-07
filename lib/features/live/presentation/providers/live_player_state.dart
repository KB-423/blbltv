import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/live_player_state.freezed.dart';

@freezed
abstract class LivePlayerState with _$LivePlayerState {
  const factory LivePlayerState({
    required int roomId,
    @Default('') String title,
    @Default('') String uname,
    @Default('') String cover,
    @Default('') String onlineCount,
    @Default(true) bool isLoading,
    @Default(false) bool isPlaying,
    @Default(false) bool isBuffering,
    String? error,
    @Default('') String streamUrl,
    @Default(true) bool showControls,
  }) = _LivePlayerState;
}

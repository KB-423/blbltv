import 'dart:typed_data';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../models/video/video_item_model.dart';

part 'generated/playback_session.freezed.dart';

/// 业务组件独立持有的播放会话状态 (纯数据)
/// 专为大屏多场景切播、状态隔离与 0ms 黑屏恢复设计
@freezed
abstract class PlaybackSession with _$PlaybackSession {
  const factory PlaybackSession({
    required String sessionId, // 会话唯一ID (如 'recommend', 'popular', 'channel', 'player_BVxxx')
    @Default('') String ownerId, // 所有权组件标识 (如 'recommend', 'popular', 'channel', 'detail_player')
    @Default([]) List<VideoItemModel> playlist, // 播放列表
    @Default(0) int currentIndex, // 当前播放项索引
    VideoItemModel? currentVideo, // 当前视频实体
    String? videoUrl, // 视频流地址
    String? audioUrl, // 音频流地址
    String? coverUrl, // 封面图地址
    @Default(Duration.zero) Duration lastPosition, // 离开时的最后精确进度
    @Default(Duration.zero) Duration duration, // 视频总时长
    Uint8List? lastFrameBytes, // 切走瞬间截取的最后一帧冻结快照数据 (用于切回时 0ms 黑屏过渡)
    @Default(80) int quality, // 当前画质 QN
    @Default(1.0) double speed, // 播放倍速
    @Default(false) bool isLive, // 是否为直播流
    @Default({}) Map<String, String> httpHeaders, // 自定义请求头
  }) = _PlaybackSession;
}

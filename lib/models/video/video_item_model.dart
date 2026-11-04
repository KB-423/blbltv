import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/video_item_model.freezed.dart';

int _parseInt(dynamic val) {
  if (val == null) return 0;
  if (val is int) return val;
  if (val is num) return val.toInt();
  if (val is String) return int.tryParse(val) ?? 0;
  return 0;
}

String? _parseRcmdReason(dynamic val) {
  if (val == null) return null;
  if (val is String && val.isNotEmpty) return val;
  if (val is Map) return val['content']?.toString();
  return null;
}

/// 视频创作者/UP主信息
@freezed
abstract class VideoOwner with _$VideoOwner {
  const factory VideoOwner({
    @Default(0) int mid,
    @Default('') String name,
    @Default('') String face,
  }) = _VideoOwner;

  factory VideoOwner.fromJson(Map<String, dynamic> json) {
    return VideoOwner(
      mid: _parseInt(json['mid']),
      name: json['name']?.toString() ?? '',
      face: json['face']?.toString() ?? '',
    );
  }
}

/// 视频统计数据（播放数、弹幕数等）
@freezed
abstract class VideoStat with _$VideoStat {
  const factory VideoStat({
    @Default(0) int view,
    @Default(0) int danmaku,
    @Default(0) int reply,
    @Default(0) int favorite,
    @Default(0) int coin,
    @Default(0) int share,
    @Default(0) int like,
  }) = _VideoStat;

  factory VideoStat.fromJson(Map<String, dynamic> json) {
    return VideoStat(
      view: _parseInt(json['view']),
      danmaku: _parseInt(json['danmaku']),
      reply: _parseInt(json['reply']),
      favorite: _parseInt(json['favorite']),
      coin: _parseInt(json['coin']),
      share: _parseInt(json['share']),
      like: _parseInt(json['like']),
    );
  }
}

/// TV 视频卡片核心数据模型
@freezed
abstract class VideoItemModel with _$VideoItemModel {
  const factory VideoItemModel({
    @Default(0) int id,
    @Default('') String bvid,
    @Default(0) int cid,
    @Default('') String title,
    @Default('') String pic,
    @Default(0) int duration,
    @Default(0) int pubdate,
    @Default('') String uri,
    VideoOwner? owner,
    VideoStat? stat,
    String? rcmdReason,
  }) = _VideoItemModel;

  factory VideoItemModel.fromJson(Map<String, dynamic> json) {
    final ownerData = json['owner'];
    final statData = json['stat'];

    return VideoItemModel(
      id: _parseInt(json['id']),
      bvid: json['bvid']?.toString() ?? '',
      cid: _parseInt(json['cid']),
      title: json['title']?.toString() ?? '',
      pic: json['pic']?.toString() ?? '',
      duration: _parseInt(json['duration']),
      pubdate: _parseInt(json['pubdate']),
      uri: json['uri']?.toString() ?? '',
      owner: ownerData is Map<String, dynamic>
          ? VideoOwner.fromJson(ownerData)
          : null,
      stat:
          statData is Map<String, dynamic> ? VideoStat.fromJson(statData) : null,
      rcmdReason: _parseRcmdReason(json['rcmd_reason']),
    );
  }

  factory VideoItemModel.fromSearchJson(Map<String, dynamic> json) {
    final rawTitle = json['title']?.toString() ?? '';
    final cleanTitle = rawTitle.replaceAll(RegExp(r'<[^>]*>'), '');

    String picUrl = json['pic']?.toString() ?? '';
    if (picUrl.startsWith('//')) {
      picUrl = 'https:$picUrl';
    }

    int parseDuration(dynamic val) {
      if (val == null) return 0;
      if (val is int) return val;
      if (val is num) return val.toInt();
      if (val is String) {
        if (int.tryParse(val) != null) return int.parse(val);
        final parts = val.split(':');
        if (parts.length == 2) {
          final m = int.tryParse(parts[0]) ?? 0;
          final s = int.tryParse(parts[1]) ?? 0;
          return m * 60 + s;
        } else if (parts.length == 3) {
          final h = int.tryParse(parts[0]) ?? 0;
          final m = int.tryParse(parts[1]) ?? 0;
          final s = int.tryParse(parts[2]) ?? 0;
          return h * 3600 + m * 60 + s;
        }
      }
      return 0;
    }

    final owner = VideoOwner(
      mid: _parseInt(json['mid']),
      name: json['author']?.toString() ?? '',
      face: json['upic']?.toString() ?? '',
    );

    final stat = VideoStat(
      view: _parseInt(json['play']),
      danmaku: _parseInt(json['video_review'] ?? json['danmaku']),
      favorite: _parseInt(json['favorites']),
      like: _parseInt(json['like']),
    );

    return VideoItemModel(
      id: _parseInt(json['aid'] ?? json['id']),
      bvid: json['bvid']?.toString() ?? '',
      cid: 0,
      title: cleanTitle,
      pic: picUrl,
      duration: parseDuration(json['duration']),
      pubdate: _parseInt(json['pubdate']),
      owner: owner,
      stat: stat,
    );
  }
}

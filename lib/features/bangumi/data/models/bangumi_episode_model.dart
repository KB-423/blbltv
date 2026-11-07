import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/bangumi_episode_model.freezed.dart';
part 'generated/bangumi_episode_model.g.dart';

@freezed
abstract class BangumiEpisodeModel with _$BangumiEpisodeModel {
  const factory BangumiEpisodeModel({
    @Default(0) int id,
    @Default(0) int aid,
    @Default('') String bvid,
    @Default(0) int cid,
    @Default('') String title,
    @JsonKey(name: 'long_title') @Default('') String longTitle,
    @Default('') String badge,
    @Default(0) int duration,
    @Default('') String cover,
    @Default(0) int status,
  }) = _BangumiEpisodeModel;

  factory BangumiEpisodeModel.fromJson(Map<String, dynamic> json) =>
      _$BangumiEpisodeModelFromJson(json);
}

import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/bangumi_season_model.freezed.dart';
part 'generated/bangumi_season_model.g.dart';

@freezed
abstract class BangumiSeasonModel with _$BangumiSeasonModel {
  const factory BangumiSeasonModel({
    @JsonKey(name: 'season_id') @Default(0) int seasonId,
    @Default('') String title,
    @Default('') String cover,
    @Default('') String badge,
    @Default('') String score,
    @Default('') String order,
    @JsonKey(name: 'index_show') @Default('') String indexShow,
    @Default('') String desc,
  }) = _BangumiSeasonModel;

  factory BangumiSeasonModel.fromJson(Map<String, dynamic> json) =>
      _$BangumiSeasonModelFromJson(json);
}

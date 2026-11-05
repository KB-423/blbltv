import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/video_part_model.freezed.dart';
part 'generated/video_part_model.g.dart';

@freezed
abstract class VideoPartItem with _$VideoPartItem {
  const factory VideoPartItem({
    required int cid,
    required int page,
    @Default('') String from,
    required String part,
    @Default(0) int duration,
  }) = _VideoPartItem;

  factory VideoPartItem.fromJson(Map<String, dynamic> json) =>
      _$VideoPartItemFromJson(json);
}

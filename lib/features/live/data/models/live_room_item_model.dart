import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/live_room_item_model.freezed.dart';
part 'generated/live_room_item_model.g.dart';

@freezed
abstract class LiveRoomItemModel with _$LiveRoomItemModel {
  const factory LiveRoomItemModel({
    @JsonKey(name: 'roomid') @Default(0) int roomId,
    @Default('') String title,
    @Default('') String uname,
    @Default('') String cover,
    @JsonKey(name: 'user_cover') @Default('') String userCover,
    @Default('') String face,
    @Default(0) int online,
    @JsonKey(name: 'area_name') @Default('') String areaName,
    @JsonKey(name: 'area_v2_name') @Default('') String areaV2Name,
  }) = _LiveRoomItemModel;

  factory LiveRoomItemModel.fromJson(Map<String, dynamic> json) =>
      _$LiveRoomItemModelFromJson(json);
}

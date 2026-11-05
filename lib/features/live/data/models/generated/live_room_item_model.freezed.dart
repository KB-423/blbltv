// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../live_room_item_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LiveRoomItemModel {

@JsonKey(name: 'roomid') int get roomId; String get title; String get uname; String get cover;@JsonKey(name: 'user_cover') String get userCover; String get face; int get online;@JsonKey(name: 'area_name') String get areaName;@JsonKey(name: 'area_v2_name') String get areaV2Name;
/// Create a copy of LiveRoomItemModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LiveRoomItemModelCopyWith<LiveRoomItemModel> get copyWith => _$LiveRoomItemModelCopyWithImpl<LiveRoomItemModel>(this as LiveRoomItemModel, _$identity);

  /// Serializes this LiveRoomItemModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as LiveRoomItemModel;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LiveRoomItemModel&&(identical(other.roomId, _this.roomId) || other.roomId == _this.roomId)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.uname, _this.uname) || other.uname == _this.uname)&&(identical(other.cover, _this.cover) || other.cover == _this.cover)&&(identical(other.userCover, _this.userCover) || other.userCover == _this.userCover)&&(identical(other.face, _this.face) || other.face == _this.face)&&(identical(other.online, _this.online) || other.online == _this.online)&&(identical(other.areaName, _this.areaName) || other.areaName == _this.areaName)&&(identical(other.areaV2Name, _this.areaV2Name) || other.areaV2Name == _this.areaV2Name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as LiveRoomItemModel;
  return Object.hash(runtimeType,_this.roomId,_this.title,_this.uname,_this.cover,_this.userCover,_this.face,_this.online,_this.areaName,_this.areaV2Name);
}

@override
String toString() {
  final _this = this as LiveRoomItemModel;
  return 'LiveRoomItemModel(roomId: ${_this.roomId}, title: ${_this.title}, uname: ${_this.uname}, cover: ${_this.cover}, userCover: ${_this.userCover}, face: ${_this.face}, online: ${_this.online}, areaName: ${_this.areaName}, areaV2Name: ${_this.areaV2Name})';
}


}

/// @nodoc
abstract mixin class $LiveRoomItemModelCopyWith<$Res>  {
  factory $LiveRoomItemModelCopyWith(LiveRoomItemModel value, $Res Function(LiveRoomItemModel) _then) = _$LiveRoomItemModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'roomid') int roomId, String title, String uname, String cover,@JsonKey(name: 'user_cover') String userCover, String face, int online,@JsonKey(name: 'area_name') String areaName,@JsonKey(name: 'area_v2_name') String areaV2Name
});




}
/// @nodoc
class _$LiveRoomItemModelCopyWithImpl<$Res>
    implements $LiveRoomItemModelCopyWith<$Res> {
  _$LiveRoomItemModelCopyWithImpl(this._self, this._then);

  final LiveRoomItemModel _self;
  final $Res Function(LiveRoomItemModel) _then;

/// Create a copy of LiveRoomItemModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? roomId = null,Object? title = null,Object? uname = null,Object? cover = null,Object? userCover = null,Object? face = null,Object? online = null,Object? areaName = null,Object? areaV2Name = null,}) {
  return _then(LiveRoomItemModel(
roomId: null == roomId ? _self.roomId : roomId // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,uname: null == uname ? _self.uname : uname // ignore: cast_nullable_to_non_nullable
as String,cover: null == cover ? _self.cover : cover // ignore: cast_nullable_to_non_nullable
as String,userCover: null == userCover ? _self.userCover : userCover // ignore: cast_nullable_to_non_nullable
as String,face: null == face ? _self.face : face // ignore: cast_nullable_to_non_nullable
as String,online: null == online ? _self.online : online // ignore: cast_nullable_to_non_nullable
as int,areaName: null == areaName ? _self.areaName : areaName // ignore: cast_nullable_to_non_nullable
as String,areaV2Name: null == areaV2Name ? _self.areaV2Name : areaV2Name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [LiveRoomItemModel].
extension LiveRoomItemModelPatterns on LiveRoomItemModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LiveRoomItemModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LiveRoomItemModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LiveRoomItemModel value)  $default,){
final _that = this;
switch (_that) {
case _LiveRoomItemModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LiveRoomItemModel value)?  $default,){
final _that = this;
switch (_that) {
case _LiveRoomItemModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'roomid')  int roomId,  String title,  String uname,  String cover, @JsonKey(name: 'user_cover')  String userCover,  String face,  int online, @JsonKey(name: 'area_name')  String areaName, @JsonKey(name: 'area_v2_name')  String areaV2Name)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LiveRoomItemModel() when $default != null:
return $default(_that.roomId,_that.title,_that.uname,_that.cover,_that.userCover,_that.face,_that.online,_that.areaName,_that.areaV2Name);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'roomid')  int roomId,  String title,  String uname,  String cover, @JsonKey(name: 'user_cover')  String userCover,  String face,  int online, @JsonKey(name: 'area_name')  String areaName, @JsonKey(name: 'area_v2_name')  String areaV2Name)  $default,) {final _that = this;
switch (_that) {
case _LiveRoomItemModel():
return $default(_that.roomId,_that.title,_that.uname,_that.cover,_that.userCover,_that.face,_that.online,_that.areaName,_that.areaV2Name);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'roomid')  int roomId,  String title,  String uname,  String cover, @JsonKey(name: 'user_cover')  String userCover,  String face,  int online, @JsonKey(name: 'area_name')  String areaName, @JsonKey(name: 'area_v2_name')  String areaV2Name)?  $default,) {final _that = this;
switch (_that) {
case _LiveRoomItemModel() when $default != null:
return $default(_that.roomId,_that.title,_that.uname,_that.cover,_that.userCover,_that.face,_that.online,_that.areaName,_that.areaV2Name);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LiveRoomItemModel implements LiveRoomItemModel {
  const _LiveRoomItemModel({@JsonKey(name: 'roomid') this.roomId = 0, this.title = '', this.uname = '', this.cover = '', @JsonKey(name: 'user_cover') this.userCover = '', this.face = '', this.online = 0, @JsonKey(name: 'area_name') this.areaName = '', @JsonKey(name: 'area_v2_name') this.areaV2Name = ''});
  factory _LiveRoomItemModel.fromJson(Map<String, dynamic> json) => _$LiveRoomItemModelFromJson(json);

@override@JsonKey(name: 'roomid') final  int roomId;
@override@JsonKey() final  String title;
@override@JsonKey() final  String uname;
@override@JsonKey() final  String cover;
@override@JsonKey(name: 'user_cover') final  String userCover;
@override@JsonKey() final  String face;
@override@JsonKey() final  int online;
@override@JsonKey(name: 'area_name') final  String areaName;
@override@JsonKey(name: 'area_v2_name') final  String areaV2Name;

/// Create a copy of LiveRoomItemModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LiveRoomItemModelCopyWith<_LiveRoomItemModel> get copyWith => __$LiveRoomItemModelCopyWithImpl<_LiveRoomItemModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LiveRoomItemModelToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LiveRoomItemModel&&(identical(other.roomId, roomId) || other.roomId == roomId)&&(identical(other.title, title) || other.title == title)&&(identical(other.uname, uname) || other.uname == uname)&&(identical(other.cover, cover) || other.cover == cover)&&(identical(other.userCover, userCover) || other.userCover == userCover)&&(identical(other.face, face) || other.face == face)&&(identical(other.online, online) || other.online == online)&&(identical(other.areaName, areaName) || other.areaName == areaName)&&(identical(other.areaV2Name, areaV2Name) || other.areaV2Name == areaV2Name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,roomId,title,uname,cover,userCover,face,online,areaName,areaV2Name);
}

@override
String toString() {
    return 'LiveRoomItemModel(roomId: $roomId, title: $title, uname: $uname, cover: $cover, userCover: $userCover, face: $face, online: $online, areaName: $areaName, areaV2Name: $areaV2Name)';
}


}

/// @nodoc
abstract mixin class _$LiveRoomItemModelCopyWith<$Res> implements $LiveRoomItemModelCopyWith<$Res> {
  factory _$LiveRoomItemModelCopyWith(_LiveRoomItemModel value, $Res Function(_LiveRoomItemModel) _then) = __$LiveRoomItemModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'roomid') int roomId, String title, String uname, String cover,@JsonKey(name: 'user_cover') String userCover, String face, int online,@JsonKey(name: 'area_name') String areaName,@JsonKey(name: 'area_v2_name') String areaV2Name
});




}
/// @nodoc
class __$LiveRoomItemModelCopyWithImpl<$Res>
    implements _$LiveRoomItemModelCopyWith<$Res> {
  __$LiveRoomItemModelCopyWithImpl(this._self, this._then);

  final _LiveRoomItemModel _self;
  final $Res Function(_LiveRoomItemModel) _then;

/// Create a copy of LiveRoomItemModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? roomId = null,Object? title = null,Object? uname = null,Object? cover = null,Object? userCover = null,Object? face = null,Object? online = null,Object? areaName = null,Object? areaV2Name = null,}) {
  return _then(_LiveRoomItemModel(
roomId: null == roomId ? _self.roomId : roomId // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,uname: null == uname ? _self.uname : uname // ignore: cast_nullable_to_non_nullable
as String,cover: null == cover ? _self.cover : cover // ignore: cast_nullable_to_non_nullable
as String,userCover: null == userCover ? _self.userCover : userCover // ignore: cast_nullable_to_non_nullable
as String,face: null == face ? _self.face : face // ignore: cast_nullable_to_non_nullable
as String,online: null == online ? _self.online : online // ignore: cast_nullable_to_non_nullable
as int,areaName: null == areaName ? _self.areaName : areaName // ignore: cast_nullable_to_non_nullable
as String,areaV2Name: null == areaV2Name ? _self.areaV2Name : areaV2Name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on

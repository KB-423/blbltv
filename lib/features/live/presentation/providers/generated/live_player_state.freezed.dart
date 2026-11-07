// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../live_player_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LivePlayerState {

 int get roomId; String get title; String get uname; String get cover; String get onlineCount; bool get isLoading; bool get isPlaying; bool get isBuffering; String? get error; String get streamUrl; bool get showControls;
/// Create a copy of LivePlayerState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LivePlayerStateCopyWith<LivePlayerState> get copyWith => _$LivePlayerStateCopyWithImpl<LivePlayerState>(this as LivePlayerState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as LivePlayerState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LivePlayerState&&(identical(other.roomId, _this.roomId) || other.roomId == _this.roomId)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.uname, _this.uname) || other.uname == _this.uname)&&(identical(other.cover, _this.cover) || other.cover == _this.cover)&&(identical(other.onlineCount, _this.onlineCount) || other.onlineCount == _this.onlineCount)&&(identical(other.isLoading, _this.isLoading) || other.isLoading == _this.isLoading)&&(identical(other.isPlaying, _this.isPlaying) || other.isPlaying == _this.isPlaying)&&(identical(other.isBuffering, _this.isBuffering) || other.isBuffering == _this.isBuffering)&&(identical(other.error, _this.error) || other.error == _this.error)&&(identical(other.streamUrl, _this.streamUrl) || other.streamUrl == _this.streamUrl)&&(identical(other.showControls, _this.showControls) || other.showControls == _this.showControls));
}


@override
int get hashCode {
  final _this = this as LivePlayerState;
  return Object.hash(runtimeType,_this.roomId,_this.title,_this.uname,_this.cover,_this.onlineCount,_this.isLoading,_this.isPlaying,_this.isBuffering,_this.error,_this.streamUrl,_this.showControls);
}

@override
String toString() {
  final _this = this as LivePlayerState;
  return 'LivePlayerState(roomId: ${_this.roomId}, title: ${_this.title}, uname: ${_this.uname}, cover: ${_this.cover}, onlineCount: ${_this.onlineCount}, isLoading: ${_this.isLoading}, isPlaying: ${_this.isPlaying}, isBuffering: ${_this.isBuffering}, error: ${_this.error}, streamUrl: ${_this.streamUrl}, showControls: ${_this.showControls})';
}


}

/// @nodoc
abstract mixin class $LivePlayerStateCopyWith<$Res>  {
  factory $LivePlayerStateCopyWith(LivePlayerState value, $Res Function(LivePlayerState) _then) = _$LivePlayerStateCopyWithImpl;
@useResult
$Res call({
 int roomId, String title, String uname, String cover, String onlineCount, bool isLoading, bool isPlaying, bool isBuffering, String? error, String streamUrl, bool showControls
});




}
/// @nodoc
class _$LivePlayerStateCopyWithImpl<$Res>
    implements $LivePlayerStateCopyWith<$Res> {
  _$LivePlayerStateCopyWithImpl(this._self, this._then);

  final LivePlayerState _self;
  final $Res Function(LivePlayerState) _then;

/// Create a copy of LivePlayerState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? roomId = null,Object? title = null,Object? uname = null,Object? cover = null,Object? onlineCount = null,Object? isLoading = null,Object? isPlaying = null,Object? isBuffering = null,Object? error = freezed,Object? streamUrl = null,Object? showControls = null,}) {
  return _then(LivePlayerState(
roomId: null == roomId ? _self.roomId : roomId // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,uname: null == uname ? _self.uname : uname // ignore: cast_nullable_to_non_nullable
as String,cover: null == cover ? _self.cover : cover // ignore: cast_nullable_to_non_nullable
as String,onlineCount: null == onlineCount ? _self.onlineCount : onlineCount // ignore: cast_nullable_to_non_nullable
as String,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isPlaying: null == isPlaying ? _self.isPlaying : isPlaying // ignore: cast_nullable_to_non_nullable
as bool,isBuffering: null == isBuffering ? _self.isBuffering : isBuffering // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,streamUrl: null == streamUrl ? _self.streamUrl : streamUrl // ignore: cast_nullable_to_non_nullable
as String,showControls: null == showControls ? _self.showControls : showControls // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [LivePlayerState].
extension LivePlayerStatePatterns on LivePlayerState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LivePlayerState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LivePlayerState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LivePlayerState value)  $default,){
final _that = this;
switch (_that) {
case _LivePlayerState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LivePlayerState value)?  $default,){
final _that = this;
switch (_that) {
case _LivePlayerState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int roomId,  String title,  String uname,  String cover,  String onlineCount,  bool isLoading,  bool isPlaying,  bool isBuffering,  String? error,  String streamUrl,  bool showControls)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LivePlayerState() when $default != null:
return $default(_that.roomId,_that.title,_that.uname,_that.cover,_that.onlineCount,_that.isLoading,_that.isPlaying,_that.isBuffering,_that.error,_that.streamUrl,_that.showControls);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int roomId,  String title,  String uname,  String cover,  String onlineCount,  bool isLoading,  bool isPlaying,  bool isBuffering,  String? error,  String streamUrl,  bool showControls)  $default,) {final _that = this;
switch (_that) {
case _LivePlayerState():
return $default(_that.roomId,_that.title,_that.uname,_that.cover,_that.onlineCount,_that.isLoading,_that.isPlaying,_that.isBuffering,_that.error,_that.streamUrl,_that.showControls);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int roomId,  String title,  String uname,  String cover,  String onlineCount,  bool isLoading,  bool isPlaying,  bool isBuffering,  String? error,  String streamUrl,  bool showControls)?  $default,) {final _that = this;
switch (_that) {
case _LivePlayerState() when $default != null:
return $default(_that.roomId,_that.title,_that.uname,_that.cover,_that.onlineCount,_that.isLoading,_that.isPlaying,_that.isBuffering,_that.error,_that.streamUrl,_that.showControls);case _:
  return null;

}
}

}

/// @nodoc


class _LivePlayerState implements LivePlayerState {
  const _LivePlayerState({required this.roomId, this.title = '', this.uname = '', this.cover = '', this.onlineCount = '', this.isLoading = true, this.isPlaying = false, this.isBuffering = false, this.error, this.streamUrl = '', this.showControls = true});
  

@override final  int roomId;
@override@JsonKey() final  String title;
@override@JsonKey() final  String uname;
@override@JsonKey() final  String cover;
@override@JsonKey() final  String onlineCount;
@override@JsonKey() final  bool isLoading;
@override@JsonKey() final  bool isPlaying;
@override@JsonKey() final  bool isBuffering;
@override final  String? error;
@override@JsonKey() final  String streamUrl;
@override@JsonKey() final  bool showControls;

/// Create a copy of LivePlayerState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LivePlayerStateCopyWith<_LivePlayerState> get copyWith => __$LivePlayerStateCopyWithImpl<_LivePlayerState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LivePlayerState&&(identical(other.roomId, roomId) || other.roomId == roomId)&&(identical(other.title, title) || other.title == title)&&(identical(other.uname, uname) || other.uname == uname)&&(identical(other.cover, cover) || other.cover == cover)&&(identical(other.onlineCount, onlineCount) || other.onlineCount == onlineCount)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.isPlaying, isPlaying) || other.isPlaying == isPlaying)&&(identical(other.isBuffering, isBuffering) || other.isBuffering == isBuffering)&&(identical(other.error, error) || other.error == error)&&(identical(other.streamUrl, streamUrl) || other.streamUrl == streamUrl)&&(identical(other.showControls, showControls) || other.showControls == showControls));
}


@override
int get hashCode {
    return Object.hash(runtimeType,roomId,title,uname,cover,onlineCount,isLoading,isPlaying,isBuffering,error,streamUrl,showControls);
}

@override
String toString() {
    return 'LivePlayerState(roomId: $roomId, title: $title, uname: $uname, cover: $cover, onlineCount: $onlineCount, isLoading: $isLoading, isPlaying: $isPlaying, isBuffering: $isBuffering, error: $error, streamUrl: $streamUrl, showControls: $showControls)';
}


}

/// @nodoc
abstract mixin class _$LivePlayerStateCopyWith<$Res> implements $LivePlayerStateCopyWith<$Res> {
  factory _$LivePlayerStateCopyWith(_LivePlayerState value, $Res Function(_LivePlayerState) _then) = __$LivePlayerStateCopyWithImpl;
@override @useResult
$Res call({
 int roomId, String title, String uname, String cover, String onlineCount, bool isLoading, bool isPlaying, bool isBuffering, String? error, String streamUrl, bool showControls
});




}
/// @nodoc
class __$LivePlayerStateCopyWithImpl<$Res>
    implements _$LivePlayerStateCopyWith<$Res> {
  __$LivePlayerStateCopyWithImpl(this._self, this._then);

  final _LivePlayerState _self;
  final $Res Function(_LivePlayerState) _then;

/// Create a copy of LivePlayerState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? roomId = null,Object? title = null,Object? uname = null,Object? cover = null,Object? onlineCount = null,Object? isLoading = null,Object? isPlaying = null,Object? isBuffering = null,Object? error = freezed,Object? streamUrl = null,Object? showControls = null,}) {
  return _then(_LivePlayerState(
roomId: null == roomId ? _self.roomId : roomId // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,uname: null == uname ? _self.uname : uname // ignore: cast_nullable_to_non_nullable
as String,cover: null == cover ? _self.cover : cover // ignore: cast_nullable_to_non_nullable
as String,onlineCount: null == onlineCount ? _self.onlineCount : onlineCount // ignore: cast_nullable_to_non_nullable
as String,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isPlaying: null == isPlaying ? _self.isPlaying : isPlaying // ignore: cast_nullable_to_non_nullable
as bool,isBuffering: null == isBuffering ? _self.isBuffering : isBuffering // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,streamUrl: null == streamUrl ? _self.streamUrl : streamUrl // ignore: cast_nullable_to_non_nullable
as String,showControls: null == showControls ? _self.showControls : showControls // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on

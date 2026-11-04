// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../player_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PlayerState {

 String get bvid; int get cid; String get title; String get currentUrl; String get currentAudioUrl; int get currentQn; List<VideoQualityItem> get qualities; bool get isLoading; bool get isPlaying; bool get isBuffering; Duration get position; Duration get duration; bool get showControls; bool get showQualityPanel; String? get error;
/// Create a copy of PlayerState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlayerStateCopyWith<PlayerState> get copyWith => _$PlayerStateCopyWithImpl<PlayerState>(this as PlayerState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PlayerState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlayerState&&(identical(other.bvid, _this.bvid) || other.bvid == _this.bvid)&&(identical(other.cid, _this.cid) || other.cid == _this.cid)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.currentUrl, _this.currentUrl) || other.currentUrl == _this.currentUrl)&&(identical(other.currentAudioUrl, _this.currentAudioUrl) || other.currentAudioUrl == _this.currentAudioUrl)&&(identical(other.currentQn, _this.currentQn) || other.currentQn == _this.currentQn)&&const DeepCollectionEquality().equals(other.qualities, _this.qualities)&&(identical(other.isLoading, _this.isLoading) || other.isLoading == _this.isLoading)&&(identical(other.isPlaying, _this.isPlaying) || other.isPlaying == _this.isPlaying)&&(identical(other.isBuffering, _this.isBuffering) || other.isBuffering == _this.isBuffering)&&(identical(other.position, _this.position) || other.position == _this.position)&&(identical(other.duration, _this.duration) || other.duration == _this.duration)&&(identical(other.showControls, _this.showControls) || other.showControls == _this.showControls)&&(identical(other.showQualityPanel, _this.showQualityPanel) || other.showQualityPanel == _this.showQualityPanel)&&(identical(other.error, _this.error) || other.error == _this.error));
}


@override
int get hashCode {
  final _this = this as PlayerState;
  return Object.hash(runtimeType,_this.bvid,_this.cid,_this.title,_this.currentUrl,_this.currentAudioUrl,_this.currentQn,const DeepCollectionEquality().hash(_this.qualities),_this.isLoading,_this.isPlaying,_this.isBuffering,_this.position,_this.duration,_this.showControls,_this.showQualityPanel,_this.error);
}

@override
String toString() {
  final _this = this as PlayerState;
  return 'PlayerState(bvid: ${_this.bvid}, cid: ${_this.cid}, title: ${_this.title}, currentUrl: ${_this.currentUrl}, currentAudioUrl: ${_this.currentAudioUrl}, currentQn: ${_this.currentQn}, qualities: ${_this.qualities}, isLoading: ${_this.isLoading}, isPlaying: ${_this.isPlaying}, isBuffering: ${_this.isBuffering}, position: ${_this.position}, duration: ${_this.duration}, showControls: ${_this.showControls}, showQualityPanel: ${_this.showQualityPanel}, error: ${_this.error})';
}


}

/// @nodoc
abstract mixin class $PlayerStateCopyWith<$Res>  {
  factory $PlayerStateCopyWith(PlayerState value, $Res Function(PlayerState) _then) = _$PlayerStateCopyWithImpl;
@useResult
$Res call({
 String bvid, int cid, String title, String currentUrl, String currentAudioUrl, int currentQn, List<VideoQualityItem> qualities, bool isLoading, bool isPlaying, bool isBuffering, Duration position, Duration duration, bool showControls, bool showQualityPanel, String? error
});




}
/// @nodoc
class _$PlayerStateCopyWithImpl<$Res>
    implements $PlayerStateCopyWith<$Res> {
  _$PlayerStateCopyWithImpl(this._self, this._then);

  final PlayerState _self;
  final $Res Function(PlayerState) _then;

/// Create a copy of PlayerState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? bvid = null,Object? cid = null,Object? title = null,Object? currentUrl = null,Object? currentAudioUrl = null,Object? currentQn = null,Object? qualities = null,Object? isLoading = null,Object? isPlaying = null,Object? isBuffering = null,Object? position = null,Object? duration = null,Object? showControls = null,Object? showQualityPanel = null,Object? error = freezed,}) {
  return _then(PlayerState(
bvid: null == bvid ? _self.bvid : bvid // ignore: cast_nullable_to_non_nullable
as String,cid: null == cid ? _self.cid : cid // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,currentUrl: null == currentUrl ? _self.currentUrl : currentUrl // ignore: cast_nullable_to_non_nullable
as String,currentAudioUrl: null == currentAudioUrl ? _self.currentAudioUrl : currentAudioUrl // ignore: cast_nullable_to_non_nullable
as String,currentQn: null == currentQn ? _self.currentQn : currentQn // ignore: cast_nullable_to_non_nullable
as int,qualities: null == qualities ? _self.qualities : qualities // ignore: cast_nullable_to_non_nullable
as List<VideoQualityItem>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isPlaying: null == isPlaying ? _self.isPlaying : isPlaying // ignore: cast_nullable_to_non_nullable
as bool,isBuffering: null == isBuffering ? _self.isBuffering : isBuffering // ignore: cast_nullable_to_non_nullable
as bool,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as Duration,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as Duration,showControls: null == showControls ? _self.showControls : showControls // ignore: cast_nullable_to_non_nullable
as bool,showQualityPanel: null == showQualityPanel ? _self.showQualityPanel : showQualityPanel // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PlayerState].
extension PlayerStatePatterns on PlayerState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlayerState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlayerState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlayerState value)  $default,){
final _that = this;
switch (_that) {
case _PlayerState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlayerState value)?  $default,){
final _that = this;
switch (_that) {
case _PlayerState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String bvid,  int cid,  String title,  String currentUrl,  String currentAudioUrl,  int currentQn,  List<VideoQualityItem> qualities,  bool isLoading,  bool isPlaying,  bool isBuffering,  Duration position,  Duration duration,  bool showControls,  bool showQualityPanel,  String? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlayerState() when $default != null:
return $default(_that.bvid,_that.cid,_that.title,_that.currentUrl,_that.currentAudioUrl,_that.currentQn,_that.qualities,_that.isLoading,_that.isPlaying,_that.isBuffering,_that.position,_that.duration,_that.showControls,_that.showQualityPanel,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String bvid,  int cid,  String title,  String currentUrl,  String currentAudioUrl,  int currentQn,  List<VideoQualityItem> qualities,  bool isLoading,  bool isPlaying,  bool isBuffering,  Duration position,  Duration duration,  bool showControls,  bool showQualityPanel,  String? error)  $default,) {final _that = this;
switch (_that) {
case _PlayerState():
return $default(_that.bvid,_that.cid,_that.title,_that.currentUrl,_that.currentAudioUrl,_that.currentQn,_that.qualities,_that.isLoading,_that.isPlaying,_that.isBuffering,_that.position,_that.duration,_that.showControls,_that.showQualityPanel,_that.error);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String bvid,  int cid,  String title,  String currentUrl,  String currentAudioUrl,  int currentQn,  List<VideoQualityItem> qualities,  bool isLoading,  bool isPlaying,  bool isBuffering,  Duration position,  Duration duration,  bool showControls,  bool showQualityPanel,  String? error)?  $default,) {final _that = this;
switch (_that) {
case _PlayerState() when $default != null:
return $default(_that.bvid,_that.cid,_that.title,_that.currentUrl,_that.currentAudioUrl,_that.currentQn,_that.qualities,_that.isLoading,_that.isPlaying,_that.isBuffering,_that.position,_that.duration,_that.showControls,_that.showQualityPanel,_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _PlayerState implements PlayerState {
  const _PlayerState({this.bvid = '', this.cid = 0, this.title = '', this.currentUrl = '', this.currentAudioUrl = '', this.currentQn = 80,  List<VideoQualityItem> qualities = const <VideoQualityItem>[], this.isLoading = true, this.isPlaying = false, this.isBuffering = false, this.position = Duration.zero, this.duration = Duration.zero, this.showControls = true, this.showQualityPanel = false, this.error}): _qualities = qualities;
  

@override@JsonKey() final  String bvid;
@override@JsonKey() final  int cid;
@override@JsonKey() final  String title;
@override@JsonKey() final  String currentUrl;
@override@JsonKey() final  String currentAudioUrl;
@override@JsonKey() final  int currentQn;
 final  List<VideoQualityItem> _qualities;
@override@JsonKey() List<VideoQualityItem> get qualities {
  if (_qualities is EqualUnmodifiableListView) return _qualities;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_qualities);
}

@override@JsonKey() final  bool isLoading;
@override@JsonKey() final  bool isPlaying;
@override@JsonKey() final  bool isBuffering;
@override@JsonKey() final  Duration position;
@override@JsonKey() final  Duration duration;
@override@JsonKey() final  bool showControls;
@override@JsonKey() final  bool showQualityPanel;
@override final  String? error;

/// Create a copy of PlayerState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlayerStateCopyWith<_PlayerState> get copyWith => __$PlayerStateCopyWithImpl<_PlayerState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlayerState&&(identical(other.bvid, bvid) || other.bvid == bvid)&&(identical(other.cid, cid) || other.cid == cid)&&(identical(other.title, title) || other.title == title)&&(identical(other.currentUrl, currentUrl) || other.currentUrl == currentUrl)&&(identical(other.currentAudioUrl, currentAudioUrl) || other.currentAudioUrl == currentAudioUrl)&&(identical(other.currentQn, currentQn) || other.currentQn == currentQn)&&const DeepCollectionEquality().equals(other.qualities, _qualities)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.isPlaying, isPlaying) || other.isPlaying == isPlaying)&&(identical(other.isBuffering, isBuffering) || other.isBuffering == isBuffering)&&(identical(other.position, position) || other.position == position)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.showControls, showControls) || other.showControls == showControls)&&(identical(other.showQualityPanel, showQualityPanel) || other.showQualityPanel == showQualityPanel)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode {
    return Object.hash(runtimeType,bvid,cid,title,currentUrl,currentAudioUrl,currentQn,const DeepCollectionEquality().hash(_qualities),isLoading,isPlaying,isBuffering,position,duration,showControls,showQualityPanel,error);
}

@override
String toString() {
    return 'PlayerState(bvid: $bvid, cid: $cid, title: $title, currentUrl: $currentUrl, currentAudioUrl: $currentAudioUrl, currentQn: $currentQn, qualities: $qualities, isLoading: $isLoading, isPlaying: $isPlaying, isBuffering: $isBuffering, position: $position, duration: $duration, showControls: $showControls, showQualityPanel: $showQualityPanel, error: $error)';
}


}

/// @nodoc
abstract mixin class _$PlayerStateCopyWith<$Res> implements $PlayerStateCopyWith<$Res> {
  factory _$PlayerStateCopyWith(_PlayerState value, $Res Function(_PlayerState) _then) = __$PlayerStateCopyWithImpl;
@override @useResult
$Res call({
 String bvid, int cid, String title, String currentUrl, String currentAudioUrl, int currentQn, List<VideoQualityItem> qualities, bool isLoading, bool isPlaying, bool isBuffering, Duration position, Duration duration, bool showControls, bool showQualityPanel, String? error
});




}
/// @nodoc
class __$PlayerStateCopyWithImpl<$Res>
    implements _$PlayerStateCopyWith<$Res> {
  __$PlayerStateCopyWithImpl(this._self, this._then);

  final _PlayerState _self;
  final $Res Function(_PlayerState) _then;

/// Create a copy of PlayerState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? bvid = null,Object? cid = null,Object? title = null,Object? currentUrl = null,Object? currentAudioUrl = null,Object? currentQn = null,Object? qualities = null,Object? isLoading = null,Object? isPlaying = null,Object? isBuffering = null,Object? position = null,Object? duration = null,Object? showControls = null,Object? showQualityPanel = null,Object? error = freezed,}) {
  return _then(_PlayerState(
bvid: null == bvid ? _self.bvid : bvid // ignore: cast_nullable_to_non_nullable
as String,cid: null == cid ? _self.cid : cid // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,currentUrl: null == currentUrl ? _self.currentUrl : currentUrl // ignore: cast_nullable_to_non_nullable
as String,currentAudioUrl: null == currentAudioUrl ? _self.currentAudioUrl : currentAudioUrl // ignore: cast_nullable_to_non_nullable
as String,currentQn: null == currentQn ? _self.currentQn : currentQn // ignore: cast_nullable_to_non_nullable
as int,qualities: null == qualities ? _self._qualities : qualities // ignore: cast_nullable_to_non_nullable
as List<VideoQualityItem>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isPlaying: null == isPlaying ? _self.isPlaying : isPlaying // ignore: cast_nullable_to_non_nullable
as bool,isBuffering: null == isBuffering ? _self.isBuffering : isBuffering // ignore: cast_nullable_to_non_nullable
as bool,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as Duration,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as Duration,showControls: null == showControls ? _self.showControls : showControls // ignore: cast_nullable_to_non_nullable
as bool,showQualityPanel: null == showQualityPanel ? _self.showQualityPanel : showQualityPanel // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on

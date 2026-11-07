// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../recommend_player_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RecommendPlayerState {

 int get currentIndex; String get currentPlayUrl; String get currentAudioUrl; int get currentQn; List<VideoQualityItem> get qualities; bool get isLoading; bool get isBuffering; bool get isPlaying; Duration get position; Duration get duration; double get speed; bool get isPurePlayback; bool get showControls; String get onlineCount; bool get hasLike; bool get hasDislike; bool get hasCoin; bool get hasFav; TvPlayMode get playMode; bool get danmakuEnabled; double get danmakuSize; double get danmakuSpeed; double get danmakuArea; VideoCollectionModel? get ugcSeason; List<VideoItemModel> get upWorks; List<VideoItemModel> get relatedVideos; String? get error;
/// Create a copy of RecommendPlayerState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecommendPlayerStateCopyWith<RecommendPlayerState> get copyWith => _$RecommendPlayerStateCopyWithImpl<RecommendPlayerState>(this as RecommendPlayerState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as RecommendPlayerState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecommendPlayerState&&(identical(other.currentIndex, _this.currentIndex) || other.currentIndex == _this.currentIndex)&&(identical(other.currentPlayUrl, _this.currentPlayUrl) || other.currentPlayUrl == _this.currentPlayUrl)&&(identical(other.currentAudioUrl, _this.currentAudioUrl) || other.currentAudioUrl == _this.currentAudioUrl)&&(identical(other.currentQn, _this.currentQn) || other.currentQn == _this.currentQn)&&const DeepCollectionEquality().equals(other.qualities, _this.qualities)&&(identical(other.isLoading, _this.isLoading) || other.isLoading == _this.isLoading)&&(identical(other.isBuffering, _this.isBuffering) || other.isBuffering == _this.isBuffering)&&(identical(other.isPlaying, _this.isPlaying) || other.isPlaying == _this.isPlaying)&&(identical(other.position, _this.position) || other.position == _this.position)&&(identical(other.duration, _this.duration) || other.duration == _this.duration)&&(identical(other.speed, _this.speed) || other.speed == _this.speed)&&(identical(other.isPurePlayback, _this.isPurePlayback) || other.isPurePlayback == _this.isPurePlayback)&&(identical(other.showControls, _this.showControls) || other.showControls == _this.showControls)&&(identical(other.onlineCount, _this.onlineCount) || other.onlineCount == _this.onlineCount)&&(identical(other.hasLike, _this.hasLike) || other.hasLike == _this.hasLike)&&(identical(other.hasDislike, _this.hasDislike) || other.hasDislike == _this.hasDislike)&&(identical(other.hasCoin, _this.hasCoin) || other.hasCoin == _this.hasCoin)&&(identical(other.hasFav, _this.hasFav) || other.hasFav == _this.hasFav)&&(identical(other.playMode, _this.playMode) || other.playMode == _this.playMode)&&(identical(other.danmakuEnabled, _this.danmakuEnabled) || other.danmakuEnabled == _this.danmakuEnabled)&&(identical(other.danmakuSize, _this.danmakuSize) || other.danmakuSize == _this.danmakuSize)&&(identical(other.danmakuSpeed, _this.danmakuSpeed) || other.danmakuSpeed == _this.danmakuSpeed)&&(identical(other.danmakuArea, _this.danmakuArea) || other.danmakuArea == _this.danmakuArea)&&(identical(other.ugcSeason, _this.ugcSeason) || other.ugcSeason == _this.ugcSeason)&&const DeepCollectionEquality().equals(other.upWorks, _this.upWorks)&&const DeepCollectionEquality().equals(other.relatedVideos, _this.relatedVideos)&&(identical(other.error, _this.error) || other.error == _this.error));
}


@override
int get hashCode {
  final _this = this as RecommendPlayerState;
  return Object.hashAll([runtimeType,_this.currentIndex,_this.currentPlayUrl,_this.currentAudioUrl,_this.currentQn,const DeepCollectionEquality().hash(_this.qualities),_this.isLoading,_this.isBuffering,_this.isPlaying,_this.position,_this.duration,_this.speed,_this.isPurePlayback,_this.showControls,_this.onlineCount,_this.hasLike,_this.hasDislike,_this.hasCoin,_this.hasFav,_this.playMode,_this.danmakuEnabled,_this.danmakuSize,_this.danmakuSpeed,_this.danmakuArea,_this.ugcSeason,const DeepCollectionEquality().hash(_this.upWorks),const DeepCollectionEquality().hash(_this.relatedVideos),_this.error]);
}

@override
String toString() {
  final _this = this as RecommendPlayerState;
  return 'RecommendPlayerState(currentIndex: ${_this.currentIndex}, currentPlayUrl: ${_this.currentPlayUrl}, currentAudioUrl: ${_this.currentAudioUrl}, currentQn: ${_this.currentQn}, qualities: ${_this.qualities}, isLoading: ${_this.isLoading}, isBuffering: ${_this.isBuffering}, isPlaying: ${_this.isPlaying}, position: ${_this.position}, duration: ${_this.duration}, speed: ${_this.speed}, isPurePlayback: ${_this.isPurePlayback}, showControls: ${_this.showControls}, onlineCount: ${_this.onlineCount}, hasLike: ${_this.hasLike}, hasDislike: ${_this.hasDislike}, hasCoin: ${_this.hasCoin}, hasFav: ${_this.hasFav}, playMode: ${_this.playMode}, danmakuEnabled: ${_this.danmakuEnabled}, danmakuSize: ${_this.danmakuSize}, danmakuSpeed: ${_this.danmakuSpeed}, danmakuArea: ${_this.danmakuArea}, ugcSeason: ${_this.ugcSeason}, upWorks: ${_this.upWorks}, relatedVideos: ${_this.relatedVideos}, error: ${_this.error})';
}


}

/// @nodoc
abstract mixin class $RecommendPlayerStateCopyWith<$Res>  {
  factory $RecommendPlayerStateCopyWith(RecommendPlayerState value, $Res Function(RecommendPlayerState) _then) = _$RecommendPlayerStateCopyWithImpl;
@useResult
$Res call({
 int currentIndex, String currentPlayUrl, String currentAudioUrl, int currentQn, List<VideoQualityItem> qualities, bool isLoading, bool isBuffering, bool isPlaying, Duration position, Duration duration, double speed, bool isPurePlayback, bool showControls, String onlineCount, bool hasLike, bool hasDislike, bool hasCoin, bool hasFav, TvPlayMode playMode, bool danmakuEnabled, double danmakuSize, double danmakuSpeed, double danmakuArea, VideoCollectionModel? ugcSeason, List<VideoItemModel> upWorks, List<VideoItemModel> relatedVideos, String? error
});


$VideoCollectionModelCopyWith<$Res>? get ugcSeason;

}
/// @nodoc
class _$RecommendPlayerStateCopyWithImpl<$Res>
    implements $RecommendPlayerStateCopyWith<$Res> {
  _$RecommendPlayerStateCopyWithImpl(this._self, this._then);

  final RecommendPlayerState _self;
  final $Res Function(RecommendPlayerState) _then;

/// Create a copy of RecommendPlayerState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? currentIndex = null,Object? currentPlayUrl = null,Object? currentAudioUrl = null,Object? currentQn = null,Object? qualities = null,Object? isLoading = null,Object? isBuffering = null,Object? isPlaying = null,Object? position = null,Object? duration = null,Object? speed = null,Object? isPurePlayback = null,Object? showControls = null,Object? onlineCount = null,Object? hasLike = null,Object? hasDislike = null,Object? hasCoin = null,Object? hasFav = null,Object? playMode = null,Object? danmakuEnabled = null,Object? danmakuSize = null,Object? danmakuSpeed = null,Object? danmakuArea = null,Object? ugcSeason = freezed,Object? upWorks = null,Object? relatedVideos = null,Object? error = freezed,}) {
  return _then(RecommendPlayerState(
currentIndex: null == currentIndex ? _self.currentIndex : currentIndex // ignore: cast_nullable_to_non_nullable
as int,currentPlayUrl: null == currentPlayUrl ? _self.currentPlayUrl : currentPlayUrl // ignore: cast_nullable_to_non_nullable
as String,currentAudioUrl: null == currentAudioUrl ? _self.currentAudioUrl : currentAudioUrl // ignore: cast_nullable_to_non_nullable
as String,currentQn: null == currentQn ? _self.currentQn : currentQn // ignore: cast_nullable_to_non_nullable
as int,qualities: null == qualities ? _self.qualities : qualities // ignore: cast_nullable_to_non_nullable
as List<VideoQualityItem>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isBuffering: null == isBuffering ? _self.isBuffering : isBuffering // ignore: cast_nullable_to_non_nullable
as bool,isPlaying: null == isPlaying ? _self.isPlaying : isPlaying // ignore: cast_nullable_to_non_nullable
as bool,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as Duration,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as Duration,speed: null == speed ? _self.speed : speed // ignore: cast_nullable_to_non_nullable
as double,isPurePlayback: null == isPurePlayback ? _self.isPurePlayback : isPurePlayback // ignore: cast_nullable_to_non_nullable
as bool,showControls: null == showControls ? _self.showControls : showControls // ignore: cast_nullable_to_non_nullable
as bool,onlineCount: null == onlineCount ? _self.onlineCount : onlineCount // ignore: cast_nullable_to_non_nullable
as String,hasLike: null == hasLike ? _self.hasLike : hasLike // ignore: cast_nullable_to_non_nullable
as bool,hasDislike: null == hasDislike ? _self.hasDislike : hasDislike // ignore: cast_nullable_to_non_nullable
as bool,hasCoin: null == hasCoin ? _self.hasCoin : hasCoin // ignore: cast_nullable_to_non_nullable
as bool,hasFav: null == hasFav ? _self.hasFav : hasFav // ignore: cast_nullable_to_non_nullable
as bool,playMode: null == playMode ? _self.playMode : playMode // ignore: cast_nullable_to_non_nullable
as TvPlayMode,danmakuEnabled: null == danmakuEnabled ? _self.danmakuEnabled : danmakuEnabled // ignore: cast_nullable_to_non_nullable
as bool,danmakuSize: null == danmakuSize ? _self.danmakuSize : danmakuSize // ignore: cast_nullable_to_non_nullable
as double,danmakuSpeed: null == danmakuSpeed ? _self.danmakuSpeed : danmakuSpeed // ignore: cast_nullable_to_non_nullable
as double,danmakuArea: null == danmakuArea ? _self.danmakuArea : danmakuArea // ignore: cast_nullable_to_non_nullable
as double,ugcSeason: freezed == ugcSeason ? _self.ugcSeason : ugcSeason // ignore: cast_nullable_to_non_nullable
as VideoCollectionModel?,upWorks: null == upWorks ? _self.upWorks : upWorks // ignore: cast_nullable_to_non_nullable
as List<VideoItemModel>,relatedVideos: null == relatedVideos ? _self.relatedVideos : relatedVideos // ignore: cast_nullable_to_non_nullable
as List<VideoItemModel>,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of RecommendPlayerState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VideoCollectionModelCopyWith<$Res>? get ugcSeason {
    if (_self.ugcSeason == null) {
    return null;
  }

  return $VideoCollectionModelCopyWith<$Res>(_self.ugcSeason!, (value) {
    return _then(_self.copyWith(ugcSeason: value));
  });
}
}


/// Adds pattern-matching-related methods to [RecommendPlayerState].
extension RecommendPlayerStatePatterns on RecommendPlayerState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RecommendPlayerState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RecommendPlayerState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RecommendPlayerState value)  $default,){
final _that = this;
switch (_that) {
case _RecommendPlayerState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RecommendPlayerState value)?  $default,){
final _that = this;
switch (_that) {
case _RecommendPlayerState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int currentIndex,  String currentPlayUrl,  String currentAudioUrl,  int currentQn,  List<VideoQualityItem> qualities,  bool isLoading,  bool isBuffering,  bool isPlaying,  Duration position,  Duration duration,  double speed,  bool isPurePlayback,  bool showControls,  String onlineCount,  bool hasLike,  bool hasDislike,  bool hasCoin,  bool hasFav,  TvPlayMode playMode,  bool danmakuEnabled,  double danmakuSize,  double danmakuSpeed,  double danmakuArea,  VideoCollectionModel? ugcSeason,  List<VideoItemModel> upWorks,  List<VideoItemModel> relatedVideos,  String? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecommendPlayerState() when $default != null:
return $default(_that.currentIndex,_that.currentPlayUrl,_that.currentAudioUrl,_that.currentQn,_that.qualities,_that.isLoading,_that.isBuffering,_that.isPlaying,_that.position,_that.duration,_that.speed,_that.isPurePlayback,_that.showControls,_that.onlineCount,_that.hasLike,_that.hasDislike,_that.hasCoin,_that.hasFav,_that.playMode,_that.danmakuEnabled,_that.danmakuSize,_that.danmakuSpeed,_that.danmakuArea,_that.ugcSeason,_that.upWorks,_that.relatedVideos,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int currentIndex,  String currentPlayUrl,  String currentAudioUrl,  int currentQn,  List<VideoQualityItem> qualities,  bool isLoading,  bool isBuffering,  bool isPlaying,  Duration position,  Duration duration,  double speed,  bool isPurePlayback,  bool showControls,  String onlineCount,  bool hasLike,  bool hasDislike,  bool hasCoin,  bool hasFav,  TvPlayMode playMode,  bool danmakuEnabled,  double danmakuSize,  double danmakuSpeed,  double danmakuArea,  VideoCollectionModel? ugcSeason,  List<VideoItemModel> upWorks,  List<VideoItemModel> relatedVideos,  String? error)  $default,) {final _that = this;
switch (_that) {
case _RecommendPlayerState():
return $default(_that.currentIndex,_that.currentPlayUrl,_that.currentAudioUrl,_that.currentQn,_that.qualities,_that.isLoading,_that.isBuffering,_that.isPlaying,_that.position,_that.duration,_that.speed,_that.isPurePlayback,_that.showControls,_that.onlineCount,_that.hasLike,_that.hasDislike,_that.hasCoin,_that.hasFav,_that.playMode,_that.danmakuEnabled,_that.danmakuSize,_that.danmakuSpeed,_that.danmakuArea,_that.ugcSeason,_that.upWorks,_that.relatedVideos,_that.error);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int currentIndex,  String currentPlayUrl,  String currentAudioUrl,  int currentQn,  List<VideoQualityItem> qualities,  bool isLoading,  bool isBuffering,  bool isPlaying,  Duration position,  Duration duration,  double speed,  bool isPurePlayback,  bool showControls,  String onlineCount,  bool hasLike,  bool hasDislike,  bool hasCoin,  bool hasFav,  TvPlayMode playMode,  bool danmakuEnabled,  double danmakuSize,  double danmakuSpeed,  double danmakuArea,  VideoCollectionModel? ugcSeason,  List<VideoItemModel> upWorks,  List<VideoItemModel> relatedVideos,  String? error)?  $default,) {final _that = this;
switch (_that) {
case _RecommendPlayerState() when $default != null:
return $default(_that.currentIndex,_that.currentPlayUrl,_that.currentAudioUrl,_that.currentQn,_that.qualities,_that.isLoading,_that.isBuffering,_that.isPlaying,_that.position,_that.duration,_that.speed,_that.isPurePlayback,_that.showControls,_that.onlineCount,_that.hasLike,_that.hasDislike,_that.hasCoin,_that.hasFav,_that.playMode,_that.danmakuEnabled,_that.danmakuSize,_that.danmakuSpeed,_that.danmakuArea,_that.ugcSeason,_that.upWorks,_that.relatedVideos,_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _RecommendPlayerState implements RecommendPlayerState {
  const _RecommendPlayerState({this.currentIndex = 0, this.currentPlayUrl = '', this.currentAudioUrl = '', this.currentQn = 80,  List<VideoQualityItem> qualities = const [], this.isLoading = true, this.isBuffering = false, this.isPlaying = false, this.position = Duration.zero, this.duration = Duration.zero, this.speed = 1.0, this.isPurePlayback = false, this.showControls = false, this.onlineCount = '', this.hasLike = false, this.hasDislike = false, this.hasCoin = false, this.hasFav = false, this.playMode = TvPlayMode.sequence, this.danmakuEnabled = true, this.danmakuSize = 1.0, this.danmakuSpeed = 1.0, this.danmakuArea = 1.0, this.ugcSeason,  List<VideoItemModel> upWorks = const [],  List<VideoItemModel> relatedVideos = const [], this.error}): _qualities = qualities,_upWorks = upWorks,_relatedVideos = relatedVideos;
  

@override@JsonKey() final  int currentIndex;
@override@JsonKey() final  String currentPlayUrl;
@override@JsonKey() final  String currentAudioUrl;
@override@JsonKey() final  int currentQn;
 final  List<VideoQualityItem> _qualities;
@override@JsonKey() List<VideoQualityItem> get qualities {
  if (_qualities is EqualUnmodifiableListView) return _qualities;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_qualities);
}

@override@JsonKey() final  bool isLoading;
@override@JsonKey() final  bool isBuffering;
@override@JsonKey() final  bool isPlaying;
@override@JsonKey() final  Duration position;
@override@JsonKey() final  Duration duration;
@override@JsonKey() final  double speed;
@override@JsonKey() final  bool isPurePlayback;
@override@JsonKey() final  bool showControls;
@override@JsonKey() final  String onlineCount;
@override@JsonKey() final  bool hasLike;
@override@JsonKey() final  bool hasDislike;
@override@JsonKey() final  bool hasCoin;
@override@JsonKey() final  bool hasFav;
@override@JsonKey() final  TvPlayMode playMode;
@override@JsonKey() final  bool danmakuEnabled;
@override@JsonKey() final  double danmakuSize;
@override@JsonKey() final  double danmakuSpeed;
@override@JsonKey() final  double danmakuArea;
@override final  VideoCollectionModel? ugcSeason;
 final  List<VideoItemModel> _upWorks;
@override@JsonKey() List<VideoItemModel> get upWorks {
  if (_upWorks is EqualUnmodifiableListView) return _upWorks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_upWorks);
}

 final  List<VideoItemModel> _relatedVideos;
@override@JsonKey() List<VideoItemModel> get relatedVideos {
  if (_relatedVideos is EqualUnmodifiableListView) return _relatedVideos;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_relatedVideos);
}

@override final  String? error;

/// Create a copy of RecommendPlayerState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecommendPlayerStateCopyWith<_RecommendPlayerState> get copyWith => __$RecommendPlayerStateCopyWithImpl<_RecommendPlayerState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecommendPlayerState&&(identical(other.currentIndex, currentIndex) || other.currentIndex == currentIndex)&&(identical(other.currentPlayUrl, currentPlayUrl) || other.currentPlayUrl == currentPlayUrl)&&(identical(other.currentAudioUrl, currentAudioUrl) || other.currentAudioUrl == currentAudioUrl)&&(identical(other.currentQn, currentQn) || other.currentQn == currentQn)&&const DeepCollectionEquality().equals(other.qualities, _qualities)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.isBuffering, isBuffering) || other.isBuffering == isBuffering)&&(identical(other.isPlaying, isPlaying) || other.isPlaying == isPlaying)&&(identical(other.position, position) || other.position == position)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.speed, speed) || other.speed == speed)&&(identical(other.isPurePlayback, isPurePlayback) || other.isPurePlayback == isPurePlayback)&&(identical(other.showControls, showControls) || other.showControls == showControls)&&(identical(other.onlineCount, onlineCount) || other.onlineCount == onlineCount)&&(identical(other.hasLike, hasLike) || other.hasLike == hasLike)&&(identical(other.hasDislike, hasDislike) || other.hasDislike == hasDislike)&&(identical(other.hasCoin, hasCoin) || other.hasCoin == hasCoin)&&(identical(other.hasFav, hasFav) || other.hasFav == hasFav)&&(identical(other.playMode, playMode) || other.playMode == playMode)&&(identical(other.danmakuEnabled, danmakuEnabled) || other.danmakuEnabled == danmakuEnabled)&&(identical(other.danmakuSize, danmakuSize) || other.danmakuSize == danmakuSize)&&(identical(other.danmakuSpeed, danmakuSpeed) || other.danmakuSpeed == danmakuSpeed)&&(identical(other.danmakuArea, danmakuArea) || other.danmakuArea == danmakuArea)&&(identical(other.ugcSeason, ugcSeason) || other.ugcSeason == ugcSeason)&&const DeepCollectionEquality().equals(other.upWorks, _upWorks)&&const DeepCollectionEquality().equals(other.relatedVideos, _relatedVideos)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode {
    return Object.hashAll([runtimeType,currentIndex,currentPlayUrl,currentAudioUrl,currentQn,const DeepCollectionEquality().hash(_qualities),isLoading,isBuffering,isPlaying,position,duration,speed,isPurePlayback,showControls,onlineCount,hasLike,hasDislike,hasCoin,hasFav,playMode,danmakuEnabled,danmakuSize,danmakuSpeed,danmakuArea,ugcSeason,const DeepCollectionEquality().hash(_upWorks),const DeepCollectionEquality().hash(_relatedVideos),error]);
}

@override
String toString() {
    return 'RecommendPlayerState(currentIndex: $currentIndex, currentPlayUrl: $currentPlayUrl, currentAudioUrl: $currentAudioUrl, currentQn: $currentQn, qualities: $qualities, isLoading: $isLoading, isBuffering: $isBuffering, isPlaying: $isPlaying, position: $position, duration: $duration, speed: $speed, isPurePlayback: $isPurePlayback, showControls: $showControls, onlineCount: $onlineCount, hasLike: $hasLike, hasDislike: $hasDislike, hasCoin: $hasCoin, hasFav: $hasFav, playMode: $playMode, danmakuEnabled: $danmakuEnabled, danmakuSize: $danmakuSize, danmakuSpeed: $danmakuSpeed, danmakuArea: $danmakuArea, ugcSeason: $ugcSeason, upWorks: $upWorks, relatedVideos: $relatedVideos, error: $error)';
}


}

/// @nodoc
abstract mixin class _$RecommendPlayerStateCopyWith<$Res> implements $RecommendPlayerStateCopyWith<$Res> {
  factory _$RecommendPlayerStateCopyWith(_RecommendPlayerState value, $Res Function(_RecommendPlayerState) _then) = __$RecommendPlayerStateCopyWithImpl;
@override @useResult
$Res call({
 int currentIndex, String currentPlayUrl, String currentAudioUrl, int currentQn, List<VideoQualityItem> qualities, bool isLoading, bool isBuffering, bool isPlaying, Duration position, Duration duration, double speed, bool isPurePlayback, bool showControls, String onlineCount, bool hasLike, bool hasDislike, bool hasCoin, bool hasFav, TvPlayMode playMode, bool danmakuEnabled, double danmakuSize, double danmakuSpeed, double danmakuArea, VideoCollectionModel? ugcSeason, List<VideoItemModel> upWorks, List<VideoItemModel> relatedVideos, String? error
});


@override $VideoCollectionModelCopyWith<$Res>? get ugcSeason;

}
/// @nodoc
class __$RecommendPlayerStateCopyWithImpl<$Res>
    implements _$RecommendPlayerStateCopyWith<$Res> {
  __$RecommendPlayerStateCopyWithImpl(this._self, this._then);

  final _RecommendPlayerState _self;
  final $Res Function(_RecommendPlayerState) _then;

/// Create a copy of RecommendPlayerState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? currentIndex = null,Object? currentPlayUrl = null,Object? currentAudioUrl = null,Object? currentQn = null,Object? qualities = null,Object? isLoading = null,Object? isBuffering = null,Object? isPlaying = null,Object? position = null,Object? duration = null,Object? speed = null,Object? isPurePlayback = null,Object? showControls = null,Object? onlineCount = null,Object? hasLike = null,Object? hasDislike = null,Object? hasCoin = null,Object? hasFav = null,Object? playMode = null,Object? danmakuEnabled = null,Object? danmakuSize = null,Object? danmakuSpeed = null,Object? danmakuArea = null,Object? ugcSeason = freezed,Object? upWorks = null,Object? relatedVideos = null,Object? error = freezed,}) {
  return _then(_RecommendPlayerState(
currentIndex: null == currentIndex ? _self.currentIndex : currentIndex // ignore: cast_nullable_to_non_nullable
as int,currentPlayUrl: null == currentPlayUrl ? _self.currentPlayUrl : currentPlayUrl // ignore: cast_nullable_to_non_nullable
as String,currentAudioUrl: null == currentAudioUrl ? _self.currentAudioUrl : currentAudioUrl // ignore: cast_nullable_to_non_nullable
as String,currentQn: null == currentQn ? _self.currentQn : currentQn // ignore: cast_nullable_to_non_nullable
as int,qualities: null == qualities ? _self._qualities : qualities // ignore: cast_nullable_to_non_nullable
as List<VideoQualityItem>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isBuffering: null == isBuffering ? _self.isBuffering : isBuffering // ignore: cast_nullable_to_non_nullable
as bool,isPlaying: null == isPlaying ? _self.isPlaying : isPlaying // ignore: cast_nullable_to_non_nullable
as bool,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as Duration,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as Duration,speed: null == speed ? _self.speed : speed // ignore: cast_nullable_to_non_nullable
as double,isPurePlayback: null == isPurePlayback ? _self.isPurePlayback : isPurePlayback // ignore: cast_nullable_to_non_nullable
as bool,showControls: null == showControls ? _self.showControls : showControls // ignore: cast_nullable_to_non_nullable
as bool,onlineCount: null == onlineCount ? _self.onlineCount : onlineCount // ignore: cast_nullable_to_non_nullable
as String,hasLike: null == hasLike ? _self.hasLike : hasLike // ignore: cast_nullable_to_non_nullable
as bool,hasDislike: null == hasDislike ? _self.hasDislike : hasDislike // ignore: cast_nullable_to_non_nullable
as bool,hasCoin: null == hasCoin ? _self.hasCoin : hasCoin // ignore: cast_nullable_to_non_nullable
as bool,hasFav: null == hasFav ? _self.hasFav : hasFav // ignore: cast_nullable_to_non_nullable
as bool,playMode: null == playMode ? _self.playMode : playMode // ignore: cast_nullable_to_non_nullable
as TvPlayMode,danmakuEnabled: null == danmakuEnabled ? _self.danmakuEnabled : danmakuEnabled // ignore: cast_nullable_to_non_nullable
as bool,danmakuSize: null == danmakuSize ? _self.danmakuSize : danmakuSize // ignore: cast_nullable_to_non_nullable
as double,danmakuSpeed: null == danmakuSpeed ? _self.danmakuSpeed : danmakuSpeed // ignore: cast_nullable_to_non_nullable
as double,danmakuArea: null == danmakuArea ? _self.danmakuArea : danmakuArea // ignore: cast_nullable_to_non_nullable
as double,ugcSeason: freezed == ugcSeason ? _self.ugcSeason : ugcSeason // ignore: cast_nullable_to_non_nullable
as VideoCollectionModel?,upWorks: null == upWorks ? _self._upWorks : upWorks // ignore: cast_nullable_to_non_nullable
as List<VideoItemModel>,relatedVideos: null == relatedVideos ? _self._relatedVideos : relatedVideos // ignore: cast_nullable_to_non_nullable
as List<VideoItemModel>,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of RecommendPlayerState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VideoCollectionModelCopyWith<$Res>? get ugcSeason {
    if (_self.ugcSeason == null) {
    return null;
  }

  return $VideoCollectionModelCopyWith<$Res>(_self.ugcSeason!, (value) {
    return _then(_self.copyWith(ugcSeason: value));
  });
}
}

// dart format on

// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../playback_session.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PlaybackSession {

 String get sessionId; String get ownerId; List<VideoItemModel> get playlist; int get currentIndex; VideoItemModel? get currentVideo; String? get videoUrl; String? get audioUrl; String? get coverUrl; Duration get lastPosition; Duration get duration; Uint8List? get lastFrameBytes; int get quality; double get speed; bool get isLive; Map<String, String> get httpHeaders;
/// Create a copy of PlaybackSession
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlaybackSessionCopyWith<PlaybackSession> get copyWith => _$PlaybackSessionCopyWithImpl<PlaybackSession>(this as PlaybackSession, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PlaybackSession;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlaybackSession&&(identical(other.sessionId, _this.sessionId) || other.sessionId == _this.sessionId)&&(identical(other.ownerId, _this.ownerId) || other.ownerId == _this.ownerId)&&const DeepCollectionEquality().equals(other.playlist, _this.playlist)&&(identical(other.currentIndex, _this.currentIndex) || other.currentIndex == _this.currentIndex)&&(identical(other.currentVideo, _this.currentVideo) || other.currentVideo == _this.currentVideo)&&(identical(other.videoUrl, _this.videoUrl) || other.videoUrl == _this.videoUrl)&&(identical(other.audioUrl, _this.audioUrl) || other.audioUrl == _this.audioUrl)&&(identical(other.coverUrl, _this.coverUrl) || other.coverUrl == _this.coverUrl)&&(identical(other.lastPosition, _this.lastPosition) || other.lastPosition == _this.lastPosition)&&(identical(other.duration, _this.duration) || other.duration == _this.duration)&&const DeepCollectionEquality().equals(other.lastFrameBytes, _this.lastFrameBytes)&&(identical(other.quality, _this.quality) || other.quality == _this.quality)&&(identical(other.speed, _this.speed) || other.speed == _this.speed)&&(identical(other.isLive, _this.isLive) || other.isLive == _this.isLive)&&const DeepCollectionEquality().equals(other.httpHeaders, _this.httpHeaders));
}


@override
int get hashCode {
  final _this = this as PlaybackSession;
  return Object.hash(runtimeType,_this.sessionId,_this.ownerId,const DeepCollectionEquality().hash(_this.playlist),_this.currentIndex,_this.currentVideo,_this.videoUrl,_this.audioUrl,_this.coverUrl,_this.lastPosition,_this.duration,const DeepCollectionEquality().hash(_this.lastFrameBytes),_this.quality,_this.speed,_this.isLive,const DeepCollectionEquality().hash(_this.httpHeaders));
}

@override
String toString() {
  final _this = this as PlaybackSession;
  return 'PlaybackSession(sessionId: ${_this.sessionId}, ownerId: ${_this.ownerId}, playlist: ${_this.playlist}, currentIndex: ${_this.currentIndex}, currentVideo: ${_this.currentVideo}, videoUrl: ${_this.videoUrl}, audioUrl: ${_this.audioUrl}, coverUrl: ${_this.coverUrl}, lastPosition: ${_this.lastPosition}, duration: ${_this.duration}, lastFrameBytes: ${_this.lastFrameBytes}, quality: ${_this.quality}, speed: ${_this.speed}, isLive: ${_this.isLive}, httpHeaders: ${_this.httpHeaders})';
}


}

/// @nodoc
abstract mixin class $PlaybackSessionCopyWith<$Res>  {
  factory $PlaybackSessionCopyWith(PlaybackSession value, $Res Function(PlaybackSession) _then) = _$PlaybackSessionCopyWithImpl;
@useResult
$Res call({
 String sessionId, String ownerId, List<VideoItemModel> playlist, int currentIndex, VideoItemModel? currentVideo, String? videoUrl, String? audioUrl, String? coverUrl, Duration lastPosition, Duration duration, Uint8List? lastFrameBytes, int quality, double speed, bool isLive, Map<String, String> httpHeaders
});


$VideoItemModelCopyWith<$Res>? get currentVideo;

}
/// @nodoc
class _$PlaybackSessionCopyWithImpl<$Res>
    implements $PlaybackSessionCopyWith<$Res> {
  _$PlaybackSessionCopyWithImpl(this._self, this._then);

  final PlaybackSession _self;
  final $Res Function(PlaybackSession) _then;

/// Create a copy of PlaybackSession
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sessionId = null,Object? ownerId = null,Object? playlist = null,Object? currentIndex = null,Object? currentVideo = freezed,Object? videoUrl = freezed,Object? audioUrl = freezed,Object? coverUrl = freezed,Object? lastPosition = null,Object? duration = null,Object? lastFrameBytes = freezed,Object? quality = null,Object? speed = null,Object? isLive = null,Object? httpHeaders = null,}) {
  return _then(PlaybackSession(
sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,ownerId: null == ownerId ? _self.ownerId : ownerId // ignore: cast_nullable_to_non_nullable
as String,playlist: null == playlist ? _self.playlist : playlist // ignore: cast_nullable_to_non_nullable
as List<VideoItemModel>,currentIndex: null == currentIndex ? _self.currentIndex : currentIndex // ignore: cast_nullable_to_non_nullable
as int,currentVideo: freezed == currentVideo ? _self.currentVideo : currentVideo // ignore: cast_nullable_to_non_nullable
as VideoItemModel?,videoUrl: freezed == videoUrl ? _self.videoUrl : videoUrl // ignore: cast_nullable_to_non_nullable
as String?,audioUrl: freezed == audioUrl ? _self.audioUrl : audioUrl // ignore: cast_nullable_to_non_nullable
as String?,coverUrl: freezed == coverUrl ? _self.coverUrl : coverUrl // ignore: cast_nullable_to_non_nullable
as String?,lastPosition: null == lastPosition ? _self.lastPosition : lastPosition // ignore: cast_nullable_to_non_nullable
as Duration,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as Duration,lastFrameBytes: freezed == lastFrameBytes ? _self.lastFrameBytes : lastFrameBytes // ignore: cast_nullable_to_non_nullable
as Uint8List?,quality: null == quality ? _self.quality : quality // ignore: cast_nullable_to_non_nullable
as int,speed: null == speed ? _self.speed : speed // ignore: cast_nullable_to_non_nullable
as double,isLive: null == isLive ? _self.isLive : isLive // ignore: cast_nullable_to_non_nullable
as bool,httpHeaders: null == httpHeaders ? _self.httpHeaders : httpHeaders // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}
/// Create a copy of PlaybackSession
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VideoItemModelCopyWith<$Res>? get currentVideo {
    if (_self.currentVideo == null) {
    return null;
  }

  return $VideoItemModelCopyWith<$Res>(_self.currentVideo!, (value) {
    return _then(_self.copyWith(currentVideo: value));
  });
}
}


/// Adds pattern-matching-related methods to [PlaybackSession].
extension PlaybackSessionPatterns on PlaybackSession {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlaybackSession value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlaybackSession() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlaybackSession value)  $default,){
final _that = this;
switch (_that) {
case _PlaybackSession():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlaybackSession value)?  $default,){
final _that = this;
switch (_that) {
case _PlaybackSession() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String sessionId,  String ownerId,  List<VideoItemModel> playlist,  int currentIndex,  VideoItemModel? currentVideo,  String? videoUrl,  String? audioUrl,  String? coverUrl,  Duration lastPosition,  Duration duration,  Uint8List? lastFrameBytes,  int quality,  double speed,  bool isLive,  Map<String, String> httpHeaders)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlaybackSession() when $default != null:
return $default(_that.sessionId,_that.ownerId,_that.playlist,_that.currentIndex,_that.currentVideo,_that.videoUrl,_that.audioUrl,_that.coverUrl,_that.lastPosition,_that.duration,_that.lastFrameBytes,_that.quality,_that.speed,_that.isLive,_that.httpHeaders);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String sessionId,  String ownerId,  List<VideoItemModel> playlist,  int currentIndex,  VideoItemModel? currentVideo,  String? videoUrl,  String? audioUrl,  String? coverUrl,  Duration lastPosition,  Duration duration,  Uint8List? lastFrameBytes,  int quality,  double speed,  bool isLive,  Map<String, String> httpHeaders)  $default,) {final _that = this;
switch (_that) {
case _PlaybackSession():
return $default(_that.sessionId,_that.ownerId,_that.playlist,_that.currentIndex,_that.currentVideo,_that.videoUrl,_that.audioUrl,_that.coverUrl,_that.lastPosition,_that.duration,_that.lastFrameBytes,_that.quality,_that.speed,_that.isLive,_that.httpHeaders);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String sessionId,  String ownerId,  List<VideoItemModel> playlist,  int currentIndex,  VideoItemModel? currentVideo,  String? videoUrl,  String? audioUrl,  String? coverUrl,  Duration lastPosition,  Duration duration,  Uint8List? lastFrameBytes,  int quality,  double speed,  bool isLive,  Map<String, String> httpHeaders)?  $default,) {final _that = this;
switch (_that) {
case _PlaybackSession() when $default != null:
return $default(_that.sessionId,_that.ownerId,_that.playlist,_that.currentIndex,_that.currentVideo,_that.videoUrl,_that.audioUrl,_that.coverUrl,_that.lastPosition,_that.duration,_that.lastFrameBytes,_that.quality,_that.speed,_that.isLive,_that.httpHeaders);case _:
  return null;

}
}

}

/// @nodoc


class _PlaybackSession implements PlaybackSession {
  const _PlaybackSession({required this.sessionId, this.ownerId = '',  List<VideoItemModel> playlist = const [], this.currentIndex = 0, this.currentVideo, this.videoUrl, this.audioUrl, this.coverUrl, this.lastPosition = Duration.zero, this.duration = Duration.zero, this.lastFrameBytes, this.quality = 80, this.speed = 1.0, this.isLive = false,  Map<String, String> httpHeaders = const {}}): _playlist = playlist,_httpHeaders = httpHeaders;
  

@override final  String sessionId;
@override@JsonKey() final  String ownerId;
 final  List<VideoItemModel> _playlist;
@override@JsonKey() List<VideoItemModel> get playlist {
  if (_playlist is EqualUnmodifiableListView) return _playlist;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_playlist);
}

@override@JsonKey() final  int currentIndex;
@override final  VideoItemModel? currentVideo;
@override final  String? videoUrl;
@override final  String? audioUrl;
@override final  String? coverUrl;
@override@JsonKey() final  Duration lastPosition;
@override@JsonKey() final  Duration duration;
@override final  Uint8List? lastFrameBytes;
@override@JsonKey() final  int quality;
@override@JsonKey() final  double speed;
@override@JsonKey() final  bool isLive;
 final  Map<String, String> _httpHeaders;
@override@JsonKey() Map<String, String> get httpHeaders {
  if (_httpHeaders is EqualUnmodifiableMapView) return _httpHeaders;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_httpHeaders);
}


/// Create a copy of PlaybackSession
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlaybackSessionCopyWith<_PlaybackSession> get copyWith => __$PlaybackSessionCopyWithImpl<_PlaybackSession>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlaybackSession&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.ownerId, ownerId) || other.ownerId == ownerId)&&const DeepCollectionEquality().equals(other.playlist, _playlist)&&(identical(other.currentIndex, currentIndex) || other.currentIndex == currentIndex)&&(identical(other.currentVideo, currentVideo) || other.currentVideo == currentVideo)&&(identical(other.videoUrl, videoUrl) || other.videoUrl == videoUrl)&&(identical(other.audioUrl, audioUrl) || other.audioUrl == audioUrl)&&(identical(other.coverUrl, coverUrl) || other.coverUrl == coverUrl)&&(identical(other.lastPosition, lastPosition) || other.lastPosition == lastPosition)&&(identical(other.duration, duration) || other.duration == duration)&&const DeepCollectionEquality().equals(other.lastFrameBytes, lastFrameBytes)&&(identical(other.quality, quality) || other.quality == quality)&&(identical(other.speed, speed) || other.speed == speed)&&(identical(other.isLive, isLive) || other.isLive == isLive)&&const DeepCollectionEquality().equals(other.httpHeaders, _httpHeaders));
}


@override
int get hashCode {
    return Object.hash(runtimeType,sessionId,ownerId,const DeepCollectionEquality().hash(_playlist),currentIndex,currentVideo,videoUrl,audioUrl,coverUrl,lastPosition,duration,const DeepCollectionEquality().hash(lastFrameBytes),quality,speed,isLive,const DeepCollectionEquality().hash(_httpHeaders));
}

@override
String toString() {
    return 'PlaybackSession(sessionId: $sessionId, ownerId: $ownerId, playlist: $playlist, currentIndex: $currentIndex, currentVideo: $currentVideo, videoUrl: $videoUrl, audioUrl: $audioUrl, coverUrl: $coverUrl, lastPosition: $lastPosition, duration: $duration, lastFrameBytes: $lastFrameBytes, quality: $quality, speed: $speed, isLive: $isLive, httpHeaders: $httpHeaders)';
}


}

/// @nodoc
abstract mixin class _$PlaybackSessionCopyWith<$Res> implements $PlaybackSessionCopyWith<$Res> {
  factory _$PlaybackSessionCopyWith(_PlaybackSession value, $Res Function(_PlaybackSession) _then) = __$PlaybackSessionCopyWithImpl;
@override @useResult
$Res call({
 String sessionId, String ownerId, List<VideoItemModel> playlist, int currentIndex, VideoItemModel? currentVideo, String? videoUrl, String? audioUrl, String? coverUrl, Duration lastPosition, Duration duration, Uint8List? lastFrameBytes, int quality, double speed, bool isLive, Map<String, String> httpHeaders
});


@override $VideoItemModelCopyWith<$Res>? get currentVideo;

}
/// @nodoc
class __$PlaybackSessionCopyWithImpl<$Res>
    implements _$PlaybackSessionCopyWith<$Res> {
  __$PlaybackSessionCopyWithImpl(this._self, this._then);

  final _PlaybackSession _self;
  final $Res Function(_PlaybackSession) _then;

/// Create a copy of PlaybackSession
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sessionId = null,Object? ownerId = null,Object? playlist = null,Object? currentIndex = null,Object? currentVideo = freezed,Object? videoUrl = freezed,Object? audioUrl = freezed,Object? coverUrl = freezed,Object? lastPosition = null,Object? duration = null,Object? lastFrameBytes = freezed,Object? quality = null,Object? speed = null,Object? isLive = null,Object? httpHeaders = null,}) {
  return _then(_PlaybackSession(
sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,ownerId: null == ownerId ? _self.ownerId : ownerId // ignore: cast_nullable_to_non_nullable
as String,playlist: null == playlist ? _self._playlist : playlist // ignore: cast_nullable_to_non_nullable
as List<VideoItemModel>,currentIndex: null == currentIndex ? _self.currentIndex : currentIndex // ignore: cast_nullable_to_non_nullable
as int,currentVideo: freezed == currentVideo ? _self.currentVideo : currentVideo // ignore: cast_nullable_to_non_nullable
as VideoItemModel?,videoUrl: freezed == videoUrl ? _self.videoUrl : videoUrl // ignore: cast_nullable_to_non_nullable
as String?,audioUrl: freezed == audioUrl ? _self.audioUrl : audioUrl // ignore: cast_nullable_to_non_nullable
as String?,coverUrl: freezed == coverUrl ? _self.coverUrl : coverUrl // ignore: cast_nullable_to_non_nullable
as String?,lastPosition: null == lastPosition ? _self.lastPosition : lastPosition // ignore: cast_nullable_to_non_nullable
as Duration,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as Duration,lastFrameBytes: freezed == lastFrameBytes ? _self.lastFrameBytes : lastFrameBytes // ignore: cast_nullable_to_non_nullable
as Uint8List?,quality: null == quality ? _self.quality : quality // ignore: cast_nullable_to_non_nullable
as int,speed: null == speed ? _self.speed : speed // ignore: cast_nullable_to_non_nullable
as double,isLive: null == isLive ? _self.isLive : isLive // ignore: cast_nullable_to_non_nullable
as bool,httpHeaders: null == httpHeaders ? _self._httpHeaders : httpHeaders // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}

/// Create a copy of PlaybackSession
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VideoItemModelCopyWith<$Res>? get currentVideo {
    if (_self.currentVideo == null) {
    return null;
  }

  return $VideoItemModelCopyWith<$Res>(_self.currentVideo!, (value) {
    return _then(_self.copyWith(currentVideo: value));
  });
}
}

// dart format on

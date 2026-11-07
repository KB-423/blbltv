// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../bangumi_player_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$BangumiPlayerState {

 int get seasonId; String get seasonTitle; List<BangumiEpisodeModel> get episodes; int get currentEpIndex; bool get isLoading; bool get isPlaying; bool get isBuffering; String? get error; Duration get position; Duration get duration; int get currentQn; List<VideoQualityItem> get qualities; bool get showControls; bool get showEpisodeDrawer; bool get showQualityPanel; String get currentPlayUrl; String get currentAudioUrl;
/// Create a copy of BangumiPlayerState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BangumiPlayerStateCopyWith<BangumiPlayerState> get copyWith => _$BangumiPlayerStateCopyWithImpl<BangumiPlayerState>(this as BangumiPlayerState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as BangumiPlayerState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BangumiPlayerState&&(identical(other.seasonId, _this.seasonId) || other.seasonId == _this.seasonId)&&(identical(other.seasonTitle, _this.seasonTitle) || other.seasonTitle == _this.seasonTitle)&&const DeepCollectionEquality().equals(other.episodes, _this.episodes)&&(identical(other.currentEpIndex, _this.currentEpIndex) || other.currentEpIndex == _this.currentEpIndex)&&(identical(other.isLoading, _this.isLoading) || other.isLoading == _this.isLoading)&&(identical(other.isPlaying, _this.isPlaying) || other.isPlaying == _this.isPlaying)&&(identical(other.isBuffering, _this.isBuffering) || other.isBuffering == _this.isBuffering)&&(identical(other.error, _this.error) || other.error == _this.error)&&(identical(other.position, _this.position) || other.position == _this.position)&&(identical(other.duration, _this.duration) || other.duration == _this.duration)&&(identical(other.currentQn, _this.currentQn) || other.currentQn == _this.currentQn)&&const DeepCollectionEquality().equals(other.qualities, _this.qualities)&&(identical(other.showControls, _this.showControls) || other.showControls == _this.showControls)&&(identical(other.showEpisodeDrawer, _this.showEpisodeDrawer) || other.showEpisodeDrawer == _this.showEpisodeDrawer)&&(identical(other.showQualityPanel, _this.showQualityPanel) || other.showQualityPanel == _this.showQualityPanel)&&(identical(other.currentPlayUrl, _this.currentPlayUrl) || other.currentPlayUrl == _this.currentPlayUrl)&&(identical(other.currentAudioUrl, _this.currentAudioUrl) || other.currentAudioUrl == _this.currentAudioUrl));
}


@override
int get hashCode {
  final _this = this as BangumiPlayerState;
  return Object.hash(runtimeType,_this.seasonId,_this.seasonTitle,const DeepCollectionEquality().hash(_this.episodes),_this.currentEpIndex,_this.isLoading,_this.isPlaying,_this.isBuffering,_this.error,_this.position,_this.duration,_this.currentQn,const DeepCollectionEquality().hash(_this.qualities),_this.showControls,_this.showEpisodeDrawer,_this.showQualityPanel,_this.currentPlayUrl,_this.currentAudioUrl);
}

@override
String toString() {
  final _this = this as BangumiPlayerState;
  return 'BangumiPlayerState(seasonId: ${_this.seasonId}, seasonTitle: ${_this.seasonTitle}, episodes: ${_this.episodes}, currentEpIndex: ${_this.currentEpIndex}, isLoading: ${_this.isLoading}, isPlaying: ${_this.isPlaying}, isBuffering: ${_this.isBuffering}, error: ${_this.error}, position: ${_this.position}, duration: ${_this.duration}, currentQn: ${_this.currentQn}, qualities: ${_this.qualities}, showControls: ${_this.showControls}, showEpisodeDrawer: ${_this.showEpisodeDrawer}, showQualityPanel: ${_this.showQualityPanel}, currentPlayUrl: ${_this.currentPlayUrl}, currentAudioUrl: ${_this.currentAudioUrl})';
}


}

/// @nodoc
abstract mixin class $BangumiPlayerStateCopyWith<$Res>  {
  factory $BangumiPlayerStateCopyWith(BangumiPlayerState value, $Res Function(BangumiPlayerState) _then) = _$BangumiPlayerStateCopyWithImpl;
@useResult
$Res call({
 int seasonId, String seasonTitle, List<BangumiEpisodeModel> episodes, int currentEpIndex, bool isLoading, bool isPlaying, bool isBuffering, String? error, Duration position, Duration duration, int currentQn, List<VideoQualityItem> qualities, bool showControls, bool showEpisodeDrawer, bool showQualityPanel, String currentPlayUrl, String currentAudioUrl
});




}
/// @nodoc
class _$BangumiPlayerStateCopyWithImpl<$Res>
    implements $BangumiPlayerStateCopyWith<$Res> {
  _$BangumiPlayerStateCopyWithImpl(this._self, this._then);

  final BangumiPlayerState _self;
  final $Res Function(BangumiPlayerState) _then;

/// Create a copy of BangumiPlayerState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? seasonId = null,Object? seasonTitle = null,Object? episodes = null,Object? currentEpIndex = null,Object? isLoading = null,Object? isPlaying = null,Object? isBuffering = null,Object? error = freezed,Object? position = null,Object? duration = null,Object? currentQn = null,Object? qualities = null,Object? showControls = null,Object? showEpisodeDrawer = null,Object? showQualityPanel = null,Object? currentPlayUrl = null,Object? currentAudioUrl = null,}) {
  return _then(BangumiPlayerState(
seasonId: null == seasonId ? _self.seasonId : seasonId // ignore: cast_nullable_to_non_nullable
as int,seasonTitle: null == seasonTitle ? _self.seasonTitle : seasonTitle // ignore: cast_nullable_to_non_nullable
as String,episodes: null == episodes ? _self.episodes : episodes // ignore: cast_nullable_to_non_nullable
as List<BangumiEpisodeModel>,currentEpIndex: null == currentEpIndex ? _self.currentEpIndex : currentEpIndex // ignore: cast_nullable_to_non_nullable
as int,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isPlaying: null == isPlaying ? _self.isPlaying : isPlaying // ignore: cast_nullable_to_non_nullable
as bool,isBuffering: null == isBuffering ? _self.isBuffering : isBuffering // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as Duration,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as Duration,currentQn: null == currentQn ? _self.currentQn : currentQn // ignore: cast_nullable_to_non_nullable
as int,qualities: null == qualities ? _self.qualities : qualities // ignore: cast_nullable_to_non_nullable
as List<VideoQualityItem>,showControls: null == showControls ? _self.showControls : showControls // ignore: cast_nullable_to_non_nullable
as bool,showEpisodeDrawer: null == showEpisodeDrawer ? _self.showEpisodeDrawer : showEpisodeDrawer // ignore: cast_nullable_to_non_nullable
as bool,showQualityPanel: null == showQualityPanel ? _self.showQualityPanel : showQualityPanel // ignore: cast_nullable_to_non_nullable
as bool,currentPlayUrl: null == currentPlayUrl ? _self.currentPlayUrl : currentPlayUrl // ignore: cast_nullable_to_non_nullable
as String,currentAudioUrl: null == currentAudioUrl ? _self.currentAudioUrl : currentAudioUrl // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [BangumiPlayerState].
extension BangumiPlayerStatePatterns on BangumiPlayerState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BangumiPlayerState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BangumiPlayerState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BangumiPlayerState value)  $default,){
final _that = this;
switch (_that) {
case _BangumiPlayerState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BangumiPlayerState value)?  $default,){
final _that = this;
switch (_that) {
case _BangumiPlayerState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int seasonId,  String seasonTitle,  List<BangumiEpisodeModel> episodes,  int currentEpIndex,  bool isLoading,  bool isPlaying,  bool isBuffering,  String? error,  Duration position,  Duration duration,  int currentQn,  List<VideoQualityItem> qualities,  bool showControls,  bool showEpisodeDrawer,  bool showQualityPanel,  String currentPlayUrl,  String currentAudioUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BangumiPlayerState() when $default != null:
return $default(_that.seasonId,_that.seasonTitle,_that.episodes,_that.currentEpIndex,_that.isLoading,_that.isPlaying,_that.isBuffering,_that.error,_that.position,_that.duration,_that.currentQn,_that.qualities,_that.showControls,_that.showEpisodeDrawer,_that.showQualityPanel,_that.currentPlayUrl,_that.currentAudioUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int seasonId,  String seasonTitle,  List<BangumiEpisodeModel> episodes,  int currentEpIndex,  bool isLoading,  bool isPlaying,  bool isBuffering,  String? error,  Duration position,  Duration duration,  int currentQn,  List<VideoQualityItem> qualities,  bool showControls,  bool showEpisodeDrawer,  bool showQualityPanel,  String currentPlayUrl,  String currentAudioUrl)  $default,) {final _that = this;
switch (_that) {
case _BangumiPlayerState():
return $default(_that.seasonId,_that.seasonTitle,_that.episodes,_that.currentEpIndex,_that.isLoading,_that.isPlaying,_that.isBuffering,_that.error,_that.position,_that.duration,_that.currentQn,_that.qualities,_that.showControls,_that.showEpisodeDrawer,_that.showQualityPanel,_that.currentPlayUrl,_that.currentAudioUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int seasonId,  String seasonTitle,  List<BangumiEpisodeModel> episodes,  int currentEpIndex,  bool isLoading,  bool isPlaying,  bool isBuffering,  String? error,  Duration position,  Duration duration,  int currentQn,  List<VideoQualityItem> qualities,  bool showControls,  bool showEpisodeDrawer,  bool showQualityPanel,  String currentPlayUrl,  String currentAudioUrl)?  $default,) {final _that = this;
switch (_that) {
case _BangumiPlayerState() when $default != null:
return $default(_that.seasonId,_that.seasonTitle,_that.episodes,_that.currentEpIndex,_that.isLoading,_that.isPlaying,_that.isBuffering,_that.error,_that.position,_that.duration,_that.currentQn,_that.qualities,_that.showControls,_that.showEpisodeDrawer,_that.showQualityPanel,_that.currentPlayUrl,_that.currentAudioUrl);case _:
  return null;

}
}

}

/// @nodoc


class _BangumiPlayerState implements BangumiPlayerState {
  const _BangumiPlayerState({this.seasonId = 0, this.seasonTitle = '',  List<BangumiEpisodeModel> episodes = const [], this.currentEpIndex = 0, this.isLoading = true, this.isPlaying = false, this.isBuffering = false, this.error, this.position = Duration.zero, this.duration = Duration.zero, this.currentQn = 80,  List<VideoQualityItem> qualities = const [], this.showControls = true, this.showEpisodeDrawer = false, this.showQualityPanel = false, this.currentPlayUrl = '', this.currentAudioUrl = ''}): _episodes = episodes,_qualities = qualities;
  

@override@JsonKey() final  int seasonId;
@override@JsonKey() final  String seasonTitle;
 final  List<BangumiEpisodeModel> _episodes;
@override@JsonKey() List<BangumiEpisodeModel> get episodes {
  if (_episodes is EqualUnmodifiableListView) return _episodes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_episodes);
}

@override@JsonKey() final  int currentEpIndex;
@override@JsonKey() final  bool isLoading;
@override@JsonKey() final  bool isPlaying;
@override@JsonKey() final  bool isBuffering;
@override final  String? error;
@override@JsonKey() final  Duration position;
@override@JsonKey() final  Duration duration;
@override@JsonKey() final  int currentQn;
 final  List<VideoQualityItem> _qualities;
@override@JsonKey() List<VideoQualityItem> get qualities {
  if (_qualities is EqualUnmodifiableListView) return _qualities;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_qualities);
}

@override@JsonKey() final  bool showControls;
@override@JsonKey() final  bool showEpisodeDrawer;
@override@JsonKey() final  bool showQualityPanel;
@override@JsonKey() final  String currentPlayUrl;
@override@JsonKey() final  String currentAudioUrl;

/// Create a copy of BangumiPlayerState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BangumiPlayerStateCopyWith<_BangumiPlayerState> get copyWith => __$BangumiPlayerStateCopyWithImpl<_BangumiPlayerState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _BangumiPlayerState&&(identical(other.seasonId, seasonId) || other.seasonId == seasonId)&&(identical(other.seasonTitle, seasonTitle) || other.seasonTitle == seasonTitle)&&const DeepCollectionEquality().equals(other.episodes, _episodes)&&(identical(other.currentEpIndex, currentEpIndex) || other.currentEpIndex == currentEpIndex)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.isPlaying, isPlaying) || other.isPlaying == isPlaying)&&(identical(other.isBuffering, isBuffering) || other.isBuffering == isBuffering)&&(identical(other.error, error) || other.error == error)&&(identical(other.position, position) || other.position == position)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.currentQn, currentQn) || other.currentQn == currentQn)&&const DeepCollectionEquality().equals(other.qualities, _qualities)&&(identical(other.showControls, showControls) || other.showControls == showControls)&&(identical(other.showEpisodeDrawer, showEpisodeDrawer) || other.showEpisodeDrawer == showEpisodeDrawer)&&(identical(other.showQualityPanel, showQualityPanel) || other.showQualityPanel == showQualityPanel)&&(identical(other.currentPlayUrl, currentPlayUrl) || other.currentPlayUrl == currentPlayUrl)&&(identical(other.currentAudioUrl, currentAudioUrl) || other.currentAudioUrl == currentAudioUrl));
}


@override
int get hashCode {
    return Object.hash(runtimeType,seasonId,seasonTitle,const DeepCollectionEquality().hash(_episodes),currentEpIndex,isLoading,isPlaying,isBuffering,error,position,duration,currentQn,const DeepCollectionEquality().hash(_qualities),showControls,showEpisodeDrawer,showQualityPanel,currentPlayUrl,currentAudioUrl);
}

@override
String toString() {
    return 'BangumiPlayerState(seasonId: $seasonId, seasonTitle: $seasonTitle, episodes: $episodes, currentEpIndex: $currentEpIndex, isLoading: $isLoading, isPlaying: $isPlaying, isBuffering: $isBuffering, error: $error, position: $position, duration: $duration, currentQn: $currentQn, qualities: $qualities, showControls: $showControls, showEpisodeDrawer: $showEpisodeDrawer, showQualityPanel: $showQualityPanel, currentPlayUrl: $currentPlayUrl, currentAudioUrl: $currentAudioUrl)';
}


}

/// @nodoc
abstract mixin class _$BangumiPlayerStateCopyWith<$Res> implements $BangumiPlayerStateCopyWith<$Res> {
  factory _$BangumiPlayerStateCopyWith(_BangumiPlayerState value, $Res Function(_BangumiPlayerState) _then) = __$BangumiPlayerStateCopyWithImpl;
@override @useResult
$Res call({
 int seasonId, String seasonTitle, List<BangumiEpisodeModel> episodes, int currentEpIndex, bool isLoading, bool isPlaying, bool isBuffering, String? error, Duration position, Duration duration, int currentQn, List<VideoQualityItem> qualities, bool showControls, bool showEpisodeDrawer, bool showQualityPanel, String currentPlayUrl, String currentAudioUrl
});




}
/// @nodoc
class __$BangumiPlayerStateCopyWithImpl<$Res>
    implements _$BangumiPlayerStateCopyWith<$Res> {
  __$BangumiPlayerStateCopyWithImpl(this._self, this._then);

  final _BangumiPlayerState _self;
  final $Res Function(_BangumiPlayerState) _then;

/// Create a copy of BangumiPlayerState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? seasonId = null,Object? seasonTitle = null,Object? episodes = null,Object? currentEpIndex = null,Object? isLoading = null,Object? isPlaying = null,Object? isBuffering = null,Object? error = freezed,Object? position = null,Object? duration = null,Object? currentQn = null,Object? qualities = null,Object? showControls = null,Object? showEpisodeDrawer = null,Object? showQualityPanel = null,Object? currentPlayUrl = null,Object? currentAudioUrl = null,}) {
  return _then(_BangumiPlayerState(
seasonId: null == seasonId ? _self.seasonId : seasonId // ignore: cast_nullable_to_non_nullable
as int,seasonTitle: null == seasonTitle ? _self.seasonTitle : seasonTitle // ignore: cast_nullable_to_non_nullable
as String,episodes: null == episodes ? _self._episodes : episodes // ignore: cast_nullable_to_non_nullable
as List<BangumiEpisodeModel>,currentEpIndex: null == currentEpIndex ? _self.currentEpIndex : currentEpIndex // ignore: cast_nullable_to_non_nullable
as int,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isPlaying: null == isPlaying ? _self.isPlaying : isPlaying // ignore: cast_nullable_to_non_nullable
as bool,isBuffering: null == isBuffering ? _self.isBuffering : isBuffering // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as Duration,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as Duration,currentQn: null == currentQn ? _self.currentQn : currentQn // ignore: cast_nullable_to_non_nullable
as int,qualities: null == qualities ? _self._qualities : qualities // ignore: cast_nullable_to_non_nullable
as List<VideoQualityItem>,showControls: null == showControls ? _self.showControls : showControls // ignore: cast_nullable_to_non_nullable
as bool,showEpisodeDrawer: null == showEpisodeDrawer ? _self.showEpisodeDrawer : showEpisodeDrawer // ignore: cast_nullable_to_non_nullable
as bool,showQualityPanel: null == showQualityPanel ? _self.showQualityPanel : showQualityPanel // ignore: cast_nullable_to_non_nullable
as bool,currentPlayUrl: null == currentPlayUrl ? _self.currentPlayUrl : currentPlayUrl // ignore: cast_nullable_to_non_nullable
as String,currentAudioUrl: null == currentAudioUrl ? _self.currentAudioUrl : currentAudioUrl // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on

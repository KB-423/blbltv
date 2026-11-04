// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../play_url_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$VideoQualityItem {

 int get qn; String get desc;
/// Create a copy of VideoQualityItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VideoQualityItemCopyWith<VideoQualityItem> get copyWith => _$VideoQualityItemCopyWithImpl<VideoQualityItem>(this as VideoQualityItem, _$identity);

  /// Serializes this VideoQualityItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as VideoQualityItem;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VideoQualityItem&&(identical(other.qn, _this.qn) || other.qn == _this.qn)&&(identical(other.desc, _this.desc) || other.desc == _this.desc));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as VideoQualityItem;
  return Object.hash(runtimeType,_this.qn,_this.desc);
}

@override
String toString() {
  final _this = this as VideoQualityItem;
  return 'VideoQualityItem(qn: ${_this.qn}, desc: ${_this.desc})';
}


}

/// @nodoc
abstract mixin class $VideoQualityItemCopyWith<$Res>  {
  factory $VideoQualityItemCopyWith(VideoQualityItem value, $Res Function(VideoQualityItem) _then) = _$VideoQualityItemCopyWithImpl;
@useResult
$Res call({
 int qn, String desc
});




}
/// @nodoc
class _$VideoQualityItemCopyWithImpl<$Res>
    implements $VideoQualityItemCopyWith<$Res> {
  _$VideoQualityItemCopyWithImpl(this._self, this._then);

  final VideoQualityItem _self;
  final $Res Function(VideoQualityItem) _then;

/// Create a copy of VideoQualityItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? qn = null,Object? desc = null,}) {
  return _then(VideoQualityItem(
qn: null == qn ? _self.qn : qn // ignore: cast_nullable_to_non_nullable
as int,desc: null == desc ? _self.desc : desc // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [VideoQualityItem].
extension VideoQualityItemPatterns on VideoQualityItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VideoQualityItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VideoQualityItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VideoQualityItem value)  $default,){
final _that = this;
switch (_that) {
case _VideoQualityItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VideoQualityItem value)?  $default,){
final _that = this;
switch (_that) {
case _VideoQualityItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int qn,  String desc)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VideoQualityItem() when $default != null:
return $default(_that.qn,_that.desc);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int qn,  String desc)  $default,) {final _that = this;
switch (_that) {
case _VideoQualityItem():
return $default(_that.qn,_that.desc);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int qn,  String desc)?  $default,) {final _that = this;
switch (_that) {
case _VideoQualityItem() when $default != null:
return $default(_that.qn,_that.desc);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VideoQualityItem implements VideoQualityItem {
  const _VideoQualityItem({required this.qn, required this.desc});
  factory _VideoQualityItem.fromJson(Map<String, dynamic> json) => _$VideoQualityItemFromJson(json);

@override final  int qn;
@override final  String desc;

/// Create a copy of VideoQualityItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VideoQualityItemCopyWith<_VideoQualityItem> get copyWith => __$VideoQualityItemCopyWithImpl<_VideoQualityItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VideoQualityItemToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _VideoQualityItem&&(identical(other.qn, qn) || other.qn == qn)&&(identical(other.desc, desc) || other.desc == desc));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,qn,desc);
}

@override
String toString() {
    return 'VideoQualityItem(qn: $qn, desc: $desc)';
}


}

/// @nodoc
abstract mixin class _$VideoQualityItemCopyWith<$Res> implements $VideoQualityItemCopyWith<$Res> {
  factory _$VideoQualityItemCopyWith(_VideoQualityItem value, $Res Function(_VideoQualityItem) _then) = __$VideoQualityItemCopyWithImpl;
@override @useResult
$Res call({
 int qn, String desc
});




}
/// @nodoc
class __$VideoQualityItemCopyWithImpl<$Res>
    implements _$VideoQualityItemCopyWith<$Res> {
  __$VideoQualityItemCopyWithImpl(this._self, this._then);

  final _VideoQualityItem _self;
  final $Res Function(_VideoQualityItem) _then;

/// Create a copy of VideoQualityItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? qn = null,Object? desc = null,}) {
  return _then(_VideoQualityItem(
qn: null == qn ? _self.qn : qn // ignore: cast_nullable_to_non_nullable
as int,desc: null == desc ? _self.desc : desc // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$VideoPlayInfo {

 String get bvid; int get cid; String get title; String get playUrl; String get audioUrl; int get currentQn; List<VideoQualityItem> get qualities; int get durationSeconds;
/// Create a copy of VideoPlayInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VideoPlayInfoCopyWith<VideoPlayInfo> get copyWith => _$VideoPlayInfoCopyWithImpl<VideoPlayInfo>(this as VideoPlayInfo, _$identity);

  /// Serializes this VideoPlayInfo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as VideoPlayInfo;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VideoPlayInfo&&(identical(other.bvid, _this.bvid) || other.bvid == _this.bvid)&&(identical(other.cid, _this.cid) || other.cid == _this.cid)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.playUrl, _this.playUrl) || other.playUrl == _this.playUrl)&&(identical(other.audioUrl, _this.audioUrl) || other.audioUrl == _this.audioUrl)&&(identical(other.currentQn, _this.currentQn) || other.currentQn == _this.currentQn)&&const DeepCollectionEquality().equals(other.qualities, _this.qualities)&&(identical(other.durationSeconds, _this.durationSeconds) || other.durationSeconds == _this.durationSeconds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as VideoPlayInfo;
  return Object.hash(runtimeType,_this.bvid,_this.cid,_this.title,_this.playUrl,_this.audioUrl,_this.currentQn,const DeepCollectionEquality().hash(_this.qualities),_this.durationSeconds);
}

@override
String toString() {
  final _this = this as VideoPlayInfo;
  return 'VideoPlayInfo(bvid: ${_this.bvid}, cid: ${_this.cid}, title: ${_this.title}, playUrl: ${_this.playUrl}, audioUrl: ${_this.audioUrl}, currentQn: ${_this.currentQn}, qualities: ${_this.qualities}, durationSeconds: ${_this.durationSeconds})';
}


}

/// @nodoc
abstract mixin class $VideoPlayInfoCopyWith<$Res>  {
  factory $VideoPlayInfoCopyWith(VideoPlayInfo value, $Res Function(VideoPlayInfo) _then) = _$VideoPlayInfoCopyWithImpl;
@useResult
$Res call({
 String bvid, int cid, String title, String playUrl, String audioUrl, int currentQn, List<VideoQualityItem> qualities, int durationSeconds
});




}
/// @nodoc
class _$VideoPlayInfoCopyWithImpl<$Res>
    implements $VideoPlayInfoCopyWith<$Res> {
  _$VideoPlayInfoCopyWithImpl(this._self, this._then);

  final VideoPlayInfo _self;
  final $Res Function(VideoPlayInfo) _then;

/// Create a copy of VideoPlayInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? bvid = null,Object? cid = null,Object? title = null,Object? playUrl = null,Object? audioUrl = null,Object? currentQn = null,Object? qualities = null,Object? durationSeconds = null,}) {
  return _then(VideoPlayInfo(
bvid: null == bvid ? _self.bvid : bvid // ignore: cast_nullable_to_non_nullable
as String,cid: null == cid ? _self.cid : cid // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,playUrl: null == playUrl ? _self.playUrl : playUrl // ignore: cast_nullable_to_non_nullable
as String,audioUrl: null == audioUrl ? _self.audioUrl : audioUrl // ignore: cast_nullable_to_non_nullable
as String,currentQn: null == currentQn ? _self.currentQn : currentQn // ignore: cast_nullable_to_non_nullable
as int,qualities: null == qualities ? _self.qualities : qualities // ignore: cast_nullable_to_non_nullable
as List<VideoQualityItem>,durationSeconds: null == durationSeconds ? _self.durationSeconds : durationSeconds // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [VideoPlayInfo].
extension VideoPlayInfoPatterns on VideoPlayInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VideoPlayInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VideoPlayInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VideoPlayInfo value)  $default,){
final _that = this;
switch (_that) {
case _VideoPlayInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VideoPlayInfo value)?  $default,){
final _that = this;
switch (_that) {
case _VideoPlayInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String bvid,  int cid,  String title,  String playUrl,  String audioUrl,  int currentQn,  List<VideoQualityItem> qualities,  int durationSeconds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VideoPlayInfo() when $default != null:
return $default(_that.bvid,_that.cid,_that.title,_that.playUrl,_that.audioUrl,_that.currentQn,_that.qualities,_that.durationSeconds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String bvid,  int cid,  String title,  String playUrl,  String audioUrl,  int currentQn,  List<VideoQualityItem> qualities,  int durationSeconds)  $default,) {final _that = this;
switch (_that) {
case _VideoPlayInfo():
return $default(_that.bvid,_that.cid,_that.title,_that.playUrl,_that.audioUrl,_that.currentQn,_that.qualities,_that.durationSeconds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String bvid,  int cid,  String title,  String playUrl,  String audioUrl,  int currentQn,  List<VideoQualityItem> qualities,  int durationSeconds)?  $default,) {final _that = this;
switch (_that) {
case _VideoPlayInfo() when $default != null:
return $default(_that.bvid,_that.cid,_that.title,_that.playUrl,_that.audioUrl,_that.currentQn,_that.qualities,_that.durationSeconds);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VideoPlayInfo implements VideoPlayInfo {
  const _VideoPlayInfo({this.bvid = '', this.cid = 0, this.title = '', this.playUrl = '', this.audioUrl = '', this.currentQn = 80,  List<VideoQualityItem> qualities = const <VideoQualityItem>[], this.durationSeconds = 0}): _qualities = qualities;
  factory _VideoPlayInfo.fromJson(Map<String, dynamic> json) => _$VideoPlayInfoFromJson(json);

@override@JsonKey() final  String bvid;
@override@JsonKey() final  int cid;
@override@JsonKey() final  String title;
@override@JsonKey() final  String playUrl;
@override@JsonKey() final  String audioUrl;
@override@JsonKey() final  int currentQn;
 final  List<VideoQualityItem> _qualities;
@override@JsonKey() List<VideoQualityItem> get qualities {
  if (_qualities is EqualUnmodifiableListView) return _qualities;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_qualities);
}

@override@JsonKey() final  int durationSeconds;

/// Create a copy of VideoPlayInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VideoPlayInfoCopyWith<_VideoPlayInfo> get copyWith => __$VideoPlayInfoCopyWithImpl<_VideoPlayInfo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VideoPlayInfoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _VideoPlayInfo&&(identical(other.bvid, bvid) || other.bvid == bvid)&&(identical(other.cid, cid) || other.cid == cid)&&(identical(other.title, title) || other.title == title)&&(identical(other.playUrl, playUrl) || other.playUrl == playUrl)&&(identical(other.audioUrl, audioUrl) || other.audioUrl == audioUrl)&&(identical(other.currentQn, currentQn) || other.currentQn == currentQn)&&const DeepCollectionEquality().equals(other.qualities, _qualities)&&(identical(other.durationSeconds, durationSeconds) || other.durationSeconds == durationSeconds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,bvid,cid,title,playUrl,audioUrl,currentQn,const DeepCollectionEquality().hash(_qualities),durationSeconds);
}

@override
String toString() {
    return 'VideoPlayInfo(bvid: $bvid, cid: $cid, title: $title, playUrl: $playUrl, audioUrl: $audioUrl, currentQn: $currentQn, qualities: $qualities, durationSeconds: $durationSeconds)';
}


}

/// @nodoc
abstract mixin class _$VideoPlayInfoCopyWith<$Res> implements $VideoPlayInfoCopyWith<$Res> {
  factory _$VideoPlayInfoCopyWith(_VideoPlayInfo value, $Res Function(_VideoPlayInfo) _then) = __$VideoPlayInfoCopyWithImpl;
@override @useResult
$Res call({
 String bvid, int cid, String title, String playUrl, String audioUrl, int currentQn, List<VideoQualityItem> qualities, int durationSeconds
});




}
/// @nodoc
class __$VideoPlayInfoCopyWithImpl<$Res>
    implements _$VideoPlayInfoCopyWith<$Res> {
  __$VideoPlayInfoCopyWithImpl(this._self, this._then);

  final _VideoPlayInfo _self;
  final $Res Function(_VideoPlayInfo) _then;

/// Create a copy of VideoPlayInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? bvid = null,Object? cid = null,Object? title = null,Object? playUrl = null,Object? audioUrl = null,Object? currentQn = null,Object? qualities = null,Object? durationSeconds = null,}) {
  return _then(_VideoPlayInfo(
bvid: null == bvid ? _self.bvid : bvid // ignore: cast_nullable_to_non_nullable
as String,cid: null == cid ? _self.cid : cid // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,playUrl: null == playUrl ? _self.playUrl : playUrl // ignore: cast_nullable_to_non_nullable
as String,audioUrl: null == audioUrl ? _self.audioUrl : audioUrl // ignore: cast_nullable_to_non_nullable
as String,currentQn: null == currentQn ? _self.currentQn : currentQn // ignore: cast_nullable_to_non_nullable
as int,qualities: null == qualities ? _self._qualities : qualities // ignore: cast_nullable_to_non_nullable
as List<VideoQualityItem>,durationSeconds: null == durationSeconds ? _self.durationSeconds : durationSeconds // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on

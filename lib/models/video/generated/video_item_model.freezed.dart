// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../video_item_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$VideoOwner {

 int get mid; String get name; String get face;
/// Create a copy of VideoOwner
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VideoOwnerCopyWith<VideoOwner> get copyWith => _$VideoOwnerCopyWithImpl<VideoOwner>(this as VideoOwner, _$identity);

  /// Serializes this VideoOwner to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as VideoOwner;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VideoOwner&&(identical(other.mid, _this.mid) || other.mid == _this.mid)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.face, _this.face) || other.face == _this.face));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as VideoOwner;
  return Object.hash(runtimeType,_this.mid,_this.name,_this.face);
}

@override
String toString() {
  final _this = this as VideoOwner;
  return 'VideoOwner(mid: ${_this.mid}, name: ${_this.name}, face: ${_this.face})';
}


}

/// @nodoc
abstract mixin class $VideoOwnerCopyWith<$Res>  {
  factory $VideoOwnerCopyWith(VideoOwner value, $Res Function(VideoOwner) _then) = _$VideoOwnerCopyWithImpl;
@useResult
$Res call({
 int mid, String name, String face
});




}
/// @nodoc
class _$VideoOwnerCopyWithImpl<$Res>
    implements $VideoOwnerCopyWith<$Res> {
  _$VideoOwnerCopyWithImpl(this._self, this._then);

  final VideoOwner _self;
  final $Res Function(VideoOwner) _then;

/// Create a copy of VideoOwner
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? mid = null,Object? name = null,Object? face = null,}) {
  return _then(VideoOwner(
mid: null == mid ? _self.mid : mid // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,face: null == face ? _self.face : face // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [VideoOwner].
extension VideoOwnerPatterns on VideoOwner {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VideoOwner value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VideoOwner() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VideoOwner value)  $default,){
final _that = this;
switch (_that) {
case _VideoOwner():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VideoOwner value)?  $default,){
final _that = this;
switch (_that) {
case _VideoOwner() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int mid,  String name,  String face)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VideoOwner() when $default != null:
return $default(_that.mid,_that.name,_that.face);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int mid,  String name,  String face)  $default,) {final _that = this;
switch (_that) {
case _VideoOwner():
return $default(_that.mid,_that.name,_that.face);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int mid,  String name,  String face)?  $default,) {final _that = this;
switch (_that) {
case _VideoOwner() when $default != null:
return $default(_that.mid,_that.name,_that.face);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VideoOwner implements VideoOwner {
  const _VideoOwner({this.mid = 0, this.name = '', this.face = ''});
  factory _VideoOwner.fromJson(Map<String, dynamic> json) => _$VideoOwnerFromJson(json);

@override@JsonKey() final  int mid;
@override@JsonKey() final  String name;
@override@JsonKey() final  String face;

/// Create a copy of VideoOwner
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VideoOwnerCopyWith<_VideoOwner> get copyWith => __$VideoOwnerCopyWithImpl<_VideoOwner>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VideoOwnerToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _VideoOwner&&(identical(other.mid, mid) || other.mid == mid)&&(identical(other.name, name) || other.name == name)&&(identical(other.face, face) || other.face == face));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,mid,name,face);
}

@override
String toString() {
    return 'VideoOwner(mid: $mid, name: $name, face: $face)';
}


}

/// @nodoc
abstract mixin class _$VideoOwnerCopyWith<$Res> implements $VideoOwnerCopyWith<$Res> {
  factory _$VideoOwnerCopyWith(_VideoOwner value, $Res Function(_VideoOwner) _then) = __$VideoOwnerCopyWithImpl;
@override @useResult
$Res call({
 int mid, String name, String face
});




}
/// @nodoc
class __$VideoOwnerCopyWithImpl<$Res>
    implements _$VideoOwnerCopyWith<$Res> {
  __$VideoOwnerCopyWithImpl(this._self, this._then);

  final _VideoOwner _self;
  final $Res Function(_VideoOwner) _then;

/// Create a copy of VideoOwner
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? mid = null,Object? name = null,Object? face = null,}) {
  return _then(_VideoOwner(
mid: null == mid ? _self.mid : mid // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,face: null == face ? _self.face : face // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$VideoStat {

 int get view; int get danmaku; int get reply; int get favorite; int get coin; int get share; int get like;
/// Create a copy of VideoStat
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VideoStatCopyWith<VideoStat> get copyWith => _$VideoStatCopyWithImpl<VideoStat>(this as VideoStat, _$identity);

  /// Serializes this VideoStat to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as VideoStat;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VideoStat&&(identical(other.view, _this.view) || other.view == _this.view)&&(identical(other.danmaku, _this.danmaku) || other.danmaku == _this.danmaku)&&(identical(other.reply, _this.reply) || other.reply == _this.reply)&&(identical(other.favorite, _this.favorite) || other.favorite == _this.favorite)&&(identical(other.coin, _this.coin) || other.coin == _this.coin)&&(identical(other.share, _this.share) || other.share == _this.share)&&(identical(other.like, _this.like) || other.like == _this.like));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as VideoStat;
  return Object.hash(runtimeType,_this.view,_this.danmaku,_this.reply,_this.favorite,_this.coin,_this.share,_this.like);
}

@override
String toString() {
  final _this = this as VideoStat;
  return 'VideoStat(view: ${_this.view}, danmaku: ${_this.danmaku}, reply: ${_this.reply}, favorite: ${_this.favorite}, coin: ${_this.coin}, share: ${_this.share}, like: ${_this.like})';
}


}

/// @nodoc
abstract mixin class $VideoStatCopyWith<$Res>  {
  factory $VideoStatCopyWith(VideoStat value, $Res Function(VideoStat) _then) = _$VideoStatCopyWithImpl;
@useResult
$Res call({
 int view, int danmaku, int reply, int favorite, int coin, int share, int like
});




}
/// @nodoc
class _$VideoStatCopyWithImpl<$Res>
    implements $VideoStatCopyWith<$Res> {
  _$VideoStatCopyWithImpl(this._self, this._then);

  final VideoStat _self;
  final $Res Function(VideoStat) _then;

/// Create a copy of VideoStat
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? view = null,Object? danmaku = null,Object? reply = null,Object? favorite = null,Object? coin = null,Object? share = null,Object? like = null,}) {
  return _then(VideoStat(
view: null == view ? _self.view : view // ignore: cast_nullable_to_non_nullable
as int,danmaku: null == danmaku ? _self.danmaku : danmaku // ignore: cast_nullable_to_non_nullable
as int,reply: null == reply ? _self.reply : reply // ignore: cast_nullable_to_non_nullable
as int,favorite: null == favorite ? _self.favorite : favorite // ignore: cast_nullable_to_non_nullable
as int,coin: null == coin ? _self.coin : coin // ignore: cast_nullable_to_non_nullable
as int,share: null == share ? _self.share : share // ignore: cast_nullable_to_non_nullable
as int,like: null == like ? _self.like : like // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [VideoStat].
extension VideoStatPatterns on VideoStat {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VideoStat value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VideoStat() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VideoStat value)  $default,){
final _that = this;
switch (_that) {
case _VideoStat():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VideoStat value)?  $default,){
final _that = this;
switch (_that) {
case _VideoStat() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int view,  int danmaku,  int reply,  int favorite,  int coin,  int share,  int like)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VideoStat() when $default != null:
return $default(_that.view,_that.danmaku,_that.reply,_that.favorite,_that.coin,_that.share,_that.like);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int view,  int danmaku,  int reply,  int favorite,  int coin,  int share,  int like)  $default,) {final _that = this;
switch (_that) {
case _VideoStat():
return $default(_that.view,_that.danmaku,_that.reply,_that.favorite,_that.coin,_that.share,_that.like);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int view,  int danmaku,  int reply,  int favorite,  int coin,  int share,  int like)?  $default,) {final _that = this;
switch (_that) {
case _VideoStat() when $default != null:
return $default(_that.view,_that.danmaku,_that.reply,_that.favorite,_that.coin,_that.share,_that.like);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VideoStat implements VideoStat {
  const _VideoStat({this.view = 0, this.danmaku = 0, this.reply = 0, this.favorite = 0, this.coin = 0, this.share = 0, this.like = 0});
  factory _VideoStat.fromJson(Map<String, dynamic> json) => _$VideoStatFromJson(json);

@override@JsonKey() final  int view;
@override@JsonKey() final  int danmaku;
@override@JsonKey() final  int reply;
@override@JsonKey() final  int favorite;
@override@JsonKey() final  int coin;
@override@JsonKey() final  int share;
@override@JsonKey() final  int like;

/// Create a copy of VideoStat
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VideoStatCopyWith<_VideoStat> get copyWith => __$VideoStatCopyWithImpl<_VideoStat>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VideoStatToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _VideoStat&&(identical(other.view, view) || other.view == view)&&(identical(other.danmaku, danmaku) || other.danmaku == danmaku)&&(identical(other.reply, reply) || other.reply == reply)&&(identical(other.favorite, favorite) || other.favorite == favorite)&&(identical(other.coin, coin) || other.coin == coin)&&(identical(other.share, share) || other.share == share)&&(identical(other.like, like) || other.like == like));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,view,danmaku,reply,favorite,coin,share,like);
}

@override
String toString() {
    return 'VideoStat(view: $view, danmaku: $danmaku, reply: $reply, favorite: $favorite, coin: $coin, share: $share, like: $like)';
}


}

/// @nodoc
abstract mixin class _$VideoStatCopyWith<$Res> implements $VideoStatCopyWith<$Res> {
  factory _$VideoStatCopyWith(_VideoStat value, $Res Function(_VideoStat) _then) = __$VideoStatCopyWithImpl;
@override @useResult
$Res call({
 int view, int danmaku, int reply, int favorite, int coin, int share, int like
});




}
/// @nodoc
class __$VideoStatCopyWithImpl<$Res>
    implements _$VideoStatCopyWith<$Res> {
  __$VideoStatCopyWithImpl(this._self, this._then);

  final _VideoStat _self;
  final $Res Function(_VideoStat) _then;

/// Create a copy of VideoStat
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? view = null,Object? danmaku = null,Object? reply = null,Object? favorite = null,Object? coin = null,Object? share = null,Object? like = null,}) {
  return _then(_VideoStat(
view: null == view ? _self.view : view // ignore: cast_nullable_to_non_nullable
as int,danmaku: null == danmaku ? _self.danmaku : danmaku // ignore: cast_nullable_to_non_nullable
as int,reply: null == reply ? _self.reply : reply // ignore: cast_nullable_to_non_nullable
as int,favorite: null == favorite ? _self.favorite : favorite // ignore: cast_nullable_to_non_nullable
as int,coin: null == coin ? _self.coin : coin // ignore: cast_nullable_to_non_nullable
as int,share: null == share ? _self.share : share // ignore: cast_nullable_to_non_nullable
as int,like: null == like ? _self.like : like // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$VideoItemModel {

 int get id; String get bvid; int get cid; String get title; String get pic; int get duration; int get pubdate; String get uri; VideoOwner? get owner; VideoStat? get stat;@JsonKey(name: 'rcmd_reason') String? get rcmdReason;
/// Create a copy of VideoItemModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VideoItemModelCopyWith<VideoItemModel> get copyWith => _$VideoItemModelCopyWithImpl<VideoItemModel>(this as VideoItemModel, _$identity);

  /// Serializes this VideoItemModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as VideoItemModel;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VideoItemModel&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.bvid, _this.bvid) || other.bvid == _this.bvid)&&(identical(other.cid, _this.cid) || other.cid == _this.cid)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.pic, _this.pic) || other.pic == _this.pic)&&(identical(other.duration, _this.duration) || other.duration == _this.duration)&&(identical(other.pubdate, _this.pubdate) || other.pubdate == _this.pubdate)&&(identical(other.uri, _this.uri) || other.uri == _this.uri)&&(identical(other.owner, _this.owner) || other.owner == _this.owner)&&(identical(other.stat, _this.stat) || other.stat == _this.stat)&&(identical(other.rcmdReason, _this.rcmdReason) || other.rcmdReason == _this.rcmdReason));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as VideoItemModel;
  return Object.hash(runtimeType,_this.id,_this.bvid,_this.cid,_this.title,_this.pic,_this.duration,_this.pubdate,_this.uri,_this.owner,_this.stat,_this.rcmdReason);
}

@override
String toString() {
  final _this = this as VideoItemModel;
  return 'VideoItemModel(id: ${_this.id}, bvid: ${_this.bvid}, cid: ${_this.cid}, title: ${_this.title}, pic: ${_this.pic}, duration: ${_this.duration}, pubdate: ${_this.pubdate}, uri: ${_this.uri}, owner: ${_this.owner}, stat: ${_this.stat}, rcmdReason: ${_this.rcmdReason})';
}


}

/// @nodoc
abstract mixin class $VideoItemModelCopyWith<$Res>  {
  factory $VideoItemModelCopyWith(VideoItemModel value, $Res Function(VideoItemModel) _then) = _$VideoItemModelCopyWithImpl;
@useResult
$Res call({
 int id, String bvid, int cid, String title, String pic, int duration, int pubdate, String uri, VideoOwner? owner, VideoStat? stat,@JsonKey(name: 'rcmd_reason') String? rcmdReason
});


$VideoOwnerCopyWith<$Res>? get owner;$VideoStatCopyWith<$Res>? get stat;

}
/// @nodoc
class _$VideoItemModelCopyWithImpl<$Res>
    implements $VideoItemModelCopyWith<$Res> {
  _$VideoItemModelCopyWithImpl(this._self, this._then);

  final VideoItemModel _self;
  final $Res Function(VideoItemModel) _then;

/// Create a copy of VideoItemModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? bvid = null,Object? cid = null,Object? title = null,Object? pic = null,Object? duration = null,Object? pubdate = null,Object? uri = null,Object? owner = freezed,Object? stat = freezed,Object? rcmdReason = freezed,}) {
  return _then(VideoItemModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,bvid: null == bvid ? _self.bvid : bvid // ignore: cast_nullable_to_non_nullable
as String,cid: null == cid ? _self.cid : cid // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,pic: null == pic ? _self.pic : pic // ignore: cast_nullable_to_non_nullable
as String,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as int,pubdate: null == pubdate ? _self.pubdate : pubdate // ignore: cast_nullable_to_non_nullable
as int,uri: null == uri ? _self.uri : uri // ignore: cast_nullable_to_non_nullable
as String,owner: freezed == owner ? _self.owner : owner // ignore: cast_nullable_to_non_nullable
as VideoOwner?,stat: freezed == stat ? _self.stat : stat // ignore: cast_nullable_to_non_nullable
as VideoStat?,rcmdReason: freezed == rcmdReason ? _self.rcmdReason : rcmdReason // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of VideoItemModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VideoOwnerCopyWith<$Res>? get owner {
    if (_self.owner == null) {
    return null;
  }

  return $VideoOwnerCopyWith<$Res>(_self.owner!, (value) {
    return _then(_self.copyWith(owner: value));
  });
}/// Create a copy of VideoItemModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VideoStatCopyWith<$Res>? get stat {
    if (_self.stat == null) {
    return null;
  }

  return $VideoStatCopyWith<$Res>(_self.stat!, (value) {
    return _then(_self.copyWith(stat: value));
  });
}
}


/// Adds pattern-matching-related methods to [VideoItemModel].
extension VideoItemModelPatterns on VideoItemModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VideoItemModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VideoItemModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VideoItemModel value)  $default,){
final _that = this;
switch (_that) {
case _VideoItemModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VideoItemModel value)?  $default,){
final _that = this;
switch (_that) {
case _VideoItemModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String bvid,  int cid,  String title,  String pic,  int duration,  int pubdate,  String uri,  VideoOwner? owner,  VideoStat? stat, @JsonKey(name: 'rcmd_reason')  String? rcmdReason)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VideoItemModel() when $default != null:
return $default(_that.id,_that.bvid,_that.cid,_that.title,_that.pic,_that.duration,_that.pubdate,_that.uri,_that.owner,_that.stat,_that.rcmdReason);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String bvid,  int cid,  String title,  String pic,  int duration,  int pubdate,  String uri,  VideoOwner? owner,  VideoStat? stat, @JsonKey(name: 'rcmd_reason')  String? rcmdReason)  $default,) {final _that = this;
switch (_that) {
case _VideoItemModel():
return $default(_that.id,_that.bvid,_that.cid,_that.title,_that.pic,_that.duration,_that.pubdate,_that.uri,_that.owner,_that.stat,_that.rcmdReason);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String bvid,  int cid,  String title,  String pic,  int duration,  int pubdate,  String uri,  VideoOwner? owner,  VideoStat? stat, @JsonKey(name: 'rcmd_reason')  String? rcmdReason)?  $default,) {final _that = this;
switch (_that) {
case _VideoItemModel() when $default != null:
return $default(_that.id,_that.bvid,_that.cid,_that.title,_that.pic,_that.duration,_that.pubdate,_that.uri,_that.owner,_that.stat,_that.rcmdReason);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VideoItemModel implements VideoItemModel {
  const _VideoItemModel({this.id = 0, this.bvid = '', this.cid = 0, this.title = '', this.pic = '', this.duration = 0, this.pubdate = 0, this.uri = '', this.owner, this.stat, @JsonKey(name: 'rcmd_reason') this.rcmdReason});
  factory _VideoItemModel.fromJson(Map<String, dynamic> json) => _$VideoItemModelFromJson(json);

@override@JsonKey() final  int id;
@override@JsonKey() final  String bvid;
@override@JsonKey() final  int cid;
@override@JsonKey() final  String title;
@override@JsonKey() final  String pic;
@override@JsonKey() final  int duration;
@override@JsonKey() final  int pubdate;
@override@JsonKey() final  String uri;
@override final  VideoOwner? owner;
@override final  VideoStat? stat;
@override@JsonKey(name: 'rcmd_reason') final  String? rcmdReason;

/// Create a copy of VideoItemModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VideoItemModelCopyWith<_VideoItemModel> get copyWith => __$VideoItemModelCopyWithImpl<_VideoItemModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VideoItemModelToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _VideoItemModel&&(identical(other.id, id) || other.id == id)&&(identical(other.bvid, bvid) || other.bvid == bvid)&&(identical(other.cid, cid) || other.cid == cid)&&(identical(other.title, title) || other.title == title)&&(identical(other.pic, pic) || other.pic == pic)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.pubdate, pubdate) || other.pubdate == pubdate)&&(identical(other.uri, uri) || other.uri == uri)&&(identical(other.owner, owner) || other.owner == owner)&&(identical(other.stat, stat) || other.stat == stat)&&(identical(other.rcmdReason, rcmdReason) || other.rcmdReason == rcmdReason));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,bvid,cid,title,pic,duration,pubdate,uri,owner,stat,rcmdReason);
}

@override
String toString() {
    return 'VideoItemModel(id: $id, bvid: $bvid, cid: $cid, title: $title, pic: $pic, duration: $duration, pubdate: $pubdate, uri: $uri, owner: $owner, stat: $stat, rcmdReason: $rcmdReason)';
}


}

/// @nodoc
abstract mixin class _$VideoItemModelCopyWith<$Res> implements $VideoItemModelCopyWith<$Res> {
  factory _$VideoItemModelCopyWith(_VideoItemModel value, $Res Function(_VideoItemModel) _then) = __$VideoItemModelCopyWithImpl;
@override @useResult
$Res call({
 int id, String bvid, int cid, String title, String pic, int duration, int pubdate, String uri, VideoOwner? owner, VideoStat? stat,@JsonKey(name: 'rcmd_reason') String? rcmdReason
});


@override $VideoOwnerCopyWith<$Res>? get owner;@override $VideoStatCopyWith<$Res>? get stat;

}
/// @nodoc
class __$VideoItemModelCopyWithImpl<$Res>
    implements _$VideoItemModelCopyWith<$Res> {
  __$VideoItemModelCopyWithImpl(this._self, this._then);

  final _VideoItemModel _self;
  final $Res Function(_VideoItemModel) _then;

/// Create a copy of VideoItemModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? bvid = null,Object? cid = null,Object? title = null,Object? pic = null,Object? duration = null,Object? pubdate = null,Object? uri = null,Object? owner = freezed,Object? stat = freezed,Object? rcmdReason = freezed,}) {
  return _then(_VideoItemModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,bvid: null == bvid ? _self.bvid : bvid // ignore: cast_nullable_to_non_nullable
as String,cid: null == cid ? _self.cid : cid // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,pic: null == pic ? _self.pic : pic // ignore: cast_nullable_to_non_nullable
as String,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as int,pubdate: null == pubdate ? _self.pubdate : pubdate // ignore: cast_nullable_to_non_nullable
as int,uri: null == uri ? _self.uri : uri // ignore: cast_nullable_to_non_nullable
as String,owner: freezed == owner ? _self.owner : owner // ignore: cast_nullable_to_non_nullable
as VideoOwner?,stat: freezed == stat ? _self.stat : stat // ignore: cast_nullable_to_non_nullable
as VideoStat?,rcmdReason: freezed == rcmdReason ? _self.rcmdReason : rcmdReason // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of VideoItemModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VideoOwnerCopyWith<$Res>? get owner {
    if (_self.owner == null) {
    return null;
  }

  return $VideoOwnerCopyWith<$Res>(_self.owner!, (value) {
    return _then(_self.copyWith(owner: value));
  });
}/// Create a copy of VideoItemModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VideoStatCopyWith<$Res>? get stat {
    if (_self.stat == null) {
    return null;
  }

  return $VideoStatCopyWith<$Res>(_self.stat!, (value) {
    return _then(_self.copyWith(stat: value));
  });
}
}

// dart format on

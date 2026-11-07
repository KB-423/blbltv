// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../bangumi_episode_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BangumiEpisodeModel {

 int get id; int get aid; String get bvid; int get cid; String get title;@JsonKey(name: 'long_title') String get longTitle; String get badge; int get duration; String get cover; int get status;
/// Create a copy of BangumiEpisodeModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BangumiEpisodeModelCopyWith<BangumiEpisodeModel> get copyWith => _$BangumiEpisodeModelCopyWithImpl<BangumiEpisodeModel>(this as BangumiEpisodeModel, _$identity);

  /// Serializes this BangumiEpisodeModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as BangumiEpisodeModel;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BangumiEpisodeModel&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.aid, _this.aid) || other.aid == _this.aid)&&(identical(other.bvid, _this.bvid) || other.bvid == _this.bvid)&&(identical(other.cid, _this.cid) || other.cid == _this.cid)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.longTitle, _this.longTitle) || other.longTitle == _this.longTitle)&&(identical(other.badge, _this.badge) || other.badge == _this.badge)&&(identical(other.duration, _this.duration) || other.duration == _this.duration)&&(identical(other.cover, _this.cover) || other.cover == _this.cover)&&(identical(other.status, _this.status) || other.status == _this.status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as BangumiEpisodeModel;
  return Object.hash(runtimeType,_this.id,_this.aid,_this.bvid,_this.cid,_this.title,_this.longTitle,_this.badge,_this.duration,_this.cover,_this.status);
}

@override
String toString() {
  final _this = this as BangumiEpisodeModel;
  return 'BangumiEpisodeModel(id: ${_this.id}, aid: ${_this.aid}, bvid: ${_this.bvid}, cid: ${_this.cid}, title: ${_this.title}, longTitle: ${_this.longTitle}, badge: ${_this.badge}, duration: ${_this.duration}, cover: ${_this.cover}, status: ${_this.status})';
}


}

/// @nodoc
abstract mixin class $BangumiEpisodeModelCopyWith<$Res>  {
  factory $BangumiEpisodeModelCopyWith(BangumiEpisodeModel value, $Res Function(BangumiEpisodeModel) _then) = _$BangumiEpisodeModelCopyWithImpl;
@useResult
$Res call({
 int id, int aid, String bvid, int cid, String title,@JsonKey(name: 'long_title') String longTitle, String badge, int duration, String cover, int status
});




}
/// @nodoc
class _$BangumiEpisodeModelCopyWithImpl<$Res>
    implements $BangumiEpisodeModelCopyWith<$Res> {
  _$BangumiEpisodeModelCopyWithImpl(this._self, this._then);

  final BangumiEpisodeModel _self;
  final $Res Function(BangumiEpisodeModel) _then;

/// Create a copy of BangumiEpisodeModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? aid = null,Object? bvid = null,Object? cid = null,Object? title = null,Object? longTitle = null,Object? badge = null,Object? duration = null,Object? cover = null,Object? status = null,}) {
  return _then(BangumiEpisodeModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,aid: null == aid ? _self.aid : aid // ignore: cast_nullable_to_non_nullable
as int,bvid: null == bvid ? _self.bvid : bvid // ignore: cast_nullable_to_non_nullable
as String,cid: null == cid ? _self.cid : cid // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,longTitle: null == longTitle ? _self.longTitle : longTitle // ignore: cast_nullable_to_non_nullable
as String,badge: null == badge ? _self.badge : badge // ignore: cast_nullable_to_non_nullable
as String,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as int,cover: null == cover ? _self.cover : cover // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [BangumiEpisodeModel].
extension BangumiEpisodeModelPatterns on BangumiEpisodeModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BangumiEpisodeModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BangumiEpisodeModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BangumiEpisodeModel value)  $default,){
final _that = this;
switch (_that) {
case _BangumiEpisodeModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BangumiEpisodeModel value)?  $default,){
final _that = this;
switch (_that) {
case _BangumiEpisodeModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int aid,  String bvid,  int cid,  String title, @JsonKey(name: 'long_title')  String longTitle,  String badge,  int duration,  String cover,  int status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BangumiEpisodeModel() when $default != null:
return $default(_that.id,_that.aid,_that.bvid,_that.cid,_that.title,_that.longTitle,_that.badge,_that.duration,_that.cover,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int aid,  String bvid,  int cid,  String title, @JsonKey(name: 'long_title')  String longTitle,  String badge,  int duration,  String cover,  int status)  $default,) {final _that = this;
switch (_that) {
case _BangumiEpisodeModel():
return $default(_that.id,_that.aid,_that.bvid,_that.cid,_that.title,_that.longTitle,_that.badge,_that.duration,_that.cover,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int aid,  String bvid,  int cid,  String title, @JsonKey(name: 'long_title')  String longTitle,  String badge,  int duration,  String cover,  int status)?  $default,) {final _that = this;
switch (_that) {
case _BangumiEpisodeModel() when $default != null:
return $default(_that.id,_that.aid,_that.bvid,_that.cid,_that.title,_that.longTitle,_that.badge,_that.duration,_that.cover,_that.status);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BangumiEpisodeModel implements BangumiEpisodeModel {
  const _BangumiEpisodeModel({this.id = 0, this.aid = 0, this.bvid = '', this.cid = 0, this.title = '', @JsonKey(name: 'long_title') this.longTitle = '', this.badge = '', this.duration = 0, this.cover = '', this.status = 0});
  factory _BangumiEpisodeModel.fromJson(Map<String, dynamic> json) => _$BangumiEpisodeModelFromJson(json);

@override@JsonKey() final  int id;
@override@JsonKey() final  int aid;
@override@JsonKey() final  String bvid;
@override@JsonKey() final  int cid;
@override@JsonKey() final  String title;
@override@JsonKey(name: 'long_title') final  String longTitle;
@override@JsonKey() final  String badge;
@override@JsonKey() final  int duration;
@override@JsonKey() final  String cover;
@override@JsonKey() final  int status;

/// Create a copy of BangumiEpisodeModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BangumiEpisodeModelCopyWith<_BangumiEpisodeModel> get copyWith => __$BangumiEpisodeModelCopyWithImpl<_BangumiEpisodeModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BangumiEpisodeModelToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _BangumiEpisodeModel&&(identical(other.id, id) || other.id == id)&&(identical(other.aid, aid) || other.aid == aid)&&(identical(other.bvid, bvid) || other.bvid == bvid)&&(identical(other.cid, cid) || other.cid == cid)&&(identical(other.title, title) || other.title == title)&&(identical(other.longTitle, longTitle) || other.longTitle == longTitle)&&(identical(other.badge, badge) || other.badge == badge)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.cover, cover) || other.cover == cover)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,aid,bvid,cid,title,longTitle,badge,duration,cover,status);
}

@override
String toString() {
    return 'BangumiEpisodeModel(id: $id, aid: $aid, bvid: $bvid, cid: $cid, title: $title, longTitle: $longTitle, badge: $badge, duration: $duration, cover: $cover, status: $status)';
}


}

/// @nodoc
abstract mixin class _$BangumiEpisodeModelCopyWith<$Res> implements $BangumiEpisodeModelCopyWith<$Res> {
  factory _$BangumiEpisodeModelCopyWith(_BangumiEpisodeModel value, $Res Function(_BangumiEpisodeModel) _then) = __$BangumiEpisodeModelCopyWithImpl;
@override @useResult
$Res call({
 int id, int aid, String bvid, int cid, String title,@JsonKey(name: 'long_title') String longTitle, String badge, int duration, String cover, int status
});




}
/// @nodoc
class __$BangumiEpisodeModelCopyWithImpl<$Res>
    implements _$BangumiEpisodeModelCopyWith<$Res> {
  __$BangumiEpisodeModelCopyWithImpl(this._self, this._then);

  final _BangumiEpisodeModel _self;
  final $Res Function(_BangumiEpisodeModel) _then;

/// Create a copy of BangumiEpisodeModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? aid = null,Object? bvid = null,Object? cid = null,Object? title = null,Object? longTitle = null,Object? badge = null,Object? duration = null,Object? cover = null,Object? status = null,}) {
  return _then(_BangumiEpisodeModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,aid: null == aid ? _self.aid : aid // ignore: cast_nullable_to_non_nullable
as int,bvid: null == bvid ? _self.bvid : bvid // ignore: cast_nullable_to_non_nullable
as String,cid: null == cid ? _self.cid : cid // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,longTitle: null == longTitle ? _self.longTitle : longTitle // ignore: cast_nullable_to_non_nullable
as String,badge: null == badge ? _self.badge : badge // ignore: cast_nullable_to_non_nullable
as String,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as int,cover: null == cover ? _self.cover : cover // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on

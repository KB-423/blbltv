// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../user_favorite_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserFavFolder {

 int get id; int get fid; int get mid; String get title; String get cover;@JsonKey(name: 'media_count') int get mediaCount;
/// Create a copy of UserFavFolder
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserFavFolderCopyWith<UserFavFolder> get copyWith => _$UserFavFolderCopyWithImpl<UserFavFolder>(this as UserFavFolder, _$identity);

  /// Serializes this UserFavFolder to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as UserFavFolder;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserFavFolder&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.fid, _this.fid) || other.fid == _this.fid)&&(identical(other.mid, _this.mid) || other.mid == _this.mid)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.cover, _this.cover) || other.cover == _this.cover)&&(identical(other.mediaCount, _this.mediaCount) || other.mediaCount == _this.mediaCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as UserFavFolder;
  return Object.hash(runtimeType,_this.id,_this.fid,_this.mid,_this.title,_this.cover,_this.mediaCount);
}

@override
String toString() {
  final _this = this as UserFavFolder;
  return 'UserFavFolder(id: ${_this.id}, fid: ${_this.fid}, mid: ${_this.mid}, title: ${_this.title}, cover: ${_this.cover}, mediaCount: ${_this.mediaCount})';
}


}

/// @nodoc
abstract mixin class $UserFavFolderCopyWith<$Res>  {
  factory $UserFavFolderCopyWith(UserFavFolder value, $Res Function(UserFavFolder) _then) = _$UserFavFolderCopyWithImpl;
@useResult
$Res call({
 int id, int fid, int mid, String title, String cover,@JsonKey(name: 'media_count') int mediaCount
});




}
/// @nodoc
class _$UserFavFolderCopyWithImpl<$Res>
    implements $UserFavFolderCopyWith<$Res> {
  _$UserFavFolderCopyWithImpl(this._self, this._then);

  final UserFavFolder _self;
  final $Res Function(UserFavFolder) _then;

/// Create a copy of UserFavFolder
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? fid = null,Object? mid = null,Object? title = null,Object? cover = null,Object? mediaCount = null,}) {
  return _then(UserFavFolder(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,fid: null == fid ? _self.fid : fid // ignore: cast_nullable_to_non_nullable
as int,mid: null == mid ? _self.mid : mid // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,cover: null == cover ? _self.cover : cover // ignore: cast_nullable_to_non_nullable
as String,mediaCount: null == mediaCount ? _self.mediaCount : mediaCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [UserFavFolder].
extension UserFavFolderPatterns on UserFavFolder {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserFavFolder value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserFavFolder() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserFavFolder value)  $default,){
final _that = this;
switch (_that) {
case _UserFavFolder():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserFavFolder value)?  $default,){
final _that = this;
switch (_that) {
case _UserFavFolder() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int fid,  int mid,  String title,  String cover, @JsonKey(name: 'media_count')  int mediaCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserFavFolder() when $default != null:
return $default(_that.id,_that.fid,_that.mid,_that.title,_that.cover,_that.mediaCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int fid,  int mid,  String title,  String cover, @JsonKey(name: 'media_count')  int mediaCount)  $default,) {final _that = this;
switch (_that) {
case _UserFavFolder():
return $default(_that.id,_that.fid,_that.mid,_that.title,_that.cover,_that.mediaCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int fid,  int mid,  String title,  String cover, @JsonKey(name: 'media_count')  int mediaCount)?  $default,) {final _that = this;
switch (_that) {
case _UserFavFolder() when $default != null:
return $default(_that.id,_that.fid,_that.mid,_that.title,_that.cover,_that.mediaCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserFavFolder implements UserFavFolder {
  const _UserFavFolder({this.id = 0, this.fid = 0, this.mid = 0, this.title = '', this.cover = '', @JsonKey(name: 'media_count') this.mediaCount = 0});
  factory _UserFavFolder.fromJson(Map<String, dynamic> json) => _$UserFavFolderFromJson(json);

@override@JsonKey() final  int id;
@override@JsonKey() final  int fid;
@override@JsonKey() final  int mid;
@override@JsonKey() final  String title;
@override@JsonKey() final  String cover;
@override@JsonKey(name: 'media_count') final  int mediaCount;

/// Create a copy of UserFavFolder
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserFavFolderCopyWith<_UserFavFolder> get copyWith => __$UserFavFolderCopyWithImpl<_UserFavFolder>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserFavFolderToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserFavFolder&&(identical(other.id, id) || other.id == id)&&(identical(other.fid, fid) || other.fid == fid)&&(identical(other.mid, mid) || other.mid == mid)&&(identical(other.title, title) || other.title == title)&&(identical(other.cover, cover) || other.cover == cover)&&(identical(other.mediaCount, mediaCount) || other.mediaCount == mediaCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,fid,mid,title,cover,mediaCount);
}

@override
String toString() {
    return 'UserFavFolder(id: $id, fid: $fid, mid: $mid, title: $title, cover: $cover, mediaCount: $mediaCount)';
}


}

/// @nodoc
abstract mixin class _$UserFavFolderCopyWith<$Res> implements $UserFavFolderCopyWith<$Res> {
  factory _$UserFavFolderCopyWith(_UserFavFolder value, $Res Function(_UserFavFolder) _then) = __$UserFavFolderCopyWithImpl;
@override @useResult
$Res call({
 int id, int fid, int mid, String title, String cover,@JsonKey(name: 'media_count') int mediaCount
});




}
/// @nodoc
class __$UserFavFolderCopyWithImpl<$Res>
    implements _$UserFavFolderCopyWith<$Res> {
  __$UserFavFolderCopyWithImpl(this._self, this._then);

  final _UserFavFolder _self;
  final $Res Function(_UserFavFolder) _then;

/// Create a copy of UserFavFolder
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? fid = null,Object? mid = null,Object? title = null,Object? cover = null,Object? mediaCount = null,}) {
  return _then(_UserFavFolder(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,fid: null == fid ? _self.fid : fid // ignore: cast_nullable_to_non_nullable
as int,mid: null == mid ? _self.mid : mid // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,cover: null == cover ? _self.cover : cover // ignore: cast_nullable_to_non_nullable
as String,mediaCount: null == mediaCount ? _self.mediaCount : mediaCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$UserFavItem {

 int get id; String get title; String get cover; String get bvid;@JsonKey(name: 'upper_name') String get upperName; int get duration;@JsonKey(name: 'fav_time') int get favTime;@JsonKey(name: 'play_count') int get playCount;@JsonKey(name: 'danmaku_count') int get danmakuCount;
/// Create a copy of UserFavItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserFavItemCopyWith<UserFavItem> get copyWith => _$UserFavItemCopyWithImpl<UserFavItem>(this as UserFavItem, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as UserFavItem;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserFavItem&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.cover, _this.cover) || other.cover == _this.cover)&&(identical(other.bvid, _this.bvid) || other.bvid == _this.bvid)&&(identical(other.upperName, _this.upperName) || other.upperName == _this.upperName)&&(identical(other.duration, _this.duration) || other.duration == _this.duration)&&(identical(other.favTime, _this.favTime) || other.favTime == _this.favTime)&&(identical(other.playCount, _this.playCount) || other.playCount == _this.playCount)&&(identical(other.danmakuCount, _this.danmakuCount) || other.danmakuCount == _this.danmakuCount));
}


@override
int get hashCode {
  final _this = this as UserFavItem;
  return Object.hash(runtimeType,_this.id,_this.title,_this.cover,_this.bvid,_this.upperName,_this.duration,_this.favTime,_this.playCount,_this.danmakuCount);
}

@override
String toString() {
  final _this = this as UserFavItem;
  return 'UserFavItem(id: ${_this.id}, title: ${_this.title}, cover: ${_this.cover}, bvid: ${_this.bvid}, upperName: ${_this.upperName}, duration: ${_this.duration}, favTime: ${_this.favTime}, playCount: ${_this.playCount}, danmakuCount: ${_this.danmakuCount})';
}


}

/// @nodoc
abstract mixin class $UserFavItemCopyWith<$Res>  {
  factory $UserFavItemCopyWith(UserFavItem value, $Res Function(UserFavItem) _then) = _$UserFavItemCopyWithImpl;
@useResult
$Res call({
 int id, String title, String cover, String bvid,@JsonKey(name: 'upper_name') String upperName, int duration,@JsonKey(name: 'fav_time') int favTime,@JsonKey(name: 'play_count') int playCount,@JsonKey(name: 'danmaku_count') int danmakuCount
});




}
/// @nodoc
class _$UserFavItemCopyWithImpl<$Res>
    implements $UserFavItemCopyWith<$Res> {
  _$UserFavItemCopyWithImpl(this._self, this._then);

  final UserFavItem _self;
  final $Res Function(UserFavItem) _then;

/// Create a copy of UserFavItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? cover = null,Object? bvid = null,Object? upperName = null,Object? duration = null,Object? favTime = null,Object? playCount = null,Object? danmakuCount = null,}) {
  return _then(UserFavItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,cover: null == cover ? _self.cover : cover // ignore: cast_nullable_to_non_nullable
as String,bvid: null == bvid ? _self.bvid : bvid // ignore: cast_nullable_to_non_nullable
as String,upperName: null == upperName ? _self.upperName : upperName // ignore: cast_nullable_to_non_nullable
as String,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as int,favTime: null == favTime ? _self.favTime : favTime // ignore: cast_nullable_to_non_nullable
as int,playCount: null == playCount ? _self.playCount : playCount // ignore: cast_nullable_to_non_nullable
as int,danmakuCount: null == danmakuCount ? _self.danmakuCount : danmakuCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [UserFavItem].
extension UserFavItemPatterns on UserFavItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserFavItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserFavItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserFavItem value)  $default,){
final _that = this;
switch (_that) {
case _UserFavItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserFavItem value)?  $default,){
final _that = this;
switch (_that) {
case _UserFavItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String title,  String cover,  String bvid, @JsonKey(name: 'upper_name')  String upperName,  int duration, @JsonKey(name: 'fav_time')  int favTime, @JsonKey(name: 'play_count')  int playCount, @JsonKey(name: 'danmaku_count')  int danmakuCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserFavItem() when $default != null:
return $default(_that.id,_that.title,_that.cover,_that.bvid,_that.upperName,_that.duration,_that.favTime,_that.playCount,_that.danmakuCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String title,  String cover,  String bvid, @JsonKey(name: 'upper_name')  String upperName,  int duration, @JsonKey(name: 'fav_time')  int favTime, @JsonKey(name: 'play_count')  int playCount, @JsonKey(name: 'danmaku_count')  int danmakuCount)  $default,) {final _that = this;
switch (_that) {
case _UserFavItem():
return $default(_that.id,_that.title,_that.cover,_that.bvid,_that.upperName,_that.duration,_that.favTime,_that.playCount,_that.danmakuCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String title,  String cover,  String bvid, @JsonKey(name: 'upper_name')  String upperName,  int duration, @JsonKey(name: 'fav_time')  int favTime, @JsonKey(name: 'play_count')  int playCount, @JsonKey(name: 'danmaku_count')  int danmakuCount)?  $default,) {final _that = this;
switch (_that) {
case _UserFavItem() when $default != null:
return $default(_that.id,_that.title,_that.cover,_that.bvid,_that.upperName,_that.duration,_that.favTime,_that.playCount,_that.danmakuCount);case _:
  return null;

}
}

}

/// @nodoc


class _UserFavItem implements UserFavItem {
  const _UserFavItem({this.id = 0, this.title = '', this.cover = '', this.bvid = '', @JsonKey(name: 'upper_name') this.upperName = '', this.duration = 0, @JsonKey(name: 'fav_time') this.favTime = 0, @JsonKey(name: 'play_count') this.playCount = 0, @JsonKey(name: 'danmaku_count') this.danmakuCount = 0});
  

@override@JsonKey() final  int id;
@override@JsonKey() final  String title;
@override@JsonKey() final  String cover;
@override@JsonKey() final  String bvid;
@override@JsonKey(name: 'upper_name') final  String upperName;
@override@JsonKey() final  int duration;
@override@JsonKey(name: 'fav_time') final  int favTime;
@override@JsonKey(name: 'play_count') final  int playCount;
@override@JsonKey(name: 'danmaku_count') final  int danmakuCount;

/// Create a copy of UserFavItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserFavItemCopyWith<_UserFavItem> get copyWith => __$UserFavItemCopyWithImpl<_UserFavItem>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserFavItem&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.cover, cover) || other.cover == cover)&&(identical(other.bvid, bvid) || other.bvid == bvid)&&(identical(other.upperName, upperName) || other.upperName == upperName)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.favTime, favTime) || other.favTime == favTime)&&(identical(other.playCount, playCount) || other.playCount == playCount)&&(identical(other.danmakuCount, danmakuCount) || other.danmakuCount == danmakuCount));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,title,cover,bvid,upperName,duration,favTime,playCount,danmakuCount);
}

@override
String toString() {
    return 'UserFavItem(id: $id, title: $title, cover: $cover, bvid: $bvid, upperName: $upperName, duration: $duration, favTime: $favTime, playCount: $playCount, danmakuCount: $danmakuCount)';
}


}

/// @nodoc
abstract mixin class _$UserFavItemCopyWith<$Res> implements $UserFavItemCopyWith<$Res> {
  factory _$UserFavItemCopyWith(_UserFavItem value, $Res Function(_UserFavItem) _then) = __$UserFavItemCopyWithImpl;
@override @useResult
$Res call({
 int id, String title, String cover, String bvid,@JsonKey(name: 'upper_name') String upperName, int duration,@JsonKey(name: 'fav_time') int favTime,@JsonKey(name: 'play_count') int playCount,@JsonKey(name: 'danmaku_count') int danmakuCount
});




}
/// @nodoc
class __$UserFavItemCopyWithImpl<$Res>
    implements _$UserFavItemCopyWith<$Res> {
  __$UserFavItemCopyWithImpl(this._self, this._then);

  final _UserFavItem _self;
  final $Res Function(_UserFavItem) _then;

/// Create a copy of UserFavItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? cover = null,Object? bvid = null,Object? upperName = null,Object? duration = null,Object? favTime = null,Object? playCount = null,Object? danmakuCount = null,}) {
  return _then(_UserFavItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,cover: null == cover ? _self.cover : cover // ignore: cast_nullable_to_non_nullable
as String,bvid: null == bvid ? _self.bvid : bvid // ignore: cast_nullable_to_non_nullable
as String,upperName: null == upperName ? _self.upperName : upperName // ignore: cast_nullable_to_non_nullable
as String,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as int,favTime: null == favTime ? _self.favTime : favTime // ignore: cast_nullable_to_non_nullable
as int,playCount: null == playCount ? _self.playCount : playCount // ignore: cast_nullable_to_non_nullable
as int,danmakuCount: null == danmakuCount ? _self.danmakuCount : danmakuCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on

// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../user_history_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$UserHistoryItem {

 String get title; String get cover; String get bvid; int get cid; int get progress; int get duration;@JsonKey(name: 'author_name') String get authorName;@JsonKey(name: 'author_face') String get authorFace;@JsonKey(name: 'author_mid') int get authorMid;@JsonKey(name: 'view_at') int get viewAt;@JsonKey(name: 'show_title') String get showTitle; String get badge;
/// Create a copy of UserHistoryItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserHistoryItemCopyWith<UserHistoryItem> get copyWith => _$UserHistoryItemCopyWithImpl<UserHistoryItem>(this as UserHistoryItem, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as UserHistoryItem;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserHistoryItem&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.cover, _this.cover) || other.cover == _this.cover)&&(identical(other.bvid, _this.bvid) || other.bvid == _this.bvid)&&(identical(other.cid, _this.cid) || other.cid == _this.cid)&&(identical(other.progress, _this.progress) || other.progress == _this.progress)&&(identical(other.duration, _this.duration) || other.duration == _this.duration)&&(identical(other.authorName, _this.authorName) || other.authorName == _this.authorName)&&(identical(other.authorFace, _this.authorFace) || other.authorFace == _this.authorFace)&&(identical(other.authorMid, _this.authorMid) || other.authorMid == _this.authorMid)&&(identical(other.viewAt, _this.viewAt) || other.viewAt == _this.viewAt)&&(identical(other.showTitle, _this.showTitle) || other.showTitle == _this.showTitle)&&(identical(other.badge, _this.badge) || other.badge == _this.badge));
}


@override
int get hashCode {
  final _this = this as UserHistoryItem;
  return Object.hash(runtimeType,_this.title,_this.cover,_this.bvid,_this.cid,_this.progress,_this.duration,_this.authorName,_this.authorFace,_this.authorMid,_this.viewAt,_this.showTitle,_this.badge);
}

@override
String toString() {
  final _this = this as UserHistoryItem;
  return 'UserHistoryItem(title: ${_this.title}, cover: ${_this.cover}, bvid: ${_this.bvid}, cid: ${_this.cid}, progress: ${_this.progress}, duration: ${_this.duration}, authorName: ${_this.authorName}, authorFace: ${_this.authorFace}, authorMid: ${_this.authorMid}, viewAt: ${_this.viewAt}, showTitle: ${_this.showTitle}, badge: ${_this.badge})';
}


}

/// @nodoc
abstract mixin class $UserHistoryItemCopyWith<$Res>  {
  factory $UserHistoryItemCopyWith(UserHistoryItem value, $Res Function(UserHistoryItem) _then) = _$UserHistoryItemCopyWithImpl;
@useResult
$Res call({
 String title, String cover, String bvid, int cid, int progress, int duration,@JsonKey(name: 'author_name') String authorName,@JsonKey(name: 'author_face') String authorFace,@JsonKey(name: 'author_mid') int authorMid,@JsonKey(name: 'view_at') int viewAt,@JsonKey(name: 'show_title') String showTitle, String badge
});




}
/// @nodoc
class _$UserHistoryItemCopyWithImpl<$Res>
    implements $UserHistoryItemCopyWith<$Res> {
  _$UserHistoryItemCopyWithImpl(this._self, this._then);

  final UserHistoryItem _self;
  final $Res Function(UserHistoryItem) _then;

/// Create a copy of UserHistoryItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = null,Object? cover = null,Object? bvid = null,Object? cid = null,Object? progress = null,Object? duration = null,Object? authorName = null,Object? authorFace = null,Object? authorMid = null,Object? viewAt = null,Object? showTitle = null,Object? badge = null,}) {
  return _then(UserHistoryItem(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,cover: null == cover ? _self.cover : cover // ignore: cast_nullable_to_non_nullable
as String,bvid: null == bvid ? _self.bvid : bvid // ignore: cast_nullable_to_non_nullable
as String,cid: null == cid ? _self.cid : cid // ignore: cast_nullable_to_non_nullable
as int,progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as int,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as int,authorName: null == authorName ? _self.authorName : authorName // ignore: cast_nullable_to_non_nullable
as String,authorFace: null == authorFace ? _self.authorFace : authorFace // ignore: cast_nullable_to_non_nullable
as String,authorMid: null == authorMid ? _self.authorMid : authorMid // ignore: cast_nullable_to_non_nullable
as int,viewAt: null == viewAt ? _self.viewAt : viewAt // ignore: cast_nullable_to_non_nullable
as int,showTitle: null == showTitle ? _self.showTitle : showTitle // ignore: cast_nullable_to_non_nullable
as String,badge: null == badge ? _self.badge : badge // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [UserHistoryItem].
extension UserHistoryItemPatterns on UserHistoryItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserHistoryItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserHistoryItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserHistoryItem value)  $default,){
final _that = this;
switch (_that) {
case _UserHistoryItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserHistoryItem value)?  $default,){
final _that = this;
switch (_that) {
case _UserHistoryItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String title,  String cover,  String bvid,  int cid,  int progress,  int duration, @JsonKey(name: 'author_name')  String authorName, @JsonKey(name: 'author_face')  String authorFace, @JsonKey(name: 'author_mid')  int authorMid, @JsonKey(name: 'view_at')  int viewAt, @JsonKey(name: 'show_title')  String showTitle,  String badge)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserHistoryItem() when $default != null:
return $default(_that.title,_that.cover,_that.bvid,_that.cid,_that.progress,_that.duration,_that.authorName,_that.authorFace,_that.authorMid,_that.viewAt,_that.showTitle,_that.badge);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String title,  String cover,  String bvid,  int cid,  int progress,  int duration, @JsonKey(name: 'author_name')  String authorName, @JsonKey(name: 'author_face')  String authorFace, @JsonKey(name: 'author_mid')  int authorMid, @JsonKey(name: 'view_at')  int viewAt, @JsonKey(name: 'show_title')  String showTitle,  String badge)  $default,) {final _that = this;
switch (_that) {
case _UserHistoryItem():
return $default(_that.title,_that.cover,_that.bvid,_that.cid,_that.progress,_that.duration,_that.authorName,_that.authorFace,_that.authorMid,_that.viewAt,_that.showTitle,_that.badge);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String title,  String cover,  String bvid,  int cid,  int progress,  int duration, @JsonKey(name: 'author_name')  String authorName, @JsonKey(name: 'author_face')  String authorFace, @JsonKey(name: 'author_mid')  int authorMid, @JsonKey(name: 'view_at')  int viewAt, @JsonKey(name: 'show_title')  String showTitle,  String badge)?  $default,) {final _that = this;
switch (_that) {
case _UserHistoryItem() when $default != null:
return $default(_that.title,_that.cover,_that.bvid,_that.cid,_that.progress,_that.duration,_that.authorName,_that.authorFace,_that.authorMid,_that.viewAt,_that.showTitle,_that.badge);case _:
  return null;

}
}

}

/// @nodoc


class _UserHistoryItem implements UserHistoryItem {
  const _UserHistoryItem({this.title = '', this.cover = '', this.bvid = '', this.cid = 0, this.progress = 0, this.duration = 0, @JsonKey(name: 'author_name') this.authorName = '', @JsonKey(name: 'author_face') this.authorFace = '', @JsonKey(name: 'author_mid') this.authorMid = 0, @JsonKey(name: 'view_at') this.viewAt = 0, @JsonKey(name: 'show_title') this.showTitle = '', this.badge = ''});
  

@override@JsonKey() final  String title;
@override@JsonKey() final  String cover;
@override@JsonKey() final  String bvid;
@override@JsonKey() final  int cid;
@override@JsonKey() final  int progress;
@override@JsonKey() final  int duration;
@override@JsonKey(name: 'author_name') final  String authorName;
@override@JsonKey(name: 'author_face') final  String authorFace;
@override@JsonKey(name: 'author_mid') final  int authorMid;
@override@JsonKey(name: 'view_at') final  int viewAt;
@override@JsonKey(name: 'show_title') final  String showTitle;
@override@JsonKey() final  String badge;

/// Create a copy of UserHistoryItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserHistoryItemCopyWith<_UserHistoryItem> get copyWith => __$UserHistoryItemCopyWithImpl<_UserHistoryItem>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserHistoryItem&&(identical(other.title, title) || other.title == title)&&(identical(other.cover, cover) || other.cover == cover)&&(identical(other.bvid, bvid) || other.bvid == bvid)&&(identical(other.cid, cid) || other.cid == cid)&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.authorName, authorName) || other.authorName == authorName)&&(identical(other.authorFace, authorFace) || other.authorFace == authorFace)&&(identical(other.authorMid, authorMid) || other.authorMid == authorMid)&&(identical(other.viewAt, viewAt) || other.viewAt == viewAt)&&(identical(other.showTitle, showTitle) || other.showTitle == showTitle)&&(identical(other.badge, badge) || other.badge == badge));
}


@override
int get hashCode {
    return Object.hash(runtimeType,title,cover,bvid,cid,progress,duration,authorName,authorFace,authorMid,viewAt,showTitle,badge);
}

@override
String toString() {
    return 'UserHistoryItem(title: $title, cover: $cover, bvid: $bvid, cid: $cid, progress: $progress, duration: $duration, authorName: $authorName, authorFace: $authorFace, authorMid: $authorMid, viewAt: $viewAt, showTitle: $showTitle, badge: $badge)';
}


}

/// @nodoc
abstract mixin class _$UserHistoryItemCopyWith<$Res> implements $UserHistoryItemCopyWith<$Res> {
  factory _$UserHistoryItemCopyWith(_UserHistoryItem value, $Res Function(_UserHistoryItem) _then) = __$UserHistoryItemCopyWithImpl;
@override @useResult
$Res call({
 String title, String cover, String bvid, int cid, int progress, int duration,@JsonKey(name: 'author_name') String authorName,@JsonKey(name: 'author_face') String authorFace,@JsonKey(name: 'author_mid') int authorMid,@JsonKey(name: 'view_at') int viewAt,@JsonKey(name: 'show_title') String showTitle, String badge
});




}
/// @nodoc
class __$UserHistoryItemCopyWithImpl<$Res>
    implements _$UserHistoryItemCopyWith<$Res> {
  __$UserHistoryItemCopyWithImpl(this._self, this._then);

  final _UserHistoryItem _self;
  final $Res Function(_UserHistoryItem) _then;

/// Create a copy of UserHistoryItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? cover = null,Object? bvid = null,Object? cid = null,Object? progress = null,Object? duration = null,Object? authorName = null,Object? authorFace = null,Object? authorMid = null,Object? viewAt = null,Object? showTitle = null,Object? badge = null,}) {
  return _then(_UserHistoryItem(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,cover: null == cover ? _self.cover : cover // ignore: cast_nullable_to_non_nullable
as String,bvid: null == bvid ? _self.bvid : bvid // ignore: cast_nullable_to_non_nullable
as String,cid: null == cid ? _self.cid : cid // ignore: cast_nullable_to_non_nullable
as int,progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as int,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as int,authorName: null == authorName ? _self.authorName : authorName // ignore: cast_nullable_to_non_nullable
as String,authorFace: null == authorFace ? _self.authorFace : authorFace // ignore: cast_nullable_to_non_nullable
as String,authorMid: null == authorMid ? _self.authorMid : authorMid // ignore: cast_nullable_to_non_nullable
as int,viewAt: null == viewAt ? _self.viewAt : viewAt // ignore: cast_nullable_to_non_nullable
as int,showTitle: null == showTitle ? _self.showTitle : showTitle // ignore: cast_nullable_to_non_nullable
as String,badge: null == badge ? _self.badge : badge // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on

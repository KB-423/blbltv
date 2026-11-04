// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../user_bangumi_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$UserBangumiItem {

@JsonKey(name: 'season_id') int get seasonId; String get title; String get cover;@JsonKey(name: 'total_count') String get totalCount;@JsonKey(name: 'new_ep_title') String get newEpTitle;@JsonKey(name: 'progress') String get progress; String get badge; String get evaluate;
/// Create a copy of UserBangumiItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserBangumiItemCopyWith<UserBangumiItem> get copyWith => _$UserBangumiItemCopyWithImpl<UserBangumiItem>(this as UserBangumiItem, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as UserBangumiItem;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserBangumiItem&&(identical(other.seasonId, _this.seasonId) || other.seasonId == _this.seasonId)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.cover, _this.cover) || other.cover == _this.cover)&&(identical(other.totalCount, _this.totalCount) || other.totalCount == _this.totalCount)&&(identical(other.newEpTitle, _this.newEpTitle) || other.newEpTitle == _this.newEpTitle)&&(identical(other.progress, _this.progress) || other.progress == _this.progress)&&(identical(other.badge, _this.badge) || other.badge == _this.badge)&&(identical(other.evaluate, _this.evaluate) || other.evaluate == _this.evaluate));
}


@override
int get hashCode {
  final _this = this as UserBangumiItem;
  return Object.hash(runtimeType,_this.seasonId,_this.title,_this.cover,_this.totalCount,_this.newEpTitle,_this.progress,_this.badge,_this.evaluate);
}

@override
String toString() {
  final _this = this as UserBangumiItem;
  return 'UserBangumiItem(seasonId: ${_this.seasonId}, title: ${_this.title}, cover: ${_this.cover}, totalCount: ${_this.totalCount}, newEpTitle: ${_this.newEpTitle}, progress: ${_this.progress}, badge: ${_this.badge}, evaluate: ${_this.evaluate})';
}


}

/// @nodoc
abstract mixin class $UserBangumiItemCopyWith<$Res>  {
  factory $UserBangumiItemCopyWith(UserBangumiItem value, $Res Function(UserBangumiItem) _then) = _$UserBangumiItemCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'season_id') int seasonId, String title, String cover,@JsonKey(name: 'total_count') String totalCount,@JsonKey(name: 'new_ep_title') String newEpTitle,@JsonKey(name: 'progress') String progress, String badge, String evaluate
});




}
/// @nodoc
class _$UserBangumiItemCopyWithImpl<$Res>
    implements $UserBangumiItemCopyWith<$Res> {
  _$UserBangumiItemCopyWithImpl(this._self, this._then);

  final UserBangumiItem _self;
  final $Res Function(UserBangumiItem) _then;

/// Create a copy of UserBangumiItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? seasonId = null,Object? title = null,Object? cover = null,Object? totalCount = null,Object? newEpTitle = null,Object? progress = null,Object? badge = null,Object? evaluate = null,}) {
  return _then(UserBangumiItem(
seasonId: null == seasonId ? _self.seasonId : seasonId // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,cover: null == cover ? _self.cover : cover // ignore: cast_nullable_to_non_nullable
as String,totalCount: null == totalCount ? _self.totalCount : totalCount // ignore: cast_nullable_to_non_nullable
as String,newEpTitle: null == newEpTitle ? _self.newEpTitle : newEpTitle // ignore: cast_nullable_to_non_nullable
as String,progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as String,badge: null == badge ? _self.badge : badge // ignore: cast_nullable_to_non_nullable
as String,evaluate: null == evaluate ? _self.evaluate : evaluate // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [UserBangumiItem].
extension UserBangumiItemPatterns on UserBangumiItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserBangumiItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserBangumiItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserBangumiItem value)  $default,){
final _that = this;
switch (_that) {
case _UserBangumiItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserBangumiItem value)?  $default,){
final _that = this;
switch (_that) {
case _UserBangumiItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'season_id')  int seasonId,  String title,  String cover, @JsonKey(name: 'total_count')  String totalCount, @JsonKey(name: 'new_ep_title')  String newEpTitle, @JsonKey(name: 'progress')  String progress,  String badge,  String evaluate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserBangumiItem() when $default != null:
return $default(_that.seasonId,_that.title,_that.cover,_that.totalCount,_that.newEpTitle,_that.progress,_that.badge,_that.evaluate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'season_id')  int seasonId,  String title,  String cover, @JsonKey(name: 'total_count')  String totalCount, @JsonKey(name: 'new_ep_title')  String newEpTitle, @JsonKey(name: 'progress')  String progress,  String badge,  String evaluate)  $default,) {final _that = this;
switch (_that) {
case _UserBangumiItem():
return $default(_that.seasonId,_that.title,_that.cover,_that.totalCount,_that.newEpTitle,_that.progress,_that.badge,_that.evaluate);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'season_id')  int seasonId,  String title,  String cover, @JsonKey(name: 'total_count')  String totalCount, @JsonKey(name: 'new_ep_title')  String newEpTitle, @JsonKey(name: 'progress')  String progress,  String badge,  String evaluate)?  $default,) {final _that = this;
switch (_that) {
case _UserBangumiItem() when $default != null:
return $default(_that.seasonId,_that.title,_that.cover,_that.totalCount,_that.newEpTitle,_that.progress,_that.badge,_that.evaluate);case _:
  return null;

}
}

}

/// @nodoc


class _UserBangumiItem implements UserBangumiItem {
  const _UserBangumiItem({@JsonKey(name: 'season_id') this.seasonId = 0, this.title = '', this.cover = '', @JsonKey(name: 'total_count') this.totalCount = '', @JsonKey(name: 'new_ep_title') this.newEpTitle = '', @JsonKey(name: 'progress') this.progress = '', this.badge = '', this.evaluate = ''});
  

@override@JsonKey(name: 'season_id') final  int seasonId;
@override@JsonKey() final  String title;
@override@JsonKey() final  String cover;
@override@JsonKey(name: 'total_count') final  String totalCount;
@override@JsonKey(name: 'new_ep_title') final  String newEpTitle;
@override@JsonKey(name: 'progress') final  String progress;
@override@JsonKey() final  String badge;
@override@JsonKey() final  String evaluate;

/// Create a copy of UserBangumiItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserBangumiItemCopyWith<_UserBangumiItem> get copyWith => __$UserBangumiItemCopyWithImpl<_UserBangumiItem>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserBangumiItem&&(identical(other.seasonId, seasonId) || other.seasonId == seasonId)&&(identical(other.title, title) || other.title == title)&&(identical(other.cover, cover) || other.cover == cover)&&(identical(other.totalCount, totalCount) || other.totalCount == totalCount)&&(identical(other.newEpTitle, newEpTitle) || other.newEpTitle == newEpTitle)&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.badge, badge) || other.badge == badge)&&(identical(other.evaluate, evaluate) || other.evaluate == evaluate));
}


@override
int get hashCode {
    return Object.hash(runtimeType,seasonId,title,cover,totalCount,newEpTitle,progress,badge,evaluate);
}

@override
String toString() {
    return 'UserBangumiItem(seasonId: $seasonId, title: $title, cover: $cover, totalCount: $totalCount, newEpTitle: $newEpTitle, progress: $progress, badge: $badge, evaluate: $evaluate)';
}


}

/// @nodoc
abstract mixin class _$UserBangumiItemCopyWith<$Res> implements $UserBangumiItemCopyWith<$Res> {
  factory _$UserBangumiItemCopyWith(_UserBangumiItem value, $Res Function(_UserBangumiItem) _then) = __$UserBangumiItemCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'season_id') int seasonId, String title, String cover,@JsonKey(name: 'total_count') String totalCount,@JsonKey(name: 'new_ep_title') String newEpTitle,@JsonKey(name: 'progress') String progress, String badge, String evaluate
});




}
/// @nodoc
class __$UserBangumiItemCopyWithImpl<$Res>
    implements _$UserBangumiItemCopyWith<$Res> {
  __$UserBangumiItemCopyWithImpl(this._self, this._then);

  final _UserBangumiItem _self;
  final $Res Function(_UserBangumiItem) _then;

/// Create a copy of UserBangumiItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? seasonId = null,Object? title = null,Object? cover = null,Object? totalCount = null,Object? newEpTitle = null,Object? progress = null,Object? badge = null,Object? evaluate = null,}) {
  return _then(_UserBangumiItem(
seasonId: null == seasonId ? _self.seasonId : seasonId // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,cover: null == cover ? _self.cover : cover // ignore: cast_nullable_to_non_nullable
as String,totalCount: null == totalCount ? _self.totalCount : totalCount // ignore: cast_nullable_to_non_nullable
as String,newEpTitle: null == newEpTitle ? _self.newEpTitle : newEpTitle // ignore: cast_nullable_to_non_nullable
as String,progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as String,badge: null == badge ? _self.badge : badge // ignore: cast_nullable_to_non_nullable
as String,evaluate: null == evaluate ? _self.evaluate : evaluate // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on

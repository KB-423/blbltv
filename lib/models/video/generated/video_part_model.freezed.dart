// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../video_part_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$VideoPartItem {

 int get cid; int get page; String get from; String get part; int get duration;
/// Create a copy of VideoPartItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VideoPartItemCopyWith<VideoPartItem> get copyWith => _$VideoPartItemCopyWithImpl<VideoPartItem>(this as VideoPartItem, _$identity);

  /// Serializes this VideoPartItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as VideoPartItem;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VideoPartItem&&(identical(other.cid, _this.cid) || other.cid == _this.cid)&&(identical(other.page, _this.page) || other.page == _this.page)&&(identical(other.from, _this.from) || other.from == _this.from)&&(identical(other.part, _this.part) || other.part == _this.part)&&(identical(other.duration, _this.duration) || other.duration == _this.duration));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as VideoPartItem;
  return Object.hash(runtimeType,_this.cid,_this.page,_this.from,_this.part,_this.duration);
}

@override
String toString() {
  final _this = this as VideoPartItem;
  return 'VideoPartItem(cid: ${_this.cid}, page: ${_this.page}, from: ${_this.from}, part: ${_this.part}, duration: ${_this.duration})';
}


}

/// @nodoc
abstract mixin class $VideoPartItemCopyWith<$Res>  {
  factory $VideoPartItemCopyWith(VideoPartItem value, $Res Function(VideoPartItem) _then) = _$VideoPartItemCopyWithImpl;
@useResult
$Res call({
 int cid, int page, String from, String part, int duration
});




}
/// @nodoc
class _$VideoPartItemCopyWithImpl<$Res>
    implements $VideoPartItemCopyWith<$Res> {
  _$VideoPartItemCopyWithImpl(this._self, this._then);

  final VideoPartItem _self;
  final $Res Function(VideoPartItem) _then;

/// Create a copy of VideoPartItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? cid = null,Object? page = null,Object? from = null,Object? part = null,Object? duration = null,}) {
  return _then(VideoPartItem(
cid: null == cid ? _self.cid : cid // ignore: cast_nullable_to_non_nullable
as int,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,from: null == from ? _self.from : from // ignore: cast_nullable_to_non_nullable
as String,part: null == part ? _self.part : part // ignore: cast_nullable_to_non_nullable
as String,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [VideoPartItem].
extension VideoPartItemPatterns on VideoPartItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VideoPartItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VideoPartItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VideoPartItem value)  $default,){
final _that = this;
switch (_that) {
case _VideoPartItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VideoPartItem value)?  $default,){
final _that = this;
switch (_that) {
case _VideoPartItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int cid,  int page,  String from,  String part,  int duration)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VideoPartItem() when $default != null:
return $default(_that.cid,_that.page,_that.from,_that.part,_that.duration);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int cid,  int page,  String from,  String part,  int duration)  $default,) {final _that = this;
switch (_that) {
case _VideoPartItem():
return $default(_that.cid,_that.page,_that.from,_that.part,_that.duration);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int cid,  int page,  String from,  String part,  int duration)?  $default,) {final _that = this;
switch (_that) {
case _VideoPartItem() when $default != null:
return $default(_that.cid,_that.page,_that.from,_that.part,_that.duration);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VideoPartItem implements VideoPartItem {
  const _VideoPartItem({required this.cid, required this.page, this.from = '', required this.part, this.duration = 0});
  factory _VideoPartItem.fromJson(Map<String, dynamic> json) => _$VideoPartItemFromJson(json);

@override final  int cid;
@override final  int page;
@override@JsonKey() final  String from;
@override final  String part;
@override@JsonKey() final  int duration;

/// Create a copy of VideoPartItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VideoPartItemCopyWith<_VideoPartItem> get copyWith => __$VideoPartItemCopyWithImpl<_VideoPartItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VideoPartItemToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _VideoPartItem&&(identical(other.cid, cid) || other.cid == cid)&&(identical(other.page, page) || other.page == page)&&(identical(other.from, from) || other.from == from)&&(identical(other.part, part) || other.part == part)&&(identical(other.duration, duration) || other.duration == duration));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,cid,page,from,part,duration);
}

@override
String toString() {
    return 'VideoPartItem(cid: $cid, page: $page, from: $from, part: $part, duration: $duration)';
}


}

/// @nodoc
abstract mixin class _$VideoPartItemCopyWith<$Res> implements $VideoPartItemCopyWith<$Res> {
  factory _$VideoPartItemCopyWith(_VideoPartItem value, $Res Function(_VideoPartItem) _then) = __$VideoPartItemCopyWithImpl;
@override @useResult
$Res call({
 int cid, int page, String from, String part, int duration
});




}
/// @nodoc
class __$VideoPartItemCopyWithImpl<$Res>
    implements _$VideoPartItemCopyWith<$Res> {
  __$VideoPartItemCopyWithImpl(this._self, this._then);

  final _VideoPartItem _self;
  final $Res Function(_VideoPartItem) _then;

/// Create a copy of VideoPartItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? cid = null,Object? page = null,Object? from = null,Object? part = null,Object? duration = null,}) {
  return _then(_VideoPartItem(
cid: null == cid ? _self.cid : cid // ignore: cast_nullable_to_non_nullable
as int,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,from: null == from ? _self.from : from // ignore: cast_nullable_to_non_nullable
as String,part: null == part ? _self.part : part // ignore: cast_nullable_to_non_nullable
as String,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on

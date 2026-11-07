// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../video_collection_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$VideoCollectionModel {

 int get id; String get title; String get cover; String get intro; int get epCount; List<VideoItemModel> get items;
/// Create a copy of VideoCollectionModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VideoCollectionModelCopyWith<VideoCollectionModel> get copyWith => _$VideoCollectionModelCopyWithImpl<VideoCollectionModel>(this as VideoCollectionModel, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as VideoCollectionModel;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VideoCollectionModel&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.cover, _this.cover) || other.cover == _this.cover)&&(identical(other.intro, _this.intro) || other.intro == _this.intro)&&(identical(other.epCount, _this.epCount) || other.epCount == _this.epCount)&&const DeepCollectionEquality().equals(other.items, _this.items));
}


@override
int get hashCode {
  final _this = this as VideoCollectionModel;
  return Object.hash(runtimeType,_this.id,_this.title,_this.cover,_this.intro,_this.epCount,const DeepCollectionEquality().hash(_this.items));
}

@override
String toString() {
  final _this = this as VideoCollectionModel;
  return 'VideoCollectionModel(id: ${_this.id}, title: ${_this.title}, cover: ${_this.cover}, intro: ${_this.intro}, epCount: ${_this.epCount}, items: ${_this.items})';
}


}

/// @nodoc
abstract mixin class $VideoCollectionModelCopyWith<$Res>  {
  factory $VideoCollectionModelCopyWith(VideoCollectionModel value, $Res Function(VideoCollectionModel) _then) = _$VideoCollectionModelCopyWithImpl;
@useResult
$Res call({
 int id, String title, String cover, String intro, int epCount, List<VideoItemModel> items
});




}
/// @nodoc
class _$VideoCollectionModelCopyWithImpl<$Res>
    implements $VideoCollectionModelCopyWith<$Res> {
  _$VideoCollectionModelCopyWithImpl(this._self, this._then);

  final VideoCollectionModel _self;
  final $Res Function(VideoCollectionModel) _then;

/// Create a copy of VideoCollectionModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? cover = null,Object? intro = null,Object? epCount = null,Object? items = null,}) {
  return _then(VideoCollectionModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,cover: null == cover ? _self.cover : cover // ignore: cast_nullable_to_non_nullable
as String,intro: null == intro ? _self.intro : intro // ignore: cast_nullable_to_non_nullable
as String,epCount: null == epCount ? _self.epCount : epCount // ignore: cast_nullable_to_non_nullable
as int,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<VideoItemModel>,
  ));
}

}


/// Adds pattern-matching-related methods to [VideoCollectionModel].
extension VideoCollectionModelPatterns on VideoCollectionModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VideoCollectionModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VideoCollectionModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VideoCollectionModel value)  $default,){
final _that = this;
switch (_that) {
case _VideoCollectionModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VideoCollectionModel value)?  $default,){
final _that = this;
switch (_that) {
case _VideoCollectionModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String title,  String cover,  String intro,  int epCount,  List<VideoItemModel> items)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VideoCollectionModel() when $default != null:
return $default(_that.id,_that.title,_that.cover,_that.intro,_that.epCount,_that.items);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String title,  String cover,  String intro,  int epCount,  List<VideoItemModel> items)  $default,) {final _that = this;
switch (_that) {
case _VideoCollectionModel():
return $default(_that.id,_that.title,_that.cover,_that.intro,_that.epCount,_that.items);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String title,  String cover,  String intro,  int epCount,  List<VideoItemModel> items)?  $default,) {final _that = this;
switch (_that) {
case _VideoCollectionModel() when $default != null:
return $default(_that.id,_that.title,_that.cover,_that.intro,_that.epCount,_that.items);case _:
  return null;

}
}

}

/// @nodoc


class _VideoCollectionModel implements VideoCollectionModel {
  const _VideoCollectionModel({this.id = 0, this.title = '', this.cover = '', this.intro = '', this.epCount = 0,  List<VideoItemModel> items = const []}): _items = items;
  

@override@JsonKey() final  int id;
@override@JsonKey() final  String title;
@override@JsonKey() final  String cover;
@override@JsonKey() final  String intro;
@override@JsonKey() final  int epCount;
 final  List<VideoItemModel> _items;
@override@JsonKey() List<VideoItemModel> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}


/// Create a copy of VideoCollectionModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VideoCollectionModelCopyWith<_VideoCollectionModel> get copyWith => __$VideoCollectionModelCopyWithImpl<_VideoCollectionModel>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _VideoCollectionModel&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.cover, cover) || other.cover == cover)&&(identical(other.intro, intro) || other.intro == intro)&&(identical(other.epCount, epCount) || other.epCount == epCount)&&const DeepCollectionEquality().equals(other.items, _items));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,title,cover,intro,epCount,const DeepCollectionEquality().hash(_items));
}

@override
String toString() {
    return 'VideoCollectionModel(id: $id, title: $title, cover: $cover, intro: $intro, epCount: $epCount, items: $items)';
}


}

/// @nodoc
abstract mixin class _$VideoCollectionModelCopyWith<$Res> implements $VideoCollectionModelCopyWith<$Res> {
  factory _$VideoCollectionModelCopyWith(_VideoCollectionModel value, $Res Function(_VideoCollectionModel) _then) = __$VideoCollectionModelCopyWithImpl;
@override @useResult
$Res call({
 int id, String title, String cover, String intro, int epCount, List<VideoItemModel> items
});




}
/// @nodoc
class __$VideoCollectionModelCopyWithImpl<$Res>
    implements _$VideoCollectionModelCopyWith<$Res> {
  __$VideoCollectionModelCopyWithImpl(this._self, this._then);

  final _VideoCollectionModel _self;
  final $Res Function(_VideoCollectionModel) _then;

/// Create a copy of VideoCollectionModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? cover = null,Object? intro = null,Object? epCount = null,Object? items = null,}) {
  return _then(_VideoCollectionModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,cover: null == cover ? _self.cover : cover // ignore: cast_nullable_to_non_nullable
as String,intro: null == intro ? _self.intro : intro // ignore: cast_nullable_to_non_nullable
as String,epCount: null == epCount ? _self.epCount : epCount // ignore: cast_nullable_to_non_nullable
as int,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<VideoItemModel>,
  ));
}


}

// dart format on

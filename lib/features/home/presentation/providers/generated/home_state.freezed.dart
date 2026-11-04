// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../home_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$HomeFeedState {

 List<VideoItemModel> get videos; bool get isLoading; bool get isRefreshing; bool get isLoadingMore; bool get hasMore; String? get error; int get freshIdx;
/// Create a copy of HomeFeedState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HomeFeedStateCopyWith<HomeFeedState> get copyWith => _$HomeFeedStateCopyWithImpl<HomeFeedState>(this as HomeFeedState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as HomeFeedState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HomeFeedState&&const DeepCollectionEquality().equals(other.videos, _this.videos)&&(identical(other.isLoading, _this.isLoading) || other.isLoading == _this.isLoading)&&(identical(other.isRefreshing, _this.isRefreshing) || other.isRefreshing == _this.isRefreshing)&&(identical(other.isLoadingMore, _this.isLoadingMore) || other.isLoadingMore == _this.isLoadingMore)&&(identical(other.hasMore, _this.hasMore) || other.hasMore == _this.hasMore)&&(identical(other.error, _this.error) || other.error == _this.error)&&(identical(other.freshIdx, _this.freshIdx) || other.freshIdx == _this.freshIdx));
}


@override
int get hashCode {
  final _this = this as HomeFeedState;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.videos),_this.isLoading,_this.isRefreshing,_this.isLoadingMore,_this.hasMore,_this.error,_this.freshIdx);
}

@override
String toString() {
  final _this = this as HomeFeedState;
  return 'HomeFeedState(videos: ${_this.videos}, isLoading: ${_this.isLoading}, isRefreshing: ${_this.isRefreshing}, isLoadingMore: ${_this.isLoadingMore}, hasMore: ${_this.hasMore}, error: ${_this.error}, freshIdx: ${_this.freshIdx})';
}


}

/// @nodoc
abstract mixin class $HomeFeedStateCopyWith<$Res>  {
  factory $HomeFeedStateCopyWith(HomeFeedState value, $Res Function(HomeFeedState) _then) = _$HomeFeedStateCopyWithImpl;
@useResult
$Res call({
 List<VideoItemModel> videos, bool isLoading, bool isRefreshing, bool isLoadingMore, bool hasMore, String? error, int freshIdx
});




}
/// @nodoc
class _$HomeFeedStateCopyWithImpl<$Res>
    implements $HomeFeedStateCopyWith<$Res> {
  _$HomeFeedStateCopyWithImpl(this._self, this._then);

  final HomeFeedState _self;
  final $Res Function(HomeFeedState) _then;

/// Create a copy of HomeFeedState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? videos = null,Object? isLoading = null,Object? isRefreshing = null,Object? isLoadingMore = null,Object? hasMore = null,Object? error = freezed,Object? freshIdx = null,}) {
  return _then(HomeFeedState(
videos: null == videos ? _self.videos : videos // ignore: cast_nullable_to_non_nullable
as List<VideoItemModel>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isRefreshing: null == isRefreshing ? _self.isRefreshing : isRefreshing // ignore: cast_nullable_to_non_nullable
as bool,isLoadingMore: null == isLoadingMore ? _self.isLoadingMore : isLoadingMore // ignore: cast_nullable_to_non_nullable
as bool,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,freshIdx: null == freshIdx ? _self.freshIdx : freshIdx // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [HomeFeedState].
extension HomeFeedStatePatterns on HomeFeedState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HomeFeedState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HomeFeedState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HomeFeedState value)  $default,){
final _that = this;
switch (_that) {
case _HomeFeedState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HomeFeedState value)?  $default,){
final _that = this;
switch (_that) {
case _HomeFeedState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<VideoItemModel> videos,  bool isLoading,  bool isRefreshing,  bool isLoadingMore,  bool hasMore,  String? error,  int freshIdx)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HomeFeedState() when $default != null:
return $default(_that.videos,_that.isLoading,_that.isRefreshing,_that.isLoadingMore,_that.hasMore,_that.error,_that.freshIdx);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<VideoItemModel> videos,  bool isLoading,  bool isRefreshing,  bool isLoadingMore,  bool hasMore,  String? error,  int freshIdx)  $default,) {final _that = this;
switch (_that) {
case _HomeFeedState():
return $default(_that.videos,_that.isLoading,_that.isRefreshing,_that.isLoadingMore,_that.hasMore,_that.error,_that.freshIdx);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<VideoItemModel> videos,  bool isLoading,  bool isRefreshing,  bool isLoadingMore,  bool hasMore,  String? error,  int freshIdx)?  $default,) {final _that = this;
switch (_that) {
case _HomeFeedState() when $default != null:
return $default(_that.videos,_that.isLoading,_that.isRefreshing,_that.isLoadingMore,_that.hasMore,_that.error,_that.freshIdx);case _:
  return null;

}
}

}

/// @nodoc


class _HomeFeedState implements HomeFeedState {
  const _HomeFeedState({ List<VideoItemModel> videos = const <VideoItemModel>[], this.isLoading = true, this.isRefreshing = false, this.isLoadingMore = false, this.hasMore = true, this.error, this.freshIdx = 1}): _videos = videos;
  

 final  List<VideoItemModel> _videos;
@override@JsonKey() List<VideoItemModel> get videos {
  if (_videos is EqualUnmodifiableListView) return _videos;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_videos);
}

@override@JsonKey() final  bool isLoading;
@override@JsonKey() final  bool isRefreshing;
@override@JsonKey() final  bool isLoadingMore;
@override@JsonKey() final  bool hasMore;
@override final  String? error;
@override@JsonKey() final  int freshIdx;

/// Create a copy of HomeFeedState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HomeFeedStateCopyWith<_HomeFeedState> get copyWith => __$HomeFeedStateCopyWithImpl<_HomeFeedState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _HomeFeedState&&const DeepCollectionEquality().equals(other.videos, _videos)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.isRefreshing, isRefreshing) || other.isRefreshing == isRefreshing)&&(identical(other.isLoadingMore, isLoadingMore) || other.isLoadingMore == isLoadingMore)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore)&&(identical(other.error, error) || other.error == error)&&(identical(other.freshIdx, freshIdx) || other.freshIdx == freshIdx));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_videos),isLoading,isRefreshing,isLoadingMore,hasMore,error,freshIdx);
}

@override
String toString() {
    return 'HomeFeedState(videos: $videos, isLoading: $isLoading, isRefreshing: $isRefreshing, isLoadingMore: $isLoadingMore, hasMore: $hasMore, error: $error, freshIdx: $freshIdx)';
}


}

/// @nodoc
abstract mixin class _$HomeFeedStateCopyWith<$Res> implements $HomeFeedStateCopyWith<$Res> {
  factory _$HomeFeedStateCopyWith(_HomeFeedState value, $Res Function(_HomeFeedState) _then) = __$HomeFeedStateCopyWithImpl;
@override @useResult
$Res call({
 List<VideoItemModel> videos, bool isLoading, bool isRefreshing, bool isLoadingMore, bool hasMore, String? error, int freshIdx
});




}
/// @nodoc
class __$HomeFeedStateCopyWithImpl<$Res>
    implements _$HomeFeedStateCopyWith<$Res> {
  __$HomeFeedStateCopyWithImpl(this._self, this._then);

  final _HomeFeedState _self;
  final $Res Function(_HomeFeedState) _then;

/// Create a copy of HomeFeedState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? videos = null,Object? isLoading = null,Object? isRefreshing = null,Object? isLoadingMore = null,Object? hasMore = null,Object? error = freezed,Object? freshIdx = null,}) {
  return _then(_HomeFeedState(
videos: null == videos ? _self._videos : videos // ignore: cast_nullable_to_non_nullable
as List<VideoItemModel>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isRefreshing: null == isRefreshing ? _self.isRefreshing : isRefreshing // ignore: cast_nullable_to_non_nullable
as bool,isLoadingMore: null == isLoadingMore ? _self.isLoadingMore : isLoadingMore // ignore: cast_nullable_to_non_nullable
as bool,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,freshIdx: null == freshIdx ? _self.freshIdx : freshIdx // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on

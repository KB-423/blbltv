// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../bangumi_season_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BangumiSeasonModel {

@JsonKey(name: 'season_id') int get seasonId; String get title; String get cover; String get badge; String get score; String get order;@JsonKey(name: 'index_show') String get indexShow; String get desc;
/// Create a copy of BangumiSeasonModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BangumiSeasonModelCopyWith<BangumiSeasonModel> get copyWith => _$BangumiSeasonModelCopyWithImpl<BangumiSeasonModel>(this as BangumiSeasonModel, _$identity);

  /// Serializes this BangumiSeasonModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as BangumiSeasonModel;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BangumiSeasonModel&&(identical(other.seasonId, _this.seasonId) || other.seasonId == _this.seasonId)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.cover, _this.cover) || other.cover == _this.cover)&&(identical(other.badge, _this.badge) || other.badge == _this.badge)&&(identical(other.score, _this.score) || other.score == _this.score)&&(identical(other.order, _this.order) || other.order == _this.order)&&(identical(other.indexShow, _this.indexShow) || other.indexShow == _this.indexShow)&&(identical(other.desc, _this.desc) || other.desc == _this.desc));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as BangumiSeasonModel;
  return Object.hash(runtimeType,_this.seasonId,_this.title,_this.cover,_this.badge,_this.score,_this.order,_this.indexShow,_this.desc);
}

@override
String toString() {
  final _this = this as BangumiSeasonModel;
  return 'BangumiSeasonModel(seasonId: ${_this.seasonId}, title: ${_this.title}, cover: ${_this.cover}, badge: ${_this.badge}, score: ${_this.score}, order: ${_this.order}, indexShow: ${_this.indexShow}, desc: ${_this.desc})';
}


}

/// @nodoc
abstract mixin class $BangumiSeasonModelCopyWith<$Res>  {
  factory $BangumiSeasonModelCopyWith(BangumiSeasonModel value, $Res Function(BangumiSeasonModel) _then) = _$BangumiSeasonModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'season_id') int seasonId, String title, String cover, String badge, String score, String order,@JsonKey(name: 'index_show') String indexShow, String desc
});




}
/// @nodoc
class _$BangumiSeasonModelCopyWithImpl<$Res>
    implements $BangumiSeasonModelCopyWith<$Res> {
  _$BangumiSeasonModelCopyWithImpl(this._self, this._then);

  final BangumiSeasonModel _self;
  final $Res Function(BangumiSeasonModel) _then;

/// Create a copy of BangumiSeasonModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? seasonId = null,Object? title = null,Object? cover = null,Object? badge = null,Object? score = null,Object? order = null,Object? indexShow = null,Object? desc = null,}) {
  return _then(BangumiSeasonModel(
seasonId: null == seasonId ? _self.seasonId : seasonId // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,cover: null == cover ? _self.cover : cover // ignore: cast_nullable_to_non_nullable
as String,badge: null == badge ? _self.badge : badge // ignore: cast_nullable_to_non_nullable
as String,score: null == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as String,order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as String,indexShow: null == indexShow ? _self.indexShow : indexShow // ignore: cast_nullable_to_non_nullable
as String,desc: null == desc ? _self.desc : desc // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [BangumiSeasonModel].
extension BangumiSeasonModelPatterns on BangumiSeasonModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BangumiSeasonModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BangumiSeasonModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BangumiSeasonModel value)  $default,){
final _that = this;
switch (_that) {
case _BangumiSeasonModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BangumiSeasonModel value)?  $default,){
final _that = this;
switch (_that) {
case _BangumiSeasonModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'season_id')  int seasonId,  String title,  String cover,  String badge,  String score,  String order, @JsonKey(name: 'index_show')  String indexShow,  String desc)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BangumiSeasonModel() when $default != null:
return $default(_that.seasonId,_that.title,_that.cover,_that.badge,_that.score,_that.order,_that.indexShow,_that.desc);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'season_id')  int seasonId,  String title,  String cover,  String badge,  String score,  String order, @JsonKey(name: 'index_show')  String indexShow,  String desc)  $default,) {final _that = this;
switch (_that) {
case _BangumiSeasonModel():
return $default(_that.seasonId,_that.title,_that.cover,_that.badge,_that.score,_that.order,_that.indexShow,_that.desc);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'season_id')  int seasonId,  String title,  String cover,  String badge,  String score,  String order, @JsonKey(name: 'index_show')  String indexShow,  String desc)?  $default,) {final _that = this;
switch (_that) {
case _BangumiSeasonModel() when $default != null:
return $default(_that.seasonId,_that.title,_that.cover,_that.badge,_that.score,_that.order,_that.indexShow,_that.desc);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BangumiSeasonModel implements BangumiSeasonModel {
  const _BangumiSeasonModel({@JsonKey(name: 'season_id') this.seasonId = 0, this.title = '', this.cover = '', this.badge = '', this.score = '', this.order = '', @JsonKey(name: 'index_show') this.indexShow = '', this.desc = ''});
  factory _BangumiSeasonModel.fromJson(Map<String, dynamic> json) => _$BangumiSeasonModelFromJson(json);

@override@JsonKey(name: 'season_id') final  int seasonId;
@override@JsonKey() final  String title;
@override@JsonKey() final  String cover;
@override@JsonKey() final  String badge;
@override@JsonKey() final  String score;
@override@JsonKey() final  String order;
@override@JsonKey(name: 'index_show') final  String indexShow;
@override@JsonKey() final  String desc;

/// Create a copy of BangumiSeasonModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BangumiSeasonModelCopyWith<_BangumiSeasonModel> get copyWith => __$BangumiSeasonModelCopyWithImpl<_BangumiSeasonModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BangumiSeasonModelToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _BangumiSeasonModel&&(identical(other.seasonId, seasonId) || other.seasonId == seasonId)&&(identical(other.title, title) || other.title == title)&&(identical(other.cover, cover) || other.cover == cover)&&(identical(other.badge, badge) || other.badge == badge)&&(identical(other.score, score) || other.score == score)&&(identical(other.order, order) || other.order == order)&&(identical(other.indexShow, indexShow) || other.indexShow == indexShow)&&(identical(other.desc, desc) || other.desc == desc));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,seasonId,title,cover,badge,score,order,indexShow,desc);
}

@override
String toString() {
    return 'BangumiSeasonModel(seasonId: $seasonId, title: $title, cover: $cover, badge: $badge, score: $score, order: $order, indexShow: $indexShow, desc: $desc)';
}


}

/// @nodoc
abstract mixin class _$BangumiSeasonModelCopyWith<$Res> implements $BangumiSeasonModelCopyWith<$Res> {
  factory _$BangumiSeasonModelCopyWith(_BangumiSeasonModel value, $Res Function(_BangumiSeasonModel) _then) = __$BangumiSeasonModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'season_id') int seasonId, String title, String cover, String badge, String score, String order,@JsonKey(name: 'index_show') String indexShow, String desc
});




}
/// @nodoc
class __$BangumiSeasonModelCopyWithImpl<$Res>
    implements _$BangumiSeasonModelCopyWith<$Res> {
  __$BangumiSeasonModelCopyWithImpl(this._self, this._then);

  final _BangumiSeasonModel _self;
  final $Res Function(_BangumiSeasonModel) _then;

/// Create a copy of BangumiSeasonModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? seasonId = null,Object? title = null,Object? cover = null,Object? badge = null,Object? score = null,Object? order = null,Object? indexShow = null,Object? desc = null,}) {
  return _then(_BangumiSeasonModel(
seasonId: null == seasonId ? _self.seasonId : seasonId // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,cover: null == cover ? _self.cover : cover // ignore: cast_nullable_to_non_nullable
as String,badge: null == badge ? _self.badge : badge // ignore: cast_nullable_to_non_nullable
as String,score: null == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as String,order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as String,indexShow: null == indexShow ? _self.indexShow : indexShow // ignore: cast_nullable_to_non_nullable
as String,desc: null == desc ? _self.desc : desc // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on

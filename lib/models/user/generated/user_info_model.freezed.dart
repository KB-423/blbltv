// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../user_info_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$UserInfoModel {

 int get mid; String get uname; String get face;@JsonKey(name: 'isLogin') bool get isLogin;@JsonKey(name: 'current_level') int get currentLevel; double get money;@JsonKey(name: 'vipType') int get vipType;@JsonKey(name: 'vipStatus') int get vipStatus;@JsonKey(name: 'vip_label_text') String get vipLabelText;
/// Create a copy of UserInfoModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserInfoModelCopyWith<UserInfoModel> get copyWith => _$UserInfoModelCopyWithImpl<UserInfoModel>(this as UserInfoModel, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as UserInfoModel;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserInfoModel&&(identical(other.mid, _this.mid) || other.mid == _this.mid)&&(identical(other.uname, _this.uname) || other.uname == _this.uname)&&(identical(other.face, _this.face) || other.face == _this.face)&&(identical(other.isLogin, _this.isLogin) || other.isLogin == _this.isLogin)&&(identical(other.currentLevel, _this.currentLevel) || other.currentLevel == _this.currentLevel)&&(identical(other.money, _this.money) || other.money == _this.money)&&(identical(other.vipType, _this.vipType) || other.vipType == _this.vipType)&&(identical(other.vipStatus, _this.vipStatus) || other.vipStatus == _this.vipStatus)&&(identical(other.vipLabelText, _this.vipLabelText) || other.vipLabelText == _this.vipLabelText));
}


@override
int get hashCode {
  final _this = this as UserInfoModel;
  return Object.hash(runtimeType,_this.mid,_this.uname,_this.face,_this.isLogin,_this.currentLevel,_this.money,_this.vipType,_this.vipStatus,_this.vipLabelText);
}

@override
String toString() {
  final _this = this as UserInfoModel;
  return 'UserInfoModel(mid: ${_this.mid}, uname: ${_this.uname}, face: ${_this.face}, isLogin: ${_this.isLogin}, currentLevel: ${_this.currentLevel}, money: ${_this.money}, vipType: ${_this.vipType}, vipStatus: ${_this.vipStatus}, vipLabelText: ${_this.vipLabelText})';
}


}

/// @nodoc
abstract mixin class $UserInfoModelCopyWith<$Res>  {
  factory $UserInfoModelCopyWith(UserInfoModel value, $Res Function(UserInfoModel) _then) = _$UserInfoModelCopyWithImpl;
@useResult
$Res call({
 int mid, String uname, String face,@JsonKey(name: 'isLogin') bool isLogin,@JsonKey(name: 'current_level') int currentLevel, double money,@JsonKey(name: 'vipType') int vipType,@JsonKey(name: 'vipStatus') int vipStatus,@JsonKey(name: 'vip_label_text') String vipLabelText
});




}
/// @nodoc
class _$UserInfoModelCopyWithImpl<$Res>
    implements $UserInfoModelCopyWith<$Res> {
  _$UserInfoModelCopyWithImpl(this._self, this._then);

  final UserInfoModel _self;
  final $Res Function(UserInfoModel) _then;

/// Create a copy of UserInfoModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? mid = null,Object? uname = null,Object? face = null,Object? isLogin = null,Object? currentLevel = null,Object? money = null,Object? vipType = null,Object? vipStatus = null,Object? vipLabelText = null,}) {
  return _then(UserInfoModel(
mid: null == mid ? _self.mid : mid // ignore: cast_nullable_to_non_nullable
as int,uname: null == uname ? _self.uname : uname // ignore: cast_nullable_to_non_nullable
as String,face: null == face ? _self.face : face // ignore: cast_nullable_to_non_nullable
as String,isLogin: null == isLogin ? _self.isLogin : isLogin // ignore: cast_nullable_to_non_nullable
as bool,currentLevel: null == currentLevel ? _self.currentLevel : currentLevel // ignore: cast_nullable_to_non_nullable
as int,money: null == money ? _self.money : money // ignore: cast_nullable_to_non_nullable
as double,vipType: null == vipType ? _self.vipType : vipType // ignore: cast_nullable_to_non_nullable
as int,vipStatus: null == vipStatus ? _self.vipStatus : vipStatus // ignore: cast_nullable_to_non_nullable
as int,vipLabelText: null == vipLabelText ? _self.vipLabelText : vipLabelText // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [UserInfoModel].
extension UserInfoModelPatterns on UserInfoModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserInfoModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserInfoModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserInfoModel value)  $default,){
final _that = this;
switch (_that) {
case _UserInfoModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserInfoModel value)?  $default,){
final _that = this;
switch (_that) {
case _UserInfoModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int mid,  String uname,  String face, @JsonKey(name: 'isLogin')  bool isLogin, @JsonKey(name: 'current_level')  int currentLevel,  double money, @JsonKey(name: 'vipType')  int vipType, @JsonKey(name: 'vipStatus')  int vipStatus, @JsonKey(name: 'vip_label_text')  String vipLabelText)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserInfoModel() when $default != null:
return $default(_that.mid,_that.uname,_that.face,_that.isLogin,_that.currentLevel,_that.money,_that.vipType,_that.vipStatus,_that.vipLabelText);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int mid,  String uname,  String face, @JsonKey(name: 'isLogin')  bool isLogin, @JsonKey(name: 'current_level')  int currentLevel,  double money, @JsonKey(name: 'vipType')  int vipType, @JsonKey(name: 'vipStatus')  int vipStatus, @JsonKey(name: 'vip_label_text')  String vipLabelText)  $default,) {final _that = this;
switch (_that) {
case _UserInfoModel():
return $default(_that.mid,_that.uname,_that.face,_that.isLogin,_that.currentLevel,_that.money,_that.vipType,_that.vipStatus,_that.vipLabelText);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int mid,  String uname,  String face, @JsonKey(name: 'isLogin')  bool isLogin, @JsonKey(name: 'current_level')  int currentLevel,  double money, @JsonKey(name: 'vipType')  int vipType, @JsonKey(name: 'vipStatus')  int vipStatus, @JsonKey(name: 'vip_label_text')  String vipLabelText)?  $default,) {final _that = this;
switch (_that) {
case _UserInfoModel() when $default != null:
return $default(_that.mid,_that.uname,_that.face,_that.isLogin,_that.currentLevel,_that.money,_that.vipType,_that.vipStatus,_that.vipLabelText);case _:
  return null;

}
}

}

/// @nodoc


class _UserInfoModel implements UserInfoModel {
  const _UserInfoModel({this.mid = 0, this.uname = '', this.face = '', @JsonKey(name: 'isLogin') this.isLogin = false, @JsonKey(name: 'current_level') this.currentLevel = 0, this.money = 0.0, @JsonKey(name: 'vipType') this.vipType = 0, @JsonKey(name: 'vipStatus') this.vipStatus = 0, @JsonKey(name: 'vip_label_text') this.vipLabelText = ''});
  

@override@JsonKey() final  int mid;
@override@JsonKey() final  String uname;
@override@JsonKey() final  String face;
@override@JsonKey(name: 'isLogin') final  bool isLogin;
@override@JsonKey(name: 'current_level') final  int currentLevel;
@override@JsonKey() final  double money;
@override@JsonKey(name: 'vipType') final  int vipType;
@override@JsonKey(name: 'vipStatus') final  int vipStatus;
@override@JsonKey(name: 'vip_label_text') final  String vipLabelText;

/// Create a copy of UserInfoModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserInfoModelCopyWith<_UserInfoModel> get copyWith => __$UserInfoModelCopyWithImpl<_UserInfoModel>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserInfoModel&&(identical(other.mid, mid) || other.mid == mid)&&(identical(other.uname, uname) || other.uname == uname)&&(identical(other.face, face) || other.face == face)&&(identical(other.isLogin, isLogin) || other.isLogin == isLogin)&&(identical(other.currentLevel, currentLevel) || other.currentLevel == currentLevel)&&(identical(other.money, money) || other.money == money)&&(identical(other.vipType, vipType) || other.vipType == vipType)&&(identical(other.vipStatus, vipStatus) || other.vipStatus == vipStatus)&&(identical(other.vipLabelText, vipLabelText) || other.vipLabelText == vipLabelText));
}


@override
int get hashCode {
    return Object.hash(runtimeType,mid,uname,face,isLogin,currentLevel,money,vipType,vipStatus,vipLabelText);
}

@override
String toString() {
    return 'UserInfoModel(mid: $mid, uname: $uname, face: $face, isLogin: $isLogin, currentLevel: $currentLevel, money: $money, vipType: $vipType, vipStatus: $vipStatus, vipLabelText: $vipLabelText)';
}


}

/// @nodoc
abstract mixin class _$UserInfoModelCopyWith<$Res> implements $UserInfoModelCopyWith<$Res> {
  factory _$UserInfoModelCopyWith(_UserInfoModel value, $Res Function(_UserInfoModel) _then) = __$UserInfoModelCopyWithImpl;
@override @useResult
$Res call({
 int mid, String uname, String face,@JsonKey(name: 'isLogin') bool isLogin,@JsonKey(name: 'current_level') int currentLevel, double money,@JsonKey(name: 'vipType') int vipType,@JsonKey(name: 'vipStatus') int vipStatus,@JsonKey(name: 'vip_label_text') String vipLabelText
});




}
/// @nodoc
class __$UserInfoModelCopyWithImpl<$Res>
    implements _$UserInfoModelCopyWith<$Res> {
  __$UserInfoModelCopyWithImpl(this._self, this._then);

  final _UserInfoModel _self;
  final $Res Function(_UserInfoModel) _then;

/// Create a copy of UserInfoModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? mid = null,Object? uname = null,Object? face = null,Object? isLogin = null,Object? currentLevel = null,Object? money = null,Object? vipType = null,Object? vipStatus = null,Object? vipLabelText = null,}) {
  return _then(_UserInfoModel(
mid: null == mid ? _self.mid : mid // ignore: cast_nullable_to_non_nullable
as int,uname: null == uname ? _self.uname : uname // ignore: cast_nullable_to_non_nullable
as String,face: null == face ? _self.face : face // ignore: cast_nullable_to_non_nullable
as String,isLogin: null == isLogin ? _self.isLogin : isLogin // ignore: cast_nullable_to_non_nullable
as bool,currentLevel: null == currentLevel ? _self.currentLevel : currentLevel // ignore: cast_nullable_to_non_nullable
as int,money: null == money ? _self.money : money // ignore: cast_nullable_to_non_nullable
as double,vipType: null == vipType ? _self.vipType : vipType // ignore: cast_nullable_to_non_nullable
as int,vipStatus: null == vipStatus ? _self.vipStatus : vipStatus // ignore: cast_nullable_to_non_nullable
as int,vipLabelText: null == vipLabelText ? _self.vipLabelText : vipLabelText // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on

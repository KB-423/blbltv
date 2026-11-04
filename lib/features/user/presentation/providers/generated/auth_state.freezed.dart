// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../auth_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AuthState {

 bool get isCheckingLogin; bool get isLoggedIn; UserInfoModel? get user; String get qrUrl; String get qrKey; String get qrMessage; bool get isPolling; bool get isQrExpired; String? get error;
/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthStateCopyWith<AuthState> get copyWith => _$AuthStateCopyWithImpl<AuthState>(this as AuthState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as AuthState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthState&&(identical(other.isCheckingLogin, _this.isCheckingLogin) || other.isCheckingLogin == _this.isCheckingLogin)&&(identical(other.isLoggedIn, _this.isLoggedIn) || other.isLoggedIn == _this.isLoggedIn)&&(identical(other.user, _this.user) || other.user == _this.user)&&(identical(other.qrUrl, _this.qrUrl) || other.qrUrl == _this.qrUrl)&&(identical(other.qrKey, _this.qrKey) || other.qrKey == _this.qrKey)&&(identical(other.qrMessage, _this.qrMessage) || other.qrMessage == _this.qrMessage)&&(identical(other.isPolling, _this.isPolling) || other.isPolling == _this.isPolling)&&(identical(other.isQrExpired, _this.isQrExpired) || other.isQrExpired == _this.isQrExpired)&&(identical(other.error, _this.error) || other.error == _this.error));
}


@override
int get hashCode {
  final _this = this as AuthState;
  return Object.hash(runtimeType,_this.isCheckingLogin,_this.isLoggedIn,_this.user,_this.qrUrl,_this.qrKey,_this.qrMessage,_this.isPolling,_this.isQrExpired,_this.error);
}

@override
String toString() {
  final _this = this as AuthState;
  return 'AuthState(isCheckingLogin: ${_this.isCheckingLogin}, isLoggedIn: ${_this.isLoggedIn}, user: ${_this.user}, qrUrl: ${_this.qrUrl}, qrKey: ${_this.qrKey}, qrMessage: ${_this.qrMessage}, isPolling: ${_this.isPolling}, isQrExpired: ${_this.isQrExpired}, error: ${_this.error})';
}


}

/// @nodoc
abstract mixin class $AuthStateCopyWith<$Res>  {
  factory $AuthStateCopyWith(AuthState value, $Res Function(AuthState) _then) = _$AuthStateCopyWithImpl;
@useResult
$Res call({
 bool isCheckingLogin, bool isLoggedIn, UserInfoModel? user, String qrUrl, String qrKey, String qrMessage, bool isPolling, bool isQrExpired, String? error
});


$UserInfoModelCopyWith<$Res>? get user;

}
/// @nodoc
class _$AuthStateCopyWithImpl<$Res>
    implements $AuthStateCopyWith<$Res> {
  _$AuthStateCopyWithImpl(this._self, this._then);

  final AuthState _self;
  final $Res Function(AuthState) _then;

/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isCheckingLogin = null,Object? isLoggedIn = null,Object? user = freezed,Object? qrUrl = null,Object? qrKey = null,Object? qrMessage = null,Object? isPolling = null,Object? isQrExpired = null,Object? error = freezed,}) {
  return _then(AuthState(
isCheckingLogin: null == isCheckingLogin ? _self.isCheckingLogin : isCheckingLogin // ignore: cast_nullable_to_non_nullable
as bool,isLoggedIn: null == isLoggedIn ? _self.isLoggedIn : isLoggedIn // ignore: cast_nullable_to_non_nullable
as bool,user: freezed == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as UserInfoModel?,qrUrl: null == qrUrl ? _self.qrUrl : qrUrl // ignore: cast_nullable_to_non_nullable
as String,qrKey: null == qrKey ? _self.qrKey : qrKey // ignore: cast_nullable_to_non_nullable
as String,qrMessage: null == qrMessage ? _self.qrMessage : qrMessage // ignore: cast_nullable_to_non_nullable
as String,isPolling: null == isPolling ? _self.isPolling : isPolling // ignore: cast_nullable_to_non_nullable
as bool,isQrExpired: null == isQrExpired ? _self.isQrExpired : isQrExpired // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserInfoModelCopyWith<$Res>? get user {
    if (_self.user == null) {
    return null;
  }

  return $UserInfoModelCopyWith<$Res>(_self.user!, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}


/// Adds pattern-matching-related methods to [AuthState].
extension AuthStatePatterns on AuthState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AuthState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AuthState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AuthState value)  $default,){
final _that = this;
switch (_that) {
case _AuthState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AuthState value)?  $default,){
final _that = this;
switch (_that) {
case _AuthState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isCheckingLogin,  bool isLoggedIn,  UserInfoModel? user,  String qrUrl,  String qrKey,  String qrMessage,  bool isPolling,  bool isQrExpired,  String? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AuthState() when $default != null:
return $default(_that.isCheckingLogin,_that.isLoggedIn,_that.user,_that.qrUrl,_that.qrKey,_that.qrMessage,_that.isPolling,_that.isQrExpired,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isCheckingLogin,  bool isLoggedIn,  UserInfoModel? user,  String qrUrl,  String qrKey,  String qrMessage,  bool isPolling,  bool isQrExpired,  String? error)  $default,) {final _that = this;
switch (_that) {
case _AuthState():
return $default(_that.isCheckingLogin,_that.isLoggedIn,_that.user,_that.qrUrl,_that.qrKey,_that.qrMessage,_that.isPolling,_that.isQrExpired,_that.error);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isCheckingLogin,  bool isLoggedIn,  UserInfoModel? user,  String qrUrl,  String qrKey,  String qrMessage,  bool isPolling,  bool isQrExpired,  String? error)?  $default,) {final _that = this;
switch (_that) {
case _AuthState() when $default != null:
return $default(_that.isCheckingLogin,_that.isLoggedIn,_that.user,_that.qrUrl,_that.qrKey,_that.qrMessage,_that.isPolling,_that.isQrExpired,_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _AuthState implements AuthState {
  const _AuthState({this.isCheckingLogin = true, this.isLoggedIn = false, this.user, this.qrUrl = '', this.qrKey = '', this.qrMessage = '请使用 哔哩哔哩手机客户端 扫码登录', this.isPolling = false, this.isQrExpired = false, this.error});
  

@override@JsonKey() final  bool isCheckingLogin;
@override@JsonKey() final  bool isLoggedIn;
@override final  UserInfoModel? user;
@override@JsonKey() final  String qrUrl;
@override@JsonKey() final  String qrKey;
@override@JsonKey() final  String qrMessage;
@override@JsonKey() final  bool isPolling;
@override@JsonKey() final  bool isQrExpired;
@override final  String? error;

/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AuthStateCopyWith<_AuthState> get copyWith => __$AuthStateCopyWithImpl<_AuthState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AuthState&&(identical(other.isCheckingLogin, isCheckingLogin) || other.isCheckingLogin == isCheckingLogin)&&(identical(other.isLoggedIn, isLoggedIn) || other.isLoggedIn == isLoggedIn)&&(identical(other.user, user) || other.user == user)&&(identical(other.qrUrl, qrUrl) || other.qrUrl == qrUrl)&&(identical(other.qrKey, qrKey) || other.qrKey == qrKey)&&(identical(other.qrMessage, qrMessage) || other.qrMessage == qrMessage)&&(identical(other.isPolling, isPolling) || other.isPolling == isPolling)&&(identical(other.isQrExpired, isQrExpired) || other.isQrExpired == isQrExpired)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode {
    return Object.hash(runtimeType,isCheckingLogin,isLoggedIn,user,qrUrl,qrKey,qrMessage,isPolling,isQrExpired,error);
}

@override
String toString() {
    return 'AuthState(isCheckingLogin: $isCheckingLogin, isLoggedIn: $isLoggedIn, user: $user, qrUrl: $qrUrl, qrKey: $qrKey, qrMessage: $qrMessage, isPolling: $isPolling, isQrExpired: $isQrExpired, error: $error)';
}


}

/// @nodoc
abstract mixin class _$AuthStateCopyWith<$Res> implements $AuthStateCopyWith<$Res> {
  factory _$AuthStateCopyWith(_AuthState value, $Res Function(_AuthState) _then) = __$AuthStateCopyWithImpl;
@override @useResult
$Res call({
 bool isCheckingLogin, bool isLoggedIn, UserInfoModel? user, String qrUrl, String qrKey, String qrMessage, bool isPolling, bool isQrExpired, String? error
});


@override $UserInfoModelCopyWith<$Res>? get user;

}
/// @nodoc
class __$AuthStateCopyWithImpl<$Res>
    implements _$AuthStateCopyWith<$Res> {
  __$AuthStateCopyWithImpl(this._self, this._then);

  final _AuthState _self;
  final $Res Function(_AuthState) _then;

/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isCheckingLogin = null,Object? isLoggedIn = null,Object? user = freezed,Object? qrUrl = null,Object? qrKey = null,Object? qrMessage = null,Object? isPolling = null,Object? isQrExpired = null,Object? error = freezed,}) {
  return _then(_AuthState(
isCheckingLogin: null == isCheckingLogin ? _self.isCheckingLogin : isCheckingLogin // ignore: cast_nullable_to_non_nullable
as bool,isLoggedIn: null == isLoggedIn ? _self.isLoggedIn : isLoggedIn // ignore: cast_nullable_to_non_nullable
as bool,user: freezed == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as UserInfoModel?,qrUrl: null == qrUrl ? _self.qrUrl : qrUrl // ignore: cast_nullable_to_non_nullable
as String,qrKey: null == qrKey ? _self.qrKey : qrKey // ignore: cast_nullable_to_non_nullable
as String,qrMessage: null == qrMessage ? _self.qrMessage : qrMessage // ignore: cast_nullable_to_non_nullable
as String,isPolling: null == isPolling ? _self.isPolling : isPolling // ignore: cast_nullable_to_non_nullable
as bool,isQrExpired: null == isQrExpired ? _self.isQrExpired : isQrExpired // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserInfoModelCopyWith<$Res>? get user {
    if (_self.user == null) {
    return null;
  }

  return $UserInfoModelCopyWith<$Res>(_self.user!, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}

// dart format on

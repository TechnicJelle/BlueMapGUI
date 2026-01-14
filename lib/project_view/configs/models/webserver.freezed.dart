// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'webserver.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WebserverConfigModel {

 int get port;
/// Create a copy of WebserverConfigModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WebserverConfigModelCopyWith<WebserverConfigModel> get copyWith => _$WebserverConfigModelCopyWithImpl<WebserverConfigModel>(this as WebserverConfigModel, _$identity);

  /// Serializes this WebserverConfigModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WebserverConfigModel&&(identical(other.port, port) || other.port == port));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,port);

@override
String toString() {
  return 'WebserverConfigModel(port: $port)';
}


}

/// @nodoc
abstract mixin class $WebserverConfigModelCopyWith<$Res>  {
  factory $WebserverConfigModelCopyWith(WebserverConfigModel value, $Res Function(WebserverConfigModel) _then) = _$WebserverConfigModelCopyWithImpl;
@useResult
$Res call({
 int port
});




}
/// @nodoc
class _$WebserverConfigModelCopyWithImpl<$Res>
    implements $WebserverConfigModelCopyWith<$Res> {
  _$WebserverConfigModelCopyWithImpl(this._self, this._then);

  final WebserverConfigModel _self;
  final $Res Function(WebserverConfigModel) _then;

/// Create a copy of WebserverConfigModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? port = null,}) {
  return _then(_self.copyWith(
port: null == port ? _self.port : port // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [WebserverConfigModel].
extension WebserverConfigModelPatterns on WebserverConfigModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WebserverConfigModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WebserverConfigModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WebserverConfigModel value)  $default,){
final _that = this;
switch (_that) {
case _WebserverConfigModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WebserverConfigModel value)?  $default,){
final _that = this;
switch (_that) {
case _WebserverConfigModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int port)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WebserverConfigModel() when $default != null:
return $default(_that.port);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int port)  $default,) {final _that = this;
switch (_that) {
case _WebserverConfigModel():
return $default(_that.port);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int port)?  $default,) {final _that = this;
switch (_that) {
case _WebserverConfigModel() when $default != null:
return $default(_that.port);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WebserverConfigModel extends WebserverConfigModel {
  const _WebserverConfigModel({required this.port}): super._();
  factory _WebserverConfigModel.fromJson(Map<String, dynamic> json) => _$WebserverConfigModelFromJson(json);

@override final  int port;

/// Create a copy of WebserverConfigModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WebserverConfigModelCopyWith<_WebserverConfigModel> get copyWith => __$WebserverConfigModelCopyWithImpl<_WebserverConfigModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WebserverConfigModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WebserverConfigModel&&(identical(other.port, port) || other.port == port));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,port);

@override
String toString() {
  return 'WebserverConfigModel(port: $port)';
}


}

/// @nodoc
abstract mixin class _$WebserverConfigModelCopyWith<$Res> implements $WebserverConfigModelCopyWith<$Res> {
  factory _$WebserverConfigModelCopyWith(_WebserverConfigModel value, $Res Function(_WebserverConfigModel) _then) = __$WebserverConfigModelCopyWithImpl;
@override @useResult
$Res call({
 int port
});




}
/// @nodoc
class __$WebserverConfigModelCopyWithImpl<$Res>
    implements _$WebserverConfigModelCopyWith<$Res> {
  __$WebserverConfigModelCopyWithImpl(this._self, this._then);

  final _WebserverConfigModel _self;
  final $Res Function(_WebserverConfigModel) _then;

/// Create a copy of WebserverConfigModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? port = null,}) {
  return _then(_WebserverConfigModel(
port: null == port ? _self.port : port // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on

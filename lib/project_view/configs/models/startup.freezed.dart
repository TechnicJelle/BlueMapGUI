// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'startup.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$StartupConfigModel {

 String get modsPath; String get minecraftVersion; String get maxRamLimit;
/// Create a copy of StartupConfigModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StartupConfigModelCopyWith<StartupConfigModel> get copyWith => _$StartupConfigModelCopyWithImpl<StartupConfigModel>(this as StartupConfigModel, _$identity);

  /// Serializes this StartupConfigModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StartupConfigModel&&(identical(other.modsPath, modsPath) || other.modsPath == modsPath)&&(identical(other.minecraftVersion, minecraftVersion) || other.minecraftVersion == minecraftVersion)&&(identical(other.maxRamLimit, maxRamLimit) || other.maxRamLimit == maxRamLimit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,modsPath,minecraftVersion,maxRamLimit);

@override
String toString() {
  return 'StartupConfigModel(modsPath: $modsPath, minecraftVersion: $minecraftVersion, maxRamLimit: $maxRamLimit)';
}


}

/// @nodoc
abstract mixin class $StartupConfigModelCopyWith<$Res>  {
  factory $StartupConfigModelCopyWith(StartupConfigModel value, $Res Function(StartupConfigModel) _then) = _$StartupConfigModelCopyWithImpl;
@useResult
$Res call({
 String modsPath, String minecraftVersion, String maxRamLimit
});




}
/// @nodoc
class _$StartupConfigModelCopyWithImpl<$Res>
    implements $StartupConfigModelCopyWith<$Res> {
  _$StartupConfigModelCopyWithImpl(this._self, this._then);

  final StartupConfigModel _self;
  final $Res Function(StartupConfigModel) _then;

/// Create a copy of StartupConfigModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? modsPath = null,Object? minecraftVersion = null,Object? maxRamLimit = null,}) {
  return _then(_self.copyWith(
modsPath: null == modsPath ? _self.modsPath : modsPath // ignore: cast_nullable_to_non_nullable
as String,minecraftVersion: null == minecraftVersion ? _self.minecraftVersion : minecraftVersion // ignore: cast_nullable_to_non_nullable
as String,maxRamLimit: null == maxRamLimit ? _self.maxRamLimit : maxRamLimit // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [StartupConfigModel].
extension StartupConfigModelPatterns on StartupConfigModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StartupConfigModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StartupConfigModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StartupConfigModel value)  $default,){
final _that = this;
switch (_that) {
case _StartupConfigModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StartupConfigModel value)?  $default,){
final _that = this;
switch (_that) {
case _StartupConfigModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String modsPath,  String minecraftVersion,  String maxRamLimit)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StartupConfigModel() when $default != null:
return $default(_that.modsPath,_that.minecraftVersion,_that.maxRamLimit);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String modsPath,  String minecraftVersion,  String maxRamLimit)  $default,) {final _that = this;
switch (_that) {
case _StartupConfigModel():
return $default(_that.modsPath,_that.minecraftVersion,_that.maxRamLimit);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String modsPath,  String minecraftVersion,  String maxRamLimit)?  $default,) {final _that = this;
switch (_that) {
case _StartupConfigModel() when $default != null:
return $default(_that.modsPath,_that.minecraftVersion,_that.maxRamLimit);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StartupConfigModel extends StartupConfigModel {
  const _StartupConfigModel({required this.modsPath, required this.minecraftVersion, required this.maxRamLimit}): super._();
  factory _StartupConfigModel.fromJson(Map<String, dynamic> json) => _$StartupConfigModelFromJson(json);

@override final  String modsPath;
@override final  String minecraftVersion;
@override final  String maxRamLimit;

/// Create a copy of StartupConfigModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StartupConfigModelCopyWith<_StartupConfigModel> get copyWith => __$StartupConfigModelCopyWithImpl<_StartupConfigModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StartupConfigModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StartupConfigModel&&(identical(other.modsPath, modsPath) || other.modsPath == modsPath)&&(identical(other.minecraftVersion, minecraftVersion) || other.minecraftVersion == minecraftVersion)&&(identical(other.maxRamLimit, maxRamLimit) || other.maxRamLimit == maxRamLimit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,modsPath,minecraftVersion,maxRamLimit);

@override
String toString() {
  return 'StartupConfigModel(modsPath: $modsPath, minecraftVersion: $minecraftVersion, maxRamLimit: $maxRamLimit)';
}


}

/// @nodoc
abstract mixin class _$StartupConfigModelCopyWith<$Res> implements $StartupConfigModelCopyWith<$Res> {
  factory _$StartupConfigModelCopyWith(_StartupConfigModel value, $Res Function(_StartupConfigModel) _then) = __$StartupConfigModelCopyWithImpl;
@override @useResult
$Res call({
 String modsPath, String minecraftVersion, String maxRamLimit
});




}
/// @nodoc
class __$StartupConfigModelCopyWithImpl<$Res>
    implements _$StartupConfigModelCopyWith<$Res> {
  __$StartupConfigModelCopyWithImpl(this._self, this._then);

  final _StartupConfigModel _self;
  final $Res Function(_StartupConfigModel) _then;

/// Create a copy of StartupConfigModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? modsPath = null,Object? minecraftVersion = null,Object? maxRamLimit = null,}) {
  return _then(_StartupConfigModel(
modsPath: null == modsPath ? _self.modsPath : modsPath // ignore: cast_nullable_to_non_nullable
as String,minecraftVersion: null == minecraftVersion ? _self.minecraftVersion : minecraftVersion // ignore: cast_nullable_to_non_nullable
as String,maxRamLimit: null == maxRamLimit ? _self.maxRamLimit : maxRamLimit // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on

// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'core.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CoreConfigModel {

 bool get acceptDownload; int get renderThreadCount;
/// Create a copy of CoreConfigModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CoreConfigModelCopyWith<CoreConfigModel> get copyWith => _$CoreConfigModelCopyWithImpl<CoreConfigModel>(this as CoreConfigModel, _$identity);

  /// Serializes this CoreConfigModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CoreConfigModel&&(identical(other.acceptDownload, acceptDownload) || other.acceptDownload == acceptDownload)&&(identical(other.renderThreadCount, renderThreadCount) || other.renderThreadCount == renderThreadCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,acceptDownload,renderThreadCount);

@override
String toString() {
  return 'CoreConfigModel(acceptDownload: $acceptDownload, renderThreadCount: $renderThreadCount)';
}


}

/// @nodoc
abstract mixin class $CoreConfigModelCopyWith<$Res>  {
  factory $CoreConfigModelCopyWith(CoreConfigModel value, $Res Function(CoreConfigModel) _then) = _$CoreConfigModelCopyWithImpl;
@useResult
$Res call({
 bool acceptDownload, int renderThreadCount
});




}
/// @nodoc
class _$CoreConfigModelCopyWithImpl<$Res>
    implements $CoreConfigModelCopyWith<$Res> {
  _$CoreConfigModelCopyWithImpl(this._self, this._then);

  final CoreConfigModel _self;
  final $Res Function(CoreConfigModel) _then;

/// Create a copy of CoreConfigModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? acceptDownload = null,Object? renderThreadCount = null,}) {
  return _then(_self.copyWith(
acceptDownload: null == acceptDownload ? _self.acceptDownload : acceptDownload // ignore: cast_nullable_to_non_nullable
as bool,renderThreadCount: null == renderThreadCount ? _self.renderThreadCount : renderThreadCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [CoreConfigModel].
extension CoreConfigModelPatterns on CoreConfigModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CoreConfigModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CoreConfigModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CoreConfigModel value)  $default,){
final _that = this;
switch (_that) {
case _CoreConfigModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CoreConfigModel value)?  $default,){
final _that = this;
switch (_that) {
case _CoreConfigModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool acceptDownload,  int renderThreadCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CoreConfigModel() when $default != null:
return $default(_that.acceptDownload,_that.renderThreadCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool acceptDownload,  int renderThreadCount)  $default,) {final _that = this;
switch (_that) {
case _CoreConfigModel():
return $default(_that.acceptDownload,_that.renderThreadCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool acceptDownload,  int renderThreadCount)?  $default,) {final _that = this;
switch (_that) {
case _CoreConfigModel() when $default != null:
return $default(_that.acceptDownload,_that.renderThreadCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CoreConfigModel extends CoreConfigModel {
  const _CoreConfigModel({required this.acceptDownload, required this.renderThreadCount}): super._();
  factory _CoreConfigModel.fromJson(Map<String, dynamic> json) => _$CoreConfigModelFromJson(json);

@override final  bool acceptDownload;
@override final  int renderThreadCount;

/// Create a copy of CoreConfigModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CoreConfigModelCopyWith<_CoreConfigModel> get copyWith => __$CoreConfigModelCopyWithImpl<_CoreConfigModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CoreConfigModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CoreConfigModel&&(identical(other.acceptDownload, acceptDownload) || other.acceptDownload == acceptDownload)&&(identical(other.renderThreadCount, renderThreadCount) || other.renderThreadCount == renderThreadCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,acceptDownload,renderThreadCount);

@override
String toString() {
  return 'CoreConfigModel(acceptDownload: $acceptDownload, renderThreadCount: $renderThreadCount)';
}


}

/// @nodoc
abstract mixin class _$CoreConfigModelCopyWith<$Res> implements $CoreConfigModelCopyWith<$Res> {
  factory _$CoreConfigModelCopyWith(_CoreConfigModel value, $Res Function(_CoreConfigModel) _then) = __$CoreConfigModelCopyWithImpl;
@override @useResult
$Res call({
 bool acceptDownload, int renderThreadCount
});




}
/// @nodoc
class __$CoreConfigModelCopyWithImpl<$Res>
    implements _$CoreConfigModelCopyWith<$Res> {
  __$CoreConfigModelCopyWithImpl(this._self, this._then);

  final _CoreConfigModel _self;
  final $Res Function(_CoreConfigModel) _then;

/// Create a copy of CoreConfigModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? acceptDownload = null,Object? renderThreadCount = null,}) {
  return _then(_CoreConfigModel(
acceptDownload: null == acceptDownload ? _self.acceptDownload : acceptDownload // ignore: cast_nullable_to_non_nullable
as bool,renderThreadCount: null == renderThreadCount ? _self.renderThreadCount : renderThreadCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on

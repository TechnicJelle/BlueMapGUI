// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'webapp.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WebappConfigModel {

 bool get defaultToFlatView;
/// Create a copy of WebappConfigModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WebappConfigModelCopyWith<WebappConfigModel> get copyWith => _$WebappConfigModelCopyWithImpl<WebappConfigModel>(this as WebappConfigModel, _$identity);

  /// Serializes this WebappConfigModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WebappConfigModel&&(identical(other.defaultToFlatView, defaultToFlatView) || other.defaultToFlatView == defaultToFlatView));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,defaultToFlatView);

@override
String toString() {
  return 'WebappConfigModel(defaultToFlatView: $defaultToFlatView)';
}


}

/// @nodoc
abstract mixin class $WebappConfigModelCopyWith<$Res>  {
  factory $WebappConfigModelCopyWith(WebappConfigModel value, $Res Function(WebappConfigModel) _then) = _$WebappConfigModelCopyWithImpl;
@useResult
$Res call({
 bool defaultToFlatView
});




}
/// @nodoc
class _$WebappConfigModelCopyWithImpl<$Res>
    implements $WebappConfigModelCopyWith<$Res> {
  _$WebappConfigModelCopyWithImpl(this._self, this._then);

  final WebappConfigModel _self;
  final $Res Function(WebappConfigModel) _then;

/// Create a copy of WebappConfigModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? defaultToFlatView = null,}) {
  return _then(_self.copyWith(
defaultToFlatView: null == defaultToFlatView ? _self.defaultToFlatView : defaultToFlatView // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [WebappConfigModel].
extension WebappConfigModelPatterns on WebappConfigModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WebappConfigModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WebappConfigModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WebappConfigModel value)  $default,){
final _that = this;
switch (_that) {
case _WebappConfigModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WebappConfigModel value)?  $default,){
final _that = this;
switch (_that) {
case _WebappConfigModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool defaultToFlatView)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WebappConfigModel() when $default != null:
return $default(_that.defaultToFlatView);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool defaultToFlatView)  $default,) {final _that = this;
switch (_that) {
case _WebappConfigModel():
return $default(_that.defaultToFlatView);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool defaultToFlatView)?  $default,) {final _that = this;
switch (_that) {
case _WebappConfigModel() when $default != null:
return $default(_that.defaultToFlatView);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WebappConfigModel extends WebappConfigModel {
  const _WebappConfigModel({required this.defaultToFlatView}): super._();
  factory _WebappConfigModel.fromJson(Map<String, dynamic> json) => _$WebappConfigModelFromJson(json);

@override final  bool defaultToFlatView;

/// Create a copy of WebappConfigModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WebappConfigModelCopyWith<_WebappConfigModel> get copyWith => __$WebappConfigModelCopyWithImpl<_WebappConfigModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WebappConfigModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WebappConfigModel&&(identical(other.defaultToFlatView, defaultToFlatView) || other.defaultToFlatView == defaultToFlatView));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,defaultToFlatView);

@override
String toString() {
  return 'WebappConfigModel(defaultToFlatView: $defaultToFlatView)';
}


}

/// @nodoc
abstract mixin class _$WebappConfigModelCopyWith<$Res> implements $WebappConfigModelCopyWith<$Res> {
  factory _$WebappConfigModelCopyWith(_WebappConfigModel value, $Res Function(_WebappConfigModel) _then) = __$WebappConfigModelCopyWithImpl;
@override @useResult
$Res call({
 bool defaultToFlatView
});




}
/// @nodoc
class __$WebappConfigModelCopyWithImpl<$Res>
    implements _$WebappConfigModelCopyWith<$Res> {
  __$WebappConfigModelCopyWithImpl(this._self, this._then);

  final _WebappConfigModel _self;
  final $Res Function(_WebappConfigModel) _then;

/// Create a copy of WebappConfigModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? defaultToFlatView = null,}) {
  return _then(_WebappConfigModel(
defaultToFlatView: null == defaultToFlatView ? _self.defaultToFlatView : defaultToFlatView // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on

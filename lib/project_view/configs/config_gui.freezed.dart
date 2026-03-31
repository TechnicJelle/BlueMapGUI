// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'config_gui.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AdvancedMode {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AdvancedMode);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AdvancedMode()';
}


}

/// @nodoc
class $AdvancedModeCopyWith<$Res>  {
$AdvancedModeCopyWith(AdvancedMode _, $Res Function(AdvancedMode) __);
}


/// Adds pattern-matching-related methods to [AdvancedMode].
extension AdvancedModePatterns on AdvancedMode {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( AdvancedModeData value)?  data,TResult Function( AdvancedModeLoading value)?  loading,required TResult orElse(),}){
final _that = this;
switch (_that) {
case AdvancedModeData() when data != null:
return data(_that);case AdvancedModeLoading() when loading != null:
return loading(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( AdvancedModeData value)  data,required TResult Function( AdvancedModeLoading value)  loading,}){
final _that = this;
switch (_that) {
case AdvancedModeData():
return data(_that);case AdvancedModeLoading():
return loading(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( AdvancedModeData value)?  data,TResult? Function( AdvancedModeLoading value)?  loading,}){
final _that = this;
switch (_that) {
case AdvancedModeData() when data != null:
return data(_that);case AdvancedModeLoading() when loading != null:
return loading(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( bool value)?  data,TResult Function()?  loading,required TResult orElse(),}) {final _that = this;
switch (_that) {
case AdvancedModeData() when data != null:
return data(_that.value);case AdvancedModeLoading() when loading != null:
return loading();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( bool value)  data,required TResult Function()  loading,}) {final _that = this;
switch (_that) {
case AdvancedModeData():
return data(_that.value);case AdvancedModeLoading():
return loading();}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( bool value)?  data,TResult? Function()?  loading,}) {final _that = this;
switch (_that) {
case AdvancedModeData() when data != null:
return data(_that.value);case AdvancedModeLoading() when loading != null:
return loading();case _:
  return null;

}
}

}

/// @nodoc


class AdvancedModeData implements AdvancedMode {
  const AdvancedModeData(this.value);
  

 final  bool value;

/// Create a copy of AdvancedMode
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AdvancedModeDataCopyWith<AdvancedModeData> get copyWith => _$AdvancedModeDataCopyWithImpl<AdvancedModeData>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AdvancedModeData&&(identical(other.value, value) || other.value == value));
}


@override
int get hashCode => Object.hash(runtimeType,value);

@override
String toString() {
  return 'AdvancedMode.data(value: $value)';
}


}

/// @nodoc
abstract mixin class $AdvancedModeDataCopyWith<$Res> implements $AdvancedModeCopyWith<$Res> {
  factory $AdvancedModeDataCopyWith(AdvancedModeData value, $Res Function(AdvancedModeData) _then) = _$AdvancedModeDataCopyWithImpl;
@useResult
$Res call({
 bool value
});




}
/// @nodoc
class _$AdvancedModeDataCopyWithImpl<$Res>
    implements $AdvancedModeDataCopyWith<$Res> {
  _$AdvancedModeDataCopyWithImpl(this._self, this._then);

  final AdvancedModeData _self;
  final $Res Function(AdvancedModeData) _then;

/// Create a copy of AdvancedMode
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? value = null,}) {
  return _then(AdvancedModeData(
null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc


class AdvancedModeLoading implements AdvancedMode {
  const AdvancedModeLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AdvancedModeLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AdvancedMode.loading()';
}


}




// dart format on

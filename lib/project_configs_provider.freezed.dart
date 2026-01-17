// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'project_configs_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ProjectConfigs {

 Directory get projectLocation; List<ConfigFile<BaseConfigModel>> get mainConfigs; List<ConfigFile<MapConfigModel>> get mapConfigs; ConfigFile? get openConfig;
/// Create a copy of ProjectConfigs
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProjectConfigsCopyWith<ProjectConfigs> get copyWith => _$ProjectConfigsCopyWithImpl<ProjectConfigs>(this as ProjectConfigs, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProjectConfigs&&(identical(other.projectLocation, projectLocation) || other.projectLocation == projectLocation)&&const DeepCollectionEquality().equals(other.mainConfigs, mainConfigs)&&const DeepCollectionEquality().equals(other.mapConfigs, mapConfigs)&&(identical(other.openConfig, openConfig) || other.openConfig == openConfig));
}


@override
int get hashCode => Object.hash(runtimeType,projectLocation,const DeepCollectionEquality().hash(mainConfigs),const DeepCollectionEquality().hash(mapConfigs),openConfig);

@override
String toString() {
  return 'ProjectConfigs(projectLocation: $projectLocation, mainConfigs: $mainConfigs, mapConfigs: $mapConfigs, openConfig: $openConfig)';
}


}

/// @nodoc
abstract mixin class $ProjectConfigsCopyWith<$Res>  {
  factory $ProjectConfigsCopyWith(ProjectConfigs value, $Res Function(ProjectConfigs) _then) = _$ProjectConfigsCopyWithImpl;
@useResult
$Res call({
 Directory projectLocation, List<ConfigFile<BaseConfigModel>> mainConfigs, List<ConfigFile<MapConfigModel>> mapConfigs, ConfigFile? openConfig
});




}
/// @nodoc
class _$ProjectConfigsCopyWithImpl<$Res>
    implements $ProjectConfigsCopyWith<$Res> {
  _$ProjectConfigsCopyWithImpl(this._self, this._then);

  final ProjectConfigs _self;
  final $Res Function(ProjectConfigs) _then;

/// Create a copy of ProjectConfigs
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? projectLocation = null,Object? mainConfigs = null,Object? mapConfigs = null,Object? openConfig = freezed,}) {
  return _then(_self.copyWith(
projectLocation: null == projectLocation ? _self.projectLocation : projectLocation // ignore: cast_nullable_to_non_nullable
as Directory,mainConfigs: null == mainConfigs ? _self.mainConfigs : mainConfigs // ignore: cast_nullable_to_non_nullable
as List<ConfigFile<BaseConfigModel>>,mapConfigs: null == mapConfigs ? _self.mapConfigs : mapConfigs // ignore: cast_nullable_to_non_nullable
as List<ConfigFile<MapConfigModel>>,openConfig: freezed == openConfig ? _self.openConfig : openConfig // ignore: cast_nullable_to_non_nullable
as ConfigFile?,
  ));
}

}


/// Adds pattern-matching-related methods to [ProjectConfigs].
extension ProjectConfigsPatterns on ProjectConfigs {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProjectConfigs value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProjectConfigs() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProjectConfigs value)  $default,){
final _that = this;
switch (_that) {
case _ProjectConfigs():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProjectConfigs value)?  $default,){
final _that = this;
switch (_that) {
case _ProjectConfigs() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Directory projectLocation,  List<ConfigFile<BaseConfigModel>> mainConfigs,  List<ConfigFile<MapConfigModel>> mapConfigs,  ConfigFile? openConfig)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProjectConfigs() when $default != null:
return $default(_that.projectLocation,_that.mainConfigs,_that.mapConfigs,_that.openConfig);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Directory projectLocation,  List<ConfigFile<BaseConfigModel>> mainConfigs,  List<ConfigFile<MapConfigModel>> mapConfigs,  ConfigFile? openConfig)  $default,) {final _that = this;
switch (_that) {
case _ProjectConfigs():
return $default(_that.projectLocation,_that.mainConfigs,_that.mapConfigs,_that.openConfig);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Directory projectLocation,  List<ConfigFile<BaseConfigModel>> mainConfigs,  List<ConfigFile<MapConfigModel>> mapConfigs,  ConfigFile? openConfig)?  $default,) {final _that = this;
switch (_that) {
case _ProjectConfigs() when $default != null:
return $default(_that.projectLocation,_that.mainConfigs,_that.mapConfigs,_that.openConfig);case _:
  return null;

}
}

}

/// @nodoc


class _ProjectConfigs implements ProjectConfigs {
  const _ProjectConfigs({required this.projectLocation, required final  List<ConfigFile<BaseConfigModel>> mainConfigs, required final  List<ConfigFile<MapConfigModel>> mapConfigs, required this.openConfig}): _mainConfigs = mainConfigs,_mapConfigs = mapConfigs;
  

@override final  Directory projectLocation;
 final  List<ConfigFile<BaseConfigModel>> _mainConfigs;
@override List<ConfigFile<BaseConfigModel>> get mainConfigs {
  if (_mainConfigs is EqualUnmodifiableListView) return _mainConfigs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_mainConfigs);
}

 final  List<ConfigFile<MapConfigModel>> _mapConfigs;
@override List<ConfigFile<MapConfigModel>> get mapConfigs {
  if (_mapConfigs is EqualUnmodifiableListView) return _mapConfigs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_mapConfigs);
}

@override final  ConfigFile? openConfig;

/// Create a copy of ProjectConfigs
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProjectConfigsCopyWith<_ProjectConfigs> get copyWith => __$ProjectConfigsCopyWithImpl<_ProjectConfigs>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProjectConfigs&&(identical(other.projectLocation, projectLocation) || other.projectLocation == projectLocation)&&const DeepCollectionEquality().equals(other._mainConfigs, _mainConfigs)&&const DeepCollectionEquality().equals(other._mapConfigs, _mapConfigs)&&(identical(other.openConfig, openConfig) || other.openConfig == openConfig));
}


@override
int get hashCode => Object.hash(runtimeType,projectLocation,const DeepCollectionEquality().hash(_mainConfigs),const DeepCollectionEquality().hash(_mapConfigs),openConfig);

@override
String toString() {
  return 'ProjectConfigs(projectLocation: $projectLocation, mainConfigs: $mainConfigs, mapConfigs: $mapConfigs, openConfig: $openConfig)';
}


}

/// @nodoc
abstract mixin class _$ProjectConfigsCopyWith<$Res> implements $ProjectConfigsCopyWith<$Res> {
  factory _$ProjectConfigsCopyWith(_ProjectConfigs value, $Res Function(_ProjectConfigs) _then) = __$ProjectConfigsCopyWithImpl;
@override @useResult
$Res call({
 Directory projectLocation, List<ConfigFile<BaseConfigModel>> mainConfigs, List<ConfigFile<MapConfigModel>> mapConfigs, ConfigFile? openConfig
});




}
/// @nodoc
class __$ProjectConfigsCopyWithImpl<$Res>
    implements _$ProjectConfigsCopyWith<$Res> {
  __$ProjectConfigsCopyWithImpl(this._self, this._then);

  final _ProjectConfigs _self;
  final $Res Function(_ProjectConfigs) _then;

/// Create a copy of ProjectConfigs
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? projectLocation = null,Object? mainConfigs = null,Object? mapConfigs = null,Object? openConfig = freezed,}) {
  return _then(_ProjectConfigs(
projectLocation: null == projectLocation ? _self.projectLocation : projectLocation // ignore: cast_nullable_to_non_nullable
as Directory,mainConfigs: null == mainConfigs ? _self._mainConfigs : mainConfigs // ignore: cast_nullable_to_non_nullable
as List<ConfigFile<BaseConfigModel>>,mapConfigs: null == mapConfigs ? _self._mapConfigs : mapConfigs // ignore: cast_nullable_to_non_nullable
as List<ConfigFile<MapConfigModel>>,openConfig: freezed == openConfig ? _self.openConfig : openConfig // ignore: cast_nullable_to_non_nullable
as ConfigFile?,
  ));
}


}

// dart format on

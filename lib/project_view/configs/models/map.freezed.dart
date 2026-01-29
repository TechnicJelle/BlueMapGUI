// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'map.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Vector2XZ {

 int get x; int get z;
/// Create a copy of Vector2XZ
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$Vector2XZCopyWith<Vector2XZ> get copyWith => _$Vector2XZCopyWithImpl<Vector2XZ>(this as Vector2XZ, _$identity);

  /// Serializes this Vector2XZ to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Vector2XZ&&(identical(other.x, x) || other.x == x)&&(identical(other.z, z) || other.z == z));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,x,z);

@override
String toString() {
  return 'Vector2XZ(x: $x, z: $z)';
}


}

/// @nodoc
abstract mixin class $Vector2XZCopyWith<$Res>  {
  factory $Vector2XZCopyWith(Vector2XZ value, $Res Function(Vector2XZ) _then) = _$Vector2XZCopyWithImpl;
@useResult
$Res call({
 int x, int z
});




}
/// @nodoc
class _$Vector2XZCopyWithImpl<$Res>
    implements $Vector2XZCopyWith<$Res> {
  _$Vector2XZCopyWithImpl(this._self, this._then);

  final Vector2XZ _self;
  final $Res Function(Vector2XZ) _then;

/// Create a copy of Vector2XZ
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? x = null,Object? z = null,}) {
  return _then(_self.copyWith(
x: null == x ? _self.x : x // ignore: cast_nullable_to_non_nullable
as int,z: null == z ? _self.z : z // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [Vector2XZ].
extension Vector2XZPatterns on Vector2XZ {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Vector2XZ value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Vector2XZ() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Vector2XZ value)  $default,){
final _that = this;
switch (_that) {
case _Vector2XZ():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Vector2XZ value)?  $default,){
final _that = this;
switch (_that) {
case _Vector2XZ() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int x,  int z)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Vector2XZ() when $default != null:
return $default(_that.x,_that.z);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int x,  int z)  $default,) {final _that = this;
switch (_that) {
case _Vector2XZ():
return $default(_that.x,_that.z);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int x,  int z)?  $default,) {final _that = this;
switch (_that) {
case _Vector2XZ() when $default != null:
return $default(_that.x,_that.z);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Vector2XZ extends Vector2XZ {
  const _Vector2XZ({required this.x, required this.z}): super._();
  factory _Vector2XZ.fromJson(Map<String, dynamic> json) => _$Vector2XZFromJson(json);

@override final  int x;
@override final  int z;

/// Create a copy of Vector2XZ
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$Vector2XZCopyWith<_Vector2XZ> get copyWith => __$Vector2XZCopyWithImpl<_Vector2XZ>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$Vector2XZToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Vector2XZ&&(identical(other.x, x) || other.x == x)&&(identical(other.z, z) || other.z == z));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,x,z);

@override
String toString() {
  return 'Vector2XZ(x: $x, z: $z)';
}


}

/// @nodoc
abstract mixin class _$Vector2XZCopyWith<$Res> implements $Vector2XZCopyWith<$Res> {
  factory _$Vector2XZCopyWith(_Vector2XZ value, $Res Function(_Vector2XZ) _then) = __$Vector2XZCopyWithImpl;
@override @useResult
$Res call({
 int x, int z
});




}
/// @nodoc
class __$Vector2XZCopyWithImpl<$Res>
    implements _$Vector2XZCopyWith<$Res> {
  __$Vector2XZCopyWithImpl(this._self, this._then);

  final _Vector2XZ _self;
  final $Res Function(_Vector2XZ) _then;

/// Create a copy of Vector2XZ
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? x = null,Object? z = null,}) {
  return _then(_Vector2XZ(
x: null == x ? _self.x : x // ignore: cast_nullable_to_non_nullable
as int,z: null == z ? _self.z : z // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$MapConfigModel {

 String get world; String get dimension; String get name; int get sorting; Vector2XZ get startPos; String get skyColor; String get voidColor; double? get skyLight; double get ambientLight; int get removeCavesBelowY; int get caveDetectionOceanFloor; bool get caveDetectionUsesBlockLight; int get minInhabitedTime; bool get renderEdges; int? get edgeLightStrength; bool? get enablePerspectiveView; bool? get enableFlatView; bool? get enableFreeFlightView; bool? get enableHires;
/// Create a copy of MapConfigModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MapConfigModelCopyWith<MapConfigModel> get copyWith => _$MapConfigModelCopyWithImpl<MapConfigModel>(this as MapConfigModel, _$identity);

  /// Serializes this MapConfigModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MapConfigModel&&(identical(other.world, world) || other.world == world)&&(identical(other.dimension, dimension) || other.dimension == dimension)&&(identical(other.name, name) || other.name == name)&&(identical(other.sorting, sorting) || other.sorting == sorting)&&(identical(other.startPos, startPos) || other.startPos == startPos)&&(identical(other.skyColor, skyColor) || other.skyColor == skyColor)&&(identical(other.voidColor, voidColor) || other.voidColor == voidColor)&&(identical(other.skyLight, skyLight) || other.skyLight == skyLight)&&(identical(other.ambientLight, ambientLight) || other.ambientLight == ambientLight)&&(identical(other.removeCavesBelowY, removeCavesBelowY) || other.removeCavesBelowY == removeCavesBelowY)&&(identical(other.caveDetectionOceanFloor, caveDetectionOceanFloor) || other.caveDetectionOceanFloor == caveDetectionOceanFloor)&&(identical(other.caveDetectionUsesBlockLight, caveDetectionUsesBlockLight) || other.caveDetectionUsesBlockLight == caveDetectionUsesBlockLight)&&(identical(other.minInhabitedTime, minInhabitedTime) || other.minInhabitedTime == minInhabitedTime)&&(identical(other.renderEdges, renderEdges) || other.renderEdges == renderEdges)&&(identical(other.edgeLightStrength, edgeLightStrength) || other.edgeLightStrength == edgeLightStrength)&&(identical(other.enablePerspectiveView, enablePerspectiveView) || other.enablePerspectiveView == enablePerspectiveView)&&(identical(other.enableFlatView, enableFlatView) || other.enableFlatView == enableFlatView)&&(identical(other.enableFreeFlightView, enableFreeFlightView) || other.enableFreeFlightView == enableFreeFlightView)&&(identical(other.enableHires, enableHires) || other.enableHires == enableHires));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,world,dimension,name,sorting,startPos,skyColor,voidColor,skyLight,ambientLight,removeCavesBelowY,caveDetectionOceanFloor,caveDetectionUsesBlockLight,minInhabitedTime,renderEdges,edgeLightStrength,enablePerspectiveView,enableFlatView,enableFreeFlightView,enableHires]);

@override
String toString() {
  return 'MapConfigModel(world: $world, dimension: $dimension, name: $name, sorting: $sorting, startPos: $startPos, skyColor: $skyColor, voidColor: $voidColor, skyLight: $skyLight, ambientLight: $ambientLight, removeCavesBelowY: $removeCavesBelowY, caveDetectionOceanFloor: $caveDetectionOceanFloor, caveDetectionUsesBlockLight: $caveDetectionUsesBlockLight, minInhabitedTime: $minInhabitedTime, renderEdges: $renderEdges, edgeLightStrength: $edgeLightStrength, enablePerspectiveView: $enablePerspectiveView, enableFlatView: $enableFlatView, enableFreeFlightView: $enableFreeFlightView, enableHires: $enableHires)';
}


}

/// @nodoc
abstract mixin class $MapConfigModelCopyWith<$Res>  {
  factory $MapConfigModelCopyWith(MapConfigModel value, $Res Function(MapConfigModel) _then) = _$MapConfigModelCopyWithImpl;
@useResult
$Res call({
 String world, String dimension, String name, int sorting, Vector2XZ startPos, String skyColor, String voidColor, double? skyLight, double ambientLight, int removeCavesBelowY, int caveDetectionOceanFloor, bool caveDetectionUsesBlockLight, int minInhabitedTime, bool renderEdges, int? edgeLightStrength, bool? enablePerspectiveView, bool? enableFlatView, bool? enableFreeFlightView, bool? enableHires
});


$Vector2XZCopyWith<$Res> get startPos;

}
/// @nodoc
class _$MapConfigModelCopyWithImpl<$Res>
    implements $MapConfigModelCopyWith<$Res> {
  _$MapConfigModelCopyWithImpl(this._self, this._then);

  final MapConfigModel _self;
  final $Res Function(MapConfigModel) _then;

/// Create a copy of MapConfigModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? world = null,Object? dimension = null,Object? name = null,Object? sorting = null,Object? startPos = null,Object? skyColor = null,Object? voidColor = null,Object? skyLight = freezed,Object? ambientLight = null,Object? removeCavesBelowY = null,Object? caveDetectionOceanFloor = null,Object? caveDetectionUsesBlockLight = null,Object? minInhabitedTime = null,Object? renderEdges = null,Object? edgeLightStrength = freezed,Object? enablePerspectiveView = freezed,Object? enableFlatView = freezed,Object? enableFreeFlightView = freezed,Object? enableHires = freezed,}) {
  return _then(_self.copyWith(
world: null == world ? _self.world : world // ignore: cast_nullable_to_non_nullable
as String,dimension: null == dimension ? _self.dimension : dimension // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,sorting: null == sorting ? _self.sorting : sorting // ignore: cast_nullable_to_non_nullable
as int,startPos: null == startPos ? _self.startPos : startPos // ignore: cast_nullable_to_non_nullable
as Vector2XZ,skyColor: null == skyColor ? _self.skyColor : skyColor // ignore: cast_nullable_to_non_nullable
as String,voidColor: null == voidColor ? _self.voidColor : voidColor // ignore: cast_nullable_to_non_nullable
as String,skyLight: freezed == skyLight ? _self.skyLight : skyLight // ignore: cast_nullable_to_non_nullable
as double?,ambientLight: null == ambientLight ? _self.ambientLight : ambientLight // ignore: cast_nullable_to_non_nullable
as double,removeCavesBelowY: null == removeCavesBelowY ? _self.removeCavesBelowY : removeCavesBelowY // ignore: cast_nullable_to_non_nullable
as int,caveDetectionOceanFloor: null == caveDetectionOceanFloor ? _self.caveDetectionOceanFloor : caveDetectionOceanFloor // ignore: cast_nullable_to_non_nullable
as int,caveDetectionUsesBlockLight: null == caveDetectionUsesBlockLight ? _self.caveDetectionUsesBlockLight : caveDetectionUsesBlockLight // ignore: cast_nullable_to_non_nullable
as bool,minInhabitedTime: null == minInhabitedTime ? _self.minInhabitedTime : minInhabitedTime // ignore: cast_nullable_to_non_nullable
as int,renderEdges: null == renderEdges ? _self.renderEdges : renderEdges // ignore: cast_nullable_to_non_nullable
as bool,edgeLightStrength: freezed == edgeLightStrength ? _self.edgeLightStrength : edgeLightStrength // ignore: cast_nullable_to_non_nullable
as int?,enablePerspectiveView: freezed == enablePerspectiveView ? _self.enablePerspectiveView : enablePerspectiveView // ignore: cast_nullable_to_non_nullable
as bool?,enableFlatView: freezed == enableFlatView ? _self.enableFlatView : enableFlatView // ignore: cast_nullable_to_non_nullable
as bool?,enableFreeFlightView: freezed == enableFreeFlightView ? _self.enableFreeFlightView : enableFreeFlightView // ignore: cast_nullable_to_non_nullable
as bool?,enableHires: freezed == enableHires ? _self.enableHires : enableHires // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}
/// Create a copy of MapConfigModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$Vector2XZCopyWith<$Res> get startPos {
  
  return $Vector2XZCopyWith<$Res>(_self.startPos, (value) {
    return _then(_self.copyWith(startPos: value));
  });
}
}


/// Adds pattern-matching-related methods to [MapConfigModel].
extension MapConfigModelPatterns on MapConfigModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MapConfigModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MapConfigModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MapConfigModel value)  $default,){
final _that = this;
switch (_that) {
case _MapConfigModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MapConfigModel value)?  $default,){
final _that = this;
switch (_that) {
case _MapConfigModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String world,  String dimension,  String name,  int sorting,  Vector2XZ startPos,  String skyColor,  String voidColor,  double? skyLight,  double ambientLight,  int removeCavesBelowY,  int caveDetectionOceanFloor,  bool caveDetectionUsesBlockLight,  int minInhabitedTime,  bool renderEdges,  int? edgeLightStrength,  bool? enablePerspectiveView,  bool? enableFlatView,  bool? enableFreeFlightView,  bool? enableHires)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MapConfigModel() when $default != null:
return $default(_that.world,_that.dimension,_that.name,_that.sorting,_that.startPos,_that.skyColor,_that.voidColor,_that.skyLight,_that.ambientLight,_that.removeCavesBelowY,_that.caveDetectionOceanFloor,_that.caveDetectionUsesBlockLight,_that.minInhabitedTime,_that.renderEdges,_that.edgeLightStrength,_that.enablePerspectiveView,_that.enableFlatView,_that.enableFreeFlightView,_that.enableHires);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String world,  String dimension,  String name,  int sorting,  Vector2XZ startPos,  String skyColor,  String voidColor,  double? skyLight,  double ambientLight,  int removeCavesBelowY,  int caveDetectionOceanFloor,  bool caveDetectionUsesBlockLight,  int minInhabitedTime,  bool renderEdges,  int? edgeLightStrength,  bool? enablePerspectiveView,  bool? enableFlatView,  bool? enableFreeFlightView,  bool? enableHires)  $default,) {final _that = this;
switch (_that) {
case _MapConfigModel():
return $default(_that.world,_that.dimension,_that.name,_that.sorting,_that.startPos,_that.skyColor,_that.voidColor,_that.skyLight,_that.ambientLight,_that.removeCavesBelowY,_that.caveDetectionOceanFloor,_that.caveDetectionUsesBlockLight,_that.minInhabitedTime,_that.renderEdges,_that.edgeLightStrength,_that.enablePerspectiveView,_that.enableFlatView,_that.enableFreeFlightView,_that.enableHires);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String world,  String dimension,  String name,  int sorting,  Vector2XZ startPos,  String skyColor,  String voidColor,  double? skyLight,  double ambientLight,  int removeCavesBelowY,  int caveDetectionOceanFloor,  bool caveDetectionUsesBlockLight,  int minInhabitedTime,  bool renderEdges,  int? edgeLightStrength,  bool? enablePerspectiveView,  bool? enableFlatView,  bool? enableFreeFlightView,  bool? enableHires)?  $default,) {final _that = this;
switch (_that) {
case _MapConfigModel() when $default != null:
return $default(_that.world,_that.dimension,_that.name,_that.sorting,_that.startPos,_that.skyColor,_that.voidColor,_that.skyLight,_that.ambientLight,_that.removeCavesBelowY,_that.caveDetectionOceanFloor,_that.caveDetectionUsesBlockLight,_that.minInhabitedTime,_that.renderEdges,_that.edgeLightStrength,_that.enablePerspectiveView,_that.enableFlatView,_that.enableFreeFlightView,_that.enableHires);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MapConfigModel extends MapConfigModel {
  const _MapConfigModel({required this.world, required this.dimension, required this.name, required this.sorting, required this.startPos, required this.skyColor, required this.voidColor, required this.skyLight, required this.ambientLight, required this.removeCavesBelowY, required this.caveDetectionOceanFloor, required this.caveDetectionUsesBlockLight, required this.minInhabitedTime, required this.renderEdges, required this.edgeLightStrength, required this.enablePerspectiveView, required this.enableFlatView, required this.enableFreeFlightView, required this.enableHires}): super._();
  factory _MapConfigModel.fromJson(Map<String, dynamic> json) => _$MapConfigModelFromJson(json);

@override final  String world;
@override final  String dimension;
@override final  String name;
@override final  int sorting;
@override final  Vector2XZ startPos;
@override final  String skyColor;
@override final  String voidColor;
@override final  double? skyLight;
@override final  double ambientLight;
@override final  int removeCavesBelowY;
@override final  int caveDetectionOceanFloor;
@override final  bool caveDetectionUsesBlockLight;
@override final  int minInhabitedTime;
@override final  bool renderEdges;
@override final  int? edgeLightStrength;
@override final  bool? enablePerspectiveView;
@override final  bool? enableFlatView;
@override final  bool? enableFreeFlightView;
@override final  bool? enableHires;

/// Create a copy of MapConfigModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MapConfigModelCopyWith<_MapConfigModel> get copyWith => __$MapConfigModelCopyWithImpl<_MapConfigModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MapConfigModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MapConfigModel&&(identical(other.world, world) || other.world == world)&&(identical(other.dimension, dimension) || other.dimension == dimension)&&(identical(other.name, name) || other.name == name)&&(identical(other.sorting, sorting) || other.sorting == sorting)&&(identical(other.startPos, startPos) || other.startPos == startPos)&&(identical(other.skyColor, skyColor) || other.skyColor == skyColor)&&(identical(other.voidColor, voidColor) || other.voidColor == voidColor)&&(identical(other.skyLight, skyLight) || other.skyLight == skyLight)&&(identical(other.ambientLight, ambientLight) || other.ambientLight == ambientLight)&&(identical(other.removeCavesBelowY, removeCavesBelowY) || other.removeCavesBelowY == removeCavesBelowY)&&(identical(other.caveDetectionOceanFloor, caveDetectionOceanFloor) || other.caveDetectionOceanFloor == caveDetectionOceanFloor)&&(identical(other.caveDetectionUsesBlockLight, caveDetectionUsesBlockLight) || other.caveDetectionUsesBlockLight == caveDetectionUsesBlockLight)&&(identical(other.minInhabitedTime, minInhabitedTime) || other.minInhabitedTime == minInhabitedTime)&&(identical(other.renderEdges, renderEdges) || other.renderEdges == renderEdges)&&(identical(other.edgeLightStrength, edgeLightStrength) || other.edgeLightStrength == edgeLightStrength)&&(identical(other.enablePerspectiveView, enablePerspectiveView) || other.enablePerspectiveView == enablePerspectiveView)&&(identical(other.enableFlatView, enableFlatView) || other.enableFlatView == enableFlatView)&&(identical(other.enableFreeFlightView, enableFreeFlightView) || other.enableFreeFlightView == enableFreeFlightView)&&(identical(other.enableHires, enableHires) || other.enableHires == enableHires));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,world,dimension,name,sorting,startPos,skyColor,voidColor,skyLight,ambientLight,removeCavesBelowY,caveDetectionOceanFloor,caveDetectionUsesBlockLight,minInhabitedTime,renderEdges,edgeLightStrength,enablePerspectiveView,enableFlatView,enableFreeFlightView,enableHires]);

@override
String toString() {
  return 'MapConfigModel(world: $world, dimension: $dimension, name: $name, sorting: $sorting, startPos: $startPos, skyColor: $skyColor, voidColor: $voidColor, skyLight: $skyLight, ambientLight: $ambientLight, removeCavesBelowY: $removeCavesBelowY, caveDetectionOceanFloor: $caveDetectionOceanFloor, caveDetectionUsesBlockLight: $caveDetectionUsesBlockLight, minInhabitedTime: $minInhabitedTime, renderEdges: $renderEdges, edgeLightStrength: $edgeLightStrength, enablePerspectiveView: $enablePerspectiveView, enableFlatView: $enableFlatView, enableFreeFlightView: $enableFreeFlightView, enableHires: $enableHires)';
}


}

/// @nodoc
abstract mixin class _$MapConfigModelCopyWith<$Res> implements $MapConfigModelCopyWith<$Res> {
  factory _$MapConfigModelCopyWith(_MapConfigModel value, $Res Function(_MapConfigModel) _then) = __$MapConfigModelCopyWithImpl;
@override @useResult
$Res call({
 String world, String dimension, String name, int sorting, Vector2XZ startPos, String skyColor, String voidColor, double? skyLight, double ambientLight, int removeCavesBelowY, int caveDetectionOceanFloor, bool caveDetectionUsesBlockLight, int minInhabitedTime, bool renderEdges, int? edgeLightStrength, bool? enablePerspectiveView, bool? enableFlatView, bool? enableFreeFlightView, bool? enableHires
});


@override $Vector2XZCopyWith<$Res> get startPos;

}
/// @nodoc
class __$MapConfigModelCopyWithImpl<$Res>
    implements _$MapConfigModelCopyWith<$Res> {
  __$MapConfigModelCopyWithImpl(this._self, this._then);

  final _MapConfigModel _self;
  final $Res Function(_MapConfigModel) _then;

/// Create a copy of MapConfigModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? world = null,Object? dimension = null,Object? name = null,Object? sorting = null,Object? startPos = null,Object? skyColor = null,Object? voidColor = null,Object? skyLight = freezed,Object? ambientLight = null,Object? removeCavesBelowY = null,Object? caveDetectionOceanFloor = null,Object? caveDetectionUsesBlockLight = null,Object? minInhabitedTime = null,Object? renderEdges = null,Object? edgeLightStrength = freezed,Object? enablePerspectiveView = freezed,Object? enableFlatView = freezed,Object? enableFreeFlightView = freezed,Object? enableHires = freezed,}) {
  return _then(_MapConfigModel(
world: null == world ? _self.world : world // ignore: cast_nullable_to_non_nullable
as String,dimension: null == dimension ? _self.dimension : dimension // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,sorting: null == sorting ? _self.sorting : sorting // ignore: cast_nullable_to_non_nullable
as int,startPos: null == startPos ? _self.startPos : startPos // ignore: cast_nullable_to_non_nullable
as Vector2XZ,skyColor: null == skyColor ? _self.skyColor : skyColor // ignore: cast_nullable_to_non_nullable
as String,voidColor: null == voidColor ? _self.voidColor : voidColor // ignore: cast_nullable_to_non_nullable
as String,skyLight: freezed == skyLight ? _self.skyLight : skyLight // ignore: cast_nullable_to_non_nullable
as double?,ambientLight: null == ambientLight ? _self.ambientLight : ambientLight // ignore: cast_nullable_to_non_nullable
as double,removeCavesBelowY: null == removeCavesBelowY ? _self.removeCavesBelowY : removeCavesBelowY // ignore: cast_nullable_to_non_nullable
as int,caveDetectionOceanFloor: null == caveDetectionOceanFloor ? _self.caveDetectionOceanFloor : caveDetectionOceanFloor // ignore: cast_nullable_to_non_nullable
as int,caveDetectionUsesBlockLight: null == caveDetectionUsesBlockLight ? _self.caveDetectionUsesBlockLight : caveDetectionUsesBlockLight // ignore: cast_nullable_to_non_nullable
as bool,minInhabitedTime: null == minInhabitedTime ? _self.minInhabitedTime : minInhabitedTime // ignore: cast_nullable_to_non_nullable
as int,renderEdges: null == renderEdges ? _self.renderEdges : renderEdges // ignore: cast_nullable_to_non_nullable
as bool,edgeLightStrength: freezed == edgeLightStrength ? _self.edgeLightStrength : edgeLightStrength // ignore: cast_nullable_to_non_nullable
as int?,enablePerspectiveView: freezed == enablePerspectiveView ? _self.enablePerspectiveView : enablePerspectiveView // ignore: cast_nullable_to_non_nullable
as bool?,enableFlatView: freezed == enableFlatView ? _self.enableFlatView : enableFlatView // ignore: cast_nullable_to_non_nullable
as bool?,enableFreeFlightView: freezed == enableFreeFlightView ? _self.enableFreeFlightView : enableFreeFlightView // ignore: cast_nullable_to_non_nullable
as bool?,enableHires: freezed == enableHires ? _self.enableHires : enableHires // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}

/// Create a copy of MapConfigModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$Vector2XZCopyWith<$Res> get startPos {
  
  return $Vector2XZCopyWith<$Res>(_self.startPos, (value) {
    return _then(_self.copyWith(startPos: value));
  });
}
}

// dart format on

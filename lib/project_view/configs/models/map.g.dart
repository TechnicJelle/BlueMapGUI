// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: type=lint, unused_field

part of 'map.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Vector2XZ _$Vector2XZFromJson(Map<String, dynamic> json) =>
    _Vector2XZ(x: (json['x'] as num).toInt(), z: (json['z'] as num).toInt());

abstract final class _$Vector2XZJsonKeys {
  static const String x = 'x';
  static const String z = 'z';
}

Map<String, dynamic> _$Vector2XZToJson(_Vector2XZ instance) =>
    <String, dynamic>{'x': instance.x, 'z': instance.z};

_MapConfigModel _$MapConfigModelFromJson(
  Map<String, dynamic> json,
) => _MapConfigModel(
  world: json['world'] as String,
  dimension: json['dimension'] as String,
  name: json['name'] as String,
  sorting: (json['sorting'] as num).toInt(),
  startPos: json['start-pos'] == null
      ? null
      : Vector2XZ.fromJson(json['start-pos'] as Map<String, dynamic>),
  skyColor: json['sky-color'] as String,
  voidColor: json['void-color'] as String,
  skyLight: (json['sky-light'] as num?)?.toDouble(),
  ambientLight: (json['ambient-light'] as num).toDouble(),
  removeCavesBelowY: (json['remove-caves-below-y'] as num).toInt(),
  caveDetectionOceanFloor: (json['cave-detection-ocean-floor'] as num).toInt(),
  caveDetectionUsesBlockLight: json['cave-detection-uses-block-light'] as bool,
  minInhabitedTime: (json['min-inhabited-time'] as num).toInt(),
  enablePerspectiveView: json['enable-perspective-view'] as bool?,
  enableFlatView: json['enable-flat-view'] as bool?,
  enableFreeFlightView: json['enable-free-flight-view'] as bool?,
  enableHires: json['enable-hires'] as bool?,
  ignoreMissingLightData: json['ignore-missing-light-data'] as bool,
);

abstract final class _$MapConfigModelJsonKeys {
  static const String world = 'world';
  static const String dimension = 'dimension';
  static const String name = 'name';
  static const String sorting = 'sorting';
  static const String startPos = 'start-pos';
  static const String skyColor = 'sky-color';
  static const String voidColor = 'void-color';
  static const String skyLight = 'sky-light';
  static const String ambientLight = 'ambient-light';
  static const String removeCavesBelowY = 'remove-caves-below-y';
  static const String caveDetectionOceanFloor = 'cave-detection-ocean-floor';
  static const String caveDetectionUsesBlockLight =
      'cave-detection-uses-block-light';
  static const String minInhabitedTime = 'min-inhabited-time';
  static const String enablePerspectiveView = 'enable-perspective-view';
  static const String enableFlatView = 'enable-flat-view';
  static const String enableFreeFlightView = 'enable-free-flight-view';
  static const String enableHires = 'enable-hires';
  static const String ignoreMissingLightData = 'ignore-missing-light-data';
}

Map<String, dynamic> _$MapConfigModelToJson(_MapConfigModel instance) =>
    <String, dynamic>{
      'world': instance.world,
      'dimension': instance.dimension,
      'name': instance.name,
      'sorting': instance.sorting,
      'start-pos': instance.startPos,
      'sky-color': instance.skyColor,
      'void-color': instance.voidColor,
      'sky-light': instance.skyLight,
      'ambient-light': instance.ambientLight,
      'remove-caves-below-y': instance.removeCavesBelowY,
      'cave-detection-ocean-floor': instance.caveDetectionOceanFloor,
      'cave-detection-uses-block-light': instance.caveDetectionUsesBlockLight,
      'min-inhabited-time': instance.minInhabitedTime,
      'enable-perspective-view': instance.enablePerspectiveView,
      'enable-flat-view': instance.enableFlatView,
      'enable-free-flight-view': instance.enableFreeFlightView,
      'enable-hires': instance.enableHires,
      'ignore-missing-light-data': instance.ignoreMissingLightData,
    };

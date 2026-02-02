import "dart:convert";

import "package:freezed_annotation/freezed_annotation.dart";

import "base.dart";

part "map.freezed.dart";
part "map.g.dart";

@freezed
abstract class Vector2XZ with _$Vector2XZ {
  const factory Vector2XZ({
    required int x,
    required int z,
  }) = _Vector2XZ;

  const Vector2XZ._();

  factory Vector2XZ.fromJson(Map<String, Object?> json) => _$Vector2XZFromJson(json);

  static final RegExp _jsonToHoconRegex = RegExp(r'{"x":(-?\d+),"z":(-?\d+)}');

  String toHocon() => jsonEncode(this).replaceFirstMapped(
    _jsonToHoconRegex,
    (Match match) => "{ x: ${match[1]}, z: ${match[2]} }",
  );
}

typedef Vector2XZKeys = _$Vector2XZJsonKeys;

@freezed
abstract class MapConfigModel extends BaseConfigModel with _$MapConfigModel {
  static const int cavesEnabledY = -10000;

  const factory MapConfigModel({
    required String world,
    required String dimension,

    required String name,

    required int sorting,

    required Vector2XZ startPos,

    required String skyColor,
    required String voidColor,

    required double? skyLight,
    required double ambientLight,

    required int removeCavesBelowY,
    required int caveDetectionOceanFloor,
    required bool caveDetectionUsesBlockLight,

    required int minInhabitedTime,

    required bool? enablePerspectiveView,
    required bool? enableFlatView,
    required bool? enableFreeFlightView,

    required bool? enableHires,
    required bool ignoreMissingLightData,
  }) = _MapConfigModel;

  const MapConfigModel._();

  factory MapConfigModel.fromJson(Map<String, Object?> json) =>
      _$MapConfigModelFromJson(json);

  String skyLightHocon() => _lightHocon(getSkyLight);

  String ambientLightHocon() => _lightHocon(ambientLight);

  static String _lightHocon(double light) {
    if (light == 0 || light == 1) return jsonEncode(light.toInt());
    return jsonEncode(light.toStringAsFixed(2)).replaceAll('"', "");
  }

  //non-null defaults
  double get getSkyLight => skyLight ?? 1;

  bool get getPerspectiveView => enablePerspectiveView ?? true;

  bool get getFlatView => enableFlatView ?? true;

  bool get getFreeFlightView => enableFreeFlightView ?? true;

  bool get getHiRes => enableHires ?? true;
}

typedef MapConfigKeys = _$MapConfigModelJsonKeys;

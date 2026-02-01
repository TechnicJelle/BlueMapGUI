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

    required bool renderEdges,
    required int? edgeLightStrength,

    required bool? enablePerspectiveView,
    required bool? enableFlatView,
    required bool? enableFreeFlightView,

    required bool? enableHires,
    required bool ignoreMissingLightData,
  }) = _MapConfigModel;

  const MapConfigModel._();

  factory MapConfigModel.fromJson(Map<String, Object?> json) =>
      _$MapConfigModelFromJson(json);

  String skyLightHocon() => _lightHocon(skyLight);

  String ambientLightHocon() => _lightHocon(ambientLight);

  static String _lightHocon(double? light) {
    final double thisLight = light ?? 1;
    if (thisLight == 0 || thisLight == 1) return jsonEncode(thisLight.toInt());
    return jsonEncode(thisLight.toStringAsFixed(2)).replaceAll('"', "");
  }
}

typedef MapConfigKeys = _$MapConfigModelJsonKeys;

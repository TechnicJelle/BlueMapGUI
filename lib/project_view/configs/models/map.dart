import "package:freezed_annotation/freezed_annotation.dart";

import "base.dart";

part "map.freezed.dart";
part "map.g.dart";

@freezed
abstract class MapConfigModel extends BaseConfigModel with _$MapConfigModel {
  const factory MapConfigModel({
    required String world,
    required String dimension,

    required String name,

    required int sorting,

    required String skyColor,
    required String voidColor,

    required double skyLight,
    required double ambientLight,

    required int removeCavesBelowY,
    required int caveDetectionOceanFloor,
    required bool caveDetectionUsesBlockLight,

    required int minInhabitedTime,

    required bool renderEdges,
    required int edgeLightStrength,

    required bool enablePerspectiveView,
    required bool enableFlatView,
    required bool enableFreeFlightView,

    required bool enableHires,
  }) = _MapConfigModel;

  const MapConfigModel._();

  factory MapConfigModel.fromJson(Map<String, dynamic> json) =>
      _$MapConfigModelFromJson(json);
}

typedef MapConfigKeys = _$MapConfigModelJsonKeys;

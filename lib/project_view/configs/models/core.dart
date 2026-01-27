import "package:freezed_annotation/freezed_annotation.dart";

import "base.dart";

part "core.freezed.dart";
part "core.g.dart";

@freezed
abstract class CoreConfigModel extends BaseConfigModel with _$CoreConfigModel {
  const factory CoreConfigModel({
    required bool acceptDownload,
    required int renderThreadCount,
  }) = _CoreConfigModel;

  const CoreConfigModel._();

  factory CoreConfigModel.fromJson(Map<String, Object?> json) =>
      _$CoreConfigModelFromJson(json);
}

typedef CoreConfigKeys = _$CoreConfigModelJsonKeys;

import "package:freezed_annotation/freezed_annotation.dart";

import "base.dart";

part "startup.freezed.dart";
part "startup.g.dart";

@freezed
abstract class StartupConfigModel extends BaseConfigModel with _$StartupConfigModel {
  const factory({
    required String modsPath,
    required String minecraftVersion,
    required String maxRamLimit,
  }) = _StartupConfigModel;

  const new _();

  factory fromJson(Map<String, Object?> json) => _$StartupConfigModelFromJson(json);
}

typedef StartupConfigKeys = _$StartupConfigModelJsonKeys;

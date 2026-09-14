import "package:freezed_annotation/freezed_annotation.dart";

import "base.dart";

part "webapp.freezed.dart";
part "webapp.g.dart";

@freezed
abstract class WebappConfigModel extends BaseConfigModel with _$WebappConfigModel {
  const factory({
    required bool defaultToFlatView,
  }) = _WebappConfigModel;

  const new _();

  factory fromJson(Map<String, Object?> json) => _$WebappConfigModelFromJson(json);
}

typedef WebappConfigKeys = _$WebappConfigModelJsonKeys;

import "package:freezed_annotation/freezed_annotation.dart";

import "base.dart";

part "webapp.freezed.dart";
part "webapp.g.dart";

@freezed
abstract class WebappConfigModel extends BaseConfigModel with _$WebappConfigModel {
  const factory WebappConfigModel({
    required bool defaultToFlatView,
  }) = _WebappConfigModel;

  const WebappConfigModel._();

  factory WebappConfigModel.fromJson(Map<String, Object?> json) =>
      _$WebappConfigModelFromJson(json);
}

typedef WebappConfigKeys = _$WebappConfigModelJsonKeys;

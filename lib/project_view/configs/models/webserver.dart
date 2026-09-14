import "package:freezed_annotation/freezed_annotation.dart";

import "base.dart";

part "webserver.freezed.dart";
part "webserver.g.dart";

@freezed
abstract class WebserverConfigModel extends BaseConfigModel with _$WebserverConfigModel {
  const factory({
    required int port,
  }) = _WebserverConfigModel;

  const new _();

  factory fromJson(Map<String, Object?> json) => _$WebserverConfigModelFromJson(json);
}

typedef WebserverConfigKeys = _$WebserverConfigModelJsonKeys;

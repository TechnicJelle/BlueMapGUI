import "package:freezed_annotation/freezed_annotation.dart";

import "base.dart";

part "webserver.freezed.dart";
part "webserver.g.dart";

@freezed
abstract class WebserverConfigModel extends BaseConfigModel with _$WebserverConfigModel {
  const factory WebserverConfigModel({
    required int port,
  }) = _WebserverConfigModel;

  const WebserverConfigModel._();

  factory WebserverConfigModel.fromJson(Map<String, dynamic> json) =>
      _$WebserverConfigModelFromJson(json);
}

typedef WebserverConfigKeys = _$WebserverConfigModelJsonKeys;

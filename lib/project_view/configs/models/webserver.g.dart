// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: type=lint, unused_field

part of 'webserver.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WebserverConfigModel _$WebserverConfigModelFromJson(
  Map<String, dynamic> json,
) => _WebserverConfigModel(port: (json['port'] as num).toInt());

abstract final class _$WebserverConfigModelJsonKeys {
  static const String port = 'port';
}

Map<String, dynamic> _$WebserverConfigModelToJson(
  _WebserverConfigModel instance,
) => <String, dynamic>{'port': instance.port};

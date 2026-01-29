// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: type=lint, unused_field

part of 'core.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CoreConfigModel _$CoreConfigModelFromJson(Map<String, dynamic> json) =>
    _CoreConfigModel(
      acceptDownload: json['accept-download'] as bool,
      renderThreadCount: (json['render-thread-count'] as num).toInt(),
    );

abstract final class _$CoreConfigModelJsonKeys {
  static const String acceptDownload = 'accept-download';
  static const String renderThreadCount = 'render-thread-count';
}

Map<String, dynamic> _$CoreConfigModelToJson(_CoreConfigModel instance) =>
    <String, dynamic>{
      'accept-download': instance.acceptDownload,
      'render-thread-count': instance.renderThreadCount,
    };

// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: type=lint, unused_field

part of 'startup.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_StartupConfigModel _$StartupConfigModelFromJson(Map<String, dynamic> json) =>
    _StartupConfigModel(
      modsPath: json['mods-path'] as String,
      minecraftVersion: json['minecraft-version'] as String,
      maxRamLimit: json['max-ram-limit'] as String,
    );

abstract final class _$StartupConfigModelJsonKeys {
  static const String modsPath = 'mods-path';
  static const String minecraftVersion = 'minecraft-version';
  static const String maxRamLimit = 'max-ram-limit';
}

Map<String, dynamic> _$StartupConfigModelToJson(_StartupConfigModel instance) =>
    <String, dynamic>{
      'mods-path': instance.modsPath,
      'minecraft-version': instance.minecraftVersion,
      'max-ram-limit': instance.maxRamLimit,
    };

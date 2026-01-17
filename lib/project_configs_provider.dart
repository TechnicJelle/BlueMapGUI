import "dart:async";
import "dart:io";

import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:freezed_annotation/freezed_annotation.dart";
import "package:path/path.dart" as p;

import "prefs.dart";
import "project_view/configs/models/base.dart";
import "project_view/configs/models/map.dart";

part "project_configs_provider.freezed.dart";

@freezed
abstract class ProjectConfigs with _$ProjectConfigs {
  const factory ProjectConfigs({
    required Directory projectLocation,
    required List<ConfigFile<BaseConfigModel>> mainConfigs,
    required List<ConfigFile<MapConfigModel>> mapConfigs,
    required ConfigFile? openConfig,
  }) = _ProjectConfigs;
}

class ProjectConfigsNotifier extends Notifier<ProjectConfigs?> {
  @override
  ProjectConfigs? build() {
    return null;
  }

  Future<void> openProject(Directory projectDirectory) async {
    final List<ConfigFile<BaseConfigModel>> mainConfigs = [];
    final List<ConfigFile<MapConfigModel>> mapConfigs = [];
    final String projectPath = projectDirectory.path;
    final Directory configDir = Directory(p.join(projectPath, "config"));

    final JavaPath javaPath = ref.read(javaPathProvider)!;
    await for (final FileSystemEntity entity in configDir.list()) {
      if (entity is File && entity.path.endsWith(".conf")) {
        final ConfigFile? configFile = await ConfigFile.fromFile(entity, javaPath);
        if (configFile == null) continue;
        mainConfigs.add(configFile);
      }

      if (entity is Directory) {
        if (p.basename(entity.path) == "maps") {
          await for (final FileSystemEntity map in entity.list()) {
            if (map is File && map.path.endsWith(".conf")) {
              final ConfigFile? configFile = await ConfigFile.fromFile(map, javaPath);
              if (configFile == null) continue;
              final MapConfigModel model = configFile.model as MapConfigModel;
              mapConfigs.add(ConfigFile(map, model));
            }
          }
        }
      }
    }

    //sort main configs alphabetically
    mainConfigs.sort((a, b) => a.path.compareTo(b.path));
    //TODO: Sort map configs according to their `sorting` property
    state = ProjectConfigs(
      projectLocation: projectDirectory,
      mainConfigs: mainConfigs,
      mapConfigs: mapConfigs,
      openConfig: null,
    );
  }

  void closeProject() {
    state = null;
  }

  void openConfig(ConfigFile toOpen) {
    state = state?.copyWith(openConfig: toOpen);
  }

  void closeConfig() {
    state = state?.copyWith(openConfig: null);
  }

  void addMap(ConfigFile<MapConfigModel> newMapConfig) {
    final ProjectConfigs project = state!;
    state = project.copyWith(
      mapConfigs: [...project.mapConfigs, newMapConfig],
      openConfig: newMapConfig,
    );
  }

  ///Does not show a popup to ask for confirmation, as that is the responsibility of the caller!
  void deleteMap(ConfigFile mapConfigToDelete) {
    final ProjectConfigs project = state!;
    final Directory projectDirectory = project.projectLocation;

    // == If the editor is open on this config file, close it ==
    final ConfigFile? openConfig = project.openConfig;
    if (openConfig != null && p.equals(openConfig.path, mapConfigToDelete.path)) {
      closeConfig();
    }

    final List<ConfigFile<MapConfigModel>> newMapsList = project.mapConfigs.where(
      (ConfigFile<MapConfigModel> element) {
        return !p.equals(element.path, mapConfigToDelete.path);
      },
    ).toList();
    state = project.copyWith(mapConfigs: newMapsList);

    // == Delete the config file and the rendered map data ==
    //delete the file next frame, to ensure the editor is closed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(mapConfigToDelete.file.delete());

      final String mapID = p.basenameWithoutExtension(mapConfigToDelete.path);
      final Directory mapDirectory = Directory(
        p.join(projectDirectory.path, "web", "maps", mapID),
      );
      if (mapDirectory.existsSync()) {
        unawaited(mapDirectory.delete(recursive: true));
      }
    });
  }

  void swapMaps(int oldIndex, int newIndex) {
    final List<ConfigFile<MapConfigModel>> maps = [...state!.mapConfigs];
    if (oldIndex < newIndex) newIndex -= 1; //TODO: Fix this warning
    final removed = maps.removeAt(oldIndex);
    maps.insert(newIndex, removed);
    state = state!.copyWith(mapConfigs: maps);
  }
}

// I don't want these for providers; too long
// ignore: specify_nonobvious_property_types
final projectProvider = NotifierProvider(ProjectConfigsNotifier.new);
// I don't want these for providers; too long
// ignore: specify_nonobvious_property_types
final openConfigProvider = projectProvider.select((project) => project?.openConfig);

import "dart:async";
import "dart:convert";
import "dart:io";

import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_riverpod/misc.dart";
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

    final List<File> configFiles = [];
    final JavaPath javaPath = ref.read(javaPathProvider)!;
    await for (final FileSystemEntity entity in configDir.list()) {
      if (entity is File && entity.path.endsWith(".conf")) {
        configFiles.add(entity);
      }

      if (entity is Directory) {
        if (p.basename(entity.path) == "maps") {
          await for (final FileSystemEntity map in entity.list()) {
            if (map is File && map.path.endsWith(".conf")) {
              configFiles.add(map);
            }
          }
        }
      }
    }

    final configs = await ConfigFile.fromFiles(configFiles, javaPath);
    for (final ConfigFile config in configs) {
      if (config.model is MapConfigModel) {
        final MapConfigModel model = config.model as MapConfigModel;
        mapConfigs.add(ConfigFile(config.file, model));
      } else {
        mainConfigs.add(config);
      }
    }

    _sortMains(mainConfigs);
    _sortMaps(mapConfigs);

    state = ProjectConfigs(
      projectLocation: projectDirectory,
      mainConfigs: mainConfigs,
      mapConfigs: mapConfigs,
      openConfig: null,
    );
  }

  ///sort main configs alphabetically
  static List<ConfigFile> _sortMains(List<ConfigFile> list) {
    list.sort((a, b) => a.path.compareTo(b.path));
    return list;
  }

  ///sort map configs based on internal sorting value
  static List<ConfigFile<MapConfigModel>> _sortMaps(
    List<ConfigFile<MapConfigModel>> list,
  ) {
    list.sort((a, b) => a.model.sorting.compareTo(b.model.sorting));
    return list;
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
    // == If the editor is open on this config file, close it ==
    final ConfigFile? openConfig = state!.openConfig;
    if (openConfig != null && p.equals(openConfig.path, mapConfigToDelete.path)) {
      closeConfig();
    }

    state = state!.copyWith(
      mapConfigs: _copyListWithout(state!.mapConfigs, mapConfigToDelete.file),
    );

    // == Delete the config file and the rendered map data ==
    //delete the file next frame, to ensure the editor is closed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(mapConfigToDelete.file.delete());

      final String mapID = p.basenameWithoutExtension(mapConfigToDelete.path);
      final Directory mapDirectory = Directory(
        p.join(state!.projectLocation.path, "web", "maps", mapID),
      );
      if (mapDirectory.existsSync()) {
        unawaited(mapDirectory.delete(recursive: true));
      }
    });
  }

  static List<ConfigFile<T>> _copyListWithout<T extends BaseConfigModel>(
    List<ConfigFile<T>> list,
    File file,
  ) => list.where((ConfigFile element) => !p.equals(element.path, file.path)).toList();

  void swapMaps(int oldIndex, int newIndex) {
    final File? openConfig = state!.openConfig?.file;
    final List<ConfigFile<MapConfigModel>> maps = [...state!.mapConfigs];
    final int localNewIndex = oldIndex < newIndex ? newIndex - 1 : newIndex;
    final removed = maps.removeAt(oldIndex);
    maps.insert(localNewIndex, removed);
    for (int i = 0; i < maps.length; i++) {
      final ConfigFile<MapConfigModel> mapConfig = maps[i];
      maps[i] = ConfigFile(mapConfig.file, mapConfig.model.copyWith(sorting: i * 100));
    }

    state = state!.copyWith(mapConfigs: maps);

    //cannot happen at the same time, because  ↓  relies on the maps being set in the state
    state = state!.copyWith(openConfig: findConfigToFile(openConfig));

    for (final mapConfig in state!.mapConfigs) {
      mapConfig.changeValueInFile(
        MapConfigKeys.sorting,
        jsonEncode(mapConfig.model.sorting),
      );
    }
  }

  ConfigFile? findConfigToFile(File? file) {
    if (file == null) return null;
    return <ConfigFile?>[...state!.mainConfigs, ...state!.mapConfigs].singleWhere(
      (ConfigFile? config) => p.equals(config!.path, file.path),
      orElse: () => null,
    );
  }

  ///triggers the mechanism to reload the config file into a model and store it in the state
  Future<void> refreshConfigFile(File file) async {
    final JavaPath javaPath = ref.read(javaPathProvider)!;

    //is this a main config to update?
    final mainConfigToUpdate = await _refreshConfig(file, state!.mainConfigs, javaPath);
    if (mainConfigToUpdate != null) {
      state = state!.copyWith(
        mainConfigs: _sortMains(
          _copyListWithout(state!.mainConfigs, file)..add(mainConfigToUpdate),
        ),
      );
    }

    //or is this a map config to update?
    final mapConfigToUpdate = await _refreshConfig(file, state!.mapConfigs, javaPath);
    if (mapConfigToUpdate != null) {
      state = state!.copyWith(
        mapConfigs: _sortMaps(
          _copyListWithout(state!.mapConfigs, file)..add(mapConfigToUpdate),
        ),
      );
    }

    //if this file was open, we need to update that too
    if (p.equals(file.path, state!.openConfig?.path ?? "")) {
      state = state!.copyWith(openConfig: mainConfigToUpdate ?? mapConfigToUpdate);
    }
  }

  ///reusable function for both main and map configs
  static Future<ConfigFile<T>?> _refreshConfig<T extends BaseConfigModel>(
    File file,
    List<ConfigFile<T>> list,
    JavaPath javaPath,
  ) async {
    for (final ConfigFile config in list) {
      if (p.equals(file.path, config.path)) {
        final config = await ConfigFile.fromFile(file, javaPath);
        return ConfigFile(file, config.model as T);
      }
    }
    return null;
  }
}

///If I want to use a value from here, make a new provider that .select()s it.
// I don't want these for providers; too long
// ignore: specify_nonobvious_property_types
final _projectProvider = NotifierProvider(ProjectConfigsNotifier.new);

// I don't want these for notifiers; too long
// ignore: specify_nonobvious_property_types
final projectProviderNotifier = _projectProvider.notifier;

// I don't want these for providers; too long
// ignore: specify_nonobvious_property_types
final openProjectProvider = _projectProvider.select((proj) => proj?.projectLocation);

// I don't want these for providers; too long
// ignore: specify_nonobvious_property_types
final openConfigProvider = _projectProvider.select((proj) => proj?.openConfig);

///do not use for map configs; only for main configs
ProviderListenable<ConfigFile<BaseConfigModel>?> createTypedOpenConfigProvider<T>() =>
    openConfigProvider.select((value) => value?.model is T ? value : null);

// I don't want these for providers; too long
// ignore: specify_nonobvious_property_types
final mainConfigsProvider = _projectProvider.select((proj) => proj?.mainConfigs);

// I don't want these for providers; too long
// ignore: specify_nonobvious_property_types
final mapConfigsProvider = _projectProvider.select((proj) => proj?.mapConfigs);

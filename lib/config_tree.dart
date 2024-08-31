import "dart:io";

import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:path/path.dart" as p;

import "config_tile.dart";
import "dual_pane.dart";
import "main.dart";
import "map_tile.dart";
import "new_map_button.dart";

class ConfigTree extends ConsumerStatefulWidget {
  const ConfigTree({super.key});

  @override
  ConsumerState<ConfigTree> createState() => _ConfigTreeState();
}

class _ConfigTreeState extends ConsumerState<ConfigTree> {
  final List<File> configs = [];
  final List<File> storages = [];
  final List<File> maps = [];

  @override
  void initState() {
    super.initState();
    final Directory projectDirectory = ref.read(projectDirectoryProvider)!;
    final String projectPath = projectDirectory.path;
    final Directory configDir = Directory(p.join(projectPath, "config"));
    for (final FileSystemEntity entity in configDir.listSync()) {
      if (entity is File) {
        configs.add(entity);
      }

      if (entity is Directory) {
        if (p.basename(entity.path) == "storages") {
          for (final FileSystemEntity storage in entity.listSync()) {
            if (storage is File) {
              storages.add(storage);
            }
          }
        }
        if (p.basename(entity.path) == "maps") {
          for (final FileSystemEntity map in entity.listSync()) {
            if (map is File) {
              maps.add(map);
            }
          }

          //watch for changes to files in the maps directory
          entity
              .watch(events: FileSystemEvent.create | FileSystemEvent.delete)
              .listen((FileSystemEvent event) {
            switch (event.type) {
              case FileSystemEvent.create:
                addMap(File(event.path));
                break;
              case FileSystemEvent.delete:
                removeMap(File(event.path));
                break;
            }
          });
        }
      }
    }

    //sort all lists alphabetically
    configs.sort((a, b) => a.path.compareTo(b.path));
    storages.sort((a, b) => a.path.compareTo(b.path));
    sortMaps();
  }

  void addMap(File newMap) {
    setState(() {
      maps.add(newMap);
      sortMaps();
    });
  }

  void removeMap(File toRemoveMap) {
    setState(() {
      maps.removeWhere((File map) => p.equals(map.path, toRemoveMap.path));
      sortMaps();
    });
  }

  void sortMaps() {
    //TODO: Sort maps based on internal `sorting` property
    maps.sort((a, b) => a.path.compareTo(b.path));
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const _ControlPanelTile(),
        const Text("Configs"),
        for (final File config in configs) ConfigTile(config),
        const Text("Storages"),
        for (final File storage in storages) ConfigTile(storage),
        const Text("Maps"),
        for (final File map in maps) MapTile(map),
        const NewMapButton(),
      ],
    );
  }
}

class _ControlPanelTile extends ConsumerWidget {
  const _ControlPanelTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final File? openConfig = ref.watch(openConfigProvider);

    return ListTile(
      title: const Text("Control Panel"),
      onTap: () {
        ref.read(openConfigProvider.notifier).close();
      },
      selected: openConfig == null,
    );
  }
}

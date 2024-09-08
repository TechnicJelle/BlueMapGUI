import "dart:async";
import "dart:io";

import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:path/path.dart" as p;

import "../../prefs.dart";
import "../project_view.dart";
import "config_tile.dart";
import "map_tile.dart";
import "new_map_button.dart";

///Group 1: Is commented?
///Group 2: Actual sorting value
final RegExp sortingRegex = RegExp(
  r"^(#|//)*\s*sorting\s*:\s*(-?\d+)",
  multiLine: true,
);

class Sidebar extends ConsumerStatefulWidget {
  const Sidebar({super.key});

  @override
  ConsumerState<Sidebar> createState() => _ConfigTreeState();
}

class _ConfigTreeState extends ConsumerState<Sidebar> {
  final List<File> configs = [];
  final List<File> storages = [];
  final List<File> maps = [];

  final List<StreamSubscription<FileSystemEvent>> subscriptions = [];

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
          final sub = entity
              .watch(
                  events: FileSystemEvent.create |
                      FileSystemEvent.delete |
                      FileSystemEvent.move |
                      FileSystemEvent.modify)
              .listen((FileSystemEvent event) {
            switch (event.type) {
              case FileSystemEvent.create:
                addMap(File(event.path));
                break;
              case FileSystemEvent.delete:
                removeMap(File(event.path));
                break;
              case FileSystemEvent.move:
                final FileSystemMoveEvent moveEvent = event as FileSystemMoveEvent;
                String? destination = moveEvent.destination;
                if (destination != null) {
                  removeMap(File(moveEvent.path));
                  addMap(File(destination));

                  final String prevMapID = p.basenameWithoutExtension(moveEvent.path);
                  final String nextMapID = p.basenameWithoutExtension(destination);

                  //Also rename the map data directory:
                  final Directory mapDataDir =
                      Directory(p.join(projectPath, "web", "maps", prevMapID));
                  if (mapDataDir.existsSync()) {
                    mapDataDir.rename(p.join(projectPath, "web", "maps", nextMapID));
                  }
                } else {
                  //could not get destination, so we nuke everything and re-add it all
                  maps.clear();
                  for (final FileSystemEntity map in entity.listSync()) {
                    if (map is File) {
                      maps.add(map);
                    }
                  }
                }
                break;
              case FileSystemEvent.modify:
                final FileSystemModifyEvent modifyEvent = event as FileSystemModifyEvent;
                if (!modifyEvent.contentChanged) return;
                sortMaps();
                break;
            }
          });
          subscriptions.add(sub);
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

  void sortMaps() async {
    final Map<File, int> mapSortings = {};
    await Future.wait(maps.map((File map) async {
      final String contents = await map.readAsString();
      final Match? match = sortingRegex.firstMatch(contents);
      if (match != null) {
        final String? comment = match.group(1);
        final bool commented = comment != null && comment.isNotEmpty;
        if (commented) {
          mapSortings[map] = 0;
        } else {
          final int sorting = int.parse(match.group(2) ?? "0");
          mapSortings[map] = sorting;
        }
      } else {
        mapSortings[map] = 0;
      }
    }));

    setState(() {
      maps.sort((a, b) {
        int? sortingA = mapSortings[a];
        int? sortingB = mapSortings[b];
        if (sortingA == null) throw Exception("Map $a has no sorting!");
        if (sortingB == null) throw Exception("Map $b has no sorting!");

        //if sort value is the same, sort by path
        //this at least keep it consistent, instead of random
        if (sortingA == sortingB) {
          return a.path.compareTo(b.path);
        }

        return sortingA.compareTo(sortingB);
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    for (var sub in subscriptions) {
      sub.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const _ControlPanelTile(),
        const Text(" Configs"),
        for (final File config in configs) ConfigTile(config),
        const Text(" Storages"),
        for (final File storage in storages) ConfigTile(storage),
        const Text(" Maps"),
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
import "dart:io";

import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:path/path.dart" as p;

import "../project_view.dart";

class MapTile extends ConsumerStatefulWidget {
  final File configFile;

  const MapTile(this.configFile, {super.key});

  @override
  ConsumerState<MapTile> createState() => _MapTileState();
}

class _MapTileState extends ConsumerState<MapTile> {
  File get configFile => widget.configFile;

  @override
  Widget build(BuildContext context) {
    final File? openConfig = ref.watch(openConfigProvider);

    return ListTile(
      title: Text(p.basenameWithoutExtension(configFile.path)),
      onTap: () {
        ref.read(openConfigProvider.notifier).open(configFile);
      },
      selected: openConfig != null && p.equals(openConfig.path, configFile.path),
    );
  }
}

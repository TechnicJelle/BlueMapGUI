import "dart:io";

import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:path/path.dart" as p;

import "dual_pane.dart";

class MapTile extends ConsumerWidget {
  final File configFile;

  const MapTile(this.configFile, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final File? openConfig = ref.watch(openConfigProvider);

    return ListTile(
      trailing: IconButton(
        icon: const Icon(Icons.delete),
        onPressed: () {
          //TODO: Show confirmation dialog

          //close the editor if it's open on that file
          if (openConfig != null && p.equals(openConfig.path, configFile.path)) {
            ref.read(openConfigProvider.notifier).close();
          }
          //delete the file next frame, to ensure the editor is closed
          WidgetsBinding.instance.addPostFrameCallback((_) {
            configFile.delete();
          });
        },
      ),
      title: Text(_toHuman(configFile)),
      onTap: () {
        ref.read(openConfigProvider.notifier).open(configFile);
      },
      selected: openConfig != null && p.equals(openConfig.path, configFile.path),
    );
  }

  static String _toHuman(File file) {
    final String name = p.basename(file.path).replaceAll(".conf", "");
    if (name == "Sql") return "SQL";
    return name;
  }
}

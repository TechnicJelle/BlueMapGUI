import "dart:io";

import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:path/path.dart" as p;

import "dual_pane.dart";
import "utils.dart";

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
          showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("Delete map"),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Wrap(
                    children: [
                      const Text("Are you sure you want to delete the map \" "),
                      Text(
                        _toHuman(configFile),
                        style: pixelCode.copyWith(height: 1.4),
                      ),
                      const Text(" \" ?"),
                    ],
                  ),
                  const Text(
                    "This action cannot be undone!",
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const Text(
                    "However, you can just add the map again, as no unrecoverable data will be deleted.",
                  ),
                  const Text(
                    "Your Minecraft world data will not be affected by this action, only the BlueMap data.",
                  )
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text("Delete"),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text("Cancel"),
                ),
              ],
            ),
          ).then((bool? confirmed) {
            if (confirmed == null || confirmed == false) return;

            //if the editor is open on that file, close it
            if (openConfig != null && p.equals(openConfig.path, configFile.path)) {
              ref.read(openConfigProvider.notifier).close();
            }
            //delete the file next frame, to ensure the editor is closed
            WidgetsBinding.instance.addPostFrameCallback((_) {
              configFile.delete();
              //TODO: Also delete the rendered map data (check if it exists first)
              //($pwd/web/maps/map-id)
            });
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

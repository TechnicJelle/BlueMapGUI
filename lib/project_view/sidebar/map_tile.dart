import "dart:io";

import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:path/path.dart" as p;

import "../../confirmation_dialog.dart";
import "../../hover.dart";
import "../../main_menu/projects/projects_screen.dart";
import "../../utils.dart";
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

    return Hover(
      alwaysChild: ListTile(
        title: Text(_toHuman(configFile)),
        onTap: () {
          ref.read(openConfigProvider.notifier).open(configFile);
        },
        selected: openConfig != null && p.equals(openConfig.path, configFile.path),
      ),
      hoverChild: Positioned(
        right: 16,
        top: 5,
        child: PopupMenuButton(
          itemBuilder: (_) => <PopupMenuEntry>[
            PopupMenuItem(
              child: const Row(
                children: [
                  Icon(Icons.delete),
                  SizedBox(width: 8),
                  Text("Delete map"),
                ],
              ),
              onTap: () {
                showConfirmationDialog(
                  context: context,
                  title: "Delete map",
                  content: [
                    Wrap(
                      children: [
                        const Text("Are you sure you want to delete the map \" "),
                        Text(
                          _toHuman(configFile),
                          style: pixelCode.copyWith(height: 1.4),
                        ),
                        const SizedBox(width: 1),
                        const Text("\" ?"),
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
                    ),
                  ],
                  confirmAction: "Delete",
                  onConfirmed: () {
                    // == If the editor is open on that file, close it ==
                    if (openConfig != null &&
                        p.equals(openConfig.path, configFile.path)) {
                      ref.read(openConfigProvider.notifier).close();
                    }

                    // == Delete the config file and the rendered map data ==
                    final Directory? projectDirectory = ref.watch(openProjectProvider);
                    //delete the file next frame, to ensure the editor is closed
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      configFile.delete();

                      if (projectDirectory == null) return;
                      final String mapID = p.basenameWithoutExtension(configFile.path);
                      final Directory mapDirectory =
                          Directory(p.join(projectDirectory.path, "web", "maps", mapID));
                      if (mapDirectory.existsSync()) {
                        mapDirectory.delete(recursive: true);
                      }
                    });
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  static String _toHuman(File file) {
    final String name = p.basename(file.path).replaceAll(".conf", "");
    if (name == "Sql") return "SQL";
    return name;
  }
}

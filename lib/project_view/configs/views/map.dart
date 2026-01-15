import "dart:async";
import "dart:convert";
import "dart:io";

import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:path/path.dart" as p;

import "../../../confirmation_dialog.dart";
import "../../../main_menu/projects/projects_screen.dart";
import "../../../main_menu/settings/setting_heading.dart";
import "../../../utils.dart";
import "../../project_view.dart";
import "../models/base.dart";
import "../models/map.dart";
import "base.dart";

class MapConfigView extends StatefulWidget {
  final ConfigFile<MapConfigModel> configFile;

  const MapConfigView(this.configFile, {super.key});

  @override
  State<MapConfigView> createState() => _MapConfigViewState();
}

class _MapConfigViewState extends State<MapConfigView> {
  late MapConfigModel config = widget.configFile.model;
  late final String filename = p.basenameWithoutExtension(widget.configFile.file.path);

  late final TextEditingController worldController = TextEditingController(
    text: config.world,
  );
  late final TextEditingController dimensionController = TextEditingController(
    text: config.dimension,
  );
  late final TextEditingController nameController = TextEditingController(
    text: config.name,
  );

  @override
  void dispose() {
    validateAndSaveOptionsThatCannotBeBlank();
    worldController.dispose();
    dimensionController.dispose();
    nameController.dispose();
    super.dispose();
  }

  void validateAndSaveOptionsThatCannotBeBlank() {
    if (worldController.text.trim().isNotEmpty) {
      config = config.copyWith(world: worldController.text);
      widget.configFile.changeValueInFile(
        MapConfigKeys.world,
        jsonEncode(config.world),
      );
    }
    if (dimensionController.text.trim().isNotEmpty) {
      config = config.copyWith(dimension: dimensionController.text);
      widget.configFile.changeValueInFile(
        MapConfigKeys.dimension,
        jsonEncode(config.dimension),
      );
    }
    if (nameController.text.trim().isNotEmpty) {
      config = config.copyWith(name: nameController.text);
      widget.configFile.changeValueInFile(
        MapConfigKeys.name,
        jsonEncode(config.name),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const padding = EdgeInsets.only(bottom: 8);
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, top: 16, bottom: 12),
          child: Text(
            "Map Config: $filename",
            style: TextTheme.of(context).headlineMedium?.copyWith(
              color: TextTheme.of(context).titleSmall?.color,
            ),
          ),
        ),
        ListTile(
          title: SettingHeading(
            context,
            "World Path",
            padding: padding,
            const [
              SettingsBodyText(
                "The path to the save folder of the world to render.",
              ),
            ],
          ),
          subtitle: TextField(
            controller: worldController,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              hintText: "Must not be empty!",
              suffixIcon: PathPickerButton(
                purpose: "world",
                initialDirectory: config.world.isNotEmpty ? config.world : "~",
                onPicked: (String? path) {
                  if (path == null) return;
                  setState(() {
                    config = config.copyWith(
                      world: worldController.text = path,
                    );
                  });
                },
              ),
            ),
            onEditingComplete: () => setState(validateAndSaveOptionsThatCannotBeBlank),
          ),
        ),
        ListTile(
          title: SettingHeading(
            context,
            "Dimension",
            padding: padding,
            const [
              SettingsBodyText("The dimension of the world.\nCan be"),
              SettingsBodyCode(" minecraft:overworld"),
              SettingsBodyText(","),
              SettingsBodyCode(" minecraft:the_nether"),
              SettingsBodyText(","),
              SettingsBodyCode(" minecraft:the_end"),
              SettingsBodyText(
                ", or any dimension key introduced by a mod or datapack.",
              ),
            ],
          ),
          subtitle: TextField(
            controller: dimensionController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: "Must not be empty!",
            ),
            onEditingComplete: () => setState(validateAndSaveOptionsThatCannotBeBlank),
          ),
        ),
        ListTile(
          title: SettingHeading(
            context,
            "Map Name",
            padding: padding,
            const [
              SettingsBodyText(
                "The display name of this map (how this map will be named on the website).",
              ),
            ],
          ),
          subtitle: TextField(
            controller: nameController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: "Must not be empty!",
            ),
            onEditingComplete: () => setState(validateAndSaveOptionsThatCannotBeBlank),
          ),
        ),
        const SizedBox(height: 32),
        const Divider(
          color: Colors.red,
          indent: 16,
          endIndent: 16,
        ),
        DangerZone(widget.configFile.file),
        const SizedBox(height: 32),
      ],
    );
  }
}

class DangerZone extends ConsumerWidget {
  final File configFile;

  const DangerZone(this.configFile, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final File? openConfig = ref.watch(openConfigProvider);

    return ListTile(
      title: Row(
        mainAxisAlignment: .spaceBetween,
        children: [
          SettingHeading(
            context,
            "Delete Map",
            padding: EdgeInsets.zero,
            const [
              SettingsBodyText(
                "If you delete this map, it will be gone forever.\n"
                "Your actual world files will not be affected!\n"
                "But you can always create a new map that uses those same world files again.\n",
              ),
            ],
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              showConfirmationDialog(
                context: context,
                title: "Delete map",
                content: [
                  Wrap(
                    children: [
                      const Text("Are you sure you want to delete the map \" "),
                      Text(
                        p.basenameWithoutExtension(configFile.path),
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
                  if (openConfig != null && p.equals(openConfig.path, configFile.path)) {
                    ref.read(openConfigProvider.notifier).close();
                  }

                  // == Delete the config file and the rendered map data ==
                  final Directory? projectDirectory = ref.watch(openProjectProvider);
                  //delete the file next frame, to ensure the editor is closed
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    unawaited(configFile.delete());

                    if (projectDirectory == null) return;
                    final String mapID = p.basenameWithoutExtension(configFile.path);
                    final Directory mapDirectory = Directory(
                      p.join(projectDirectory.path, "web", "maps", mapID),
                    );
                    if (mapDirectory.existsSync()) {
                      unawaited(mapDirectory.delete(recursive: true));
                    }
                  });
                },
              );
            },
            child: const Text("Delete Map"),
          ),
        ],
      ),
    );
  }
}

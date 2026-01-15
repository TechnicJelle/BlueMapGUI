import "dart:convert";

import "package:flutter/material.dart";
import "package:path/path.dart" as p;

import "../../../main_menu/settings/setting_heading.dart";
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
      ],
    );
  }
}

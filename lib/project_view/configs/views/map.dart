import "dart:convert";

import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:path/path.dart" as p;

import "../../../confirmation_dialog.dart";
import "../../../main_menu/settings/setting_heading.dart";
import "../../../project_configs_provider.dart";
import "../../../utils.dart";
import "../models/base.dart";
import "../models/map.dart";
import "base.dart";

class MapConfigView extends ConsumerStatefulWidget {
  final ConfigFile<MapConfigModel> initialConfig;

  const MapConfigView(this.initialConfig, {super.key});

  @override
  ConsumerState<MapConfigView> createState() => _MapConfigViewState();
}

class _MapConfigViewState extends ConsumerState<MapConfigView> {
  ConfigFile<MapConfigModel>? configFile;

  MapConfigModel get model => configFile!.model;

  set model(MapConfigModel newModel) => configFile!.model = newModel;

  String get filename => p.basenameWithoutExtension(configFile!.path);

  late TextEditingController worldController;
  late TextEditingController dimensionController;
  late TextEditingController nameController;

  @override
  void initState() {
    super.initState();
    openConfigFile(widget.initialConfig);
  }

  @override
  void dispose() {
    validateAndSaveOptionsThatCannotBeBlank();
    worldController.dispose();
    dimensionController.dispose();
    nameController.dispose();
    super.dispose();
  }

  void openConfigFile(ConfigFile<MapConfigModel> newConfig) {
    //allow reopening of configs that are already open, to handle the sorting value changes

    //save and close previously open config
    if (configFile != null && configFile!.file.existsSync()) {
      validateAndSaveOptionsThatCannotBeBlank();
      worldController.dispose();
      dimensionController.dispose();
      nameController.dispose();
    }

    setState(() {
      configFile = newConfig;
      worldController = TextEditingController(text: model.world);
      dimensionController = TextEditingController(text: model.dimension);
      nameController = TextEditingController(text: model.name);
    });
  }

  void validateAndSaveOptionsThatCannotBeBlank() {
    if (worldController.text.trim().isNotEmpty) {
      model = model.copyWith(world: worldController.text);
      configFile!.changeValueInFile(
        MapConfigKeys.world,
        jsonEncode(model.world),
      );
    }
    if (dimensionController.text.trim().isNotEmpty) {
      model = model.copyWith(dimension: dimensionController.text);
      configFile!.changeValueInFile(
        MapConfigKeys.dimension,
        jsonEncode(model.dimension),
      );
    }
    if (nameController.text.trim().isNotEmpty) {
      model = model.copyWith(name: nameController.text);
      configFile!.changeValueInFile(
        MapConfigKeys.name,
        jsonEncode(model.name),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ConfigFile<MapConfigModel> openConfig = ref.watch(
      openConfigProvider.select((value) {
        if (value is ConfigFile<MapConfigModel>) return value;
        return null;
      }),
    )!;
    openConfigFile(openConfig);

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
                initialDirectory: model.world.isNotEmpty ? model.world : "~",
                onPicked: (String? path) {
                  if (path == null) return;
                  setState(() {
                    model = model.copyWith(
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
        DangerZone(configFile!),
        const SizedBox(height: 32),
      ],
    );
  }
}

class DangerZone extends ConsumerWidget {
  final ConfigFile configFile;

  const DangerZone(this.configFile, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                  ref.read(projectProviderNotifier).deleteMap(configFile);
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

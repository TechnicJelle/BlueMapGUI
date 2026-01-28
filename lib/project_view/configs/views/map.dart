import "dart:convert";

import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../../confirmation_dialog.dart";
import "../../../main_menu/settings/setting_heading.dart";
import "../../../project_configs_provider.dart";
import "../../../utils.dart";
import "../models/base.dart";
import "../models/map.dart";
import "base.dart";

class MapConfigView extends ConsumerStatefulWidget {
  const MapConfigView({super.key});

  @override
  ConsumerState<MapConfigView> createState() => _MapConfigViewState();
}

class _MapConfigViewState extends ConsumerState<MapConfigView> {
  ConfigFile<MapConfigModel>? configFile;

  MapConfigModel get model => configFile!.model;

  set model(MapConfigModel newModel) => configFile!.model = newModel;

  late TextEditingController worldController;
  late TextEditingController dimensionController;
  late TextEditingController nameController;

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
      openConfigProvider.select(
        (config) => config is ConfigFile<MapConfigModel> ? config : null,
      ),
    )!;
    openConfigFile(openConfig);

    const padding = EdgeInsets.only(bottom: 8);
    return ListView(
      padding: const .only(right: 16), //to give the scrollbar some space
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, top: 16, bottom: 12),
          child: Text(
            "Map Config: ${openConfig.name}",
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
        _DangerZone(configFile!),
      ],
    );
  }
}

class _DangerZone extends ConsumerWidget {
  final ConfigFile configFile;

  const _DangerZone(this.configFile);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const .symmetric(horizontal: 16, vertical: 32),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Text(
            "Danger zone",
            style: TextTheme.of(
              context,
            ).headlineSmall?.copyWith(fontWeight: .w500, fontSize: 25),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const .only(top: 8, right: 8),
            decoration: BoxDecoration(
              border: .all(color: Colors.red),
              borderRadius: .circular(12),
            ),
            child: Column(
              children: [
                _DangerButton(
                  title: "Delete Map",
                  text: const [
                    SettingsBodyText(
                      "If you delete this map, it will be gone forever.\n"
                      "Your actual world files will not be affected!\n"
                      "But you can always create a new map that uses those same world files again.\n",
                    ),
                  ],
                  buttonLabel: "Delete Map",
                  onPressed: () {
                    showConfirmationDialog(
                      context: context,
                      title: "Delete map",
                      content: [
                        Wrap(
                          children: [
                            const Text("Are you sure you want to delete the map \" "),
                            Text(
                              configFile.name,
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DangerButton extends StatelessWidget {
  final String title;
  final List<SettingsBodyBase> text;
  final String buttonLabel;
  final VoidCallback? onPressed;

  const _DangerButton({
    required this.title,
    required this.text,
    required this.buttonLabel,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Row(
        mainAxisAlignment: .spaceBetween,
        children: [
          SettingHeading(context, title, padding: EdgeInsets.zero, text),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
            ),
            onPressed: onPressed,
            child: Text(buttonLabel),
          ),
        ],
      ),
    );
  }
}

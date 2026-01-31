import "dart:convert";
import "dart:io";

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
  late TextEditingController startPosXController;
  late TextEditingController startPosZController;

  @override
  void dispose() {
    validateAndSaveOptionsThatCannotBeBlank();
    worldController.dispose();
    dimensionController.dispose();
    nameController.dispose();
    startPosXController.dispose();
    startPosZController.dispose();
    super.dispose();
  }

  void openConfigFile(ConfigFile<MapConfigModel> newConfig) {
    //don't open something that is already open.
    //if the sorting value were displayed anywhere in this MapConfigView, this would be a problem, but it is not :)
    if (p.equals(newConfig.path, configFile?.path ?? "")) return;

    //save and close previously open config
    if (configFile != null && configFile!.file.existsSync()) {
      validateAndSaveOptionsThatCannotBeBlank();
      worldController.dispose();
      dimensionController.dispose();
      nameController.dispose();
      startPosXController.dispose();
      startPosZController.dispose();
    }

    setState(() {
      configFile = newConfig;
      worldController = TextEditingController(text: model.world);
      dimensionController = TextEditingController(text: model.dimension);
      nameController = TextEditingController(text: model.name);
      startPosXController = TextEditingController(text: model.startPos.x.toString());
      startPosZController = TextEditingController(text: model.startPos.z.toString());
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
    if (startPosXController.text.trim().isNotEmpty) {
      model = model.copyWith(
        startPos: model.startPos.copyWith(x: int.parse(startPosXController.text)),
      );
      configFile!.changeValueInFile(
        MapConfigKeys.startPos,
        model.startPos.toHocon(),
      );
    }
    if (startPosZController.text.trim().isNotEmpty) {
      model = model.copyWith(
        startPos: model.startPos.copyWith(z: int.parse(startPosZController.text)),
      );
      configFile!.changeValueInFile(
        MapConfigKeys.startPos,
        model.startPos.toHocon(),
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

    return ListView(
      padding: const .only(right: 16), //to give the scrollbar some space
      children: [
        ConfigTitle(title: "Map Config: ${openConfig.name}"),
        TextFieldOption(
          title: "World Path",
          description: "The path to the save folder of the world to render.",
          controller: worldController,
          hintText: "Must not be empty!",
          button: PathPickerButton(
            purpose: "world",
            initialDirectory: model.world.isNotEmpty ? model.world : "~",
            onPicked: (String path) => setState(() {
              model = model.copyWith(world: worldController.text = path);
            }),
          ),
          onChanged: null,
          onEditingComplete: () => setState(validateAndSaveOptionsThatCannotBeBlank),
        ),
        TextFieldOption.customDescription(
          title: "Dimension",
          descriptionList: const [
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
          controller: dimensionController,
          hintText: "Must not be empty!",
          onChanged: null,
          onEditingComplete: () => setState(validateAndSaveOptionsThatCannotBeBlank),
        ),
        TextFieldOption(
          title: "Map Name",
          description:
              "The display name of this map (how this map will be named on the website).",
          controller: nameController,
          hintText: "Must not be empty!",
          onChanged: null,
          onEditingComplete: () => setState(validateAndSaveOptionsThatCannotBeBlank),
        ),
        Vector2XZOption(
          title: "Start Position",
          description:
              "The position in the world where the map will be centered on when you open it.",
          controllerX: startPosXController,
          controllerZ: startPosZController,
          onChanged: null,
          onEditingComplete: () => setState(validateAndSaveOptionsThatCannotBeBlank),
        ),
        ColourOption(
          title: "Sky Colour",
          description: "The colour of the sky.",
          colour: colorFromHexColour(model.skyColor),
          label: model.skyColor,
          onPicked: (Color colour, String hex) => setState(() {
            model = model.copyWith(skyColor: hex);
            configFile!.changeValueInFile(
              MapConfigKeys.skyColor,
              jsonEncode(model.skyColor),
            );
          }),
        ),
        ColourOption(
          title: "Void Colour",
          description: "The colour of the void.",
          colour: colorFromHexColour(model.voidColor),
          label: model.voidColor,
          onPicked: (Color colour, String hex) => setState(() {
            model = model.copyWith(voidColor: hex);
            configFile!.changeValueInFile(
              MapConfigKeys.voidColor,
              jsonEncode(model.voidColor),
            );
          }),
        ),
        DoubleSliderOption(
          title: "Sky Light",
          description: """
Defines the initial sky light strength the map will be set to when it is opened.
0 is no sky light, 1 is fully lit up.""",
          value: model.skyLight ?? 1,
          min: 0,
          max: 1,
          onChanged: (double value) => setState(() {
            model = model.copyWith(skyLight: value);
          }),
          onChangeEnd: (_) => configFile!.changeValueInFile(
            MapConfigKeys.skyLight,
            model.skyLightHocon(),
          ),
        ),
        DoubleSliderOption(
          title: "Ambient Light",
          description: """
Defines the ambient light strength that every block is receiving, regardless of the sunlight/blocklight.
0 is no ambient light, 1 is fully lit up.""",
          value: model.ambientLight,
          min: 0,
          max: 1,
          onChanged: (double value) => setState(() {
            model = model.copyWith(ambientLight: value);
          }),
          onChangeEnd: (_) => configFile!.changeValueInFile(
            MapConfigKeys.ambientLight,
            model.ambientLightHocon(),
          ),
        ),
        _DangerZone(configFile!),
      ],
    );
  }
}

class _DangerZone extends ConsumerStatefulWidget {
  final ConfigFile configFile;

  const _DangerZone(this.configFile);

  @override
  ConsumerState<_DangerZone> createState() => _DangerZoneState();
}

class _DangerZoneState extends ConsumerState<_DangerZone> {
  ConfigFile get configFile => widget.configFile;

  @override
  Widget build(BuildContext context) {
    final Directory projectDirectory = ref.watch(openProjectProvider)!;
    final Directory renderDataDirectory = Directory(
      p.join(projectDirectory.path, "web", "maps", configFile.name),
    );
    final renderDataDirectoryExists = renderDataDirectory.existsSync();
    return Padding(
      padding: const .symmetric(horizontal: 16, vertical: 32),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Text(
            "Danger zone",
            style: TextTheme.of(context).headlineSmall?.copyWith(
              fontWeight: .w500,
              fontSize: 25,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const .symmetric(vertical: 8),
            decoration: BoxDecoration(
              border: .all(color: Colors.red),
              borderRadius: .circular(12),
            ),
            child: Column(
              children: [
                _DangerButton(
                  title: "Re-Render Map",
                  buttonLabel: "Re-Render",
                  text: """
Some options require a re-render of the map when you change them.
With this button, you can do that. It deletes the current render of the map, so it can be regenerated.
No unrecoverable data will be lost if you click this button. 
It will just take some time to render the whole map again.
You will also have to restart the BlueMap process in the Control Panel.""",
                  onPressed: renderDataDirectoryExists
                      ? () async {
                          await renderDataDirectory.delete(recursive: true);
                          setState(() {}); //rebuild the widget to deactivate the button
                        }
                      : null,
                  buttonTooltip:
                      "${renderDataDirectoryExists ? "Will delete" : "Folder does not exist"}: ${renderDataDirectory.path}",
                ),
                _DangerButton(
                  title: "Delete Map",
                  text: """
If you delete this map, it will be gone forever.
Your actual world files will not be affected!
"But you can always create a new map that uses those same world files again.""",
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
  final String text;
  final String buttonLabel;
  final VoidCallback? onPressed;
  final String? buttonTooltip;

  const _DangerButton({
    required this.title,
    required this.text,
    required this.buttonLabel,
    required this.onPressed,
    this.buttonTooltip,
  });

  @override
  Widget build(BuildContext context) {
    final button = ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
      ),
      onPressed: onPressed,
      child: Text(buttonLabel),
    );
    return ListTile(
      title: Row(
        mainAxisAlignment: .spaceBetween,
        children: [
          Expanded(
            child: SettingHeading(
              context,
              title,
              padding: EdgeInsets.zero,
              [SettingsBodyText(text)],
            ),
          ),
          const SizedBox(width: 16),
          if (buttonTooltip == null)
            button
          else
            Tooltip(message: buttonTooltip, child: button),
        ],
      ),
    );
  }
}

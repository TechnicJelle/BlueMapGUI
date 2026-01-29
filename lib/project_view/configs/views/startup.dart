import "dart:convert";

import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../../main_menu/settings/setting_heading.dart";
import "../../../project_configs_provider.dart";
import "../models/base.dart";
import "../models/startup.dart";
import "base.dart";

class StartupConfigView extends ConsumerStatefulWidget {
  const StartupConfigView({super.key});

  @override
  ConsumerState<StartupConfigView> createState() => _StartupConfigViewState();
}

class _StartupConfigViewState extends ConsumerState<StartupConfigView> {
  ///reference to the actual mapConfig in the _projectProvider,
  ///so changing the model will properly apply
  late ConfigFile configFile;

  StartupConfigModel get model => configFile.model as StartupConfigModel;

  set model(StartupConfigModel newModel) => configFile.model = newModel;

  late final TextEditingController modsPathController = TextEditingController(
    text: model.modsPath,
  );
  late final TextEditingController mcVerController = TextEditingController(
    text: model.minecraftVersion,
  );

  @override
  void dispose() {
    configFile.changeValueInFile(
      StartupConfigKeys.modsPath,
      jsonEncode(model.modsPath),
    );
    modsPathController.dispose();

    configFile.changeValueInFile(
      StartupConfigKeys.minecraftVersion,
      jsonEncode(model.minecraftVersion),
    );
    mcVerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    configFile = ref.watch(createTypedOpenConfigProvider<StartupConfigModel>())!;

    return ListView(
      children: [
        const ConfigTitle(title: "Startup Config"),
        TextFieldOption.customDescription(
          title: "Mods Path",
          descriptionList: const [
            SettingsBodyText(
              "Path to mods folder. Used for properly rendering (most) modded blocks.\n",
            ),
            SettingsBodyLink(
              "More information about BlueMap and mods.",
              "https://bluemap.bluecolored.de/wiki/customization/Mods.html",
            ),
            SettingsBodyText("\nLeave empty to not use any mods."),
          ],
          controller: modsPathController,
          hintText: "No mods active.",
          button: PathPickerButton(
            purpose: "mods",
            onPicked: (String path) => setState(() {
              model = model.copyWith(modsPath: modsPathController.text = path);
            }),
            initialDirectory: model.modsPath.isNotEmpty ? model.modsPath : "~",
          ),
          onChanged: (String value) {
            setState(() => model = model.copyWith(modsPath: value));
          },
          onEditingComplete: () => configFile.changeValueInFile(
            StartupConfigKeys.modsPath,
            jsonEncode(model.modsPath),
          ),
        ),
        TextFieldOption(
          title: "Minecraft Version",
          description: """
The Minecraft version.
Leave empty to use the latest version that this BlueMap version supports.""",
          controller: mcVerController,
          hintText:
              "Using the latest Minecraft version that this BlueMap version supports.",
          onChanged: (String value) {
            setState(() => model = model.copyWith(minecraftVersion: value));
          },
          onEditingComplete: () => configFile.changeValueInFile(
            StartupConfigKeys.minecraftVersion,
            jsonEncode(model.minecraftVersion),
          ),
        ),
      ],
    );
  }
}

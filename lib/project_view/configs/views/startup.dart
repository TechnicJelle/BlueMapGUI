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
    mcVerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    configFile = ref.watch(createTypedOpenConfigProvider<StartupConfigModel>())!;

    const padding = EdgeInsets.only(bottom: 8);
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, top: 16, bottom: 12),
          child: Text(
            "Startup Config",
            style: TextTheme.of(context).headlineMedium?.copyWith(
              color: TextTheme.of(context).titleSmall?.color,
            ),
          ),
        ),
        ListTile(
          title: SettingHeading(
            context,
            "Mods Path",
            padding: padding,
            const [
              SettingsBodyText(
                "Path to mods folder. Used for properly rendering (most) modded blocks.\n",
              ),
              SettingsBodyLink(
                "More information about BlueMap and mods.",
                "https://bluemap.bluecolored.de/wiki/customization/Mods.html",
              ),
              SettingsBodyText("\nLeave empty to not use any mods."),
            ],
          ),
          subtitle: TextField(
            controller: modsPathController,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              hintText: "No mods active.",
              suffixIcon: PathPickerButton(
                purpose: "mods",
                onPicked: (String? path) {
                  if (path == null) return;
                  setState(() {
                    model = model.copyWith(
                      modsPath: modsPathController.text = path,
                    );
                  });
                },
                initialDirectory: model.modsPath.isNotEmpty ? model.modsPath : "~",
              ),
            ),
            onChanged: (String value) {
              setState(() => model = model.copyWith(modsPath: value));
            },
            onEditingComplete: () => configFile.changeValueInFile(
              StartupConfigKeys.modsPath,
              jsonEncode(model.modsPath),
            ),
          ),
        ),
        ListTile(
          title: SettingHeading(
            context,
            "Minecraft Version",
            padding: padding,
            const [
              SettingsBodyText(
                "The Minecraft version.\n"
                "Leave empty to use the latest version that this BlueMap version supports.",
              ),
            ],
          ),
          subtitle: TextField(
            controller: mcVerController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText:
                  "Using the latest Minecraft version that this BlueMap version supports.",
            ),
            onChanged: (String value) {
              setState(() => model = model.copyWith(minecraftVersion: value));
            },
            onEditingComplete: () => configFile.changeValueInFile(
              StartupConfigKeys.minecraftVersion,
              jsonEncode(model.minecraftVersion),
            ),
          ),
        ),
      ],
    );
  }
}

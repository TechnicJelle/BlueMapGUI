import "dart:convert";

import "package:file_picker/file_picker.dart";
import "package:flutter/material.dart";

import "../../../main_menu/settings/setting_heading.dart";
import "../models/base.dart";
import "../models/startup.dart";

class StartupConfigView extends StatefulWidget {
  final ConfigFile<StartupConfigModel> configFile;

  const StartupConfigView(this.configFile, {super.key});

  @override
  State<StartupConfigView> createState() => _StartupConfigViewState();
}

class _StartupConfigViewState extends State<StartupConfigView> {
  late StartupConfigModel config = widget.configFile.model;

  late final TextEditingController modsPathController = TextEditingController(
    text: config.modsPath,
  );
  late final TextEditingController mcVerController = TextEditingController(
    text: config.minecraftVersion,
  );

  @override
  void dispose() {
    widget.configFile.changeValueInFile(
      StartupConfigKeys.modsPath,
      jsonEncode(config.modsPath),
    );
    modsPathController.dispose();
    mcVerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          subtitle: Row(
            children: [
              IconButton(
                tooltip: "Pick your mods folder",
                onPressed: () async {
                  final String? picked = await FilePicker.platform.getDirectoryPath(
                    dialogTitle: "Pick your mods folder",
                    initialDirectory: config.modsPath.isNotEmpty ? config.modsPath : "~",
                  );
                  if (picked == null) return;
                  setState(
                    () => config = config.copyWith(
                      modsPath: modsPathController.text = picked,
                    ),
                  );
                },
                icon: const Icon(Icons.folder),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: modsPathController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "No mods active.",
                  ),
                  onChanged: (String value) {
                    setState(() => config = config.copyWith(modsPath: value));
                  },
                  onEditingComplete: () => widget.configFile.changeValueInFile(
                    StartupConfigKeys.modsPath,
                    jsonEncode(config.modsPath),
                  ),
                ),
              ),
            ],
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
              setState(() => config = config.copyWith(minecraftVersion: value));
            },
            onEditingComplete: () => widget.configFile.changeValueInFile(
              StartupConfigKeys.minecraftVersion,
              jsonEncode(config.minecraftVersion),
            ),
          ),
        ),
      ],
    );
  }
}

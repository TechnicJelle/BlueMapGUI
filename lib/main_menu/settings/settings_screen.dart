import "package:flutter/material.dart";

import "console_clear_picker.dart";
import "java/java_picker.dart";
import "render_caves_default_picker.dart";
import "setting_heading.dart";
import "theme_mode_picker.dart";

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        SettingHeading(context, "Java Executable", const [
          SettingsBodyText("You can download Java manually "),
          SettingsBodyLink("here", "https://adoptium.net/temurin/releases/"),
          SettingsBodyText(", or use the automatic Bundled mode."),
        ]),
        const JavaPicker(),

        SettingHeading(context, "Application Theme", const [
          SettingsBodyText("Choose your theme"),
        ]),
        const ThemeModePicker(),

        SettingHeading(context, "Render All Caves by Default", const [
          SettingsBodyText(
            """
Whether all map types should render all caves by default.
Regardless of this option, you can still always enable or disable caves per map in the project's maps list.
Not rendering caves will save some storage space, and possibly some FPS on the webmap.""",
          ),
        ]),
        const RenderCavesDefaultPicker(),

        SettingHeading(context, "Clear Console Before Start", const [
          SettingsBodyText(
            """
Whether to clear the console every time BlueMap starts up.
If disabled, errors from previous sessions may still be on screen, which could cause confusion.""",
          ),
        ]),
        const ConsoleClearPicker(),
      ],
    );
  }
}

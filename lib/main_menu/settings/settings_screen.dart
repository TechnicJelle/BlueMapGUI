import "package:flutter/material.dart";

import "java/java_picker.dart";
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
      ],
    );
  }
}

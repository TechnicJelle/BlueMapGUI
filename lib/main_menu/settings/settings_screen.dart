import "package:flutter/material.dart";

import "java/java_picker.dart";
import "setting_heading.dart";

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        SettingHeading(context, "Java Executable", [
          SettingsBodyText("You can download Java "),
          SettingsBodyLink("here", "https://adoptium.net/temurin/releases/"),
        ]),
        const JavaPicker(),
      ],
    );
  }
}

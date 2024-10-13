import "package:flutter/material.dart";

import "java/java_picker.dart";
import "setting_heading.dart";

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        SettingHeading(
          "# Java Executable\n"
          "You can download Java [here](https://adoptium.net/temurin/releases/)",
        ),
        JavaPicker(),
      ],
    );
  }
}

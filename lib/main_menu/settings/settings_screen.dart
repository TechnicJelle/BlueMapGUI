import "package:flutter/material.dart";

import "java/java_picker.dart";

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(children: const [
      Text("Java Executable"), //TODO: Add link to download Java
      SizedBox(height: 4),
      JavaPicker(),
    ]);
  }
}

import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../prefs.dart";
import "../path_picker_button.dart";

class ProjectsScreen extends ConsumerWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(javaPathProvider.select((path) => path == null))) {
      return const Center(
        child: Text("⬅ Please select your Java in the settings"),
      );
    }

    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Select an empty folder to store your BlueMap files in:"),
          SizedBox(height: 8),
          PathPickerButton(),
          SizedBox(height: 8),
          Text("The BlueMap CLI tool will be downloaded into that folder."),
          SizedBox(height: 4),
          Text("It will generate some default config files for you."),
          SizedBox(height: 4),
          Text("You will then need to configure your maps in the BlueMap GUI."),
        ],
      ),
    );
  }
}

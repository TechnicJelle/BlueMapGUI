import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../prefs.dart";
import "java/java_picker.dart";
import "path_picker_button.dart";

class MainMenu extends ConsumerWidget {
  const MainMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const JavaPicker(),
          if (ref.watch(javaPathProvider.select((path) => path != null))) ...[
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: const Divider(),
            ),
            const Text("Select an empty folder to store your BlueMap files in:"),
            const SizedBox(height: 8),
            const PathPickerButton(),
            const SizedBox(height: 8),
            const Text("The BlueMap CLI tool will be downloaded into that folder."),
            const SizedBox(height: 4),
            const Text("It will generate some default config files for you."),
            const SizedBox(height: 4),
            const Text("You will then need to configure your maps in the BlueMap GUI."),
          ],
        ],
      ),
    );
  }
}

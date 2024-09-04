import "dart:io";

import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "confirmation_dialog.dart";
import "dual_pane.dart";
import "path_picker_button.dart";
import "prefs.dart";
import "tech_app.dart";

// == Hardcoded BlueMap CLI JAR download URL and hash ==
const blueMapCliJarUrl = "https://github.com/BlueMap-Minecraft/BlueMap/releases/download/"
    "v5.3/BlueMap-5.3-cli.jar";
const blueMapCliJarHash =
    "a0be9a36325f3caabc6306e9c6dd306aeec464b8abe907e93b6589659c8751f5"; //SHA256

String get blueMapCliJarName => blueMapCliJarUrl.split("/").last;

const String commit = String.fromEnvironment("commit", defaultValue: "development");

final projectDirectoryProvider = Provider<Directory?>((ref) {
  final String? bluemapJarPath = Prefs.instance.projectPath;
  if (bluemapJarPath == null) {
    return null;
  } else {
    return Directory(bluemapJarPath);
  }
});

Future<void> main() async {
  await Prefs.init();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return TechApp(
      title: "BlueMap GUI",
      primary: Colors.blue,
      secondary: Colors.blueAccent,
      themeMode: ThemeMode.system,
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends ConsumerWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Directory? projectDirectory = ref.watch(projectDirectoryProvider);

    String title = "BlueMap GUI";
    if (projectDirectory != null) {
      title += ": ${projectDirectory.path}";
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          const Text(commit),
          if (projectDirectory != null)
            IconButton(
              tooltip: "Close project",
              onPressed: () {
                showConfirmationDialog(
                  context: context,
                  title: "Close project",
                  content: const [
                    Text("Are you sure you want to close this project?"),
                    Text("You can always open it again later."),
                  ],
                  confirmAction: "Close",
                  onConfirmed: () {
                    Prefs.instance.projectPath = null;
                    ref.invalidate(projectDirectoryProvider);
                  },
                );
              },
              icon: const Icon(Icons.close),
            ),
        ],
      ),
      body: projectDirectory == null
          ? const Center(
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
            )
          : const DualPane(),
    );
  }
}

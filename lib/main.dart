import "dart:io";

import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "close_project_button.dart";
import "dual_pane.dart";
import "java/java_picker.dart";
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
          if (projectDirectory != null) const CloseProjectButton(),
        ],
      ),
      body: projectDirectory == null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const JavaPicker(),
                  if (ref.watch(javaPathProvider) != null) ...[
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: const Divider(),
                    ),
                    const Text("Select an empty folder to store your BlueMap files in:"),
                    const SizedBox(height: 8),
                    const PathPickerButton(),
                    const SizedBox(height: 8),
                    const Text(
                        "The BlueMap CLI tool will be downloaded into that folder."),
                    const SizedBox(height: 4),
                    const Text("It will generate some default config files for you."),
                    const SizedBox(height: 4),
                    const Text(
                        "You will then need to configure your maps in the BlueMap GUI."),
                  ],
                ],
              ),
            )
          : const DualPane(),
    );
  }
}

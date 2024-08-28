import "dart:io";

import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "dual_pane.dart";
import "path_picker_button.dart";
import "prefs.dart";
import "tech_app.dart";

const String commit = String.fromEnvironment("commit", defaultValue: "development");

const blueMapCliJarUrl = "https://github.com/BlueMap-Minecraft/BlueMap/releases/download/"
    "v5.3/BlueMap-5.3-cli.jar";

String get blueMapCliJarName => blueMapCliJarUrl.split("/").last;

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

    final List<PopupMenuEntry> extraOptions = [
      if (projectDirectory != null)
        PopupMenuItem(
          child: const Row(
            children: [
              Icon(Icons.close),
              SizedBox(width: 8),
              Text("Close project"),
            ],
          ),
          onTap: () {
            Prefs.instance.projectPath = null;
            ref.invalidate(projectDirectoryProvider);
          },
        ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          const Text(commit),
          if (extraOptions.isNotEmpty)
            PopupMenuButton(
              tooltip: "Extra options",
              itemBuilder: (context) => extraOptions,
            )
        ],
      ),
      body: Center(
        child: projectDirectory == null ? const PathPickerButton() : const DualPane(),
      ),
    );
  }
}

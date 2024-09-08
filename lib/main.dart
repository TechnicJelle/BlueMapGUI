import "dart:io";

import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "main_menu/main_menu.dart";
import "prefs.dart";
import "project_view/close_project_button.dart";
import "project_view/project_view.dart";
import "tech_app.dart";

// == Hardcoded BlueMap CLI JAR download URL and hash ==
const blueMapTag = "5.3";
const blueMapCliJarHash =
    "a0be9a36325f3caabc6306e9c6dd306aeec464b8abe907e93b6589659c8751f5"; //SHA256

const blueMapCliJarUrl = "https://github.com/BlueMap-Minecraft/BlueMap/releases/download/"
    "v$blueMapTag/BlueMap-$blueMapTag-cli.jar";
String get blueMapCliJarName => blueMapCliJarUrl.split("/").last;

const String commit = String.fromEnvironment("commit", defaultValue: "development");

Future<void> main() async {
  await initPrefs();

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
      body: projectDirectory == null ? const MainMenu() : const ProjectView(),
    );
  }
}

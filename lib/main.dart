import "dart:io";

import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "main_menu/main_menu.dart";
import "main_menu/projects/projects_screen.dart";
import "prefs.dart";
import "project_view/close_project_button.dart";
import "project_view/open_in_explorer_button.dart";
import "project_view/project_view.dart";
import "tech_app.dart";

// == Hardcoded BlueMap CLI JAR download URL and hash ==
const blueMapTag = "5.5";
const blueMapCliJarHash =
    "766d962d60db6ebb1021f0fe81b453ade24d6d9af210781e8ec9319572ff23d1"; //SHA256

// == Derived variables ==
const blueMapCliJarUrl = "https://github.com/BlueMap-Minecraft/BlueMap/releases/download/"
    "v$blueMapTag/BlueMap-$blueMapTag-cli.jar";
String get blueMapCliJarName => blueMapCliJarUrl.split("/").last;

const String vDev = "development";
const String version = String.fromEnvironment("version", defaultValue: vDev);

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
    final Directory? projectDirectory = ref.watch(openProjectProvider);

    String title = "BlueMap GUI";
    if (projectDirectory != null) {
      title += ": ${projectDirectory.path}";
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          const Text("Version: $version\nBlueMap: $blueMapTag"),
          if (projectDirectory != null) ...[
            const OpenInFileManagerButton(),
            const CloseProjectButton(),
          ]
        ],
      ),
      body: projectDirectory == null ? const MainMenu() : const ProjectView(),
    );
  }
}

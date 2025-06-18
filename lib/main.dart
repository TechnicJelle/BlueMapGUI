import "dart:io";

import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:path/path.dart" as p;
import "package:window_manager/window_manager.dart";

import "main_menu/main_menu.dart";
import "main_menu/projects/projects_screen.dart";
import "prefs.dart";
import "project_view/close_project_button.dart";
import "project_view/open_in_explorer_button.dart";
import "project_view/project_view.dart";
import "tech_app.dart";

// == Hardcoded BlueMap CLI JAR download URL and hash ==
const blueMapTag = "5.7";
const blueMapCliJarHash =
    "f2e75960982baf86e2da68d162b01277c270528515656d6d66938b46069f008c"; //SHA256

// == Derived variables ==
const blueMapCliJarUrl =
    "https://github.com/BlueMap-Minecraft/BlueMap/releases/download/"
    "v$blueMapTag/bluemap-$blueMapTag-cli.jar";

String get blueMapCliJarName => blueMapCliJarUrl.split("/").last;

const String vDev = "development";
const String version = String.fromEnvironment("version", defaultValue: vDev);

Future<void> main() async {
  await initPrefs();

  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = WindowOptions(minimumSize: const Size(600, 300));
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

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

    final String title = projectDirectory == null
        ? "BlueMap GUI"
        : "Project: ${p.basename(projectDirectory.path)}";

    return Scaffold(
      appBar: AppBar(
        title: Tooltip(message: projectDirectory?.path ?? "Hi :)", child: Text(title)),
        actions: [
          if (projectDirectory != null) ...[
            const OpenInFileManagerButton(),
            const CloseProjectButton(),
          ],
        ],
      ),
      body: Stack(
        children: [
          projectDirectory == null ? const MainMenu() : const ProjectView(),
          _VersionText(),
        ],
      ),
    );
  }
}

class _VersionText extends StatelessWidget {
  const _VersionText();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 4, left: 4),
        child: Text(
          "Version: $version\nBlueMap: $blueMapTag",
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
    );
  }
}

import "dart:io";

import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:path/path.dart" as p;
import "package:url_launcher/url_launcher_string.dart";
import "package:window_manager/window_manager.dart";

import "main_menu/main_menu.dart";
import "main_menu/projects/projects_screen.dart";
import "prefs.dart";
import "project_view/close_project_button.dart";
import "project_view/open_in_explorer_button.dart";
import "project_view/project_view.dart";
import "tech_app.dart";

// == Hardcoded BlueMap CLI JAR download URL and hash ==
const blueMapTag = "5.12";
const blueMapCliJarHash =
    "93eb5222580e8fba3b6873dd2735d25b5cf1c76a59ebb4c1dda27816fed4d293"; //SHA256

// == Derived variables ==
final blueMapCliJarUrl = Uri.https(
  "github.com",
  "BlueMap-Minecraft/BlueMap/releases/download/v$blueMapTag/bluemap-$blueMapTag-cli.jar",
);

const String vDev = "development";
const String version = String.fromEnvironment("version", defaultValue: vDev);

Future<void> main() async {
  await initPrefs();

  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(minimumSize: Size(600, 300));
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    return TechApp(
      title: "BlueMap GUI",
      primary: Colors.blue,
      secondary: Colors.blueAccent,
      themeMode: themeMode,
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
          IconButton(
            tooltip: "Help",
            onPressed: () {
              launchUrlString("https://github.com/TechnicJelle/BlueMapGUI#readme");
            },
            icon: const Icon(Icons.help),
          ),
          if (projectDirectory != null) ...[
            const OpenInFileManagerButton(),
            const CloseProjectButton(),
          ],
        ],
      ),
      body: Stack(
        children: [
          projectDirectory == null ? const MainMenu() : const ProjectView(),
          const _VersionText(),
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

import "dart:async";
import "dart:io";

import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:path/path.dart" as p;
import "package:url_launcher/url_launcher_string.dart";
import "package:window_manager/window_manager.dart";

import "main_menu/main_menu.dart";
import "prefs.dart";
import "project_configs_provider.dart";
import "project_view/close_project_button.dart";
import "project_view/open_in_explorer_button.dart";
import "project_view/project_view.dart";
import "tech_app.dart";
import "versions.dart";

Future<void> main() async {
  await initPrefs();

  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  const WindowOptions windowOptions = WindowOptions(minimumSize: Size(600, 300));
  await windowManager.waitUntilReadyToShow(windowOptions, () async {
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
              unawaited(
                launchUrlString("https://github.com/TechnicJelle/BlueMapGUI#readme"),
              );
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
          if (projectDirectory == null) const MainMenu() else const ProjectView(),
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
    return IgnorePointer(
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 4, left: 4),
          child: Text(
            "Version: $version\nBlueMap: $blueMapTag",
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ),
    );
  }
}

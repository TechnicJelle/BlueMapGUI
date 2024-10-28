import "dart:async";
import "dart:io";

import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:path/path.dart" as p;
import "package:url_launcher/url_launcher.dart";
import "package:url_launcher/url_launcher_string.dart";

import "../../confirmation_dialog.dart";
import "../../hover.dart";
import "../../main.dart";
import "../../prefs.dart";
import "../../utils.dart";
import "projects_screen.dart";

enum _PickingState {
  nothing,
  scanning,
  downloading,
  downloadFailed,
  hashing,
  wrongHash,
  running,
}

class _PickingStateNotifier extends Notifier<_PickingState> {
  @override
  _PickingState build() {
    return _PickingState.nothing;
  }

  void set(_PickingState newState) {
    state = newState;
  }
}

class ProjectTile extends ConsumerStatefulWidget {
  final Directory projectDirectory;

  const ProjectTile(this.projectDirectory, {super.key});

  @override
  ConsumerState<ProjectTile> createState() => _PathPickerButtonState();
}

class _PathPickerButtonState extends ConsumerState<ProjectTile> {
  final _pickingStateProvider = NotifierProvider<_PickingStateNotifier, _PickingState>(
      () => _PickingStateNotifier());
  String? errorText;

  late final StreamSubscription<FileSystemEvent> fileWatchSub;
  late bool projectDirectoryExists;

  Directory get projectDirectory => widget.projectDirectory;

  String get projectName => p.basename(projectDirectory.path);

  @override
  void initState() {
    super.initState();
    projectDirectoryExists = projectDirectory.existsSync();

    fileWatchSub = projectDirectory.parent.watch().listen((FileSystemEvent event) {
      projectDirectory.exists().then((bool exists) {
        if (mounted) {
          setState(() => projectDirectoryExists = exists);
        }
      });
    });
  }

  @override
  void dispose() {
    fileWatchSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _PickingState pickingState = ref.watch(_pickingStateProvider);
    return Hover(
      alwaysChild: switch (pickingState) {
        //TODO: The states other than ListTile should get more polish
        _PickingState.nothing => ListTile(
            enabled: projectDirectoryExists,
            onTap: openProject,
            title: Text(projectName),
            subtitle: Wrap(
              spacing: 12,
              runSpacing: 2,
              children: [
                Text(projectDirectory.path),
                if (!projectDirectoryExists)
                  Text(
                    "Error: Directory not found",
                    style: TextStyle(color: Colors.red[600]),
                  ),
              ],
            ),
          ),
        _PickingState.scanning => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Scanning folder for BlueMap CLI JAR..."),
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 300),
                child: const LinearProgressIndicator(),
              ),
            ],
          ),
        _PickingState.downloading => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Downloading BlueMap CLI JAR..."),
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 300),
                child: const LinearProgressIndicator(),
              ),
            ],
          ),
        _PickingState.downloadFailed => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              const Text(
                "Downloaded failed:",
                style: TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 4),
              Text(
                errorText ?? "Unknown error",
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () =>
                    ref.read(_pickingStateProvider.notifier).set(_PickingState.nothing),
                child: const Text("Try again"),
              ),
              const SizedBox(height: 8),
            ],
          ),
        _PickingState.hashing => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Verifying BlueMap CLI JAR hash..."),
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 300),
                child: const LinearProgressIndicator(),
              ),
            ],
          ),
        _PickingState.wrongHash => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Downloaded failed! Invalid hash!",
                style: TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => launchUrlString(
                  "https://github.com/TechnicJelle/BlueMapGUI/issues/new",
                ),
                child: const Text("Contact developer"),
              ),
            ],
          ),
        _PickingState.running => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Running BlueMap CLI to generate default configs..."),
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 300),
                child: const LinearProgressIndicator(),
              ),
            ],
          ),
      },
      hoverChild: Positioned(
        right: 16,
        top: 12,
        child: projectDirectoryExists
            ? PopupMenuButton(
                itemBuilder: (BuildContext context) => <PopupMenuEntry>[
                  PopupMenuItem(
                    enabled: projectDirectoryExists,
                    child: const Row(
                      children: [
                        Icon(Icons.folder_open),
                        SizedBox(width: 8),
                        Text("Open in file manager"),
                      ],
                    ),
                    onTap: () => launchUrl(projectDirectory.uri),
                    // does nothing when dir doesn't exist ↑
                  ),
                  PopupMenuItem(
                    child: const Row(
                      children: [
                        Icon(Icons.clear),
                        SizedBox(width: 8),
                        Text("Remove from projects"),
                      ],
                    ),
                    onTap: () => removeProjectFromList(),
                  ),
                ],
              )
            : IconButton(
                onPressed: () => removeProjectFromList(),
                icon: const Icon(Icons.clear),
              ),
      ),
    );
  }

  void removeProjectFromList() {
    showConfirmationDialog(
      context: context,
      title: "Remove Project",
      content: [
        Text("Are you sure you want to remove $projectName from the projects list?"),
      ],
      confirmAction: "Yes",
      onConfirmed: () =>
          ref.read(knownProjectsProvider.notifier).removeProject(projectDirectory),
    );
  }

  Future<void> openProject() async {
    // == Check if project directory exists ==
    if (!projectDirectory.existsSync()) {
      return;
    }

    // == Scanning for BlueMap CLI JAR ==
    ref.read(_pickingStateProvider.notifier).set(_PickingState.scanning);
    final contents = projectDirectory.listSync();

    NonHashedFile? susBlueMapJar;
    for (final file in contents) {
      if (file is! File) continue;
      String fileName = p.split(file.path).last;
      if (fileName == blueMapCliJarName) {
        susBlueMapJar = NonHashedFile(file);
        break;
      }
    }

    // == If needed, download BlueMap CLI JAR ==
    if (susBlueMapJar == null) {
      ref.read(_pickingStateProvider.notifier).set(_PickingState.downloading);
      try {
        susBlueMapJar = await downloadBlueMap(projectDirectory);
      } catch (e) {
        setState(() {
          ref.read(_pickingStateProvider.notifier).set(_PickingState.downloadFailed);
          errorText = e.toString();
        });
        return;
      }
    }

    // == Verify BlueMap CLI JAR hash ==
    ref.read(_pickingStateProvider.notifier).set(_PickingState.hashing);
    final File? bluemapJar = await susBlueMapJar.hashFile(blueMapCliJarHash);
    if (bluemapJar == null) {
      ref.read(_pickingStateProvider.notifier).set(_PickingState.wrongHash);
      return;
    }

    // == Run BlueMap CLI JAR to generate default configs ==
    ref.read(_pickingStateProvider.notifier).set(_PickingState.running);
    ProcessResult run = await Process.run(
      ref.read(javaPathProvider)!,
      ["-jar", bluemapJar.path],
      workingDirectory: projectDirectory.path,
    );

    final String stdout = run.stdout;
    if (!stdout.contains("Generated default config files for you")) {
      throw Exception("BlueMap CLI JAR failed to run!");
    }

    // == Turn default maps directory into templates directory ==
    final templatesDir =
        Directory(p.join(projectDirectory.path, "config", "map-templates"));
    //Make sure to support opening existing projects; only do this on fresh projects
    if (!templatesDir.existsSync()) {
      final Directory mapsDir =
          Directory(p.join(projectDirectory.path, "config", "maps"));
      mapsDir.renameSync(templatesDir.path); //rename maps dir to templates dir
      mapsDir.createSync(); //recreate maps dir (now empty)
    }

    ref.read(openProjectProvider.notifier).openProject(projectDirectory);
  }
}

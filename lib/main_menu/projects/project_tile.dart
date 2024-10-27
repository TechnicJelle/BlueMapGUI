import "dart:io";

import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:path/path.dart" as p;
import "package:url_launcher/url_launcher_string.dart";

import "../../main.dart";
import "../../prefs.dart";
import "../../utils.dart";
import "projects_screen.dart";

enum _PickingState {
  nothing,
  directoryNotFound,
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

  Directory get projectDirectory => widget.projectDirectory;

  @override
  void initState() {
    super.initState();

    projectDirectory.exists().then((bool exists) {
      if (!exists) {
        ref.read(_pickingStateProvider.notifier).set(_PickingState.directoryNotFound);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final _PickingState pickingState = ref.watch(_pickingStateProvider);
    return switch (pickingState) {
      //TODO: The states other than ListTile should get more polish
      _PickingState.nothing => ListTile(
          title: Text(p.basename(projectDirectory.path)),
          subtitle: Text(projectDirectory.path),
          onTap: openProject,
        ),
      _PickingState.directoryNotFound =>
        Text("Directory ${projectDirectory.path} not found!"),
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
    };
  }

  Future<void> openProject() async {
    // == Check if project directory exists ==
    if (!projectDirectory.existsSync()) {
      ref.read(_pickingStateProvider.notifier).set(_PickingState.directoryNotFound);
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

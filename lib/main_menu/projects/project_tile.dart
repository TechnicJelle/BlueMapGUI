import "dart:async";
import "dart:io";

import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:path/path.dart" as p;
import "package:url_launcher/url_launcher.dart";

import "../../confirmation_dialog.dart";
import "../../hover.dart";
import "../../main.dart";
import "../../prefs.dart";
import "../../utils.dart";
import "projects_screen.dart";

enum _OpeningStep {
  nothing,
  scanning,
  downloading,
  hashing,
  running,
  mapping,
  opening,
}

enum _OpenError {
  downloadFailed,
  wrongHash,
}

class _OpeningStateNotifier extends Notifier<_OpeningStep?> {
  _OpenError? _openError;
  String? _openErrorDetails;

  @override
  _OpeningStep build() {
    return _OpeningStep.nothing;
  }

  void set(_OpeningStep newState) {
    state = newState;
    _openError = null;
    _openErrorDetails = null;
  }

  void error({required _OpenError error, String? details}) {
    state = null;
    _openError = error;
    print(_openError);
    if (details != null) {
      _openErrorDetails = details;
      print(_openErrorDetails);
    }
  }

  _OpenError? getError() {
    return _openError;
  }

  String? getErrorDetails() {
    return _openErrorDetails;
  }
}

class ProjectTile extends ConsumerStatefulWidget {
  final Directory projectDirectory;

  const ProjectTile(this.projectDirectory, {super.key});

  @override
  ConsumerState<ProjectTile> createState() => _PathPickerButtonState();
}

class _PathPickerButtonState extends ConsumerState<ProjectTile> {
  final _openingStateProvider = NotifierProvider<_OpeningStateNotifier, _OpeningStep?>(
      () => _OpeningStateNotifier());

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
    return Hover(
      alwaysChild: ListTile(
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
    // == Open opening progress dialog ==
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Consumer(
          builder: (context, ref, child) {
            final _OpeningStep? pickingStep = ref.watch(_openingStateProvider);
            if (pickingStep == null) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("An error occurred while opening the project:"),
                  const SizedBox(height: 8),
                  switch (ref.read(_openingStateProvider.notifier).getError()!) {
                    _OpenError.downloadFailed => Text(
                        "Failed to download BlueMap CLI JAR!\n${ref.read(_openingStateProvider.notifier).getErrorDetails() ?? "Unknown error"}"),
                    _OpenError.wrongHash =>
                      const Text("BlueMap CLI JAR hash verification failed!\n"
                          "Delete the BlueMap CLI JAR and try again to re-download it."),
                  },
                ],
              );
            }
            return switch (pickingStep) {
              //TODO: This should get more polish. DRY it up.
              _OpeningStep.nothing => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("Preparing to open the project..."),
                    const SizedBox(height: 8),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 300),
                      child: const LinearProgressIndicator(),
                    ),
                  ],
                ),
              _OpeningStep.scanning => Column(
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
              _OpeningStep.downloading => Column(
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
              _OpeningStep.hashing => Column(
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
              _OpeningStep.running => Column(
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
              _OpeningStep.mapping => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("Turning BlueMap's default map configs into templates..."),
                    const SizedBox(height: 8),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 300),
                      child: const LinearProgressIndicator(),
                    ),
                  ],
                ),
              _OpeningStep.opening => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("Opening project..."),
                    const SizedBox(height: 8),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 300),
                      child: const LinearProgressIndicator(),
                    ),
                  ],
                ),
            };
          },
        ),
        //TODO: Add cancel button
      ),
      barrierDismissible: false,
    );

    // == Check if project directory exists ==
    if (!projectDirectory.existsSync()) {
      return;
    }

    // == Scanning for BlueMap CLI JAR ==
    ref.read(_openingStateProvider.notifier).set(_OpeningStep.scanning);
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
      ref.read(_openingStateProvider.notifier).set(_OpeningStep.downloading);
      try {
        susBlueMapJar = await downloadBlueMap(projectDirectory);
      } catch (e) {
        ref.read(_openingStateProvider.notifier).error(
              error: _OpenError.downloadFailed,
              details: e.toString(),
            );
        return;
      }
    }

    // == Verify BlueMap CLI JAR hash ==
    ref.read(_openingStateProvider.notifier).set(_OpeningStep.hashing);
    final File? bluemapJar = await susBlueMapJar.hashFile(blueMapCliJarHash);
    if (bluemapJar == null) {
      ref.read(_openingStateProvider.notifier).error(error: _OpenError.wrongHash);
      return;
    }

    // == Run BlueMap CLI JAR to generate default configs ==
    ref.read(_openingStateProvider.notifier).set(_OpeningStep.running);
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
    ref.read(_openingStateProvider.notifier).set(_OpeningStep.mapping);
    final templatesDir =
        Directory(p.join(projectDirectory.path, "config", "map-templates"));
    //Make sure to support opening existing projects; only do this on fresh projects
    if (!templatesDir.existsSync()) {
      final Directory mapsDir =
          Directory(p.join(projectDirectory.path, "config", "maps"));
      mapsDir.renameSync(templatesDir.path); //rename maps dir to templates dir
      mapsDir.createSync(); //recreate maps dir (now empty)
    }

    // == Open project ==
    ref.read(_openingStateProvider.notifier).set(_OpeningStep.opening);
    ref.read(openProjectProvider.notifier).openProject(projectDirectory);

    // == Close opening progress dialog ==
    if (mounted) {
      //TODO: Is there a better way to do this?
      Navigator.of(context).pop();
    }
  }
}

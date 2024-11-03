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
  checking,
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
    if (details != null) {
      _openErrorDetails = details;
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
      builder: (context) => _OpenProjectDialog(
        openingStateProvider: _openingStateProvider,
      ),
      barrierDismissible: false,
    );

    // == Check if project directory exists ==
    if (!projectDirectory.existsSync()) {
      return;
    }

    // == Checking for BlueMap CLI JAR ==
    ref.read(_openingStateProvider.notifier).set(_OpeningStep.checking);
    final File potentialBlueMapJar =
        File(p.join(projectDirectory.path, blueMapCliJarName));

    final File bluemapJar;
    // == If needed, download BlueMap CLI JAR ==
    if (potentialBlueMapJar.existsSync()) {
      bluemapJar = potentialBlueMapJar;
    } else {
      ref.read(_openingStateProvider.notifier).set(_OpeningStep.downloading);
      final NonHashedFile susBlueMapJar;
      try {
        susBlueMapJar = await downloadBlueMap(projectDirectory);
      } catch (e) {
        ref.read(_openingStateProvider.notifier).error(
              error: _OpenError.downloadFailed,
              details: e.toString(),
            );
        return;
      }

      // == Verify BlueMap CLI JAR hash ==
      ref.read(_openingStateProvider.notifier).set(_OpeningStep.hashing);
      final File? hashedBlueMapJar = await susBlueMapJar.hashFile(blueMapCliJarHash);
      if (hashedBlueMapJar == null) {
        ref.read(_openingStateProvider.notifier).error(error: _OpenError.wrongHash);
        return;
      }
      bluemapJar = hashedBlueMapJar;
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
    //TODO: Is there a better way to do this?
    if (mounted) {
      Navigator.of(context).pop();
    }
  }
}

class _OpenProjectDialog extends ConsumerWidget {
  //TODO: Is there a way to add an explicit type annotation?
  // Technically, the type is `NotifierProviderImpl<_OpeningStateNotifier, _OpeningStep?>`
  // But "The member 'NotifierProviderImpl' can only be used within its package."
  final _openingStateProvider;

  const _OpenProjectDialog({required openingStateProvider})
      : _openingStateProvider = openingStateProvider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _OpeningStep? pickingStep = ref.watch(_openingStateProvider);
    final bool isError = pickingStep == null;
    return AlertDialog(
      title: isError
          ? const Text(
              "An error occurred while opening the project",
              style: TextStyle(color: Colors.red),
            )
          : switch (pickingStep) {
              _OpeningStep.nothing => const Text("Preparing to open the project..."),
              _OpeningStep.checking =>
                const Text("Checking if BlueMap CLI JAR has already been downloaded..."),
              _OpeningStep.downloading => const Text("Downloading BlueMap CLI JAR..."),
              _OpeningStep.hashing => const Text("Verifying BlueMap CLI JAR hash..."),
              _OpeningStep.running =>
                const Text("Running BlueMap CLI to generate default configs..."),
              _OpeningStep.mapping =>
                const Text("Turning BlueMap's default map configs into templates..."),
              _OpeningStep.opening => const Text("Opening project..."),
            },
      content: isError
          ? switch (ref.read(_openingStateProvider.notifier).getError()) {
              _OpenError.downloadFailed => Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Failed to download BlueMap CLI JAR.\n"
                        "Check your internet connection and try again."),
                    const SizedBox(height: 8),
                    Text(
                      ref.read(_openingStateProvider.notifier).getErrorDetails(),
                      //sub text
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              _OpenError.wrongHash =>
                const Text("Could not verify BlueMap CLI JAR hash!\n"
                    "Manually delete the BlueMap CLI JAR and try again."),
              _ => const Text("An unknown error occurred!"),
            }
          : ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 500),
              child: const LinearProgressIndicator(),
            ),
      actions: isError
          ? [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("Understood"),
              ),
            ]
          : null,
    );
  }
}

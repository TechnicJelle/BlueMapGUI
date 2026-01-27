import "dart:async";
import "dart:io";

import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:path/path.dart" as p;
import "package:url_launcher/url_launcher.dart";

import "../../confirmation_dialog.dart";
import "../../hover.dart";
import "../../prefs.dart";
import "../../project_configs_provider.dart";
import "../../utils.dart";
import "../../versions.dart";
import "../settings/java/check_java_version.dart";

enum _OpeningStep {
  nothing,
  checking,
  downloading,
  hashing,
  running,
  mapping,
  copying,
  opening,
}

enum _OpenError { directoryNotFound, downloadFailed, wrongHash, runFail, copyFail }

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

// I don't want these for providers; too long
// ignore: specify_nonobvious_property_types
final _openingStateProvider = NotifierProvider(_OpeningStateNotifier.new);

// I don't want these for providers; too long
// ignore: specify_nonobvious_property_types
final _progressNotifier = NotifierProvider(ProgressNotifier.new);

class ProjectTile extends ConsumerStatefulWidget {
  final Directory projectDirectory;

  const ProjectTile(this.projectDirectory, {super.key});

  @override
  ConsumerState<ProjectTile> createState() => _PathPickerButtonState();
}

class _PathPickerButtonState extends ConsumerState<ProjectTile> {
  StreamSubscription<FileSystemEvent>? fileWatchSub;
  late bool projectDirectoryExists;

  Directory get projectDirectory => widget.projectDirectory;

  String get projectName => p.basename(projectDirectory.path);

  @override
  void initState() {
    super.initState();
    projectDirectoryExists = projectDirectory.existsSync();

    final Directory parent = projectDirectory.parent;

    unawaited(
      // I actually want this to run later; I don't mind if it takes a bit
      // ignore: avoid_slow_async_io
      parent.exists().then((bool parentExists) {
        if (!parentExists) return;
        fileWatchSub = parent.watch().listen((FileSystemEvent event) {
          unawaited(
            // I actually want this to run later; I don't mind if it takes a bit
            // ignore: avoid_slow_async_io
            projectDirectory.exists().then((bool projectDirectoryExists) {
              if (!mounted) return;
              setState(() => this.projectDirectoryExists = projectDirectoryExists);
            }),
          );
        });
      }),
    );
  }

  @override
  void dispose() {
    unawaited(fileWatchSub?.cancel());
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
                "Error: Directory not found.",
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
                itemBuilder: (BuildContext context) => <PopupMenuItem<void>>[
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
                    onTap: removeProjectFromList,
                    child: const Row(
                      children: [
                        Icon(Icons.clear),
                        SizedBox(width: 8),
                        Text("Remove from projects"),
                      ],
                    ),
                  ),
                ],
              )
            : IconButton(
                onPressed: removeProjectFromList,
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
        Text(
          "Are you sure you want to remove $projectName from the projects list?\n"
          "This will not delete the project directory from your disk.\n"
          "It will only be removed from the list.",
        ),
      ],
      confirmAction: "Yes",
      onConfirmed: () =>
          ref.read(knownProjectsProvider.notifier).removeProject(projectDirectory),
    );
  }

  Future<void> openProject() async {
    ref.read(_progressNotifier.notifier).indeterminate();

    // == Open opening progress dialog ==
    unawaited(
      showDialog<void>(
        context: context,
        builder: (context) => const _OpenProjectDialog(),
        barrierDismissible: false,
      ),
    );

    // == Check if project directory exists ==
    if (!projectDirectory.existsSync()) {
      ref
          .read(_openingStateProvider.notifier)
          .error(error: _OpenError.directoryNotFound);
      setState(() => projectDirectoryExists = false); //to update the subtitle
      return;
    }

    // == Checking for BlueMap CLI JAR ==
    ref.read(_openingStateProvider.notifier).set(_OpeningStep.checking);
    final File potentialBlueMapJar = getBlueMapJarFile(projectDirectory);

    final File bluemapJar;
    // == If needed, download BlueMap CLI JAR ==
    if (potentialBlueMapJar.existsSync()) {
      bluemapJar = potentialBlueMapJar;
    } else {
      ref.read(_openingStateProvider.notifier).set(_OpeningStep.downloading);
      final NonHashedFile susBlueMapJar;
      try {
        susBlueMapJar = await downloadFile(
          uri: blueMapCliJarUrl,
          outputFileGenerator: (_) => getBlueMapJarFile(projectDirectory),
          onProgress: (double progress) {
            ref.read(_progressNotifier.notifier).set(progress);
          },
        );
        ref.read(_progressNotifier.notifier).indeterminate();
      } on IOException catch (e) {
        ref
            .read(_openingStateProvider.notifier)
            .error(error: _OpenError.downloadFailed, details: e.toString());
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

    final JavaPath? javaPath = ref.read(javaPathProvider);
    if (javaPath == null) {
      ref
          .read(_openingStateProvider.notifier)
          .error(error: _OpenError.runFail, details: "Java Path was null");
      return;
    }

    try {
      await checkJavaVersion(javaPath);
    } on JavaVersionCheckException catch (e) {
      ref
          .read(_openingStateProvider.notifier)
          .error(error: _OpenError.runFail, details: e.message);
      return;
    }

    final mapTemplatesDirectory = getMapTemplatesDirectory(projectDirectory);
    final mapsDir = Directory(p.join(projectDirectory.path, "config", "maps"));
    final Directory? tempMapsDir;
    //If maps exists but the templatesDir doesn't, we are upgrading an outdated project
    if (mapsDir.existsSync() && !mapTemplatesDirectory.existsSync()) {
      //So the user's current maps will be moved to a different location for the duration of the upgrade
      tempMapsDir = mapsDir.renameSync(
        p.join(projectDirectory.path, "config", "maps.temp"),
      );
      //After this, the bluemap-cli will run and generate a new maps directory
    } else {
      tempMapsDir = null;
    }

    final ProcessResult run;
    try {
      run = await javaPath.runJarTimeout(
        bluemapJar,
        const Duration(seconds: 5),
        workingDirectory: projectDirectory,
      );
    } on ProcessException catch (e) {
      ref
          .read(_openingStateProvider.notifier)
          .error(error: _OpenError.runFail, details: e.toString());
      return;
    }
    final String stdout = run.stdout.toString();

    final bool startSuccess = stdout.contains("Generated default config files for you");

    //If there's an issue with a map (e.g. outdated configs), continue opening anyway; don't error out
    //The user will see the error later, when they try to start BlueMap itself
    final bool mapConfigProblem = stdout.contains(RegExp("Failed to load map.?config"));

    if (!startSuccess && !mapConfigProblem) {
      ref
          .read(_openingStateProvider.notifier)
          .error(
            error: _OpenError.runFail,
            details: stdout.trim().isEmpty ? "<no output>" : stdout,
          );
      return;
    }

    // == Turn default maps directory into templates directory ==
    ref.read(_openingStateProvider.notifier).set(_OpeningStep.mapping);
    //Check if we are currently upgrading an outdated project
    if (tempMapsDir == null) {
      //We are not currently upgrading an outdated project
      //If there is no mapTemplatesDirectory yet, but we are also not upgrading, this is a fresh project
      //So the mapsDir has just been generated by the bluemap-cli, so we rename it to the templates dir, and create an empty maps dir for the user
      if (!mapTemplatesDirectory.existsSync()) {
        mapsDir
          ..renameSync(mapTemplatesDirectory.path) //rename maps dir to templates dir
          ..createSync(); //recreate maps dir (now empty)
      }
    } else {
      //We are currently upgrading an outdated project
      //mapsDir has just been generated by the bluemap-cli with new, up-to-date configs, so we rename it to the mapTemplatesDirectory
      mapsDir.renameSync(mapTemplatesDirectory.path);
      //And now we rename the users' mapsDir back
      tempMapsDir.renameSync(mapsDir.path);
    }

    // == Copy BlueMap GUI Configs ==
    ref.read(_openingStateProvider.notifier).set(_OpeningStep.copying);
    final File startupConfigFile = File(
      p.join(projectDirectory.path, "config", "startup.conf"),
    );
    if (!startupConfigFile.existsSync()) {
      try {
        final ByteData bytes = await rootBundle.load("assets/startup.conf");
        await startupConfigFile.writeAsBytes(
          bytes.buffer.asUint8List(),
          mode: FileMode.writeOnly,
          flush: true,
        );
      } on FileSystemException catch (e) {
        ref
            .read(_openingStateProvider.notifier)
            .error(error: _OpenError.copyFail, details: e.toString());
        return;
      }
    }

    // == Open project ==
    ref.read(_openingStateProvider.notifier).set(_OpeningStep.opening);

    await ref.read(projectProviderNotifier).openProject(projectDirectory);

    // == Close opening progress dialog ==
    if (mounted) {
      Navigator.of(context).pop();
    }
  }
}

class _OpenProjectDialog extends ConsumerWidget {
  const _OpenProjectDialog();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _OpeningStep? pickingStep = ref.watch(_openingStateProvider);
    final bool isError = pickingStep == null;
    final _OpenError? openError = ref.read(_openingStateProvider.notifier).getError();
    return AlertDialog(
      title: isError
          ? const Text(
              "An error occurred while opening the project",
              style: TextStyle(color: Colors.red),
            )
          : switch (pickingStep) {
              _OpeningStep.nothing => const Text("Preparing to open the project..."),
              _OpeningStep.checking => const Text(
                "Checking if BlueMap CLI JAR has already been downloaded...",
              ),
              _OpeningStep.downloading => const Text("Downloading BlueMap CLI JAR..."),
              _OpeningStep.hashing => const Text("Verifying BlueMap CLI JAR hash..."),
              _OpeningStep.running => const Text(
                "Running BlueMap CLI to generate default configs...",
              ),
              _OpeningStep.mapping => const Text(
                "Turning BlueMap's default map configs into templates...",
              ),
              _OpeningStep.copying => const Text(
                "Copying BlueMap GUI configs into the project...",
              ),
              _OpeningStep.opening => const Text("Opening project..."),
            },
      content: isError && openError != null
          ? Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: switch (openError) {
                _OpenError.directoryNotFound => [
                  const Text("The project directory could not be found!"),
                  const SizedBox(height: 8),
                  const Text("Try removing it from the list and recreating it."),
                ],
                _OpenError.downloadFailed => [
                  const Text(
                    "Failed to download BlueMap CLI JAR.\n"
                    "Check your internet connection and try again.",
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "${ref.read(_openingStateProvider.notifier).getErrorDetails()}",
                    //sub text
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
                _OpenError.wrongHash => [
                  const Text(
                    "Could not verify the downloaded BlueMap CLI JAR's integrity!\n"
                    "The hash of the downloaded file does not match the expected hash.",
                  ),
                  const SizedBox(height: 8),
                  const Text("Please try again later or download the file manually."),
                ],
                _OpenError.runFail => [
                  const Text(
                    "Failed to run the CLI to generate default BlueMap configs!\n"
                    "Please check your Java settings and try again.",
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "${ref.read(_openingStateProvider.notifier).getErrorDetails()}",
                    //sub text
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
                _OpenError.copyFail => [
                  const Text("Failed to copy BlueMap GUI config into the project!"),
                  const SizedBox(height: 8),
                  Text(
                    "${ref.read(_openingStateProvider.notifier).getErrorDetails()}",
                    //sub text
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              },
            )
          : ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 500),
              child: LinearProgressIndicator(value: ref.watch(_progressNotifier)),
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

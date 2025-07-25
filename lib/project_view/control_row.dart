import "dart:async";
import "dart:convert";
import "dart:io";

import "package:async/async.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:path/path.dart" as p;
import "package:rxdart/rxdart.dart";
import "package:url_launcher/url_launcher.dart";
import "package:window_manager/window_manager.dart";

import "../main.dart";
import "../main_menu/projects/projects_screen.dart";
import "../prefs.dart";
import "../utils.dart";
import "update_button.dart";

final portExtractionRegex = RegExp(r"(?:port\s*|:)(\d{4,5})$");

final _processProvider = Provider<RunningProcess?>((ref) {
  final Directory? projectDirectory = ref.watch(openProjectProvider);
  if (projectDirectory == null) return null;
  final String? javaPath = ref.watch(javaPathProvider);
  if (javaPath == null) return null;
  final process = RunningProcess(projectDirectory, javaPath);
  ref.onDispose(() => process.dispose());
  return process;
});

final processOutputProvider = StreamProvider<String>((ref) async* {
  final RunningProcess? process = ref.watch(_processProvider);
  if (process == null) return;
  yield* process.consoleOutput;
});

final processStateProvider = StreamProvider<RunningProcessState>((ref) async* {
  final RunningProcess? process = ref.watch(_processProvider);
  if (process == null) return;
  yield* process.state;
});

enum RunningProcessState { stopped, starting, running, stopping }

class RunningProcess with WindowListener {
  final Directory _projectDirectory;
  final String _javaPath;

  Process? _process;

  int _port = 8100;

  int get port => _port;

  Stream<String> get consoleOutput => _consoleOutputController.stream;
  final _consoleOutputController = StreamController<String>();

  ValueStream<RunningProcessState> get state => _stateController.stream;
  final _stateController = BehaviorSubject<RunningProcessState>.seeded(
    RunningProcessState.stopped,
  );

  StreamSubscription? _processOutputStreamSub;

  RunningProcess(this._projectDirectory, this._javaPath) {
    windowManager.addListener(this);
    // Add this line to override the default close handler
    windowManager.setPreventClose(true);
  }

  /// "destructor"
  /// Actually called by the managing Provider
  void dispose() {
    windowManager.setPreventClose(false);
    windowManager.removeListener(this);

    //Stop the process when the project is closed
    if (state.value != RunningProcessState.stopped) {
      stop();
    }
  }

  @override
  void onWindowClose() async {
    bool isPreventClose = await windowManager.isPreventClose();
    if (isPreventClose) {
      if (_stateController.value != RunningProcessState.stopped) {
        //start looking for state to change to stopped
        final stopFuture = _stateController.stream.firstWhere(
          (state) => state == RunningProcessState.stopped,
        );

        if (_stateController.value == RunningProcessState.starting ||
            _stateController.value == RunningProcessState.running) {
          //start stopping the process
          stop();
        }

        //actually wait for the process to stop
        await stopFuture;

        //allow user to read the "Stopped." message
        await Future.delayed(const Duration(seconds: 1));
      }
      await windowManager.setPreventClose(false);
      await windowManager.close();
    }
  }

  String? extractOptionFromConfig({
    required String configContent,
    required String optionName,
  }) {
    //TODO: Do not use regexes for this, but parse the config file properly.
    // Perhaps use a new program that converts HOCON to JSON, which can then be loaded.
    final RegExp optionRegex = RegExp("^$optionName:.*?\"(.*)\"", multiLine: true);
    final Match? match = optionRegex.firstMatch(configContent);
    String? optionValue;
    if (match != null && match.groupCount > 0) {
      optionValue = match.group(1);
    }
    if (optionValue != null && optionValue.isNotEmpty) {
      return optionValue;
    }
    return null;
  }

  Future<void> fillArgsFromStartupConfig({
    required List<String> jvmArgs,
    required List<String> bluemapArgs,
  }) async {
    //Load file
    final File startupConfigFile = File(
      p.join(_projectDirectory.path, "config", "startup.conf"),
    );
    final String startupConfigContent = await startupConfigFile.readAsString();

    //Option: Mods Path
    String? modsPath = extractOptionFromConfig(
      configContent: startupConfigContent,
      optionName: "mods-path",
    );
    if (modsPath != null) {
      bluemapArgs.addAll(["--mods", modsPath]);
    }

    //Option: Minecraft Version
    String? mcVersion = extractOptionFromConfig(
      configContent: startupConfigContent,
      optionName: "minecraft-version",
    );
    if (mcVersion != null) {
      bluemapArgs.addAll(["--mc-version", mcVersion]);
    }

    //Option: Max Ram Limit
    String? maxRamLimit = extractOptionFromConfig(
      configContent: startupConfigContent,
      optionName: "max-ram-limit",
    );
    if (maxRamLimit != null) {
      jvmArgs.add("-XX:MaxRAM=$maxRamLimit");
    }
  }

  Future<void> start() async {
    if (_stateController.value != RunningProcessState.stopped) {
      throw Exception("Process is already running!");
    }

    _consoleOutputController.add("Starting...");
    final File bluemapJar = File(p.join(_projectDirectory.path, blueMapCliJarName));

    if (!bluemapJar.existsSync()) {
      _consoleOutputController.add(
        "[ERROR] BlueMap CLI JAR not found."
        " Try closing and re-opening the project to re-download it.",
      );
      return;
    }

    final NonHashedFile nonHashedBlueMapJar = NonHashedFile(bluemapJar);
    final File? hashedBlueMapJar = await nonHashedBlueMapJar.hashFile(blueMapCliJarHash);
    if (hashedBlueMapJar == null) {
      _consoleOutputController.add(
        "[WARNING] BlueMap CLI JAR hash is not valid. "
        "Your BlueMap CLI JAR may be modified, corrupted or outdated.",
      );
    }

    List<String> jvmArgs = [];
    List<String> bluemapArgs = ["--render", "--watch", "--webserver"];
    await fillArgsFromStartupConfig(jvmArgs: jvmArgs, bluemapArgs: bluemapArgs);

    final process = await Process.start(
      _javaPath,
      ["-jar", ...jvmArgs, bluemapJar.path, ...bluemapArgs],
      workingDirectory: _projectDirectory.path,
      mode: ProcessStartMode.normal,
      runInShell: false,
    );
    _process = process;
    _stateController.add(RunningProcessState.starting);

    Stream<String> mergedStream = StreamGroup.merge([
      process.stdout,
      process.stderr,
    ]).transform(utf8.decoder).transform(const LineSplitter());

    _processOutputStreamSub = mergedStream.listen((event) {
      int pleaseCheckIndex = event.indexOf("Please check:");
      if (pleaseCheckIndex != -1 && event.contains("core.conf")) {
        _consoleOutputController.add(
          "${event.substring(0, pleaseCheckIndex)}Please check the Core config in the bar on the left!",
        );
      } else {
        _consoleOutputController.add(event);
      }

      if (event.contains("This usually happens when the configured port ") &&
          event.contains(" is already in use by some other program.")) {
        _consoleOutputController.add(
          " There is probably already a BlueMap process running.\n"
          " Check that you don't have any BlueMap mods installed on your Minecraft client,\n"
          "  and check in your Task Manager for any orphaned BlueMapCLI processes and close them.\n"
          " If you are sure there is no other BlueMap process running and this error persists,\n"
          "  try restarting your computer.",
        );
      }

      if (event.contains("WebServer bound to")) {
        _stateController.add(RunningProcessState.running);
        final String? portText = portExtractionRegex.firstMatch(event)?.group(1);
        _port = int.tryParse(portText ?? "") ?? 8100;
      }
    });

    process.exitCode.then((int value) {
      _stateController.add(RunningProcessState.stopped);
      _processOutputStreamSub?.cancel();
      _consoleOutputController.add("Stopped. ($value)");
    });
  }

  void stop() {
    if (_stateController.value == RunningProcessState.stopped) {
      throw Exception("Process is stopped!");
    }

    bool? success = _process?.kill(ProcessSignal.sigint);
    if (success == false) {
      _consoleOutputController.add("Failed to stop the process.");
    }
    _stateController.add(RunningProcessState.stopping);
  }
}

class ControlRow extends ConsumerWidget {
  const ControlRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final processState = ref.watch(processStateProvider).value;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 150,
          child: ElevatedButton.icon(
            onPressed: switch (processState) {
              RunningProcessState.stopped => () => ref.read(_processProvider)?.start(),
              RunningProcessState.running => () => ref.read(_processProvider)?.stop(),
              _ => null,
            },
            label: Text(switch (processState) {
              RunningProcessState.stopped => "Start",
              RunningProcessState.running => "Stop",
              RunningProcessState.starting => "Starting...",
              RunningProcessState.stopping => "Stopping...",
              null => "Unknown",
            }),
            icon: Icon(switch (processState) {
              RunningProcessState.stopped => Icons.play_arrow,
              RunningProcessState.running => Icons.stop,
              null => Icons.error,
              _ => Icons.hourglass_bottom,
            }),
          ),
        ),
        const SizedBox(width: 16),
        ElevatedButton.icon(
          onPressed: processState == RunningProcessState.running
              ? () async {
                  final int port = ref.read(_processProvider)?.port ?? 8100;
                  if (!await launchUrl(Uri.parse("http://localhost:$port"))) {
                    throw Exception("Could not launch url!");
                  }
                }
              : null,
          label: const Text("Open"),
          icon: const Icon(Icons.open_in_browser),
        ),
        const SizedBox(width: 32),
        const Spacer(),
        const UpdateButton(),
      ],
    );
  }
}

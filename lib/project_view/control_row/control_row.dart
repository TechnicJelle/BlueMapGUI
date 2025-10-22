import "dart:async";
import "dart:convert";
import "dart:io";

import "package:async/async.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:path/path.dart" as p;
import "package:rxdart/rxdart.dart";
import "package:window_manager/window_manager.dart";

import "../../main_menu/projects/projects_screen.dart";
import "../../prefs.dart";
import "../../utils.dart";
import "../../versions.dart";
import "open_button.dart";
import "start_button.dart";
import "update_button.dart";

final portExtractionRegex = RegExp(r"(?:port\s*|:)(\d{4,5})$");

final processProvider = Provider<RunningProcess?>((ref) {
  final Directory? projectDirectory = ref.watch(openProjectProvider);
  if (projectDirectory == null) return null;
  final JavaPath? javaPath = ref.watch(javaPathProvider);
  if (javaPath == null) return null;
  final process = RunningProcess(projectDirectory, javaPath.path);
  ref.onDispose(process.dispose);
  return process;
});

final processOutputProvider = StreamProvider<String>((ref) async* {
  final RunningProcess? process = ref.watch(processProvider);
  if (process == null) return;
  yield "Loading done!";
  yield* process.consoleOutput;
});

final processStateProvider = StreamProvider<RunningProcessState>((ref) async* {
  final RunningProcess? process = ref.watch(processProvider);
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

  StreamSubscription<String>? _processOutputStreamSub;

  RunningProcess(this._projectDirectory, this._javaPath) {
    windowManager.addListener(this);
    // Add this line to override the default close handler
    unawaited(windowManager.setPreventClose(true));
  }

  /// "destructor"
  /// Actually called by the managing Provider
  void dispose() {
    unawaited(windowManager.setPreventClose(false));
    windowManager.removeListener(this);

    //Stop the process when the project is closed
    if (state.value != RunningProcessState.stopped) {
      stop();
    }
  }

  @override
  Future<void> onWindowClose() async {
    final bool isPreventClose = await windowManager.isPreventClose();
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
        await Future<void>.delayed(const Duration(seconds: 1));
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
    final String? modsPath = extractOptionFromConfig(
      configContent: startupConfigContent,
      optionName: "mods-path",
    );
    if (modsPath != null) {
      bluemapArgs.addAll(["--mods", modsPath]);
    }

    //Option: Minecraft Version
    final String? mcVersion = extractOptionFromConfig(
      configContent: startupConfigContent,
      optionName: "minecraft-version",
    );
    if (mcVersion != null) {
      bluemapArgs.addAll(["--mc-version", mcVersion]);
    }

    //Option: Max Ram Limit
    final String? maxRamLimit = extractOptionFromConfig(
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
    final File bluemapJar = getBlueMapJarFile(_projectDirectory);

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

    final List<String> jvmArgs = [];
    final List<String> bluemapArgs = ["--render", "--watch", "--webserver"];
    await fillArgsFromStartupConfig(jvmArgs: jvmArgs, bluemapArgs: bluemapArgs);

    final process = await Process.start(_javaPath, [
      "-jar",
      ...jvmArgs,
      bluemapJar.path,
      ...bluemapArgs,
    ], workingDirectory: _projectDirectory.path);
    _process = process;
    _stateController.add(RunningProcessState.starting);

    final Stream<String> mergedStream = StreamGroup.merge([
      process.stdout,
      process.stderr,
    ]).transform(utf8.decoder).transform(const LineSplitter());

    _processOutputStreamSub = mergedStream.listen((event) {
      final int pleaseCheckIndex = event.indexOf("Please check:");
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
          " Make sure that you don't have BlueMap installed as a mod on your Minecraft client,\n"
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

      if (event.contains("WebServer started")) {
        _consoleOutputController.add(
          " You can now click the open button above, to see your map!",
        );
      }

      if (event.contains("Start updating 0 maps")) {
        _consoleOutputController.add(
          "[WARNING] You don't have any maps, so BlueMap will be doing nothing!\n"
          " You should create a map with the \"New Map\" button on the left.",
        );
      }
    });

    unawaited(
      process.exitCode.then((int value) {
        _stateController.add(RunningProcessState.stopped);
        unawaited(_processOutputStreamSub?.cancel());
        _consoleOutputController.add("Stopped. ($value)");
      }),
    );
  }

  void stop() {
    if (_stateController.value == RunningProcessState.stopped) {
      throw Exception("Process is stopped!");
    }

    final bool? success = _process?.kill(ProcessSignal.sigint);
    if (success == false) {
      _consoleOutputController.add("Failed to stop the process.");
    }
    _stateController.add(RunningProcessState.stopping);
  }
}

class ControlRow extends StatelessWidget {
  const ControlRow({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        StartButton(),
        SizedBox(width: 16),
        OpenButton(),
        SizedBox(width: 32),
        Spacer(),
        UpdateButton(),
      ],
    );
  }
}

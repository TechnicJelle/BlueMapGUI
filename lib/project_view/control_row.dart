import "dart:async";
import "dart:convert";
import "dart:io";
import "dart:ui";

import "package:async/async.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:meta/meta.dart";
import "package:path/path.dart" as p;
import "package:rxdart/rxdart.dart";
import "package:url_launcher/url_launcher.dart";

import "../main.dart";
import "../main_menu/projects/projects_screen.dart";
import "../prefs.dart";
import "../utils.dart";

final portExtractionRegex = RegExp(r"(?:port\s*|:)(\d{4,5})$");

final _processProvider = Provider<RunningProcess?>((ref) {
  final Directory? projectDirectory = ref.watch(openProjectProvider);
  if (projectDirectory == null) return null;
  final String? javaPath = ref.watch(javaPathProvider);
  if (javaPath == null) return null;
  final process = RunningProcess(projectDirectory, javaPath);
  ref.onDispose(() {
    if (process.state.value == RunningProcessState.running) {
      process.stop();
    }
  });
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

enum RunningProcessState {
  stopped,
  starting,
  running,
  stopping,
}

class RunningProcess {
  final Directory _projectDirectory;
  final String _javaPath;

  Process? _process;

  int _port = 8100;
  int get port => _port;

  Stream<String> get consoleOutput => _consoleOutputController.stream;
  final _consoleOutputController = StreamController<String>();

  ValueStream<RunningProcessState> get state => _stateController.stream;
  final _stateController =
      BehaviorSubject<RunningProcessState>.seeded(RunningProcessState.stopped);

  StreamSubscription? _outputStreamSub;

  RunningProcess(this._projectDirectory, this._javaPath) {
    AppLifecycleListener(
      onExitRequested: () async {
        if (_stateController.value == RunningProcessState.running) {
          //start looking for state to change to stopped
          final stopFuture = _stateController.stream
              .firstWhere((state) => state == RunningProcessState.stopped);

          //stop the process
          stop();

          //wait for the process to stop
          await stopFuture;

          //allow user to read the "Stopped." message
          return Future.delayed(const Duration(seconds: 1), () => AppExitResponse.exit);
        }
        return Future.value(AppExitResponse.exit);
      },
    );
  }

  @useResult
  Future<bool> _downloadBlueMap() async {
    final NonHashedFile suspiciousBlueMapJar;
    try {
      suspiciousBlueMapJar = await downloadBlueMap(_projectDirectory);
    } catch (e) {
      _consoleOutputController.add("[ERROR] Failed to download BlueMap CLI JAR: $e");
      return false;
    }
    final bluemapJar = await suspiciousBlueMapJar.hashFile(blueMapCliJarHash);
    if (bluemapJar == null) {
      _consoleOutputController.add("[ERROR] BlueMap CLI JAR hash mismatch!");
      return false;
    }
    _consoleOutputController.add("[INFO] BlueMap CLI JAR downloaded.");
    return true;
  }

  Future<void> start() async {
    if (_stateController.value != RunningProcessState.stopped) {
      throw Exception("Process is already running!");
    }

    _consoleOutputController.add("Starting...");

    final File bluemapJar = File(p.join(_projectDirectory.path, blueMapCliJarName));

    if (bluemapJar.existsSync()) {
      if (!await checkHash(bluemapJar, blueMapCliJarHash)) {
        _consoleOutputController.add("[ERROR] BlueMap CLI JAR hash mismatch!"
            " Re-downloading and overwriting the corrupted file...");
        if (!await _downloadBlueMap()) return;
      }
    } else {
      _consoleOutputController.add("[WARNING] BlueMap CLI JAR not found."
          " Re-downloading...");
      if (!await _downloadBlueMap()) return;
    }

    final process = await Process.start(
      _javaPath,
      ["-jar", bluemapJar.path, "--render", "--watch", "--webserver"],
      workingDirectory: _projectDirectory.path,
      mode: ProcessStartMode.normal,
      runInShell: false,
    );
    _process = process;
    _stateController.add(RunningProcessState.starting);

    Stream<String> mergedStream = StreamGroup.merge([
      process.stdout.transform(utf8.decoder),
      process.stderr.transform(utf8.decoder),
    ]);

    _outputStreamSub = mergedStream.transform(const LineSplitter()).listen((event) {
      int pleaseCheckIndex = event.indexOf("Please check:");
      if (pleaseCheckIndex != -1 && event.contains("core.conf")) {
        _consoleOutputController.add(
          "${event.substring(0, pleaseCheckIndex)}Please check the Core config in the bar on the left!",
        );
      } else {
        _consoleOutputController.add(event);
      }

      if (event.contains("WebServer bound to")) {
        _stateController.add(RunningProcessState.running);
        final String? portText = portExtractionRegex.firstMatch(event)?.group(1);
        _port = int.tryParse(portText ?? "") ?? 8100;
      }
    });

    process.exitCode.then((value) {
      _stateController.add(RunningProcessState.stopped);
      _consoleOutputController.add("Stopped. ($value)");
    });
  }

  void stop() {
    if (_stateController.value != RunningProcessState.running) {
      throw Exception("Process is not running!");
    }

    _process?.kill();
    _outputStreamSub?.cancel();
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
            label: Text(
              switch (processState) {
                RunningProcessState.stopped => "Start",
                RunningProcessState.running => "Stop",
                RunningProcessState.starting => "Starting...",
                RunningProcessState.stopping => "Stopping...",
                null => "Unknown",
              },
            ),
            icon: Icon(
              switch (processState) {
                RunningProcessState.stopped => Icons.play_arrow,
                RunningProcessState.running => Icons.stop,
                null => Icons.error,
                _ => Icons.hourglass_bottom,
              },
            ),
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
      ],
    );
  }
}

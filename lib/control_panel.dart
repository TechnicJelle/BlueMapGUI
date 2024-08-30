import "dart:async";
import "dart:convert";
import "dart:io";

import "package:async/async.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:path/path.dart" as p;
import "package:rxdart/rxdart.dart";
import "package:url_launcher/url_launcher.dart";

import "console.dart";
import "main.dart";

final _processProvider = Provider<RunningProcess?>((ref) {
  final Directory? projectDirectory = ref.watch(projectDirectoryProvider);
  if (projectDirectory == null) return null;
  final process = RunningProcess(projectDirectory);
  ref.onDispose(() => process.stop());
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

  Process? _process;

  Stream<String> get consoleOutput => _consoleOutputController.stream;
  final _consoleOutputController = StreamController<String>();

  ValueStream<RunningProcessState> get state => _stateController.stream;
  final _stateController =
      BehaviorSubject<RunningProcessState>.seeded(RunningProcessState.stopped);

  StreamSubscription? _outputStreamSub;

  RunningProcess(this._projectDirectory); //ctor

  Future<void> start() async {
    if (_stateController.value != RunningProcessState.stopped) {
      throw Exception("Process is already running!");
    }

    _consoleOutputController.add("Starting...");

    final String bluemapJarPath = p.join(_projectDirectory.path, blueMapCliJarName);

    final process = await Process.start(
      "java",
      ["-jar", bluemapJarPath, "--render", "--watch", "--webserver"],
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
      _consoleOutputController.add(event);

      if (event.contains("WebServer started")) {
        _stateController.add(RunningProcessState.running);
      }
    });

    process.exitCode.then((value) {
      _stateController.add(RunningProcessState.stopped);
      _consoleOutputController.add("Stopped.");
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

class ControlPanel extends ConsumerWidget {
  const ControlPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final processState = ref.watch(processStateProvider).value;

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Row(
            children: [
              SizedBox(
                width: 150,
                child: ElevatedButton.icon(
                  onPressed: switch (processState) {
                    RunningProcessState.stopped => () =>
                        ref.read(_processProvider)?.start(),
                    RunningProcessState.running => () =>
                        ref.read(_processProvider)?.stop(),
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
                        if (!await launchUrl(Uri.parse("http://localhost:8100"))) {
                          throw Exception("Could not launch url!");
                        }
                      }
                    : null,
                label: const Text("Open"),
                icon: const Icon(Icons.open_in_browser),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Expanded(child: Console()),
        ],
      ),
    );
  }
}

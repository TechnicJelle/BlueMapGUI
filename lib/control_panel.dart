import "dart:convert";
import "dart:io";

import "package:flutter/material.dart";
import "package:flutter_list_view/flutter_list_view.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:url_launcher/url_launcher.dart";

import "main.dart";
import "utils.dart";

class ControlPanel extends ConsumerStatefulWidget {
  const ControlPanel({super.key});

  @override
  ConsumerState<ControlPanel> createState() => _ControlPanelState();
}

class LogOutput {
  final String message;
  final Color colour;

  LogOutput(this.message, this.colour);
}

class _ControlPanelState extends ConsumerState<ControlPanel> {
  final List<LogOutput> output = [];
  Process? runningProcess;

  Future<void> start() async {
    print("Starting Bluemap");
    final Globals globals = ref.read(projectGlobals).requireValue;

    Process process = await Process.start(
      "java",
      ["-jar", globals.bluemapJar.path, "--render", "--watch", "--webserver"],
      workingDirectory: globals.projectDirectory.path,
      mode: ProcessStartMode.normal,
      runInShell: false,
    );
    process.stdout.transform(utf8.decoder).listen((event) {
      setState(() {
        final Color colour;
        if (event.contains("ERR")) {
          colour = Colors.red;
        } else if (event.contains("WARN")) {
          colour = Colors.yellow;
        } else {
          colour = Colors.white;
        }
        output.add(LogOutput(event, colour));
      });
    });

    runningProcess = process;
  }

  void stop() {
    Process? process = runningProcess;
    if (process != null) {
      print("Stopping Bluemap...");
      bool success = process.kill();
      print("Success: $success");
      process.exitCode.then((value) {
        print("Exit code: $value");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  start();
                },
                label: const Text("Start"),
                icon: const Icon(Icons.play_circle_outline),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () {
                  stop();
                },
                label: const Text("Stop"),
                icon: const Icon(Icons.stop_circle_outlined),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () async {
                  if (!await launchUrl(Uri.parse("http://localhost:8100"))) {
                    throw Exception("Could not launch url!");
                  }
                },
                label: const Text("Open"),
                icon: const Icon(Icons.open_in_browser),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 8, right: 8),
              padding: const EdgeInsets.all(8),
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              child: DefaultTextStyle(
                style: pixelCode,
                child: FlutterListView(
                  reverse: true,
                  delegate: FlutterListViewDelegate(
                    (BuildContext context, int index) {
                      LogOutput entry = output[output.length - 1 - index];
                      return Text(entry.message, style: TextStyle(color: entry.colour));
                    },
                    childCount: output.length,
                    keepPosition: true,
                    keepPositionOffset: 80,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

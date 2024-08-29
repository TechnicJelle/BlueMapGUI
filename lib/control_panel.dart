import "dart:async";
import "dart:convert";
import "dart:io";

import "package:async/async.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:path/path.dart" as p;
import "package:url_launcher/url_launcher.dart";

import "console.dart";
import "main.dart";

class LogNotifier extends AutoDisposeAsyncNotifier<String?> {
  Process? _process;
  StreamSubscription? _streamSub;
  @override
  Future<String?> build() async {
    return null;
  }

  Future<void> start() async {
    state = const AsyncValue.loading();

    final Directory projectDirectory = ref.read(projectDirectoryProvider)!;
    final String bluemapJarPath = p.join(projectDirectory.path, blueMapCliJarName);

    final process = await Process.start(
      "java",
      ["-jar", bluemapJarPath, "--render", "--watch", "--webserver"],
      workingDirectory: projectDirectory.path,
      mode: ProcessStartMode.normal,
      runInShell: false,
    );
    process.exitCode.then((value) {
      print("Exit code: $value");
      state = const AsyncValue.data(null);
      return;
    });

    var mergedStream = StreamGroup.merge([
      process.stdout.transform(utf8.decoder),
      process.stderr.transform(utf8.decoder),
    ]);

    // bool hasWebserverStartedYet = false;
    // process.stdout.transform(utf8.decoder).listen((String event) {
    //   if (event.contains("WebServer started")) {
    //     hasWebserverStartedYet = true;
    //   }
    // });
    //
    // while (!hasWebserverStartedYet) {
    //   await Future.delayed(const Duration(milliseconds: 100));
    // }

    _process = process;
    _streamSub?.cancel();
    _streamSub = mergedStream.listen((String event) {
      print("OUTPUT: $event");
      state = AsyncValue.data(event);
    });
  }

  void stop() {
    Process? process = _process;
    if (process == null) throw Exception("No process to stop!");
    process.kill();
    _streamSub?.cancel();
  }
}

final logNotifierProvider =
    AsyncNotifierProvider.autoDispose<LogNotifier, String?>(() => LogNotifier());

class ControlPanel extends ConsumerWidget {
  const ControlPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logMessage = ref.watch(logNotifierProvider).value;

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
                  if (logMessage == null) {
                    ref.read(logNotifierProvider.notifier).start();
                  } else {
                    ref.read(logNotifierProvider.notifier).stop();
                  }
                },
                label: Text(logMessage == null ? "Start" : "Stop"),
                icon: Icon(logMessage == null ? Icons.play_arrow : Icons.stop),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: logMessage == null
                    ? null
                    : () async {
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
          const Expanded(child: Console()),
        ],
      ),
    );
  }
}

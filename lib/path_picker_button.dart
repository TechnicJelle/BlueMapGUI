import "dart:convert";
import "dart:io";

import "package:file_picker/file_picker.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:path/path.dart" as p;

import "main.dart";
import "prefs.dart";

enum _PickingState {
  nothing,
  picking,
  scanning,
  downloading,
  running,
}

class PathPickerButton extends ConsumerStatefulWidget {
  const PathPickerButton({super.key});

  @override
  ConsumerState<PathPickerButton> createState() => _PathPickerButtonState();
}

class _PathPickerButtonState extends ConsumerState<PathPickerButton> {
  _PickingState _pickingState = _PickingState.nothing;

  @override
  Widget build(BuildContext context) {
    return switch (_pickingState) {
      _PickingState.nothing => ElevatedButton(
          onPressed: () async {
            // == Picking Project Directory ==
            setState(() => _pickingState = _PickingState.picking);
            final String? result = await FilePicker.platform.getDirectoryPath(
              dialogTitle: "Select project folder",
            );
            if (result == null) {
              setState(() => _pickingState = _PickingState.nothing);
              return; // User canceled the picker
            }

            // == Scanning for BlueMap CLI JAR ==
            setState(() => _pickingState = _PickingState.scanning);
            final Directory projectDirectory = Directory(result);
            final contents = projectDirectory.listSync();

            File? bluemapJar;
            for (final file in contents) {
              if (file is! File) continue;
              String fileName = p.split(file.path).last;
              if (fileName == blueMapCliJarName) {
                bluemapJar = file;
                break;
              }
            }

            // == If needed, download BlueMap CLI JAR ==
            if (bluemapJar == null) {
              setState(() => _pickingState = _PickingState.downloading);
              Uri link = Uri.parse(blueMapCliJarUrl);
              final client = HttpClient();
              final request = await client.getUrl(link);
              final response = await request.close();
              bluemapJar = File(p.join(projectDirectory.path, blueMapCliJarName));
              await response.pipe(bluemapJar.openWrite());
              client.close();
            }

            // == Run BlueMap CLI JAR to generate default configs ==
            setState(() => _pickingState = _PickingState.running);
            ProcessResult run = await Process.run(
              "java",
              ["-jar", bluemapJar.path],
              workingDirectory: projectDirectory.path,
              stdoutEncoding: utf8,
            );

            final String stdout = run.stdout;
            if (!stdout.contains("Generated default config files for you")) {
              throw Exception("BlueMap CLI JAR failed to run!");
            }

            Prefs.instance.projectPath = projectDirectory.path;
            ref.invalidate(projectDirectoryProvider);
          },
          child: const Text("Select project folder"),
        ),
      _PickingState.picking => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Waiting for user to pick a folder..."),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 300),
              child: const LinearProgressIndicator(),
            ),
          ],
        ),
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
}

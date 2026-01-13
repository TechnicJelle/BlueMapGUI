import "dart:async";
import "dart:io";

import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:path/path.dart" as p;
import "package:path_provider/path_provider.dart";

import "../../prefs.dart";
import "../project_view.dart";
import "advanced_editor.dart";

class AdvancedModeNotifier extends Notifier<bool> {
  @override
  bool build() {
    return false;
  }

  void enable() {
    state = true;
  }

  void disable() {
    state = false;
  }
}

// I don't want these for providers; too long
// ignore: specify_nonobvious_property_types
final advancedModeProvider = NotifierProvider(AdvancedModeNotifier.new);

class ConfigGUI extends ConsumerStatefulWidget {
  final File openConfig;

  const ConfigGUI(this.openConfig, {super.key});

  @override
  ConsumerState<ConfigGUI> createState() => _ConfigGUIState();
}

class _ConfigGUIState extends ConsumerState<ConfigGUI> {
  String? content;

  @override
  void initState() {
    super.initState();
    unawaited(readFile(widget.openConfig));
  }

  Future<void> readFile(File file) async {
    setState(() {
      content = null;
    });
    final Directory supportDir = await getApplicationSupportDirectory();
    final File hoconReaderFile = File(p.join(supportDir.path, "HOCONReader.jar"));
    if (!hoconReaderFile.existsSync()) {
      final hoconReaderAsset = await rootBundle.load("assets/HOCONReader.jar");
      await hoconReaderFile.writeAsBytes(hoconReaderAsset.buffer.asUint8List());
    }

    final JavaPath javaPath = ref.read(javaPathProvider)!;

    final ProcessResult result = await javaPath.runJar(
      hoconReaderFile,
      processArgs: [file.path],
    );

    //TODO: Error handling!
    final int exitCode = result.exitCode;
    final String stderr = result.stderr.toString();
    final String stdout = result.stdout.toString();

    setState(() {
      content = stdout;
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(advancedModeProvider, (_, next) {
      if (!next) unawaited(readFile(widget.openConfig));
    });

    final bool advancedMode = ref.watch(advancedModeProvider);
    if (advancedMode) {
      return Stack(
        children: [
          AdvancedEditor(widget.openConfig),
          AdvancedModeToggle(widget.openConfig),
        ],
      );
    }

    ref.listen(openConfigProvider, (previous, next) {
      // if (previous != null && next != null) writeFile(previous);
      if (next != null) unawaited(readFile(next));
    });
    final String? thisContent = content;

    return Stack(
      children: [
        if (thisContent == null)
          const Center(child: CircularProgressIndicator())
        else
          Text(thisContent),
        AdvancedModeToggle(widget.openConfig),
      ],
    );
  }
}

class AdvancedModeToggle extends ConsumerWidget {
  final File openConfig;

  const AdvancedModeToggle(this.openConfig, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool advancedMode = ref.watch(advancedModeProvider);
    return Align(
      alignment: .topRight,
      child: Padding(
        padding: const EdgeInsets.only(right: 12, top: 4),
        child: Row(
          mainAxisSize: .min,
          children: [
            const Text("Advanced Mode"),
            Switch(
              value: advancedMode,
              onChanged: (bool value) {
                if (value) {
                  ref.read(advancedModeProvider.notifier).enable();
                } else {
                  ref.read(advancedModeProvider.notifier).disable();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

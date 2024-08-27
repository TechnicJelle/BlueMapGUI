import "dart:async";
import "dart:io";

import "package:flutter/material.dart";
import "package:flutter_code_editor/flutter_code_editor.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "dual_pane.dart";

class ConfigEditor extends ConsumerStatefulWidget {
  final File openConfig;
  const ConfigEditor(this.openConfig, {super.key});

  @override
  ConsumerState<ConfigEditor> createState() => _ConfigEditorState();
}

class _ConfigEditorState extends ConsumerState<ConfigEditor> {
  final controller = CodeController();

  late File openConfig;
  late final Timer autoSaveTimer;
  bool hasChanged = false;

  @override
  void initState() {
    super.initState();
    readFile(widget.openConfig);

    controller.addListener(() => hasChanged = true);

    autoSaveTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      writeFile(openConfig);
    });
  }

  void writeFile(File file) {
    if (!hasChanged) return;

    hasChanged = false;
    file.writeAsString(controller.fullText);
  }

  void readFile(File file) {
    controller.fullText = file.readAsStringSync();
    openConfig = file;
  }

  @override
  void dispose() {
    super.dispose();
    writeFile(openConfig);
    autoSaveTimer.cancel();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(openConfigProvider, (previous, next) {
      if (previous != null && next != null) writeFile(previous);
      if (next != null) readFile(next);
    });
    return SingleChildScrollView(
      child: CodeField(
        textStyle: const TextStyle(fontFamily: "monospace"),
        controller: controller,
        minLines: null,
        maxLines: null,
        // expands: true,
      ),
    );
  }
}

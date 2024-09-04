import "dart:async";
import "dart:io";

import "package:flutter/material.dart";
import "package:flutter_code_editor/flutter_code_editor.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "dual_pane.dart";
import "utils.dart";

class ConfigEditor extends ConsumerStatefulWidget {
  final File openConfig;

  const ConfigEditor(this.openConfig, {super.key});

  @override
  ConsumerState<ConfigEditor> createState() => _ConfigEditorState();
}

class _ConfigEditorState extends ConsumerState<ConfigEditor> {
  final codeController = CodeController();
  final vScrollController = ScrollController();

  late File openConfig;
  late final Timer autoSaveTimer;
  bool hasChanged = false;

  @override
  void initState() {
    super.initState();
    readFile(widget.openConfig);

    autoSaveTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      writeFile(openConfig);
    });
  }

  void writeFile(File file) {
    if (!hasChanged) return;

    hasChanged = false;
    file.writeAsString(codeController.fullText);
  }

  void readFile(File file) {
    codeController.fullText = file.readAsStringSync();
    openConfig = file;
  }

  @override
  void dispose() {
    super.dispose();
    writeFile(openConfig);
    autoSaveTimer.cancel();
    codeController.dispose();
    vScrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(openConfigProvider, (previous, next) {
      if (previous != null && next != null) writeFile(previous);
      if (next != null) readFile(next);
    });
    return SingleChildScrollView(
      controller: vScrollController,
      child: CodeField(
        onChanged: (_) => hasChanged = true,
        textStyle: pixelCode,
        controller: codeController,
        minLines: null,
        maxLines: null,
        // expands: true,
      ),
    );
  }
}

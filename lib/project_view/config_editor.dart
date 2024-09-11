import "dart:async";
import "dart:io";

import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:re_editor/re_editor.dart";
import "package:re_highlight/languages/yaml.dart" show langYaml;
import "package:re_highlight/styles/ir-black.dart" show irBlackTheme;

import "../utils.dart";
import "project_view.dart";

class ConfigEditor extends ConsumerStatefulWidget {
  final File openConfig;

  const ConfigEditor(this.openConfig, {super.key});

  @override
  ConsumerState<ConfigEditor> createState() => _ConfigEditorState();
}

class _ConfigEditorState extends ConsumerState<ConfigEditor> {
  final codeController = CodeLineEditingController();

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
    file.writeAsString(codeController.text);
  }

  void readFile(File file) {
    codeController.text = file.readAsStringSync();
    codeController.clearHistory();
    openConfig = file;
  }

  @override
  void dispose() {
    writeFile(openConfig);
    autoSaveTimer.cancel();
    codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(openConfigProvider, (previous, next) {
      if (previous != null && next != null) writeFile(previous);
      if (next != null) readFile(next);
    });
    return ScrollbarTheme(
      data: Theme.of(context).scrollbarTheme.copyWith(
            thumbColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.dragged)) return Colors.white38;
              if (states.contains(WidgetState.hovered)) return Colors.white30;
              return Colors.white24;
            }),
            trackColor: WidgetStateProperty.all(Colors.white10),
            trackBorderColor: WidgetStateProperty.all(Colors.white12),
          ),
      child: CodeEditor(
        indicatorBuilder: (context, editingController, chunkController, notifier) {
          return Padding(
            padding: const EdgeInsets.only(left: 16),
            child: DefaultCodeLineNumber(
              notifier: notifier,
              controller: editingController,
            ),
          );
        },
        style: CodeEditorStyle(
          textColor: Colors.white,
          backgroundColor: Colors.grey.shade900,
          fontFamily: pixelCode.fontFamily,
          fontSize: pixelCode.fontSize,
          fontHeight: pixelCode.height,
          codeTheme: CodeHighlightTheme(
            theme: irBlackTheme,
            languages: {
              "yaml": CodeHighlightThemeMode(mode: langYaml),
            },
          ),
        ),
        onChanged: (_) => hasChanged = true,
        controller: codeController,
        wordWrap: false,
        sperator: const SizedBox(width: 12),
        scrollbarBuilder: (context, child, details) {
          return Scrollbar(
            controller: details.controller,
            child: child,
          );
        },
      ),
    );
  }
}

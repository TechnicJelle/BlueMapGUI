import "dart:async";
import "dart:io";

import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:path/path.dart" as p;
import "package:re_editor/re_editor.dart";
import "package:re_highlight/languages/yaml.dart" show langYaml;
import "package:re_highlight/styles/ir-black.dart" show irBlackTheme;

import "../../project_configs_provider.dart";
import "../../utils.dart";
import "models/base.dart";

class AdvancedEditor extends ConsumerStatefulWidget {
  final ConfigFile openConfig;

  const AdvancedEditor(this.openConfig, {super.key});

  @override
  ConsumerState<AdvancedEditor> createState() => _AdvancedEditorState();
}

class _AdvancedEditorState extends ConsumerState<AdvancedEditor> {
  final codeController = CodeLineEditingController();

  ConfigFile? openConfig;
  late final Timer autoSaveTimer;
  bool hasChanged = false;
  int? errorOnLine;

  @override
  void initState() {
    super.initState();
    unawaited(readFile(widget.openConfig));

    autoSaveTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      final oc = openConfig;
      if (oc != null) writeFile(oc);
    });
  }

  void writeFile(ConfigFile file) {
    if (!hasChanged) return;

    hasChanged = false;
    unawaited(_write(file.file));
  }

  Future<void> _write(File file) async {
    await file.writeAsString(codeController.text);
    final project = ref.read(projectProviderNotifier);

    try {
      await project.refreshConfigFile(file);
      errorOnLine = null;
    } on ConfigFileCastException catch (e) {
      //TODO: Figure out a way to display this error to the user too
      debugPrint(e.message);
    } on ConfigFileLoadException catch (e) {
      final RegExp lineFinder = RegExp(r"line\s*(\d+)");
      final match = lineFinder.firstMatch(e.stderr);
      if (match != null) {
        final String? lineNumber = match[1];
        if (lineNumber != null) {
          setState(() {
            errorOnLine = int.tryParse(lineNumber);
            // We add 5 to make up for the header that each config has
            if (errorOnLine != null) errorOnLine = errorOnLine! + 5;
          });
        }
      }
    }
  }

  Future<void> readFile(ConfigFile file) async {
    //do not re-open files that are already open
    if (p.equals(file.path, openConfig?.path ?? "")) return;

    codeController.text = await file.file.readAsString();
    codeController.clearHistory();
    openConfig = file;
    hasChanged = false;
    errorOnLine = null;
  }

  @override
  void dispose() {
    if (hasChanged) {
      //when advanced editor is closed, we need to save sync, so that the data is ready to be parsed into a model in the next frame
      openConfig!.file.writeAsStringSync(codeController.text);
    }
    autoSaveTimer.cancel();
    codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(openConfigProvider, (previous, next) {
      if (previous != null) writeFile(previous);
      if (next != null) unawaited(readFile(next));
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
        padding: const .only(right: 32),
        indicatorBuilder: (context, editingController, chunkController, notifier) {
          const String errorIndicator = "Error";
          return Padding(
            padding: const EdgeInsets.only(left: 16),
            child: DefaultCodeLineNumber(
              notifier: notifier,
              controller: editingController,
              customLineIndex2Text: (lineIndex) {
                final int lineNumber = lineIndex + 1;
                if (lineNumber == errorOnLine) {
                  return errorIndicator;
                } else {
                  return lineNumber.toString();
                }
              },
              minNumberCount: errorOnLine == null ? null : errorIndicator.length,
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
            languages: {"yaml": CodeHighlightThemeMode(mode: langYaml)},
          ),
        ),
        onChanged: (_) => hasChanged = true,
        controller: codeController,
        wordWrap: false,
        sperator: const SizedBox(width: 12),
        scrollbarBuilder: (context, child, details) {
          return Scrollbar(controller: details.controller, child: child);
        },
      ),
    );
  }
}

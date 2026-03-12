import "dart:async";
import "dart:io";

import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:path/path.dart" as p;
import "package:re_editor/re_editor.dart";
import "package:re_highlight/languages/yaml.dart" show langYaml;
import "package:re_highlight/styles/a11y-light.dart" show a11YLightTheme;
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
  String? problemDescription;
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
    final project = ref.read(projectProviderNotifier);
    await file.writeAsString(codeController.text);

    await project.refreshConfigFile(file);
  }

  Future<void> readFile(ConfigFile file) async {
    file.modelOrProblem.getLeft().match(
      () {
        setState(() {
          errorOnLine = null;
          problemDescription = null;
        });
      },
      (FileConfigFileLoadProblem e) {
        switch (e) {
          case FileConfigFileCastProblem():
            setState(() {
              problemDescription =
                  "${e.getDetails()}"
                  "\nThere is likely a critical option renamed, removed, or commented out.";
            });
          case FileConfigFileParseProblem():
            final int? lineNumber = e.getLine();
            if (lineNumber != null) {
              setState(() {
                errorOnLine = lineNumber;
                problemDescription = "\n${e.getDetailsOnly()}";
              });
            }
        }
      },
    );
    //do not re-open files that are already open
    if (p.equals(file.path, openConfig?.path ?? "")) return;

    //wait a frame for the file to be properly saved on dispose of the simple editor
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      codeController.text = await file.file.readAsString();
      codeController.clearHistory();
      openConfig = file;
      hasChanged = false;
    });
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

    final brightness = Theme.brightnessOf(context);
    final Map<String, TextStyle> codeTheme = {}
      ..addAll(switch (brightness) {
        Brightness.dark => irBlackTheme,
        Brightness.light => a11YLightTheme,
      });
    codeTheme["comment"] = const TextStyle(color: Colors.green);

    return _ProblemWrapper(
      problemText: problemDescription == null
          ? null
          : Text(
              "Problem found${errorOnLine != null ? " on line $errorOnLine" : ""}: $problemDescription",
              style: pixelCode300,
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
          fontFamily: pixelCode200.fontFamily,
          fontSize: pixelCode200.fontSize,
          fontHeight: pixelCode200.height,
          codeTheme: CodeHighlightTheme(
            theme: codeTheme,
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

class _ProblemWrapper extends StatelessWidget {
  final Text? problemText;
  final CodeEditor child;

  const _ProblemWrapper({
    required this.problemText,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        if (problemText != null)
          Padding(
            padding: const EdgeInsets.only(left: 8, top: 8),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.red,
              ),
              child: problemText,
            ),
          ),
        Expanded(
          child: ScrollbarTheme(
            data: Theme.of(context).scrollbarTheme.copyWith(
              thumbColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.dragged)) return Colors.white38;
                if (states.contains(WidgetState.hovered)) return Colors.white30;
                return Colors.white24;
              }),
              trackColor: WidgetStateProperty.all(Colors.white10),
              trackBorderColor: WidgetStateProperty.all(Colors.white12),
            ),
            child: child,
          ),
        ),
      ],
    );
  }
}

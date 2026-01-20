import "dart:async";
import "dart:io";

import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
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

  late ConfigFile openConfig;
  late final Timer autoSaveTimer;
  bool hasChanged = false;

  @override
  void initState() {
    super.initState();
    unawaited(readFile(widget.openConfig));

    autoSaveTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      writeFile(openConfig);
    });
  }

  void writeFile(ConfigFile file) {
    if (!hasChanged) return;

    hasChanged = false;
    unawaited(
      file.file.writeAsString(codeController.text).then((File file) {
        unawaited(ref.read(projectProvider.notifier).refreshConfigFile(file));
      }),
    );
  }

  Future<void> readFile(ConfigFile file) async {
    codeController.text = await file.file.readAsString();
    codeController.clearHistory();
    openConfig = file;
  }

  @override
  void dispose() {
    if (hasChanged) {
      //when advanced editor is closed, we need to save sync, so that the data is ready to be parsed into a model in the next frame
      openConfig.file.writeAsStringSync(codeController.text);
    }
    autoSaveTimer.cancel();
    codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(
      projectProvider.select(
        (project) => project?.openConfig,
      ),
      (previous, next) {
        if (previous != null && next != null) writeFile(previous);
        if (next != null) unawaited(readFile(next));
      },
    );
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

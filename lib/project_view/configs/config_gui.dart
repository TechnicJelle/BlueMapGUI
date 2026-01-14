import "dart:async";
import "dart:io";

import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../prefs.dart";
import "../project_view.dart";
import "advanced_editor.dart";
import "models/base.dart";
import "views/base.dart";

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
  BaseConfigView? configWidget;

  @override
  void initState() {
    super.initState();
    unawaited(readFile(widget.openConfig));
  }

  Future<void> readFile(File file) async {
    setState(() {
      configWidget = null;
    });

    final JavaPath javaPath = ref.read(javaPathProvider)!;
    final ConfigFile? configFile = await ConfigFile.fromFile(file, javaPath);
    if (configFile == null) return;

    setState(() {
      configWidget = BaseConfigView(configFile);
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
          _AdvancedModeToggle(widget.openConfig),
        ],
      );
    }

    ref.listen(openConfigProvider, (_, next) {
      if (next != null) unawaited(readFile(next));
    });
    final BaseConfigView? thisConfig = configWidget;

    return Stack(
      children: [
        if (thisConfig == null)
          const Center(child: CircularProgressIndicator())
        else
          thisConfig,
        _AdvancedModeToggle(widget.openConfig),
      ],
    );
  }
}

class _AdvancedModeToggle extends ConsumerWidget {
  final File openConfig;

  const _AdvancedModeToggle(this.openConfig);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool advancedMode = ref.watch(advancedModeProvider);
    return Align(
      alignment: .topRight,
      child: Padding(
        padding: const EdgeInsets.only(right: 12, top: 6),
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

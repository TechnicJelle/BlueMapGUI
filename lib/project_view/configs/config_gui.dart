import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../project_configs_provider.dart";
import "advanced_editor.dart";
import "models/base.dart";
import "views/base.dart";

class AdvancedModeNotifier extends Notifier<bool> {
  @override
  bool build() {
    return false;
  }

  @override
  set state(bool newState) => super.state = newState;
}

// I don't want these for providers; too long
// ignore: specify_nonobvious_property_types
final advancedModeProvider = NotifierProvider(AdvancedModeNotifier.new);

class ConfigGUI extends ConsumerStatefulWidget {
  const ConfigGUI({super.key});

  @override
  ConsumerState<ConfigGUI> createState() => _ConfigGUIState();
}

class _ConfigGUIState extends ConsumerState<ConfigGUI> {
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    final ConfigFile openConfig = ref.watch(openConfigProvider)!;
    final bool advancedMode = ref.watch(advancedModeProvider);

    return Stack(
      children: [
        if (loading)
          const Center(child: CircularProgressIndicator())
        else if (advancedMode)
          AdvancedEditor(openConfig)
        else
          BaseConfigView(openConfig),
        Align(
          alignment: .topRight,
          child: Padding(
            padding: const EdgeInsets.only(right: 12, top: 6),
            child: Row(
              mainAxisSize: .min,
              children: [
                const Text("Advanced Mode"),
                Switch(
                  value: advancedMode,
                  onChanged: loading
                      ? null
                      : (bool justSwitchedToAdvancedMode) async {
                          ref.read(advancedModeProvider.notifier).state =
                              justSwitchedToAdvancedMode;
                          setState(() {
                            if (!justSwitchedToAdvancedMode) loading = true;
                          });

                          // advanced mode was just disabled, so we need to re-read the file into the models again
                          if (!justSwitchedToAdvancedMode) {
                            //wait a frame for the file to be properly saved on dispose of the advanced editor
                            WidgetsBinding.instance.addPostFrameCallback((_) async {
                              await ref
                                  .read(projectProviderNotifier)
                                  .refreshConfigFile(openConfig.file);

                              setState(() => loading = false);
                            });
                          }
                        },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

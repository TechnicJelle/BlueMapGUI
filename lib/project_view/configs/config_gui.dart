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

  // The function name and lack of other parameters makes it clear enough
  // ignore: avoid_positional_boolean_parameters, use_setters_to_change_properties
  void set(bool newState) {
    state = newState;
  }
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
            padding: const EdgeInsets.only(right: 12, top: 8),
            child: Row(
              mainAxisSize: .min,
              children: [
                Text(
                  "Advanced Mode",
                  style: TextStyle(
                    color: advancedMode
                        ? Colors.white
                        : TextTheme.of(context).bodyLarge?.color,
                  ),
                ),
                Switch(
                  value: advancedMode,
                  onChanged: loading
                      ? null
                      : (bool justSwitchedToAdvancedMode) async {
                          ref
                              .read(advancedModeProvider.notifier)
                              .set(justSwitchedToAdvancedMode);
                          setState(() {
                            if (!justSwitchedToAdvancedMode) loading = true;
                          });

                          // advanced mode was just disabled, so we need to re-read the file into the models again
                          if (!justSwitchedToAdvancedMode) {
                            //wait a frame for the file to be properly saved on dispose of the advanced editor
                            //this cannot be called there, because it's not allowed to red.read in a dispose()
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

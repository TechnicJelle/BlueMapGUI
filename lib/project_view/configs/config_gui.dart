import "dart:async";

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
                          ref
                              .read(advancedModeProvider.notifier)
                              .set(justSwitchedToAdvancedMode);
                          setState(() {
                            if (!justSwitchedToAdvancedMode) loading = true;
                          });

                          // advanced mode was just disabled, so we need to re-read the file into the models again
                          if (!justSwitchedToAdvancedMode) {
                            //wait a frame for the file to be properly saved on dispose of the advanced editor
                            WidgetsBinding.instance.addPostFrameCallback((_) async {
                              try {
                                await ref
                                    .read(projectProviderNotifier)
                                    .refreshConfigFile(openConfig.file);
                              } on ConfigFileCastException catch (e) {
                                if (context.mounted) {
                                  showError([
                                    const Text(
                                      """
There is a critical option missing or commented.
You need to add it (back) or uncomment it, before you can go back to Simple Mode.""",
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      e.message,
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ]);
                                }
                              } on ConfigFileLoadException catch (e) {
                                if (context.mounted) {
                                  showError([
                                    const Text(
                                      """
There is likely a syntax error in this config.
You need to fix that first, before you can go back to Simple Mode.
See below for more details:""",
                                    ),
                                    const SizedBox(height: 8),
                                    Flexible(
                                      child: SingleChildScrollView(
                                        child: Text(
                                          e.stderr,
                                          style: Theme.of(context).textTheme.bodySmall,
                                        ),
                                      ),
                                    ),
                                  ]);
                                }
                              }
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

  void showError(List<Widget> children) {
    ref.read(advancedModeProvider.notifier).set(true);
    unawaited(
      showDialog<void>(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: const Text(
              "An error occurred while switching to Simple Mode",
              style: TextStyle(color: Colors.red),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
            actions: [
              TextButton(
                child: const Text("Understood"),
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

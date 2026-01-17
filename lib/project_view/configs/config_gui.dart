import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../project_configs_provider.dart";
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

class ConfigGUI extends ConsumerWidget {
  const ConfigGUI({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //TODO: Reinstate the advanced mode
    // ref.listen(advancedModeProvider, (_, next) {
    //   if (!next) readFile(widget.openConfig);
    // });
    //
    // final bool advancedMode = ref.watch(advancedModeProvider);
    // if (advancedMode) {
    //   return Stack(
    //     children: [
    //       AdvancedEditor(widget.openConfig),
    //       const _AdvancedModeToggle(),
    //     ],
    //   );
    // }

    final ConfigFile openConfig = ref.watch(openConfigProvider)!;
    print(openConfig.path);

    return Stack(
      children: [
        BaseConfigView(openConfig),
        const _AdvancedModeToggle(),
      ],
    );
  }
}

class _AdvancedModeToggle extends ConsumerWidget {
  const _AdvancedModeToggle();

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

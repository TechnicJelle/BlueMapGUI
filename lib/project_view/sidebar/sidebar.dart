import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../project_configs_provider.dart";
import "../configs/config_gui.dart";
import "../configs/models/base.dart";
import "config_tile.dart";
import "new_map_button.dart";

class Sidebar extends ConsumerWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mainConfigs = ref.watch(mainConfigsProvider)!;
    final mapConfigs = ref.watch(mapConfigsProvider)!;
    final bool advancedMode = ref.watch(advancedModeProvider);

    return ListView(
      children: [
        const _ControlPanelTile(),
        const SizedBox(height: 32),
        const Text(" Configs"),
        for (final ConfigFile config in mainConfigs)
          ConfigTile(
            config,
            prettifyName: true,
          ),
        const SizedBox(height: 32),
        const Text(" Maps"),
        //don't show the reorder handles when in advanced mode, because the text editor does not handle config options being changed from outside of itself
        //and it makes enough sense to not show them then, so i think this is a fine fix
        if (advancedMode)
          ListView.builder(
            shrinkWrap: true,
            itemCount: mapConfigs.length,
            itemBuilder: (context, index) => ConfigTile(
              mapConfigs[index],
              key: ValueKey(index),
            ),
          )
        else
          ReorderableListView.builder(
            shrinkWrap: true,
            itemCount: mapConfigs.length,
            itemBuilder: (context, index) => ConfigTile(
              mapConfigs[index],
              key: ValueKey(index),
            ),
            onReorder: (int oldIndex, int newIndex) {
              ref.read(projectProviderNotifier).swapMaps(oldIndex, newIndex);
            },
          ),
        const NewMapButton(),
      ],
    );
  }
}

class _ControlPanelTile extends ConsumerWidget {
  const _ControlPanelTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ConfigFile? openConfig = ref.watch(openConfigProvider);

    return ListTile(
      title: const Text("Control Panel"),
      onTap: () {
        ref.read(projectProviderNotifier).closeConfig();
      },
      selected: openConfig == null,
    );
  }
}

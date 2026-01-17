import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../project_configs_provider.dart";
import "../configs/models/base.dart";
import "config_tile.dart";
import "new_map_button.dart";

class Sidebar extends ConsumerWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ProjectConfigs configs = ref.watch(projectProvider)!;

    return ListView(
      children: [
        const _ControlPanelTile(),
        const SizedBox(height: 32),
        const Text(" Configs"),
        for (final ConfigFile config in configs.mainConfigs)
          ConfigTile(
            config,
            prettifyName: true,
          ),
        const SizedBox(height: 32),
        const Text(" Maps"),
        ReorderableListView.builder(
          shrinkWrap: true,
          itemCount: configs.mapConfigs.length,
          itemBuilder: (context, index) => ConfigTile(
            configs.mapConfigs[index],
            key: ValueKey(index),
          ),
          onReorder: (int oldIndex, int newIndex) {
            ref.read(projectProvider.notifier).swapMaps(oldIndex, newIndex);
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
    final ConfigFile? openConfig = ref.watch(projectProvider)!.openConfig;

    return ListTile(
      title: const Text("Control Panel"),
      onTap: () {
        ref.read(projectProvider.notifier).closeConfig();
      },
      selected: openConfig == null,
    );
  }
}

import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../project_configs_provider.dart";
import "../configs/config_gui.dart";
import "../configs/models/base.dart";
import "../control_row/control_row.dart";
import "config_tile.dart";
import "new_map_button.dart";

class Sidebar extends ConsumerWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mainConfigs = ref.watch(mainConfigsProvider)!;

    return ListView(
      children: [
        const _ControlPanelTile(),
        const Divider(height: 2),
        const _SidebarHeading("Configs"),
        for (final ConfigFile config in mainConfigs)
          ConfigTile(
            config,
            prettifyName: true,
          ),
        const Divider(height: 2),
        const _SidebarHeading("Maps"),
        const _MapsTiles(),
        const NewMapButton(),
      ],
    );
  }
}

class _SidebarHeading extends StatelessWidget {
  final String text;

  const _SidebarHeading(this.text);

  static const configHeadingPadding = EdgeInsets.only(left: 14, top: 16, bottom: 8);
  static const configHeadingStyle = TextStyle(fontSize: 20, fontWeight: .w400);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: configHeadingPadding,
      child: Text(text, style: configHeadingStyle),
    );
  }
}

class _ControlPanelTile extends ConsumerWidget {
  const _ControlPanelTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ConfigFile? openConfig = ref.watch(openConfigProvider);
    final RunningProcessState? processState = ref.watch(processStateProvider).value;

    return Tooltip(
      message: "Status: ${processState?.name}",
      waitDuration: Durations.long4,
      child: ListTile(
        title: const Text("Control Panel"),
        trailing: openConfig != null && processState != .stopped
            ? processState == .running
                  ? const Icon(Icons.play_arrow)
                  : const Icon(Icons.hourglass_bottom)
            : null,
        onTap: () {
          ref.read(projectProviderNotifier).closeConfig();
        },
        selected: openConfig == null,
      ),
    );
  }
}

class AllowMapReorderingNotifier extends Notifier<bool> {
  @override
  bool build() {
    final bool advancedMode = ref.watch(advancedModeProvider);
    final mapConfigs = ref.watch(mapConfigsProvider);
    if (mapConfigs == null) return advancedMode;
    final bool aMapConfigHasAProblem = mapConfigs
        .map((config) => config.modelOrProblem.toNullable())
        .any((element) => element == null);

    return advancedMode || aMapConfigHasAProblem;
  }
}

// I don't want these for providers; too long
// ignore: specify_nonobvious_property_types
final allowMapReorderingProvider = NotifierProvider(AllowMapReorderingNotifier.new);

class _MapsTiles extends ConsumerWidget {
  const _MapsTiles();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mapConfigs = ref.watch(mapConfigsProvider)!;
    final bool allowMapReordering = ref.watch(allowMapReorderingProvider);

    //don't show the reorder handles when in advanced mode, because the text editor does not handle config options being changed from outside of itself
    //and it makes enough sense to not show them then, so i think this is a fine fix
    return allowMapReordering
        ? ListView.builder(
            shrinkWrap: true,
            itemCount: mapConfigs.length,
            itemBuilder: (context, index) => ConfigTile(
              mapConfigs[index],
              key: ValueKey(index),
            ),
          )
        : ReorderableListView.builder(
            shrinkWrap: true,
            itemCount: mapConfigs.length,
            itemBuilder: (context, index) => ConfigTile(
              mapConfigs[index],
              key: ValueKey(index),
            ),
            onReorder: (int oldIndex, int newIndex) {
              ref.read(projectProviderNotifier).swapMaps(oldIndex, newIndex);
            },
          );
  }
}

import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../project_configs_provider.dart";
import "configs/config_gui.dart";
import "control_panel.dart";
import "sidebar/sidebar.dart";

class ProjectView extends ConsumerWidget {
  const ProjectView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isConfigOpen = ref.watch(
      openConfigProvider.select((config) => config != null),
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          constraints: const BoxConstraints(maxWidth: 200),
          child: const Sidebar(),
        ),
        const VerticalDivider(width: 2),
        Expanded(
          child: isConfigOpen ? const ConfigGUI() : const ControlPanel(),
        ),
      ],
    );
  }
}

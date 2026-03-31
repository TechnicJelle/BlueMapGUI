import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../project_configs_provider.dart";
import "configs/advanced_editor.dart";
import "configs/advanced_mode_toggle.dart";
import "configs/models/base.dart";
import "configs/views/base.dart";
import "control_panel.dart";
import "sidebar/project_sidebar.dart";

class ProjectView extends ConsumerWidget {
  const ProjectView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ConfigFile? openConfig = ref.watch(openConfigProvider);
    final AdvancedMode advancedMode = ref.watch(advancedModeProvider);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const ProjectSidebar(),
        Expanded(
          child: openConfig == null
              ? const ControlPanel()
              : Stack(
                  children: [
                    advancedMode.when(
                      data: (enabled) => enabled
                          ? AdvancedEditor(openConfig)
                          : LayoutBuilder(
                              builder: (context, constraints) {
                                final configView = BaseConfigView(openConfig);
                                return Center(
                                  child: constraints.maxWidth < 1900
                                      ? configView
                                      : ConstrainedBox(
                                          constraints: const .new(maxWidth: 1500),
                                          child: configView,
                                        ),
                                );
                              },
                            ),
                      loading: () => const Center(child: CircularProgressIndicator()),
                    ),
                    const AdvancedModeToggle(),
                  ],
                ),
        ),
      ],
    );
  }
}

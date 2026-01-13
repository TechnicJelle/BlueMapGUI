import "dart:io";

import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "configs/config_gui.dart";
import "control_panel.dart";
import "sidebar/sidebar.dart";

class OpenFileNotifier extends Notifier<File?> {
  @override
  File? build() {
    return null;
  }

  // Notifiers should not use setters
  // ignore: use_setters_to_change_properties
  void open(File file) {
    state = file;
  }

  void close() {
    state = null;
  }
}

// I don't want these for providers; too long
// ignore: specify_nonobvious_property_types
final openConfigProvider = NotifierProvider(OpenFileNotifier.new);

class ProjectView extends ConsumerWidget {
  const ProjectView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final File? openConfig = ref.watch(openConfigProvider);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          constraints: const BoxConstraints(maxWidth: 200),
          child: const Sidebar(),
        ),
        const VerticalDivider(width: 2),
        Expanded(
          child: openConfig == null ? const ControlPanel() : ConfigGUI(openConfig),
        ),
      ],
    );
  }
}

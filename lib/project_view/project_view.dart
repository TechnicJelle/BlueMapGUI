import "dart:io";

import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "config_editor.dart";
import "control_panel.dart";
import "sidebar/sidebar.dart";

class OpenFileNotifier extends Notifier<File?> {
  @override
  File? build() {
    return null;
  }

  void open(File file) {
    state = file;
  }

  void close() {
    state = null;
  }
}

final openConfigProvider =
    NotifierProvider<OpenFileNotifier, File?>(() => OpenFileNotifier());

class ProjectView extends ConsumerWidget {
  const ProjectView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    File? openConfig = ref.watch(openConfigProvider);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          constraints: const BoxConstraints(maxWidth: 200),
          child: const Sidebar(),
        ),
        Expanded(
          child: openConfig == null ? const ControlPanel() : ConfigEditor(openConfig),
        ),
      ],
    );
  }
}

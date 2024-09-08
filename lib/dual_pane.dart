import "dart:io";

import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "config_editor.dart";
import "config_tree.dart";
import "console.dart";
import "control_row.dart";

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

class DualPane extends ConsumerWidget {
  const DualPane({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    File? openConfig = ref.watch(openConfigProvider);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          constraints: const BoxConstraints(maxWidth: 200),
          child: const ConfigTree(),
        ),
        Expanded(
          child: openConfig == null
              ? const Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      ControlRow(),
                      SizedBox(height: 16),
                      Expanded(child: Console()),
                    ],
                  ),
                )
              : ConfigEditor(openConfig),
        ),
      ],
    );
  }
}

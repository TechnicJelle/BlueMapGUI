import "dart:io";

import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:path/path.dart" as p;

import "../../utils.dart";
import "../project_view.dart";

class ConfigTile extends ConsumerWidget {
  final File configFile;

  const ConfigTile(this.configFile, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final File? openConfig = ref.watch(openConfigProvider);

    return ListTile(
      title: Text(_toHuman(configFile)),
      onTap: () {
        ref.read(openConfigProvider.notifier).open(configFile);
      },
      selected: openConfig == configFile,
    );
  }

  static String _toHuman(File file) {
    final String name = p.basename(file.path).replaceAll(".conf", "").capitalize();
    if (name == "Sql") return "SQL";
    return name;
  }
}

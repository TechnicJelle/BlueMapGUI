import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:path/path.dart" as p;

import "../../project_configs_provider.dart";
import "../../utils.dart";
import "../configs/models/base.dart";

class ConfigTile extends ConsumerWidget {
  final ConfigFile configFile;
  final bool prettifyName;

  const ConfigTile(
    this.configFile, {
    this.prettifyName = false,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ConfigFile? openConfig = ref.watch(openConfigProvider);

    final String configName = configFile.name;
    return ListTile(
      title: Text(prettifyName ? configName.capitalize() : configName),
      onTap: () {
        ref.read(projectProviderNotifier).openConfig(configFile);
      },
      selected: openConfig != null && p.equals(openConfig.path, configFile.path),
    );
  }
}

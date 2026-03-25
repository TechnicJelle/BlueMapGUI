import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:path/path.dart" as p;

import "../../project_configs_provider.dart";
import "../../sidebar.dart";
import "../../utils.dart";
import "../configs/models/base.dart";
import "../configs/models/map.dart";

class ConfigTile extends ConsumerWidget {
  final ConfigFile configFile;

  const ConfigTile(this.configFile, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ConfigFile? openConfig = ref.watch(openConfigProvider);

    final filename = configFile.name;
    Widget? mapId = Tooltip(
      message: "Map ID: $filename",
      child: Text(filename),
    );
    final String configName = configFile.modelOrProblem.match(
      (_) => filename, // Broken map config
      (BaseConfigModel r) {
        if (r is MapConfigModel) {
          // Functional map config
          return r.name;
        } else {
          // Normal (non-map) configs
          mapId = null;
          return filename.capitalize();
        }
      },
    );

    return SidebarTab(
      title: configName,
      subtitle: mapId,
      trailing: configFile.modelOrProblem.isLeft()
          ? const Tooltip(
              message: "Error in config",
              child: Icon(Icons.warning_amber_rounded, color: Colors.red),
            )
          : null,
      onTap: () {
        ref.read(projectProviderNotifier).openConfig(configFile);
      },
      selected: openConfig != null && p.equals(openConfig.path, configFile.path),
    );
  }
}

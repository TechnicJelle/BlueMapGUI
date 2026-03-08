import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:path/path.dart" as p;

import "../../project_configs_provider.dart";
import "../../utils.dart";
import "../configs/models/base.dart";
import "../configs/models/map.dart";
import "sidebar.dart";

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
    final bool mapReorderingAllowed = ref.watch(allowMapReorderingProvider);
    final double warningSpacing =
        !mapReorderingAllowed && (configFile is ConfigFile<MapConfigModel>) ? 22 : 0;

    final String configName = configFile.name;
    return ListTile(
      title: Row(
        mainAxisAlignment: .spaceBetween,
        children: [
          Text(prettifyName ? configName.capitalize() : configName),
          if (configFile.modelOrProblem.isLeft())
            Padding(
              padding: EdgeInsets.only(right: warningSpacing),
              child: const Tooltip(
                message: "Error in config",
                child: Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.red,
                ),
              ),
            ),
        ],
      ),
      onTap: () {
        ref.read(projectProviderNotifier).openConfig(configFile);
      },
      selected: openConfig != null && p.equals(openConfig.path, configFile.path),
    );
  }
}

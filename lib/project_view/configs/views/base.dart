import "package:flutter/material.dart";

import "../models/base.dart";
import "../models/core.dart";
import "../models/startup.dart";
import "../models/webapp.dart";
import "../models/webserver.dart";
import "core.dart";
import "startup.dart";
import "webapp.dart";
import "webserver.dart";

class BaseConfigView<T extends BaseConfigModel> extends StatelessWidget {
  final ConfigFile<T> config;

  const BaseConfigView(this.config, {super.key});

  @override
  Widget build(BuildContext context) {
    final T model = config.model;
    return switch (model) {
      CoreConfigModel() => CoreConfigView(ConfigFile(config.file, model)),
      StartupConfigModel() => StartupConfigView(ConfigFile(config.file, model)),
      WebappConfigModel() => WebappConfigView(ConfigFile(config.file, model)),
      WebserverConfigModel() => WebserverConfigView(ConfigFile(config.file, model)),
      //TODO: The map config
      _ => const Center(
        child: Text(
          "Simple view currently not available for this config.\n"
          "Please use the Advanced Mode for the time being.",
          textAlign: .center,
        ),
      ),
    };
  }
}

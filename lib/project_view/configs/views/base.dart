import "package:flutter/material.dart";

import "../models/base.dart";
import "../models/core.dart";
import "core.dart";

class BaseConfigView<T extends BaseConfigModel> extends StatelessWidget {
  final ConfigFile<T> config;

  const BaseConfigView(this.config, {super.key});

  @override
  Widget build(BuildContext context) {
    final T model = config.model;
    return switch (model) {
      CoreConfigModel() => CoreConfigView(ConfigFile(config.file, model)),
      //TODO: The other configs
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

import "package:file_picker/file_picker.dart";
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

class PathPickerButton extends StatelessWidget {
  final String purpose;
  final void Function(String? path) onPicked;
  final String initialDirectory;

  const PathPickerButton({
    required this.purpose,
    required this.onPicked,
    required this.initialDirectory,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: TextButton.icon(
        icon: const Icon(Icons.drive_folder_upload_rounded),
        label: Text("Pick $purpose folder"),
        onPressed: () async {
          final String? picked = await FilePicker.platform.getDirectoryPath(
            dialogTitle: "Pick your $purpose folder",
            initialDirectory: initialDirectory,
          );
          onPicked(picked);
        },
      ),
    );
  }
}

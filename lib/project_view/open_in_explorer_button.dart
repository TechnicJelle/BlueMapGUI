import "dart:async";
import "dart:io";

import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:url_launcher/url_launcher.dart";

import "../project_configs_provider.dart";

class OpenInFileManagerButton extends ConsumerWidget {
  const OpenInFileManagerButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      tooltip: "Open in file manager",
      onPressed: () {
        final Directory projectDirectory = ref.read(openProjectProvider)!;
        unawaited(launchUrl(projectDirectory.uri));
      },
      icon: const Icon(Icons.folder_open),
    );
  }
}

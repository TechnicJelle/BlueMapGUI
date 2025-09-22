import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:url_launcher/url_launcher.dart";

import "control_row.dart";

class OpenButton extends ConsumerWidget {
  const OpenButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isRunning = ref.watch(
      processStateProvider.select(
        (asyncValue) => asyncValue.value == RunningProcessState.running,
      ),
    );

    return ElevatedButton.icon(
      onPressed: isRunning
          ? () async {
              final int port = ref.read(processProvider)?.port ?? 8100;
              if (!await launchUrl(Uri.parse("http://localhost:$port"))) {
                throw Exception("Could not launch url!");
              }
            }
          : null,
      label: const Text("Open"),
      icon: const Icon(Icons.open_in_browser),
    );
  }
}

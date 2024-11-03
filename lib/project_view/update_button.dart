import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:url_launcher/url_launcher_string.dart";

import "../main.dart";
import "../update_checker.dart";

final updateProvider = FutureProvider.autoDispose<String?>((ref) async {
  //Only check for updates in release versions
  if (!version.startsWith("v")) return null;

  UpdateChecker updateChecker = UpdateChecker(
    author: "TechnicJelle",
    repoName: "BlueMapGUI",
    currentVersion: version,
  );

  try {
    if (await updateChecker.isUpdateAvailable()) {
      final String latestVersion = await updateChecker.getLatestVersion();
      return latestVersion;
    }
  } catch (e) {
    print(e);
  }
  return null;
});

class UpdateButton extends ConsumerWidget {
  const UpdateButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final update = ref.watch(updateProvider);

    if (!update.hasValue || update.value == null) {
      return const SizedBox.shrink();
    }

    return Tooltip(
      message: "BlueMapGUI Update Available\n"
          "$version -> ${update.value}",
      child: ElevatedButton.icon(
        onPressed: () {
          launchUrlString(
            "https://github.com/TechnicJelle/BlueMapGUI/releases/latest",
          );
        },
        label: const Text("Update"),
        icon: const Icon(Icons.browser_updated),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.yellow[500],
        ),
      ),
    );
  }
}

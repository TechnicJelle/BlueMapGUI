import "dart:async";
import "dart:io";

import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:url_launcher/url_launcher_string.dart";

import "../../update_checker.dart";
import "../../versions.dart";

// I don't want these for providers; too long
// ignore: specify_nonobvious_property_types
final updateProvider = FutureProvider.autoDispose<String?>((ref) async {
  //Only check for updates in release versions
  if (!version.startsWith("v")) return null;

  final UpdateChecker updateChecker = UpdateChecker(
    author: "TechnicJelle",
    repoName: "BlueMapGUI",
    currentVersion: version,
  );

  try {
    if (await updateChecker.isUpdateAvailable()) {
      final String latestVersion = await updateChecker.getLatestVersion();
      return latestVersion;
    }
  } on HttpException catch (e, s) {
    stderr.addError(e, s);
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
      message:
          "BlueMap GUI Update Available\n"
          "${UpdateChecker.removePrefix(version)} -> ${update.value}",
      child: ElevatedButton.icon(
        onPressed: () {
          unawaited(
            launchUrlString(
              "https://github.com/TechnicJelle/BlueMapGUI/releases/latest",
            ),
          );
        },
        label: const Text("Update"),
        icon: const Icon(Icons.browser_updated),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow[500]),
      ),
    );
  }
}

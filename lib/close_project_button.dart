import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "confirmation_dialog.dart";
import "main.dart";
import "prefs.dart";

class CloseProjectButton extends ConsumerWidget {
  const CloseProjectButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      tooltip: "Close project",
      onPressed: () {
        showConfirmationDialog(
          context: context,
          title: "Close project",
          content: const [
            Text("Are you sure you want to close this project?"),
            Text("You can always open it again later."),
          ],
          confirmAction: "Close",
          onConfirmed: () {
            Prefs.instance.projectPath = null;
            ref.invalidate(projectDirectoryProvider);
          },
        );
      },
      icon: const Icon(Icons.close),
    );
  }
}

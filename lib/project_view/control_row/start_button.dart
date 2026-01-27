import "dart:async";

import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../prefs.dart";
import "../console.dart";
import "control_row.dart";

class StartButton extends ConsumerWidget {
  const StartButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final RunningProcessState? processState = ref.watch(processStateProvider).value;

    return SizedBox(
      width: 150,
      child: ElevatedButton.icon(
        onPressed: switch (processState) {
          .stopped => () async {
            final bool clearConsoleBeforeStart =
                ref.read(consoleClearProvider) ?? ConsoleClearProvider.defaultOption;
            if (clearConsoleBeforeStart) {
              ref.read(outputNotifierProvider.notifier).clear();
              // small delay to let the console be fully empty for a moment
              await Future<void>.delayed(const Duration(milliseconds: 50));
            }
            unawaited(ref.read(processProvider)?.start());
          },
          .running => () => ref.read(processProvider)?.stop(),
          _ => null,
        },
        label: Text(switch (processState) {
          .stopped => "Start",
          .running => "Stop",
          .starting => "Starting...",
          .stopping => "Stopping...",
          null => "Unknown",
        }),
        icon: Icon(switch (processState) {
          .stopped => Icons.play_arrow,
          .running => Icons.stop,
          null => Icons.error,
          _ => Icons.hourglass_bottom,
        }),
      ),
    );
  }
}

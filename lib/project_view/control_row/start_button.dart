import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "control_row.dart";

class StartButton extends ConsumerWidget {
  const StartButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final processState = ref.watch(processStateProvider).value;

    return SizedBox(
      width: 150,
      child: ElevatedButton.icon(
        onPressed: switch (processState) {
          RunningProcessState.stopped => () => ref.read(processProvider)?.start(),
          RunningProcessState.running => () => ref.read(processProvider)?.stop(),
          _ => null,
        },
        label: Text(switch (processState) {
          RunningProcessState.stopped => "Start",
          RunningProcessState.running => "Stop",
          RunningProcessState.starting => "Starting...",
          RunningProcessState.stopping => "Stopping...",
          null => "Unknown",
        }),
        icon: Icon(switch (processState) {
          RunningProcessState.stopped => Icons.play_arrow,
          RunningProcessState.running => Icons.stop,
          null => Icons.error,
          _ => Icons.hourglass_bottom,
        }),
      ),
    );
  }
}

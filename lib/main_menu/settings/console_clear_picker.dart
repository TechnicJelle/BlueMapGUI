import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../prefs.dart";

class ConsoleClearPicker extends ConsumerWidget {
  const ConsoleClearPicker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool option = ref.watch(consoleClearProvider);

    return CheckboxListTile(
      value: option,
      onChanged: (bool? newOption) {
        ref.read(consoleClearProvider.notifier).set(newOption);
      },
      title: option ? const Text("Enabled") : const Text("Disabled"),
      subtitle: option
          ? const Text("The console will be cleared every time you start BlueMap.")
          : const Text(
              "The logs from previous runs will remain visible in the console.",
            ),
      controlAffinity: ListTileControlAffinity.leading,
    );
  }
}

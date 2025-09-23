import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../prefs.dart";

class ConsoleClearPicker extends ConsumerWidget {
  const ConsoleClearPicker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool? option = ref.watch(consoleClearProvider);

    return CheckboxListTile(
      value: option,
      onChanged: (bool? newOption) {
        ref
            .read(consoleClearProvider.notifier)
            .set(newOption ?? ConsoleClearProvider.defaultOption);
      },
      title: const Text("Enabled"),
      subtitle: option ?? ConsoleClearProvider.defaultOption
          ? const Text("Do clear the console.")
          : const Text("Don't clear the console."),
      controlAffinity: ListTileControlAffinity.leading,
    );
  }
}

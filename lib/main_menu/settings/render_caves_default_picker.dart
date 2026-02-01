import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../prefs.dart";

class RenderCavesDefaultPicker extends ConsumerWidget {
  const RenderCavesDefaultPicker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool option = ref.watch(renderCavesDefaultProvider);

    return CheckboxListTile(
      value: option,
      onChanged: (bool? newOption) {
        ref.read(renderCavesDefaultProvider.notifier).set(newOption);
      },
      title: option ? const Text("Enabled") : const Text("Disabled"),
      subtitle: option
          ? const Text("All maps will render all caves by default.")
          : const Text("Some map types may not render all caves by default."),
      controlAffinity: ListTileControlAffinity.leading,
    );
  }
}

import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../prefs.dart";
import "../../utils.dart";

class ThemeModePicker extends ConsumerWidget {
  const ThemeModePicker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeMode themeMode = ref.watch(themeModeProvider);

    return RadioGroup(
      groupValue: themeMode,
      onChanged: (ThemeMode? newThemeMode) {
        ref.read(themeModeProvider.notifier).set(newThemeMode ?? ThemeMode.system);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          RadioListTile(
            value: ThemeMode.system,
            title: Text(ThemeMode.system.name.capitalize()),
            subtitle: const Text(
              "Automatically use the theme of your Operating System.",
            ),
          ),
          RadioListTile(
            value: ThemeMode.light,
            title: Text(ThemeMode.light.name.capitalize()),
            subtitle: const Text("Light Mode"),
          ),
          RadioListTile(
            value: ThemeMode.dark,
            title: Text(ThemeMode.dark.name.capitalize()),
            subtitle: const Text("Dark Mode"),
          ),
        ],
      ),
    );
  }
}

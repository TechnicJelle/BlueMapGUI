import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../prefs.dart";
import "radio_list_tile_custom_java_picker.dart";
import "radio_list_tile_system_java_picker.dart";

enum JavaPickerMode {
  system,
  pick,
}

class JavaPicker extends ConsumerStatefulWidget {
  const JavaPicker({super.key});

  @override
  ConsumerState<JavaPicker> createState() => _JavaPickerState();
}

class _JavaPickerState extends ConsumerState<JavaPicker> {
  JavaPickerMode? javaPickerMode;

  @override
  void initState() {
    super.initState();
    final String? javaPath = ref.read(javaPathProvider);
    if (javaPath != null) {
      javaPickerMode = javaPath == "java" ? JavaPickerMode.system : JavaPickerMode.pick;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 500),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text("Select your Java executable:"),
          const SizedBox(height: 4),
          RadioListTileSystemJavaPicker(
            groupValue: javaPickerMode,
            onSet: () {
              setState(() => javaPickerMode = JavaPickerMode.system);
              ref.read(javaPathProvider.notifier).setJavaPath("java");
            },
          ),
          RadioListTileCustomJavaPicker(
            groupValue: javaPickerMode,
            onChanged: (javaPath) {
              setState(() => javaPickerMode = JavaPickerMode.pick);
              ref.read(javaPathProvider.notifier).setJavaPath(javaPath);
            },
          )
        ],
      ),
    );
  }
}

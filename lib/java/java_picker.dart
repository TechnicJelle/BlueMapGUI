import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../prefs.dart";
import "radio_list_tile_custom_java_picker.dart";
import "radio_list_tile_system_java_picker.dart";

final javaPathProvider = Provider<String?>((ref) {
  return Prefs.instance.javaPath;
});

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
    if (Prefs.instance.javaPath != null) {
      javaPickerMode =
          Prefs.instance.javaPath == "java" ? JavaPickerMode.system : JavaPickerMode.pick;
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
              setState(() {
                javaPickerMode = JavaPickerMode.system;
              });
              Prefs.instance.javaPath = "java";
              ref.invalidate(javaPathProvider);
            },
          ),
          RadioListTileCustomJavaPicker(
            groupValue: javaPickerMode,
            onChanged: (javaPath) {
              setState(() {
                javaPickerMode = JavaPickerMode.pick;
              });
              Prefs.instance.javaPath = javaPath;
              ref.invalidate(javaPathProvider);
            },
          )
        ],
      ),
    );
  }
}

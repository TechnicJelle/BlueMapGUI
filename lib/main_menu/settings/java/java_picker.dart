import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../../prefs.dart";
import "radio_list_tile_custom_java_picker.dart";
import "radio_list_tile_system_java_picker.dart";

enum JavaPickerMode { system, pick }

class JavaPicker extends ConsumerWidget {
  const JavaPicker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final JavaPickerMode? javaPickerMode = ref.watch(
      javaPathProvider.select((javaPath) {
        if (javaPath != null) {
          return javaPath == "java" ? JavaPickerMode.system : JavaPickerMode.pick;
        }
        return null;
      }),
    );
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 500),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          RadioListTileSystemJavaPicker(
            groupValue: javaPickerMode,
            onSet: () {
              ref.read(javaPathProvider.notifier).setJavaPath("java");
            },
          ),
          RadioListTileCustomJavaPicker(
            groupValue: javaPickerMode,
            onChanged: (javaPath) {
              ref.read(javaPathProvider.notifier).setJavaPath(javaPath);
            },
          ),
        ],
      ),
    );
  }
}

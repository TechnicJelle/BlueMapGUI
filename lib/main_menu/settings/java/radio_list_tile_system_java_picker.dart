import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../../utils.dart";
import "java_picker.dart";
import "util_for_checking_java_path_version.dart";

final _systemJavaVersionProvider = FutureProvider((ref) async {
  return checkJavaVersion("java");
});

class RadioListTileSystemJavaPicker extends ConsumerWidget {
  final JavaPickerMode? groupValue;
  final Function() onSet;

  const RadioListTileSystemJavaPicker({
    super.key,
    required this.groupValue,
    required this.onSet,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<int> javaVersion = ref.watch(_systemJavaVersionProvider);
    final bool hasSuitableJavaInstalled = javaVersion.hasValue;

    return RadioListTile<JavaPickerMode>(
      title: Text(JavaPickerMode.system.name.capitalize()),
      subtitle: switch (javaVersion) {
        AsyncData(:final value) => Text("Detected System Java version: $value"),
        AsyncError(:final error) => Text(
            error.toString(),
            style: const TextStyle(color: Colors.red),
          ),
        _ => const Text("Checking System Java version..."),
      },
      value: JavaPickerMode.system,
      groupValue: groupValue,
      onChanged: hasSuitableJavaInstalled ? (JavaPickerMode? value) => onSet() : null,
    );
  }
}

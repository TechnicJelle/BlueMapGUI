import "package:file_picker/file_picker.dart";
import "package:flutter/material.dart";

import "java_picker.dart";
import "util_for_checking_java_path_version.dart";

enum _CustomPickingState {
  nothing,
  picking,
  checking,
  failed,
  success,
}

class RadioListTileCustomJavaPicker extends StatefulWidget {
  final JavaPickerMode? groupValue;
  final Function(String javaPath) onChanged;

  const RadioListTileCustomJavaPicker({
    super.key,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  State<RadioListTileCustomJavaPicker> createState() =>
      _RadioListTileCustomJavaPickerState();
}

class _RadioListTileCustomJavaPickerState extends State<RadioListTileCustomJavaPicker> {
  _CustomPickingState customPickingState = _CustomPickingState.nothing;
  String? customPickErrorText;
  int? customJavaVersion;

  @override
  Widget build(BuildContext context) {
    return RadioListTile<JavaPickerMode>(
      title: const Text("Custom"),
      subtitle: switch (customPickingState) {
        _CustomPickingState.nothing => const Text("Select a Java executable manually"),
        _CustomPickingState.picking => const Text("Selecting Java executable..."),
        _CustomPickingState.checking => const Text("Checking Java version..."),
        _CustomPickingState.failed => Text(
            customPickErrorText ?? "Unknown error",
            style: const TextStyle(color: Colors.red),
          ),
        _CustomPickingState.success => Text(
            "Detected Java version: $customJavaVersion",
          ),
      },
      value: JavaPickerMode.pick,
      groupValue: widget.groupValue,
      onChanged: (JavaPickerMode? value) async {
        if (customPickingState != _CustomPickingState.nothing &&
            customPickingState != _CustomPickingState.failed &&
            customPickingState != _CustomPickingState.success) return;
        setState(() => customPickingState = _CustomPickingState.picking);
        final FilePickerResult? picked = await FilePicker.platform.pickFiles(
          dialogTitle: "Select Java executable",
          //cannot use FileType.custom, because it doesn't support files with no extension, which is the case for executables on linux
          type: FileType.any,
        );
        if (picked == null) {
          setState(() => customPickingState = _CustomPickingState.nothing);
          return; // User canceled the picker
        }
        setState(() => customPickingState = _CustomPickingState.checking);

        final String? javaPath = picked.files.single.path;
        if (javaPath == null) {
          setState(() {
            customPickingState = _CustomPickingState.failed;
            customPickErrorText = "Path is null";
          });
          return;
        }

        int javaVersion;
        try {
          javaVersion = await checkJavaVersion(javaPath);
        } catch (e) {
          setState(() {
            customPickingState = _CustomPickingState.failed;
            customPickErrorText = e.toString().replaceAll("Exception:", "Error:");
          });
          return;
        }

        setState(() {
          customPickingState = _CustomPickingState.success;
          customJavaVersion = javaVersion;
          widget.onChanged(javaPath);
        });
      },
    );
  }
}

import "package:file_picker/file_picker.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../../prefs.dart";
import "../../../utils.dart";
import "check_java_version.dart";

enum JavaPickerMode { unset, system, custom }

enum _SystemRadioState { loading, success, errored }

enum _CustomRadioState { empty, success, errored }

class JavaPicker extends ConsumerStatefulWidget {
  const JavaPicker({super.key});

  @override
  ConsumerState<JavaPicker> createState() => _JavaPickerState();
}

class _JavaPickerState extends ConsumerState<JavaPicker> {
  final _javaPickerModeProvider = javaPathProvider.select((javaPath) {
    if (javaPath != null) {
      return javaPath == "java" ? JavaPickerMode.system : JavaPickerMode.custom;
    }
    return null;
  });

  _SystemRadioState systemRadioState = _SystemRadioState.loading;
  int? systemJavaVersion;
  String? systemError;

  _CustomRadioState customRadioState = _CustomRadioState.empty;
  int? customJavaVersion;
  String? customJavaPath;
  String? customError;

  @override
  void initState() {
    super.initState();

    // System
    checkJavaVersion("java").then(
      (javaVersion) {
        setState(() {
          systemRadioState = _SystemRadioState.success;
          systemJavaVersion = javaVersion;
          systemError = null;
        });
      },
      onError: (e) {
        setState(() {
          systemRadioState = _SystemRadioState.errored;
          systemJavaVersion = null;
          systemError = e.toString();
        });
      },
    );

    // Custom
    if (ref.read(_javaPickerModeProvider) == JavaPickerMode.custom) {
      String javaPath = ref.read(javaPathProvider)!;
      customRadioState = _CustomRadioState.success;
      customJavaVersion = 0;
      customJavaPath = javaPath;
      customError = null;

      checkJavaVersion(javaPath).then(
        (javaVersion) {
          setState(() {
            customJavaVersion = javaVersion;
          });
        },
        onError: (e) {
          setState(() {
            customRadioState = _CustomRadioState.errored;
            customJavaVersion = null;
            customError = e.toString();
          });
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final JavaPickerMode javaPickerMode =
        ref.watch(_javaPickerModeProvider) ?? JavaPickerMode.unset;

    const TextStyle red = TextStyle(color: Colors.red);

    return RadioGroup(
      groupValue: javaPickerMode,
      onChanged: (JavaPickerMode? newJavaPickerMode) async {
        switch (newJavaPickerMode) {
          case JavaPickerMode.unset:
            onUnset();
            break;
          case JavaPickerMode.system:
            onSystem();
            break;
          case JavaPickerMode.custom:
            onCustom();
            break;
          case null:
            break;
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          RadioListTile(
            value: JavaPickerMode.unset,
            title: Text(JavaPickerMode.unset.name.capitalize()),
          ),
          RadioListTile<JavaPickerMode>(
            value: JavaPickerMode.system,
            title: Text(JavaPickerMode.system.name.capitalize()),

            subtitle: switch (systemRadioState) {
              _SystemRadioState.loading => const Text("Checking System Java version..."),
              _SystemRadioState.success => Text(
                "Detected System Java version: $systemJavaVersion",
              ),
              _SystemRadioState.errored => Text("$systemError", style: red),
            },

            enabled: systemRadioState == _SystemRadioState.success,
          ),
          RadioListTile<JavaPickerMode>(
            value: JavaPickerMode.custom,
            title: Text(JavaPickerMode.custom.name.capitalize()),

            subtitle: switch (customRadioState) {
              _CustomRadioState.empty => const Text(
                "Select a custom Java executable manually",
              ),
              _CustomRadioState.success => Text(
                "Detected Java version: $customJavaVersion  ( $customJavaPath )",
              ),
              _CustomRadioState.errored => Text(
                "$customError  ( $customJavaPath )",
                style: red,
              ),
            },
          ),
        ],
      ),
    );
  }

  void onUnset() {
    ref.read(javaPathProvider.notifier).clearJavaPath();
  }

  void onSystem() {
    ref.read(javaPathProvider.notifier).setJavaPath("java");
  }

  Future<void> onCustom() async {
    final FilePickerResult? browsed = await FilePicker.platform.pickFiles(
      dialogTitle: "Select Java executable",
      //cannot use FileType.custom, because it doesn't support files with no extension, which is the case for executables on linux
      type: FileType.any,
    );
    if (browsed == null) {
      return; // User canceled the browser
    }

    final String? javaPath = browsed.files.single.path;
    if (javaPath == null) {
      setState(() {
        customRadioState = _CustomRadioState.errored;
        customJavaVersion = null;
        customJavaPath = null;
        customError = "Path is null";
      });
      return;
    }

    customJavaPath = javaPath;
    try {
      int javaVersion = await checkJavaVersion(javaPath);
      setState(() {
        customRadioState = _CustomRadioState.success;
        customJavaVersion = javaVersion;
        customError = null;
        ref.read(javaPathProvider.notifier).setJavaPath(javaPath);
      });
    } catch (e) {
      setState(() {
        customRadioState = _CustomRadioState.errored;
        customJavaVersion = null;
        customError = e.toString();
      });
    }
  }
}

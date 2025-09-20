import "dart:ffi";
import "dart:io";

import "package:archive/archive_io.dart";
import "package:file_picker/file_picker.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:path/path.dart" as p;
import "package:path_provider/path_provider.dart";

import "../../../prefs.dart";
import "../../../utils.dart";
import "check_java_version.dart";

enum _SystemRadioState { loading, success, errored }

enum _BundledRadioState { empty, downloading, unpacking, success, errored }

enum _CustomRadioState { empty, success, errored }

Uri? createBundleDownloadLink() {
  const int javaVersion = 21;
  Uri createLink(String platform, String architecture) {
    return Uri.https(
      "api.adoptium.net",
      "/v3/binary/latest/$javaVersion/ga/$platform/$architecture/jre/hotspot/normal/eclipse",
    );
  }

  return switch (Abi.current()) {
    Abi.linuxX64 => createLink("linux", "x64"),
    Abi.windowsX64 => createLink("windows", "x64"),
    _ => null,
  };
}

class JavaPicker extends ConsumerStatefulWidget {
  const JavaPicker({super.key});

  @override
  ConsumerState<JavaPicker> createState() => _JavaPickerState();
}

class _JavaPickerState extends ConsumerState<JavaPicker> {
  final _javaPickerModeProvider = javaPathProvider.select((javaPath) {
    if (javaPath != null) {
      return javaPath.type;
    }
    return null;
  });

  _SystemRadioState systemRadioState = _SystemRadioState.loading;
  int? systemJavaVersion;
  String? systemError;

  _BundledRadioState bundledRadioState = _BundledRadioState.empty;
  late final Uri? bundledDownloadLink = createBundleDownloadLink();
  String? bundledError;

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
    if (ref.read(_javaPickerModeProvider) == JavaPathMode.custom) {
      JavaPath javaPath = ref.read(javaPathProvider)!;
      customRadioState = _CustomRadioState.success;
      customJavaVersion = 0;
      customJavaPath = javaPath.path;
      customError = null;

      checkJavaVersion(javaPath.path).then(
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
    final JavaPathMode javaPickerMode =
        ref.watch(_javaPickerModeProvider) ?? JavaPathMode.unset;

    const TextStyle red = TextStyle(color: Colors.red);

    return RadioGroup(
      groupValue: javaPickerMode,
      onChanged: (JavaPathMode? newJavaPickerMode) async {
        switch (newJavaPickerMode) {
          case JavaPathMode.unset:
            onUnset();
            break;
          case JavaPathMode.system:
            onSystem();
            break;
          case JavaPathMode.bundled:
            onBundled();
            break;
          case JavaPathMode.custom:
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
            value: JavaPathMode.unset,
            title: Text(JavaPathMode.unset.name.capitalize()),
          ),
          RadioListTile<JavaPathMode>(
            value: JavaPathMode.system,
            title: Text(JavaPathMode.system.name.capitalize()),

            subtitle: switch (systemRadioState) {
              _SystemRadioState.loading => const Text("Checking System Java version..."),
              _SystemRadioState.success => Text(
                "Detected System Java version: $systemJavaVersion",
              ),
              _SystemRadioState.errored => Text("$systemError", style: red),
            },

            enabled: systemRadioState == _SystemRadioState.success,
          ),
          RadioListTile(
            value: JavaPathMode.bundled,
            title: Text("${JavaPathMode.bundled.name.capitalize()} (WIP)"),

            subtitle: bundledDownloadLink == null
                ? const Text(
                    "Your computer is incompatible with the automatic download. Please try the Custom mode below.",
                    style: red,
                  )
                : switch (bundledRadioState) {
                    _BundledRadioState.empty => const Text(
                      "Automatically download Java. Use this if you don't have a working System Installation, and you don't want to use a custom one either.",
                    ),
                    _BundledRadioState.downloading => const Text("Downloading..."),
                    _BundledRadioState.unpacking => const Text("Unpacking..."),
                    _BundledRadioState.success => const Text(
                      "Successfully downloaded! You are ready to go!",
                    ),
                    _BundledRadioState.errored => Text("$bundledError", style: red),
                  },

            enabled: bundledDownloadLink != null,
          ),
          RadioListTile<JavaPathMode>(
            value: JavaPathMode.custom,
            title: Text(JavaPathMode.custom.name.capitalize()),

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
    ref
        .read(javaPathProvider.notifier)
        .setJavaPath(JavaPath(JavaPathMode.system, "java"));
  }

  File? findJavaExecutableInDirectory(Directory dir) {
    final File javaExe = File(p.join(dir.path, "java.exe"));
    if (javaExe.existsSync()) return javaExe;

    final File java = File(p.join(dir.path, "java"));
    if (java.existsSync()) return java;

    final FileSystemEntity fallback = dir.listSync().firstWhere(
      (file) => p.basename(file.path).startsWith("java"),
    );

    if (fallback is File) {
      return fallback;
    }

    return null;
  }

  Future<void> onBundled() async {
    final Uri? downloadLink = bundledDownloadLink;
    if (downloadLink == null) return;

    setState(() {
      bundledRadioState = _BundledRadioState.downloading;
    });

    final Directory supportDir = await getApplicationSupportDirectory();
    final Directory javaBundleDirectory = Directory(p.join(supportDir.path, "java"));

    // Delete old Java Bundle(s)
    if (javaBundleDirectory.existsSync()) {
      try {
        javaBundleDirectory.deleteSync(recursive: true);
      } catch (e) {
        setState(() {
          bundledRadioState = _BundledRadioState.errored;
          bundledError = e.toString();
        });
        return;
      }
    }

    final File javaBundleArchive;
    try {
      final client = HttpClient();
      final request = await client.getUrl(downloadLink);
      final response = await request.close();
      final String filename = p.basename(response.redirects.first.location.path);
      javaBundleArchive = File(p.join(supportDir.path, filename));
      await response.pipe(javaBundleArchive.openWrite());
      client.close();
      //TODO: Maybe some verification, like what happens with the BlueMap-cli.jar as well?
    } catch (e) {
      setState(() {
        bundledRadioState = _BundledRadioState.errored;
        bundledError = e.toString();
      });
      return;
    }

    setState(() {
      bundledRadioState = _BundledRadioState.unpacking;
    });

    try {
      await extractFileToDisk(javaBundleArchive.path, javaBundleDirectory.path);
    } catch (e) {
      setState(() {
        bundledRadioState = _BundledRadioState.errored;
        bundledError = e.toString();
      });
      return;
    }

    // Delete the archive; it is not needed anymore.
    try {
      javaBundleArchive.deleteSync(recursive: true);
    } catch (e) {
      setState(() {
        bundledRadioState = _BundledRadioState.errored;
        bundledError = e.toString();
      });
      return;
    }

    final Directory binDir = Directory(
      p.join(javaBundleDirectory.listSync().first.path, "bin"),
    );

    final File? javaExecutable = findJavaExecutableInDirectory(binDir);
    if (javaExecutable == null) {
      setState(() {
        bundledRadioState = _BundledRadioState.errored;
        bundledError = "Could not find Java Executable in the downloaded bundle.";
      });
      return;
    }

    setState(() {
      bundledRadioState = _BundledRadioState.success;
      bundledError = null;
      ref
          .read(javaPathProvider.notifier)
          .setJavaPath(JavaPath(JavaPathMode.bundled, javaExecutable.path));
    });
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
        ref
            .read(javaPathProvider.notifier)
            .setJavaPath(JavaPath(JavaPathMode.custom, javaPath));
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

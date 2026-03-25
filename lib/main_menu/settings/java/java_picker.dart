import "dart:async";
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
import "../../../versions.dart";
import "check_java_version.dart";

enum _SystemRadioState { loading, success, errored }

enum _ManagedRadioState { empty, downloading, hashing, unpacking, success, errored }

enum _CustomRadioState { empty, success, errored }

class JavaPicker extends ConsumerStatefulWidget {
  const JavaPicker({super.key});

  @override
  ConsumerState<JavaPicker> createState() => _JavaPickerState();
}

class _JavaPickerState extends ConsumerState<JavaPicker> {
  // I don't want these for providers; too long
  // ignore: specify_nonobvious_property_types
  final _javaPickerModeProvider = javaPathProvider.select((javaPath) => javaPath?.type);

  ///disables all RadioListTiles whenever something is in progress, so it cannot be interrupted
  bool inProgress = false;

  _SystemRadioState systemRadioState = .loading;
  int? systemJavaVersion;
  String? systemError;

  _ManagedRadioState managedRadioState = .empty;

  late final Uri? managedDownloadLink;
  late final String? managedHash;
  String? managedError;
  double? managedProgress;

  void initManagedDownloadLink() {
    Uri createLink(String platform, String architecture) {
      return Uri.https(
        "api.adoptium.net",
        "/v3/binary/version/$javaManagedVersion/$platform/$architecture/jre/hotspot/normal/eclipse",
      );
    }

    // Hashes are SHA256
    switch (Abi.current()) {
      case Abi.linuxX64:
        managedDownloadLink = createLink("linux", "x64");
        managedHash = javaManagedLinuxX64Hash;
      case Abi.windowsX64:
        managedDownloadLink = createLink("windows", "x64");
        managedHash = javaManagedWindowsX64Hash;
    }
  }

  _CustomRadioState customRadioState = .empty;
  int? customJavaVersion;
  String? customJavaPath;
  String? customError;

  @override
  void initState() {
    super.initState();

    initManagedDownloadLink();

    // System
    unawaited(
      checkJavaVersion(JavaPath(.system, "java")).then(
        (javaVersion) {
          setState(() {
            systemRadioState = .success;
            systemJavaVersion = javaVersion;
            systemError = null;
          });
        },
        onError: (Object e) {
          setState(() {
            systemRadioState = .errored;
            systemJavaVersion = null;
            systemError = e is JavaVersionCheckException ? e.message : e.toString();
          });
        },
      ),
    );

    // Custom
    if (ref.read(_javaPickerModeProvider) == .custom) {
      final JavaPath javaPath = ref.read(javaPathProvider)!;
      customRadioState = .success;
      customJavaVersion = 0;
      customJavaPath = javaPath.path;
      customError = null;

      unawaited(
        checkJavaVersion(javaPath).then(
          (int javaVersion) {
            setState(() {
              customJavaVersion = javaVersion;
            });
          },
          onError: (Object e) {
            setState(() {
              customRadioState = .errored;
              customJavaVersion = null;
              customError = e is JavaVersionCheckException ? e.message : e.toString();
            });
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final JavaPathMode javaPickerMode = ref.watch(_javaPickerModeProvider) ?? .unset;

    const TextStyle red = TextStyle(color: Colors.red);

    return RadioGroup(
      groupValue: javaPickerMode,
      onChanged: (JavaPathMode? newJavaPickerMode) async {
        switch (newJavaPickerMode) {
          case .unset:
            onUnset();
          case .system:
            onSystem();
          case .managed:
            setState(() => inProgress = true);
            await onManaged();
            setState(() => inProgress = false);
          case .custom:
            setState(() => inProgress = true);
            await onCustom();
            setState(() => inProgress = false);
          case null:
            break;
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RadioListTile(
            value: JavaPathMode.unset,
            title: Text(JavaPathMode.unset.name.capitalize()),

            subtitle: const Text("No Java selected."),

            enabled: !inProgress,
          ),
          RadioListTile(
            value: JavaPathMode.system,
            title: Text(JavaPathMode.system.name.capitalize()),

            subtitle: switch (systemRadioState) {
              .loading => const Text("Checking System Java version..."),
              .success => Text("Detected System Java version: $systemJavaVersion"),
              .errored => Text("$systemError", style: red),
            },

            enabled: systemRadioState == .success && !inProgress,
          ),
          RadioListTile(
            value: JavaPathMode.managed,
            title: Text(JavaPathMode.managed.name.capitalize()),

            subtitle: managedDownloadLink == null
                ? const Text(
                    "Your computer is incompatible with the automatic download. Please try the Custom mode below.",
                    style: red,
                  )
                : Column(
                    crossAxisAlignment: .start,
                    mainAxisSize: .min,
                    children: [
                      switch (managedRadioState) {
                        .empty => const Text(
                          "Automatically download Java. Use this if you don't have a working System Installation, and you don't want to use a custom one either.",
                        ),
                        .downloading => const Text("Downloading..."),
                        .hashing => const Text("Verifying..."),
                        .unpacking => const Text("Unpacking..."),
                        .success => const Text(
                          "Successfully downloaded! You are ready to go!",
                        ),
                        .errored => Text("$managedError", style: red),
                      },
                      if (managedRadioState == .downloading ||
                          managedRadioState == .hashing ||
                          managedRadioState == .unpacking)
                        LinearProgressIndicator(value: managedProgress),
                    ],
                  ),

            enabled: managedDownloadLink != null && !inProgress,
          ),
          RadioListTile(
            value: JavaPathMode.custom,
            title: Text(JavaPathMode.custom.name.capitalize()),

            subtitle: switch (customRadioState) {
              .empty => const Text("Select a custom Java executable manually."),
              .success => Text(
                "Detected Java version: $customJavaVersion  ( $customJavaPath )",
              ),
              .errored => Text("$customError  ( $customJavaPath )", style: red),
            },

            enabled: !inProgress,
          ),
        ],
      ),
    );
  }

  void onUnset() {
    ref.read(javaPathProvider.notifier).clearJavaPath();
  }

  void onSystem() {
    ref.read(javaPathProvider.notifier).setJavaPath(JavaPath(.system, "java"));
  }

  Future<File?> findJavaExecutableInDirectory(Directory dir) async {
    final File javaExe = File(p.join(dir.path, "java.exe"));
    if (javaExe.existsSync()) return javaExe;

    final File java = File(p.join(dir.path, "java"));
    if (java.existsSync()) return java;

    final FileSystemEntity fallback = await dir.list().firstWhere(
      (file) => p.basename(file.path).startsWith("java"),
    );

    if (fallback is File) {
      return fallback;
    }

    return null;
  }

  Future<void> onManaged() async {
    final Uri? downloadLink = managedDownloadLink;
    final String? hash = managedHash;
    if (downloadLink == null || hash == null) return;

    setState(() {
      managedRadioState = .downloading;
      managedProgress = null;
    });

    final Directory supportDir = await getApplicationSupportDirectory();
    final Directory javaManagedDirectory = Directory(p.join(supportDir.path, "java"));

    // Delete old Java Manageds(s)
    if (javaManagedDirectory.existsSync()) {
      try {
        await javaManagedDirectory.delete(recursive: true);
      } on FileSystemException catch (e) {
        setState(() {
          managedRadioState = .errored;
          managedError = e.toString();
          managedProgress = null;
        });
        return;
      }
    }

    final NonHashedFile susManagedArchive;
    try {
      susManagedArchive = await downloadFile(
        uri: downloadLink,
        outputFileGenerator: (response) {
          final String filename = response.redirects.first.location.getFileName();
          return File(p.join(supportDir.path, filename));
        },
        onProgress: (double progress) {
          setState(() {
            managedProgress = progress;
          });
        },
      );
    } on IOException catch (e) {
      setState(() {
        managedRadioState = .errored;
        managedError = e.toString();
        managedProgress = null;
      });
      return;
    }

    setState(() {
      managedRadioState = .hashing;
      managedProgress = null;
    });

    final File? hashedManagedArchive = await susManagedArchive.hashFile(hash);
    if (hashedManagedArchive == null) {
      setState(() {
        managedRadioState = .errored;
        managedError =
            "Could not verify the downloaded Java archive's integrity!\n"
            "The hash of the downloaded file does not match the expected hash.";
        managedProgress = null;
      });
      return;
    }
    final File javaManagedArchive = hashedManagedArchive;

    setState(() {
      managedRadioState = .unpacking;
    });

    try {
      await extractFileToDisk(javaManagedArchive.path, javaManagedDirectory.path);
    } on IOException catch (e) {
      setState(() {
        managedRadioState = .errored;
        managedError = e.toString();
        managedProgress = null;
      });
      return;
    }

    // Delete the archive; it is not needed anymore.
    try {
      await javaManagedArchive.delete(recursive: true);
    } on FileSystemException catch (e) {
      setState(() {
        managedRadioState = .errored;
        managedError = e.toString();
        managedProgress = null;
      });
      return;
    }

    final Directory binDir = Directory(
      p.join((await javaManagedDirectory.list().first).path, "bin"),
    );

    final File? javaExecutable = await findJavaExecutableInDirectory(binDir);
    if (javaExecutable == null) {
      setState(() {
        managedRadioState = .errored;
        managedError = "Could not find Java Executable in the download.";
        managedProgress = null;
      });
      return;
    }

    setState(() {
      managedRadioState = .success;
      managedError = null;
      managedProgress = null;
      ref
          .read(javaPathProvider.notifier)
          .setJavaPath(JavaPath(.managed, javaExecutable.path));
    });
  }

  Future<void> onCustom() async {
    final FilePickerResult? browsed = await FilePicker.platform.pickFiles(
      dialogTitle: "Select Java executable",
      // Specifically mention this, because we can't use FileType.custom, which would be expected here.
      // This is because it doesn't support files with no extension, which is the case for executables on linux.
      // ignore: avoid_redundant_argument_values
      type: FileType.any,
    );
    if (browsed == null) {
      return; // User canceled the browser
    }

    final String? javaPath = browsed.files.single.path;
    if (javaPath == null) {
      setState(() {
        customRadioState = .errored;
        customJavaVersion = null;
        customJavaPath = null;
        customError = "Path is null";
      });
      return;
    }

    customJavaPath = javaPath;
    try {
      final JavaPath potentialJavaPath = JavaPath(.custom, javaPath);
      final int javaVersion = await checkJavaVersion(potentialJavaPath);
      setState(() {
        customRadioState = .success;
        customJavaVersion = javaVersion;
        customError = null;
        ref.read(javaPathProvider.notifier).setJavaPath(potentialJavaPath);
      });
    } on JavaVersionCheckException catch (e) {
      setState(() {
        customRadioState = .errored;
        customJavaVersion = null;
        customError = e.message;
      });
    }
  }
}

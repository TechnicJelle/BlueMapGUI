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

enum _BundledRadioState { empty, downloading, hashing, unpacking, success, errored }

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

  _SystemRadioState systemRadioState = .loading;
  int? systemJavaVersion;
  String? systemError;

  _BundledRadioState bundledRadioState = .empty;

  late final Uri? bundledDownloadLink;
  late final String? bundleHash;
  String? bundledError;
  double? bundleProgress;

  void initBundleDownloadLink() {
    Uri createLink(String platform, String architecture) {
      return Uri.https(
        "api.adoptium.net",
        "/v3/binary/version/$javaBundleVersion/$platform/$architecture/jre/hotspot/normal/eclipse",
      );
    }

    // Hashes are SHA256
    switch (Abi.current()) {
      case Abi.linuxX64:
        bundledDownloadLink = createLink("linux", "x64");
        bundleHash = javaBundleLinuxX64Hash;
      case Abi.windowsX64:
        bundledDownloadLink = createLink("windows", "x64");
        bundleHash = javaBundleWindowsX64Hash;
    }
  }

  _CustomRadioState customRadioState = .empty;
  int? customJavaVersion;
  String? customJavaPath;
  String? customError;

  @override
  void initState() {
    super.initState();

    initBundleDownloadLink();

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
      onChanged: (JavaPathMode? newJavaPickerMode) {
        switch (newJavaPickerMode) {
          case .unset:
            onUnset();
          case .system:
            onSystem();
          case .bundled:
            unawaited(onBundled());
          case .custom:
            unawaited(onCustom());
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
          ),
          RadioListTile(
            value: JavaPathMode.system,
            title: Text(JavaPathMode.system.name.capitalize()),

            subtitle: switch (systemRadioState) {
              .loading => const Text("Checking System Java version..."),
              .success => Text("Detected System Java version: $systemJavaVersion"),
              .errored => Text("$systemError", style: red),
            },

            enabled: systemRadioState == .success,
          ),
          RadioListTile(
            value: JavaPathMode.bundled,
            title: Text(JavaPathMode.bundled.name.capitalize()),

            subtitle: bundledDownloadLink == null
                ? const Text(
                    "Your computer is incompatible with the automatic download. Please try the Custom mode below.",
                    style: red,
                  )
                : Column(
                    crossAxisAlignment: .start,
                    mainAxisSize: .min,
                    children: [
                      switch (bundledRadioState) {
                        .empty => const Text(
                          "Automatically download Java. Use this if you don't have a working System Installation, and you don't want to use a custom one either.",
                        ),
                        .downloading => const Text("Downloading..."),
                        .hashing => const Text("Verifying..."),
                        .unpacking => const Text("Unpacking..."),
                        .success => const Text(
                          "Successfully downloaded! You are ready to go!",
                        ),
                        .errored => Text("$bundledError", style: red),
                      },
                      if (bundledRadioState == .downloading ||
                          bundledRadioState == .hashing ||
                          bundledRadioState == .unpacking)
                        LinearProgressIndicator(value: bundleProgress),
                    ],
                  ),

            enabled: bundledDownloadLink != null,
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

  Future<void> onBundled() async {
    final Uri? downloadLink = bundledDownloadLink;
    final String? hash = bundleHash;
    if (downloadLink == null || hash == null) return;

    setState(() {
      bundledRadioState = .downloading;
      bundleProgress = null;
    });

    final Directory supportDir = await getApplicationSupportDirectory();
    final Directory javaBundleDirectory = Directory(p.join(supportDir.path, "java"));

    // Delete old Java Bundle(s)
    if (javaBundleDirectory.existsSync()) {
      try {
        await javaBundleDirectory.delete(recursive: true);
      } on FileSystemException catch (e) {
        setState(() {
          bundledRadioState = .errored;
          bundledError = e.toString();
          bundleProgress = null;
        });
        return;
      }
    }

    final NonHashedFile susBundleArchive;
    try {
      susBundleArchive = await downloadFile(
        uri: downloadLink,
        outputFileGenerator: (response) {
          final String filename = response.redirects.first.location.getFileName();
          return File(p.join(supportDir.path, filename));
        },
        onProgress: (double progress) {
          setState(() {
            bundleProgress = progress;
          });
        },
      );
    } on IOException catch (e) {
      setState(() {
        bundledRadioState = .errored;
        bundledError = e.toString();
        bundleProgress = null;
      });
      return;
    }

    setState(() {
      bundledRadioState = .hashing;
      bundleProgress = null;
    });

    final File? hashedBundleArchive = await susBundleArchive.hashFile(hash);
    if (hashedBundleArchive == null) {
      setState(() {
        bundledRadioState = .errored;
        bundledError =
            "Could not verify the downloaded Java Bundle archive's integrity!\n"
            "The hash of the downloaded file does not match the expected hash.";
        bundleProgress = null;
      });
      return;
    }
    final File javaBundleArchive = hashedBundleArchive;

    setState(() {
      bundledRadioState = .unpacking;
    });

    try {
      await extractFileToDisk(javaBundleArchive.path, javaBundleDirectory.path);
    } on IOException catch (e) {
      setState(() {
        bundledRadioState = .errored;
        bundledError = e.toString();
        bundleProgress = null;
      });
      return;
    }

    // Delete the archive; it is not needed anymore.
    try {
      await javaBundleArchive.delete(recursive: true);
    } on FileSystemException catch (e) {
      setState(() {
        bundledRadioState = .errored;
        bundledError = e.toString();
        bundleProgress = null;
      });
      return;
    }

    final Directory binDir = Directory(
      p.join((await javaBundleDirectory.list().first).path, "bin"),
    );

    final File? javaExecutable = await findJavaExecutableInDirectory(binDir);
    if (javaExecutable == null) {
      setState(() {
        bundledRadioState = .errored;
        bundledError = "Could not find Java Executable in the downloaded bundle.";
        bundleProgress = null;
      });
      return;
    }

    setState(() {
      bundledRadioState = .success;
      bundledError = null;
      bundleProgress = null;
      ref
          .read(javaPathProvider.notifier)
          .setJavaPath(JavaPath(.bundled, javaExecutable.path));
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

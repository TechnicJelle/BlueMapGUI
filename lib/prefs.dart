import "dart:async";
import "dart:io";
import "dart:typed_data";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:material_ui/material_ui.dart";
import "package:shared_preferences/shared_preferences.dart";

import "utils.dart";

late final SharedPreferencesWithCache _prefs;

Future<void> initPrefs() async {
  _prefs = await SharedPreferencesWithCache.create(
    cacheOptions: const SharedPreferencesWithCacheOptions(
      allowList: {
        JavaPathNotifier._javaPathKey,
        JavaPathNotifier._javaPathTypeKey,
        KnownProjectsNotifier._knownProjectsKey,
        ThemeModeProvider._themeModeKey,
        ConsoleClearProvider._consoleClearKey,
        RenderCavesDefaultProvider._renderCavesDefaultKey,
      },
    ),
  );
}

enum JavaPathMode { unset, system, managed, custom }

final class JavaResult {
  /// Exit code for the process.
  ///
  /// See [Process.exitCode] for more information in the exit code value.
  final int exitCode;

  /// Standard output from the process.
  final String stdout;

  /// Standard error from the process.
  final String stderr;

  /// Process id of the process.
  final int pid;

  JavaResult(this.pid, this.exitCode, Uint8List stdout, Uint8List stderr)
    : stdout = processOutputToString(stdout),
      stderr = processOutputToString(stderr);

  JavaResult.from(ProcessResult processResult)
    : pid = processResult.pid,
      exitCode = processResult.exitCode,
      stdout = processOutputToString(processResult.stdout),
      stderr = processOutputToString(processResult.stderr);
}

class JavaPath {
  JavaPathMode type;
  String path;

  JavaPath(this.type, this.path);

  Future<JavaResult> run({
    required List<String> args,
    Directory? workingDirectory,
  }) async {
    final ProcessResult processResult = await Process.run(
      path,
      args,
      workingDirectory: workingDirectory?.path,
    );
    return JavaResult.from(processResult);
  }

  Future<JavaResult> runJar(
    File jar, {
    List<String> jvmArgs = const [],
    List<String> processArgs = const [],
    Directory? workingDirectory,
  }) => run(
    args: ["-jar", ...jvmArgs, jar.path, ...processArgs],
    workingDirectory: workingDirectory,
  );

  Future<Process> startJar(
    File jar, {
    List<String> jvmArgs = const [],
    List<String> processArgs = const [],
    Directory? workingDirectory,
  }) => Process.start(
    path,
    ["-jar", ...jvmArgs, jar.path, ...processArgs],
    workingDirectory: workingDirectory?.path,
  );

  Future<JavaResult> runJarTimeout(
    File jar,
    Duration timeout, {
    List<String> jvmArgs = const [],
    List<String> processArgs = const [],
    Directory? workingDirectory,
  }) async {
    // These are actually Uint8's (raw bytes 0..255 from the OS pipe)
    final List<int> stdoutBuffer = [];
    final List<int> stderrBuffer = [];

    // Track stream completion to ensure all output is captured (see Process.exitCode's docs' last paragraph)
    final stdoutDone = Completer<void>();
    final stderrDone = Completer<void>();

    final Process process = await startJar(
      jar,
      jvmArgs: jvmArgs,
      processArgs: processArgs,
      workingDirectory: workingDirectory,
    );
    final stdoutSub = process.stdout.listen(
      stdoutBuffer.addAll,
      onDone: stdoutDone.complete,
    );
    final stderrSub = process.stderr.listen(
      stderrBuffer.addAll,
      onDone: stderrDone.complete,
    );

    //We kill the process after the duration
    bool wasKilled = false;
    final Timer killer = Timer(timeout, () {
      if (process.kill()) wasKilled = true;
    });

    // Wait for process to exit
    final int exitCode = await process.exitCode;
    // Wait for stdStreams to drain
    await Future.wait([stdoutDone.future, stderrDone.future]);
    // Cancel the stream subscriptions
    await Future.wait([stdoutSub.cancel(), stderrSub.cancel()]);
    //If the process has already stopped, we cancel the killer
    killer.cancel();

    if (wasKilled) {
      throw ProcessException(
        jar.path,
        [...jvmArgs, ...processArgs],
        "Timeout of $timeout was hit!",
      );
    }

    return JavaResult(
      process.pid,
      exitCode,
      Uint8List.fromList(stdoutBuffer),
      Uint8List.fromList(stderrBuffer),
    );
  }
}

class JavaPathNotifier extends Notifier<JavaPath?> {
  static const String _javaPathKey = "java_path";
  static const String _javaPathTypeKey = "java_path_type";

  @override
  JavaPath? build() {
    final String? path = _prefs.getString(_javaPathKey);
    if (path == null) return null;

    final String? typeString = _prefs.getString(_javaPathTypeKey);
    if (typeString == null) return null;
    final JavaPathMode? type = JavaPathMode.values.asNameMap()[typeString];
    if (type == null) return null;

    return JavaPath(type, path);
  }

  void setJavaPath(JavaPath javaPath) {
    state = javaPath;
    unawaited(_prefs.setString(_javaPathKey, javaPath.path));
    unawaited(_prefs.setString(_javaPathTypeKey, javaPath.type.name));
  }

  void clearJavaPath() {
    state = null;
    unawaited(_prefs.remove(_javaPathKey));
  }
}

// I don't want these for providers; too long
// ignore: specify_nonobvious_property_types
final javaPathProvider = NotifierProvider(JavaPathNotifier.new);

class KnownProjectsNotifier extends Notifier<List<Directory>> {
  static const String _knownProjectsKey = "known_projects";

  @override
  List<Directory> build() {
    final List<String> knownProjects = _prefs.getStringList(_knownProjectsKey) ?? [];
    final List<Directory> knownProjectsDirectories = knownProjects
        .map(Directory.new)
        .toList();
    return knownProjectsDirectories;
  }

  void addProject(Directory projectDirectory) {
    state = [...state, projectDirectory];
    projectDirectory.createSync(recursive: true);
    unawaited(
      _prefs.setStringList(
        _knownProjectsKey,
        state.map((Directory dir) => dir.path).toList(),
      ),
    );
  }

  void removeProject(Directory projectDirectory) {
    state = state.where((Directory dir) => dir != projectDirectory).toList();
    unawaited(
      _prefs.setStringList(
        _knownProjectsKey,
        state.map((Directory dir) => dir.path).toList(),
      ),
    );
  }
}

// I don't want these for providers; too long
// ignore: specify_nonobvious_property_types
final knownProjectsProvider = NotifierProvider(KnownProjectsNotifier.new);

class ThemeModeProvider extends Notifier<ThemeMode> {
  static const String _themeModeKey = "theme_mode";

  static const ThemeMode defaultOption = ThemeMode.system;

  @override
  ThemeMode build() {
    final String? themeModeString = _prefs.getString(_themeModeKey);
    final ThemeMode? themeMode = ThemeMode.values.asNameMap()[themeModeString];
    if (themeMode == null) return defaultOption;

    return themeMode;
  }

  void set(ThemeMode newThemeMode) {
    state = newThemeMode;
    unawaited(_prefs.setString(_themeModeKey, newThemeMode.name));
  }
}

// I don't want these for providers; too long
// ignore: specify_nonobvious_property_types
final themeModeProvider = NotifierProvider(ThemeModeProvider.new);

class ConsoleClearProvider extends Notifier<bool> {
  static const String _consoleClearKey = "console_clear";

  static const bool _defaultOption = true;

  @override
  bool build() {
    final bool? option = _prefs.getBool(_consoleClearKey);
    if (option == null) return _defaultOption;

    return option;
  }

  // The function name and lack of other parameters makes it clear enough
  // ignore: avoid_positional_boolean_parameters
  void set(bool? newOption) {
    state = newOption ?? _defaultOption;
    unawaited(_prefs.setBool(_consoleClearKey, state));
  }
}

// I don't want these for providers; too long
// ignore: specify_nonobvious_property_types
final consoleClearProvider = NotifierProvider(ConsoleClearProvider.new);

class RenderCavesDefaultProvider extends Notifier<bool> {
  static const String _renderCavesDefaultKey = "render_all_caves_by_default";

  static const bool _defaultOption = true;

  @override
  bool build() {
    final bool? option = _prefs.getBool(_renderCavesDefaultKey);
    if (option == null) return _defaultOption;

    return option;
  }

  // The function name and lack of other parameters makes it clear enough
  // ignore: avoid_positional_boolean_parameters
  void set(bool? newOption) {
    state = newOption ?? _defaultOption;
    unawaited(_prefs.setBool(_renderCavesDefaultKey, state));
  }
}

// I don't want these for providers; too long
// ignore: specify_nonobvious_property_types
final renderCavesDefaultProvider = NotifierProvider(RenderCavesDefaultProvider.new);

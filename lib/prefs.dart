import "dart:io";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:shared_preferences/shared_preferences.dart";

late final SharedPreferencesWithCache _prefs;

Future<void> initPrefs() async {
  _prefs = await SharedPreferencesWithCache.create(
    cacheOptions: const SharedPreferencesWithCacheOptions(
      allowList: {
        JavaPathNotifier._javaPathKey,
        JavaPathNotifier._javaPathTypeKey,
        KnownProjectsNotifier._knownProjectsKey,
      },
    ),
  );
}

enum JavaPathMode { unset, system, custom }

class JavaPath {
  JavaPathMode type;
  String path;

  JavaPath(this.type, this.path);
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

    JavaPathMode type;
    if (typeString == JavaPathMode.unset.name) {
      type = JavaPathMode.unset;
    } else if (typeString == JavaPathMode.system.name) {
      type = JavaPathMode.system;
    } else if (typeString == JavaPathMode.custom.name) {
      type = JavaPathMode.custom;
    } else {
      return null;
    }

    return JavaPath(type, path);
  }

  void setJavaPath(JavaPath javaPath) {
    state = javaPath;
    _prefs.setString(_javaPathKey, javaPath.path);
    _prefs.setString(_javaPathTypeKey, javaPath.type.name);
  }

  void clearJavaPath() {
    state = null;
    _prefs.remove(_javaPathKey);
  }
}

final javaPathProvider = NotifierProvider<JavaPathNotifier, JavaPath?>(
  () => JavaPathNotifier(),
);

class KnownProjectsNotifier extends Notifier<List<Directory>> {
  static const String _knownProjectsKey = "known_projects";

  @override
  List<Directory> build() {
    final List<String> knownProjects = _prefs.getStringList(_knownProjectsKey) ?? [];
    final List<Directory> knownProjectsDirectories = knownProjects
        .map((String path) => Directory(path))
        .toList();
    return knownProjectsDirectories;
  }

  void addProject(Directory projectDirectory) {
    state = [...state, projectDirectory];
    projectDirectory.create(recursive: true);
    _prefs.setStringList(
      _knownProjectsKey,
      state.map((Directory dir) => dir.path).toList(),
    );
  }

  void removeProject(Directory projectDirectory) {
    state = state.where((Directory dir) => dir != projectDirectory).toList();
    _prefs.setStringList(
      _knownProjectsKey,
      state.map((Directory dir) => dir.path).toList(),
    );
  }
}

final knownProjectsProvider = NotifierProvider<KnownProjectsNotifier, List<Directory>>(
  () => KnownProjectsNotifier(),
);

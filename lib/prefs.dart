import "dart:io";

import "package:flutter/material.dart";
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
        ThemeModeProvider._themeModeKey,
      },
    ),
  );
}

enum JavaPathMode { unset, system, bundled, custom }

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
    final JavaPathMode? type = JavaPathMode.values.asNameMap()[typeString];
    if (type == null) return null;

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

final javaPathProvider = NotifierProvider(() => JavaPathNotifier());

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

final knownProjectsProvider = NotifierProvider(() => KnownProjectsNotifier());

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
    _prefs.setString(_themeModeKey, newThemeMode.name);
  }
}

final themeModeProvider = NotifierProvider(() => ThemeModeProvider());

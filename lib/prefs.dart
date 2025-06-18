import "dart:io";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:shared_preferences/shared_preferences.dart";

late final SharedPreferencesWithCache _prefs;

Future<void> initPrefs() async {
  _prefs = await SharedPreferencesWithCache.create(
    cacheOptions: const SharedPreferencesWithCacheOptions(
      allowList: {
        JavaPathNotifier._javaPathKey,
        KnownProjectsNotifier._knownProjectsKey,
      },
    ),
  );
}

class JavaPathNotifier extends Notifier<String?> {
  static const String _javaPathKey = "java_path";

  @override
  String? build() {
    return _prefs.getString(_javaPathKey);
  }

  void setJavaPath(String javaPath) {
    state = javaPath;
    _prefs.setString(_javaPathKey, javaPath);
  }
}

final javaPathProvider = NotifierProvider<JavaPathNotifier, String?>(
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

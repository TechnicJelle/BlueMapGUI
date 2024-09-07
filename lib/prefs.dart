import "dart:io";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:shared_preferences/shared_preferences.dart";

late final SharedPreferencesWithCache _prefs;

Future<void> initPrefs() async {
  _prefs = await SharedPreferencesWithCache.create(
    cacheOptions: const SharedPreferencesWithCacheOptions(
      allowList: {
        JavaPathNotifier._javaPathKey,
        ProjectDirectoryNotifier._projectPathKey,
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

final javaPathProvider =
    NotifierProvider<JavaPathNotifier, String?>(() => JavaPathNotifier());

class ProjectDirectoryNotifier extends Notifier<Directory?> {
  static const String _projectPathKey = "project_path";

  @override
  Directory? build() {
    final String? bluemapJarPath = _prefs.getString(_projectPathKey);
    if (bluemapJarPath == null) {
      return null;
    } else {
      return Directory(bluemapJarPath);
    }
  }

  void openProject(Directory projectDirectory) {
    state = projectDirectory;
    _prefs.setString(_projectPathKey, projectDirectory.path);
  }

  void closeProject() {
    state = null;
    _prefs.remove(_projectPathKey);
  }
}

final projectDirectoryProvider = NotifierProvider<ProjectDirectoryNotifier, Directory?>(
    () => ProjectDirectoryNotifier());

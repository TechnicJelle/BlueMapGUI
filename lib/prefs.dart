import "dart:io";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:shared_preferences/shared_preferences.dart";

class JavaPathNotifier extends Notifier<String?> {
  static const String javaPathKey = "java_path";

  @override
  String? build() {
    return Prefs.instance._prefs.getString(javaPathKey);
  }

  void setJavaPath(String javaPath) {
    Prefs.instance._prefs.setString(javaPathKey, javaPath);
    state = build();
  }
}

final javaPathProvider =
    NotifierProvider<JavaPathNotifier, String?>(() => JavaPathNotifier());

class ProjectDirectoryNotifier extends Notifier<Directory?> {
  static const String projectPathKey = "project_path";

  @override
  Directory? build() {
    final String? bluemapJarPath = Prefs.instance._prefs.getString(projectPathKey);
    if (bluemapJarPath == null) {
      return null;
    } else {
      return Directory(bluemapJarPath);
    }
  }

  void openProject(Directory projectDirectory) {
    Prefs.instance._prefs.setString(projectPathKey, projectDirectory.path);
    state = build();
  }

  void closeProject() {
    Prefs.instance._prefs.remove(projectPathKey);
    state = null;
  }
}

final projectDirectoryProvider = NotifierProvider<ProjectDirectoryNotifier, Directory?>(
    () => ProjectDirectoryNotifier());

class Prefs {
  // == Static ==
  static late Prefs _instance;

  static Prefs get instance => _instance;

  // == Private Variables ==
  final SharedPreferences _prefs;

  // == Constructors ==
  Prefs._(this._prefs);

  // == Public Methods ==
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _instance = Prefs._(prefs);
  }
}

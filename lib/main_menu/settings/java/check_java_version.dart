import "dart:io";

import "../../../prefs.dart";

const int _minJavaVersion = 21;

class JavaVersionCheckException implements Exception {
  final String message;

  JavaVersionCheckException(this.message);
}

/// Checks the Java version at the given path.
/// Throws a [JavaVersionCheckException] if the Java version is too old, not installed, or the path is invalid.
Future<int> checkJavaVersion(JavaPath javaPath) async {
  final String path = javaPath.path;
  if (path.isEmpty) {
    throw JavaVersionCheckException("Provided path is empty.");
  }

  if (!path.contains("java")) {
    throw JavaVersionCheckException("Provided path is not a Java executable.");
  }

  // If the path is not the system Java path, check if the file exists
  if (path != "java") {
    if (!File(path).existsSync()) {
      throw JavaVersionCheckException("File at provided path does not exist.");
    }
  }

  try {
    final ProcessResult jv = await javaPath.run(args: ["-fullversion"]);
    final int exitCode = jv.exitCode;
    final String stderr = jv.stderr.toString();

    if (exitCode != 0) {
      throw JavaVersionCheckException("Process exited with $exitCode.\n$stderr");
    }

    final RegExp r = RegExp(r'^.*"(\d+\.\d+)');
    final Match? match = r.firstMatch(stderr);
    if (match == null) {
      throw JavaVersionCheckException(
        "Version message did not contain a version number.",
      );
    }

    String? versionString = match.group(1);
    if (versionString == null) {
      throw JavaVersionCheckException("Version message match did not have a group 1.");
    }

    if (versionString.startsWith("1.")) {
      // java 1.8 aka java 8
      versionString = versionString.substring(2);
    } else {
      // java all the other ones
      versionString = versionString.split(".").first;
    }

    final int? version = int.tryParse(versionString);
    if (version == null) {
      throw JavaVersionCheckException("Couldn't parse version message.");
    }

    if (version < _minJavaVersion) {
      if (path == "java") {
        throw JavaVersionCheckException(
          "System Java version is $version, which is too old. Please install Java $_minJavaVersion or newer.",
        );
      } else {
        throw JavaVersionCheckException(
          "This Java version is $version, which is too old. Please select Java $_minJavaVersion or newer.",
        );
      }
    }

    return version;
  } on ProcessException catch (e) {
    if (e.executable == "java") {
      throw JavaVersionCheckException(
        "Java (probably) not installed on your system. Please install Java $_minJavaVersion or newer.",
      );
    } else {
      throw JavaVersionCheckException("Invalid Java executable.");
    }
  }
}

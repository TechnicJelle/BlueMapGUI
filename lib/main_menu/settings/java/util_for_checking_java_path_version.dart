import "dart:io";

const int _minJavaVersion = 21;

/// Checks the Java version at the given path.
/// Throw an exception if the Java version is too old, not installed, or the path is invalid.
Future<int> checkJavaVersion(String javaPath) async {
  if (javaPath.isEmpty) {
    throw "Provided path is empty.";
  }

  if (!javaPath.contains("java")) {
    throw "Provided path is not a Java executable.";
  }

  // If the path is not the system Java path, check if the file exists
  if (javaPath != "java") {
    if (!File(javaPath).existsSync()) {
      throw "File at provided path does not exist.";
    }
  }

  try {
    ProcessResult jv = await Process.run(javaPath, ["-fullversion"]);
    final int exitCode = jv.exitCode;
    final String stderr = jv.stderr;

    if (exitCode != 0) {
      throw "Process exited with $exitCode.\n$stderr";
    }

    RegExp r = RegExp(r'^.*"(\d+\.\d+)');
    final Match? match = r.firstMatch(stderr);
    if (match == null) {
      throw "Version message did not contain a version number.";
    }

    String? versionString = match.group(1);
    if (versionString == null) {
      throw "Version message match did not have a group 1.";
    }

    if (versionString.startsWith("1.")) {
      // java 1.8 aka java 8
      versionString = versionString.substring(2);
    } else {
      // java all the other ones
      versionString = versionString.split(".").first;
    }

    int? version = int.tryParse(versionString);
    if (version == null) {
      throw "Couldn't parse version message.";
    }

    if (version < _minJavaVersion) {
      if (javaPath == "java") {
        throw "System Java version $version is too old. Please install Java $_minJavaVersion or newer.";
      } else {
        throw "This Java version $version is too old. Please select Java $_minJavaVersion or newer.";
      }
    }

    return version;
  } on ProcessException {
    if (javaPath == "java") {
      throw "Java (probably) not installed on your system. Please install Java $_minJavaVersion or newer.";
    } else {
      throw "Invalid Java executable.";
    }
  }
}

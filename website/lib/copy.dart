import "dart:io";

import "package:path/path.dart" as p;

import "constants.dart";

void copy(String source, String targetInBuild) {
  final targetDir = Directory(p.joinAll([dirBuild.path, ...targetInBuild.split("/")]))
    ..createSync();
  for (final FileSystemEntity fse in Directory(source).listSync(recursive: true)) {
    final String copyTo = p.join(targetDir.path, p.relative(fse.path, from: source));
    switch (fse) {
      case File():
        fse.copySync(copyTo);
      case Directory():
        Directory(copyTo).createSync(recursive: true);
    }
  }
}

void copyFile(String source, String targetInBuild) {
  final file = File(source);
  final String filename = p.basename(file.path);
  file.copySync(p.join(dirBuild.path, filename));
}

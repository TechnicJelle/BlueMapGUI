import "dart:io";

import "package:crypto/crypto.dart";
import "package:flutter/material.dart";
import "package:meta/meta.dart";
import "package:path/path.dart" as p;

import "main.dart";

final RegExp regexSafeCharacters = RegExp(r"^[a-zA-Z0-9_-]+$");

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}

extension UriExtension on Uri {
  String getFileName() {
    return p.basename(path);
  }
}

File getBlueMapJarFile(Directory projectDirectory) {
  return File(p.join(projectDirectory.path, blueMapCliJarUrl.getFileName()));
}

const TextStyle pixelCode = TextStyle(
  fontFamily: "PixelCode",
  fontSize: 14,
  height: 1.2,
);

/// Checks if the given file has the same SHA256 hash as the given hash.
/// Returns true if the hashes match, false otherwise.
Future<bool> checkHash(File file, String validHash) async {
  String fileHash = await file.openRead().transform(sha256).join();
  return fileHash == validHash;
}

class NonHashedFile {
  final File _file;

  NonHashedFile(this._file);

  Future<File?> hashFile(String validHash) async {
    if (await checkHash(_file, validHash)) {
      return _file;
    } else {
      return null;
    }
  }
}

@useResult
Future<NonHashedFile> downloadBlueMap(Directory projectDirectory) async {
  final client = HttpClient();
  final request = await client.getUrl(blueMapCliJarUrl);
  final response = await request.close();
  final File bluemapJar = getBlueMapJarFile(projectDirectory);
  await response.pipe(bluemapJar.openWrite());
  client.close();
  return NonHashedFile(bluemapJar);
}

@useResult
Future<NonHashedFile> downloadJava(Uri downloadLink, Directory supportDir) async {
  final client = HttpClient();
  final request = await client.getUrl(downloadLink);
  final response = await request.close();
  final String filename = response.redirects.first.location.getFileName();
  final javaBundleArchive = File(p.join(supportDir.path, filename));
  await response.pipe(javaBundleArchive.openWrite());
  client.close();
  return NonHashedFile(javaBundleArchive);
}

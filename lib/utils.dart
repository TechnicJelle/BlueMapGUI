import "dart:io";

import "package:crypto/crypto.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:path/path.dart" as p;

import "versions.dart";

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

Directory getMapTemplatesDirectory(Directory projectDirectory) {
  return Directory(
    p.join(projectDirectory.path, "config", "map-templates-$blueMapTag"),
  );
}

const TextStyle pixelCode = TextStyle(
  fontFamily: "PixelCode",
  fontSize: 14,
  height: 1.2,
  fontWeight: .w200,
);

Color getTextColourForBackground(Color backgroundColour) {
  return ThemeData.estimateBrightnessForColor(backgroundColour) == Brightness.dark
      ? Colors.white
      : Colors.black;
}

Color colorFromHexColour(String hexString) {
  final int ox = int.parse(hexString.replaceFirst("#", "0x")); //heehee

  if (hexString.length == 1 + 6) {
    final int b = ox & 255;
    final int g = (ox >> 8) & 255;
    final int r = (ox >> 16) & 255;
    return Color.fromARGB(255, r, g, b);
  }

  throw Exception("Failed to parse colour code: $hexString");
}

/// Checks if the given file has the same SHA256 hash as the given hash.
/// Returns true if the hashes match, false otherwise.
Future<bool> checkHash(File file, String validHash) async {
  final String fileHash = await file.openRead().transform(sha256).join();
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

class ProgressNotifier extends Notifier<double?> {
  @override
  double? build() {
    return null;
  }

  // Notifiers should not use setters
  // ignore: use_setters_to_change_properties
  void set(double progress) {
    state = progress;
  }

  void indeterminate() {
    state = null;
  }
}

/// `progress` is a double between 0 and 1.
Future<NonHashedFile> downloadFile({
  required Uri uri,
  required File Function(HttpClientResponse response) outputFileGenerator,
  void Function(double progress)? onProgress,
}) async {
  final client = HttpClient();
  final request = await client.getUrl(uri);
  final response = await request.close();

  final File outputFile = outputFileGenerator(response);
  final IOSink sink = outputFile.openWrite();

  int current = 0;
  await response.forEach((List<int> buffer) {
    if (onProgress != null) {
      current += buffer.length;
      final double progress = current.toDouble() / response.contentLength.toDouble();
      onProgress(progress);
    }
    sink.add(buffer);
  });

  client.close();
  return NonHashedFile(outputFile);
}

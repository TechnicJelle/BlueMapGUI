import "dart:convert";
import "dart:io";

import "package:flutter/services.dart";
import "package:path/path.dart" as p;
import "package:path_provider/path_provider.dart";

import "../../../prefs.dart";
import "core.dart";
import "map.dart";
import "startup.dart";
import "webapp.dart";
import "webserver.dart";

class ConfigFileLoadException implements Exception {
  final int exitCode;
  final String stderr;

  ConfigFileLoadException({
    required this.exitCode,
    required this.stderr,
  });
}

class ConfigFileCastException implements Exception {
  final String message;

  ConfigFileCastException({
    required this.message,
  });
}

class ConfigFile<T extends BaseConfigModel> {
  static File? _hoconFile;

  final File file;
  T model;

  ConfigFile(this.file, this.model);

  late String path = file.path;

  ///basenameWithoutExtension
  late String name = p.basenameWithoutExtension(path);

  static Future<ConfigFile> fromFile(File file, JavaPath javaPath) async =>
      (await fromFiles([file], javaPath)).first;

  static Future<List<ConfigFile>> fromFiles(
    List<File> files,
    JavaPath javaPath, {
    bool interpretAsMapConfig = false,
  }) async {
    if (_hoconFile == null) {
      final Directory supportDir = await getApplicationSupportDirectory();
      _hoconFile = File(p.join(supportDir.path, "HOCONReader.jar"));
      final hoconReaderAsset = await rootBundle.load("assets/HOCONReader.jar");
      await _hoconFile!.writeAsBytes(hoconReaderAsset.buffer.asUint8List());
    }

    final List<String> args = files.map((f) => f.path).toList();
    final ProcessResult result = await javaPath.runJar(_hoconFile!, processArgs: args);

    final int exitCode = result.exitCode;
    final String stderr = result.stderr.toString();
    if (exitCode != 0 || stderr.isNotEmpty) {
      throw ConfigFileLoadException(exitCode: exitCode, stderr: stderr);
    }
    final String stdout = result.stdout.toString();
    final List<String> jsons = stdout.split(String.fromCharCode(0));

    try {
      return List.generate(files.length, (int index) {
        final File file = files[index];
        final configMap = jsonDecode(jsons[index]) as Map<String, Object?>;
        if (p.basename(file.parent.path) == "maps" || interpretAsMapConfig) {
          return ConfigFile(file, MapConfigModel.fromJson(configMap));
        } else {
          return switch (p.basename(file.path)) {
            "core.conf" => ConfigFile(file, CoreConfigModel.fromJson(configMap)),
            "startup.conf" => ConfigFile(file, StartupConfigModel.fromJson(configMap)),
            "webapp.conf" => ConfigFile(file, WebappConfigModel.fromJson(configMap)),
            "webserver.conf" => ConfigFile(
              file,
              WebserverConfigModel.fromJson(configMap),
            ),
            _ => throw ConfigFileLoadException(
              exitCode: 137,
              stderr: "Could not conclude what type of config this is:\n ${file.path}",
            ),
          };
        }
      });
      // Rethrow the Error as a more safe Exception
      // In this case it *is* necessary to catch an Error
      // ignore: avoid_catching_errors
    } on TypeError catch (e) {
      throw ConfigFileCastException(message: e.toString());
    }
  }

  ///if [optionName] is not found, it just doesn't do anything
  void changeValueInFile(String optionName, String newValue) {
    final RegExp optionRegex = RegExp("(^\\s*$optionName:\\s*).*\$", multiLine: true);

    final String fileContents = file.readAsStringSync();
    final String newContents = fileContents.replaceFirstMapped(
      optionRegex,
      (Match match) => "${match[1]}$newValue",
    );
    file.writeAsStringSync(newContents);
  }

  @override
  String toString() {
    return "ConfigFile<$T>(file: $file, model: $model)";
  }
}

abstract class BaseConfigModel {
  const BaseConfigModel();
}

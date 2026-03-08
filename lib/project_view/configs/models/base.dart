import "dart:convert";
import "dart:io";

import "package:flutter/services.dart";
import "package:fpdart/fpdart.dart";
import "package:path/path.dart" as p;
import "package:path_provider/path_provider.dart";
import "package:re_editor/re_editor.dart";

import "../../../prefs.dart";
import "core.dart";
import "map.dart";
import "startup.dart";
import "webapp.dart";
import "webserver.dart";

abstract interface class FatalConfigFileLoadException implements Exception {
  String getDetails();
}

class FatalConfigFileRunException implements FatalConfigFileLoadException {
  final int _exitCode;
  final String _stderr;

  FatalConfigFileRunException({
    required int exitCode,
    required String stderr,
  }) : _exitCode = exitCode,
       _stderr = stderr;

  @override
  String getDetails() => _stderr;

  int getExitCode() => _exitCode;
}

class FatalConfigFileConcludeException implements FatalConfigFileLoadException {
  final String _message;

  FatalConfigFileConcludeException({
    required File file,
  }) : _message = "Could not conclude what type of config this is: ${file.path}";

  @override
  String getDetails() => _message;
}

class FatalConfigProblemException implements FatalConfigFileLoadException {
  final String _message;

  FatalConfigProblemException({
    required FileConfigFileLoadProblem problem,
  }) : _message = problem.getDetails();

  @override
  String getDetails() => _message;
}

// "Problem" so that they cannot be accidentally thrown

// I want to be able to call getDetails() even when I don't know exactly which one it is:
// ignore: one_member_abstracts
abstract interface class FileConfigFileLoadProblem {
  String getDetails();
}

class FileConfigFileCastProblem implements FileConfigFileLoadProblem {
  final String _message;

  FileConfigFileCastProblem({
    required TypeError typeError,
  }) : _message = typeError.toString().trim();

  @override
  String getDetails() => _message;
}

class FileConfigFileParseProblem implements FileConfigFileLoadProblem {
  final String _message;

  FileConfigFileParseProblem({
    required String message,
  }) : _message = message.trim();

  @override
  String getDetails() => _message;

  String getDetailsOnly() {
    final lines = _message.textLines
      ..removeAt(0)
      ..removeAt(0);
    return lines.join("\n");
  }

  int? getLine() {
    final RegExp lineFinder = RegExp(r"Line:?\s*(\d+)");
    final match = lineFinder.firstMatch(_message);
    if (match != null) {
      final String? lineNumber = match[1];
      if (lineNumber != null) {
        return int.tryParse(lineNumber);
      }
    }
    return null;
  }
}

class ConfigFile<T extends BaseConfigModel> {
  static File? _hoconFile;

  final File file;
  Either<FileConfigFileLoadProblem, T> modelOrProblem;

  ConfigFile(this.file, this.modelOrProblem);

  late String path = file.path;

  /// basenameWithoutExtension
  late String name = p.basenameWithoutExtension(path);

  /// This replaceAll replicates BlueMap's own behaviour: https://github.com/BlueMap-Minecraft/BlueMap/blob/c232a79c51b711b22c2771d24c1fb5024d46f7ae/common/src/main/java/de/bluecolored/bluemap/common/config/BlueMapConfigManager.java#L382-L384
  late String sanitisedMapId = name.replaceAll(RegExp(r"\W"), "_");

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
      throw FatalConfigFileRunException(exitCode: exitCode, stderr: stderr);
    }
    final String stdout = result.stdout.toString();
    final List<String> jsons = stdout.split(String.fromCharCode(0));

    return List.generate(files.length, (int index) {
      final File file = files[index];
      final String item = jsons[index];
      if (item.startsWith("Error ")) {
        final ex = FileConfigFileParseProblem(message: item);
        return _fileToConfigFile(
          file: file,
          interpretAsMapConfig: interpretAsMapConfig,
          onMap: () => ConfigFile<MapConfigModel>(file, .left(ex)),
          onCore: () => ConfigFile<CoreConfigModel>(file, .left(ex)),
          onStartup: () => ConfigFile<StartupConfigModel>(file, .left(ex)),
          onWebapp: () => ConfigFile<WebappConfigModel>(file, .left(ex)),
          onWebserver: () => ConfigFile<WebserverConfigModel>(file, .left(ex)),
        );
      } else {
        final configMap = jsonDecode(item) as Map<String, Object?>;
        try {
          return _fileToConfigFile(
            file: file,
            interpretAsMapConfig: interpretAsMapConfig,
            onMap: () => ConfigFile<MapConfigModel>(file, .of(.fromJson(configMap))),
            onCore: () => ConfigFile<CoreConfigModel>(file, .of(.fromJson(configMap))),
            onStartup: () =>
                ConfigFile<StartupConfigModel>(file, .of(.fromJson(configMap))),
            onWebapp: () =>
                ConfigFile<WebappConfigModel>(file, .of(.fromJson(configMap))),
            onWebserver: () =>
                ConfigFile<WebserverConfigModel>(file, .of(.fromJson(configMap))),
          );

          // In this case it *is* necessary to catch an Error
          // ignore: avoid_catching_errors
        } on TypeError catch (e) {
          // This happens when the .fromJson call fails due to a type mismatch between the expectation of the model, and the reality that we parsed.
          // So we turn the Error into Problem for the user instead, because it is up to the user to fix their config so it is not a Problem anymore.
          final problem = FileConfigFileCastProblem(typeError: e);
          return _fileToConfigFile(
            file: file,
            interpretAsMapConfig: interpretAsMapConfig,
            onMap: () => ConfigFile<MapConfigModel>(file, .left(problem)),
            onCore: () => ConfigFile<CoreConfigModel>(file, .left(problem)),
            onStartup: () => ConfigFile<StartupConfigModel>(file, .left(problem)),
            onWebapp: () => ConfigFile<WebappConfigModel>(file, .left(problem)),
            onWebserver: () => ConfigFile<WebserverConfigModel>(file, .left(problem)),
          );
        }
      }
    });
  }

  static ConfigFile<BaseConfigModel> _fileToConfigFile({
    required File file,
    required bool interpretAsMapConfig,
    required _ConfigFileCallback onMap,
    required _ConfigFileCallback onCore,
    required _ConfigFileCallback onStartup,
    required _ConfigFileCallback onWebapp,
    required _ConfigFileCallback onWebserver,
  }) {
    if (p.basename(file.parent.path) == "maps" || interpretAsMapConfig) {
      return onMap();
    } else {
      return switch (p.basename(file.path)) {
        "core.conf" => onCore(),
        "startup.conf" => onStartup(),
        "webapp.conf" => onWebapp(),
        "webserver.conf" => onWebserver(),
        _ => throw FatalConfigFileConcludeException(file: file),
      };
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
    return "ConfigFile<$T>(file: $file, model: $modelOrProblem)";
  }
}

typedef _ConfigFileCallback = ConfigFile Function();

abstract class BaseConfigModel {
  const BaseConfigModel();
}

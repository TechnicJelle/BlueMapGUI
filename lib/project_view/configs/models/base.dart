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

class ConfigFile<T extends BaseConfigModel> {
  File file;
  T model;

  ConfigFile(this.file, this.model);

  static Future<ConfigFile?> fromFile(File file, JavaPath javaPath) async {
    final Directory supportDir = await getApplicationSupportDirectory();
    final File hoconReaderFile = File(p.join(supportDir.path, "HOCONReader.jar"));
    if (!hoconReaderFile.existsSync()) {
      final hoconReaderAsset = await rootBundle.load("assets/HOCONReader.jar");
      await hoconReaderFile.writeAsBytes(hoconReaderAsset.buffer.asUint8List());
    }

    final ProcessResult result = await javaPath.runJar(
      hoconReaderFile,
      processArgs: [file.path],
    );

    //TODO: Error handling!
    final int exitCode = result.exitCode;
    final String stderr = result.stderr.toString();
    if (exitCode != 0 || stderr.isNotEmpty) {
      print("exitCode: $exitCode");
      print("stderr: $stderr");
      return null;
    }
    final String stdout = result.stdout.toString();

    final configMap = jsonDecode(stdout) as Map<String, dynamic>;
    if (p.basename(file.parent.path) == "maps") {
      return ConfigFile(file, MapConfigModel.fromJson(configMap));
    }
    return switch (p.basename(file.path)) {
      "core.conf" => ConfigFile(file, CoreConfigModel.fromJson(configMap)),
      "startup.conf" => ConfigFile(file, StartupConfigModel.fromJson(configMap)),
      "webapp.conf" => ConfigFile(file, WebappConfigModel.fromJson(configMap)),
      "webserver.conf" => ConfigFile(file, WebserverConfigModel.fromJson(configMap)),
      _ => null,
    };
  }

  void changeValueInFile(String optionName, String newValue) {
    final RegExp optionRegex = RegExp("(^\\s*$optionName:\\s*).*\$", multiLine: true);

    final String fileContents = file.readAsStringSync();
    final String newContents = fileContents.replaceFirstMapped(
      optionRegex,
      (Match match) => "${match[1]}$newValue",
    );
    file.writeAsStringSync(newContents);
  }
}

abstract class BaseConfigModel {
  const BaseConfigModel();
}

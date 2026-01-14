import "dart:convert";
import "dart:io";

import "package:flutter/services.dart";
import "package:path/path.dart" as p;
import "package:path_provider/path_provider.dart";

import "../../../prefs.dart";
import "core.dart";
import "startup.dart";

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
      //this is a map config
    }
    return switch (p.basename(file.path)) {
      "core.conf" => ConfigFile(file, CoreConfigModel.fromJson(configMap)),
      "startup.conf" => ConfigFile(file, StartupConfigModel.fromJson(configMap)),
      //TODO: The other configs (this causes infinite loading for unsupported configs)
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

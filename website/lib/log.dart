import "dart:io";

import "package:logging/logging.dart";

final Logger log = _setupLogger();

Logger _setupLogger() {
  Logger.root.level = Level.ALL; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    stdout.writeln("${record.level.name}: ${record.time}: ${record.message}");
  });
  return Logger("SSG");
}

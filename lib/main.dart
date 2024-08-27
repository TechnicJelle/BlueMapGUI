import "dart:convert";
import "dart:io";

import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:path/path.dart" as p;

import "dual_pane.dart";
import "tech_app.dart";

const String commit = String.fromEnvironment("commit", defaultValue: "development");

const blueMapCliJarUrl = "https://github.com/BlueMap-Minecraft/BlueMap/releases/download/"
    "v5.3/BlueMap-5.3-cli.jar";

String get blueMapCliJarName => blueMapCliJarUrl.split("/").last;

class Globals {
  Directory projectDirectory;
  File bluemapJar;

  Globals(this.projectDirectory, this.bluemapJar);
}

final projectGlobals = FutureProvider<Globals>((ref) async {
  Directory dir = Directory("/home/technicjelle/Downloads/bmsupport/my_bluemap_dir/");
  if (!dir.existsSync()) {
    dir.createSync(recursive: true);
  }
  final contents = dir.listSync();

  File? bluemapJar;
  for (final file in contents) {
    if (file is! File) continue;
    String fileName = p.split(file.path).last;
    if (fileName == blueMapCliJarName) {
      bluemapJar = file;
      break;
    }
  }

  if (bluemapJar == null) {
    Uri link = Uri.parse(blueMapCliJarUrl);
    final client = HttpClient();
    final request = await client.getUrl(link);
    final response = await request.close();
    bluemapJar = File(p.join(dir.path, blueMapCliJarName));
    await response.pipe(bluemapJar.openWrite());
    client.close();
  }

  ProcessResult run = await Process.run(
    "java",
    ["-jar", bluemapJar.path],
    workingDirectory: dir.path,
    stdoutEncoding: utf8,
  );

  final String stdout = run.stdout;
  if (!stdout.contains("Generated default config files for you")) {
    throw Exception("BlueMap CLI JAR failed to run!");
  }

  return Globals(dir, bluemapJar);
});

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return TechApp(
      title: "BlueMap GUI",
      primary: Colors.blue,
      secondary: Colors.blueAccent,
      themeMode: ThemeMode.system,
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends ConsumerWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<Globals> asyncGlobals = ref.watch(projectGlobals);

    String title = "BlueMap GUI";
    asyncGlobals.whenData((globals) {
      title += ": ${globals.projectDirectory.path}";
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: const [Text(commit)],
      ),
      body: Center(
        child: switch (asyncGlobals) {
          AsyncData() => const DualPane(),
          AsyncError(:final error) =>
            Text("$error", style: const TextStyle(color: Colors.red)),
          _ => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 8),
                Text("Downloading $blueMapCliJarName..."),
              ],
            ),
        },
      ),
    );
  }
}

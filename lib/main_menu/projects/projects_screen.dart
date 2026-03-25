import "dart:async";
import "dart:io";
import "dart:math" as math;

import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../prefs.dart";
import "../settings/java/check_java_version.dart";
import "new_project_dialog.dart";
import "project_tile.dart";

class ProjectsScreen extends ConsumerStatefulWidget {
  const ProjectsScreen({super.key});

  @override
  ConsumerState<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends ConsumerState<ProjectsScreen> {
  bool loading = false;
  bool javaSelected = false;
  String? javaError;

  @override
  void initState() {
    super.initState();

    final JavaPath? javaPath = ref.read(javaPathProvider);
    if (javaPath == null) {
      loading = false;
      javaSelected = false;
      javaError = null;
    } else {
      loading = true;
      javaSelected = true;
      unawaited(
        checkJavaVersion(javaPath).then(
          (_) {
            setState(() {
              loading = false;
            });
          },
          onError: (Object e) {
            setState(() {
              loading = false;
              javaError = e is JavaVersionCheckException ? e.message : e.toString();
            });
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (!javaSelected) {
      return const _JavaError("Please set up Java in the settings");
    }
    final String? thisJavaError = javaError;
    if (thisJavaError != null) {
      if (thisJavaError.contains("install")) {
        return _JavaError(
          "$thisJavaError\n"
          "Or choose a different Java Executable in the settings",
        );
      } else if (thisJavaError.contains("select")) {
        return const _JavaError(
          "Managed Java version is too old.\n"
          'Please update in the settings: unset your Java Executable and reselect "Managed".',
        );
      } else {
        return _JavaError(thisJavaError);
      }
    }

    final List<Directory> projects = ref.watch(knownProjectsProvider);

    return Stack(
      children: [
        ListView.separated(
          itemCount: projects.length + 1,
          itemBuilder: (BuildContext context, int index) {
            if (index == projects.length) {
              return const SizedBox(height: 64 + 24);
            }
            final projectDirectory = projects[index];
            return ProjectTile(projectDirectory);
          },
          separatorBuilder: (BuildContext context, int index) =>
              const Divider(height: 1),
        ),

        if (projects.isEmpty)
          Center(
            child: Column(
              mainAxisSize: .min,
              children: [
                const Text("You can create a new project with the (+) button"),
                const SizedBox(height: 6),
                Transform.rotate(
                  angle: -math.pi / 4.0,
                  child: const Icon(Icons.arrow_downward),
                ),
              ],
            ),
          ),

        if (projects.length == 1)
          const Center(
            child: Column(
              mainAxisSize: .min,
              children: [
                Icon(Icons.arrow_upward),
                SizedBox(height: 6),
                Text("You can open your project by clicking it"),
              ],
            ),
          ),

        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            child: const Icon(Icons.add),
            onPressed: () {
              unawaited(
                showDialog<void>(
                  context: context,
                  builder: (context) => const NewProjectDialog(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _JavaError extends StatelessWidget {
  final String message;

  const _JavaError(this.message);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: .center,
      children: [
        Text(message),
        const SizedBox(height: 8),
        const Icon(Icons.arrow_back),
      ],
    );
  }
}

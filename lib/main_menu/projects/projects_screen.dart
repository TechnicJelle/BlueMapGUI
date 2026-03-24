import "dart:async";
import "dart:io";

import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../prefs.dart";
import "../../project_view/project_view.dart";
import "../settings/java/check_java_version.dart";
import "new_project_dialog.dart";
import "project_tile.dart";

class OpenProjectNotifier extends Notifier<Directory?> {
  @override
  Directory? build() {
    return null;
  }

  // Notifiers should not use setters
  // ignore: use_setters_to_change_properties
  void openProject(Directory projectDirectory) {
    state = projectDirectory;
  }

  void closeProject() {
    ref.read(openConfigProvider.notifier).close();
    state = null;
  }
}

// I don't want these for providers; too long
// ignore: specify_nonobvious_property_types
final openProjectProvider = NotifierProvider(OpenProjectNotifier.new);

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
        checkJavaVersion(javaPath.path).then(
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
          "Bundled Java version is too old.\n"
          'Please update in the settings: unset your Java Executable and reselect "Bundled".',
        );
      } else {
        return _JavaError(thisJavaError);
      }
    }

    final List<Directory> projects = ref.watch(knownProjectsProvider);

    return Stack(
      children: [
        ListView.builder(
          itemCount: projects.length + 1,
          itemBuilder: (BuildContext context, int index) {
            if (index == projects.length) {
              return const SizedBox(height: 64 + 24);
            }
            final projectDirectory = projects[index];
            return ProjectTile(projectDirectory);
          },
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
    return Center(
      child: Text(
        "⟵\n\n$message\n\n⟵",
        textAlign: .center,
      ),
    );
  }
}

import "dart:async";
import "dart:io";

import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../prefs.dart";
import "../../project_view/project_view.dart";
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

class ProjectsScreen extends ConsumerWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(javaPathProvider.select((path) => path == null))) {
      return const Center(
        child: Text(
          "⟵\n\nPlease set up your Java in the settings\n\n⟵",
          textAlign: TextAlign.center,
        ),
      );
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

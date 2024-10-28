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

  void openProject(Directory projectDirectory) {
    state = projectDirectory;
  }

  void closeProject() {
    ref.read(openConfigProvider.notifier).close();
    state = null;
  }
}

final openProjectProvider =
    NotifierProvider<OpenProjectNotifier, Directory?>(() => OpenProjectNotifier());

class ProjectsScreen extends ConsumerWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(javaPathProvider.select((path) => path == null))) {
      return const Center(
        child: Text("⬅ Please select your Java in the settings"),
      );
    }

    final List<Directory> projects = ref.watch(knownProjectsProvider);

    return Stack(
      children: [
        ListView.builder(
          itemCount: projects.length,
          itemBuilder: (BuildContext context, int index) {
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
              showDialog(
                context: context,
                builder: (context) => const NewProjectDialog(),
              );
            },
          ),
        ),
      ],
    );
  }
}

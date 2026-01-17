import "dart:async";
import "dart:io";

import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../prefs.dart";
import "new_project_dialog.dart";
import "project_tile.dart";

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

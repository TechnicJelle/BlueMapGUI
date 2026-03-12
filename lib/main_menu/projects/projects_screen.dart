import "dart:async";
import "dart:io";
import "dart:math" as math;

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
      return const Column(
        mainAxisAlignment: .center,
        children: [
          Text("Please set up your Java in the settings"),
          SizedBox(height: 8),
          Icon(Icons.arrow_back),
        ],
      );
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

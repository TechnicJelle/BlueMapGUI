import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "projects/projects_screen.dart";
import "settings/settings_screen.dart";

enum MainMenuState { projects, settings }

class MainMenu extends ConsumerStatefulWidget {
  const MainMenu({super.key});

  @override
  ConsumerState<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends ConsumerState<MainMenu> {
  MainMenuState state = MainMenuState.projects;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          constraints: const BoxConstraints(maxWidth: 200),
          child: ListView(
            children: [
              ListTile(
                title: const Text("Projects"),
                selected: state == MainMenuState.projects,
                onTap: () => setState(() => state = MainMenuState.projects),
              ),
              ListTile(
                title: const Text("Settings"),
                selected: state == MainMenuState.settings,
                onTap: () => setState(() => state = MainMenuState.settings),
              ),
            ],
          ),
        ),
        const VerticalDivider(width: 2),
        Expanded(
          child: switch (state) {
            MainMenuState.projects => const ProjectsScreen(),
            MainMenuState.settings => const SettingsScreen(),
          },
        ),
      ],
    );
  }
}

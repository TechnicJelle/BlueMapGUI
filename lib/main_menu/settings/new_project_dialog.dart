import "dart:io";

import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:path/path.dart" as p;
import "package:path_provider/path_provider.dart";

import "../../prefs.dart";

//TODO: This thing needs a LOT of polish and error checking!
class NewProjectDialog extends ConsumerStatefulWidget {
  const NewProjectDialog({super.key});

  @override
  NewProjectDialogState createState() => NewProjectDialogState();
}

class NewProjectDialogState extends ConsumerState<NewProjectDialog> {
  final TextEditingController _nameController = TextEditingController(text: "untitled");
  TextEditingController? _locationController;

  String get _projectPath =>
      p.join(_locationController?.text ?? "", _nameController.text);

  @override
  void initState() {
    super.initState();
    getApplicationDocumentsDirectory().then((documentsDirectory) {
      final String projectDir = p.join(documentsDirectory.path, "BlueMapGUI");
      setState(() {
        _locationController = TextEditingController(text: projectDir);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("New project"),
      content: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 600),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                labelText: "Name:",
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _locationController,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                labelText: "Location:",
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Project will be created in: $_projectPath",
              style:
                  Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            ref.read(knownProjectsProvider.notifier).addProject(Directory(_projectPath));
            Navigator.of(context).pop();
          },
          child: const Text("Create"),
        ),
      ],
    );
  }
}

import "dart:io";

import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:path/path.dart" as p;
import "package:path_provider/path_provider.dart";

import "../../prefs.dart";

class NewProjectDialog extends ConsumerStatefulWidget {
  const NewProjectDialog({super.key});

  @override
  NewProjectDialogState createState() => NewProjectDialogState();
}

class NewProjectDialogState extends ConsumerState<NewProjectDialog> {
  final formKey = GlobalKey<FormState>();
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
  void dispose() {
    _nameController.dispose();
    _locationController?.dispose();
    super.dispose();
  }

  void validateAndCreate() {
    final formState = formKey.currentState;
    if (formState != null && formState.validate()) {
      Navigator.of(context).pop();
      ref.read(knownProjectsProvider.notifier).addProject(Directory(_projectPath));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("New project"),
      content: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 600),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  labelText: "Name:",
                ),
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.words,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Can't be empty";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  labelText: "Location:",
                ),
                textInputAction: TextInputAction.done,
                textCapitalization: TextCapitalization.none,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Can't be empty";
                  }
                  if (!Directory(value).existsSync()) {
                    return "Directory does not exist";
                  }
                  return null;
                },
                onFieldSubmitted: (_) => validateAndCreate(),
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
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () => validateAndCreate(),
          child: const Text("Create"),
        ),
      ],
    );
  }
}

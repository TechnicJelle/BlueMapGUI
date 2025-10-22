import "dart:async";
import "dart:io";

import "package:file_picker/file_picker.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:path/path.dart" as p;
import "package:path_provider/path_provider.dart";

import "../../prefs.dart";
import "../../utils.dart";

class NewProjectDialog extends ConsumerStatefulWidget {
  const NewProjectDialog({super.key});

  @override
  NewProjectDialogState createState() => NewProjectDialogState();
}

class NewProjectDialogState extends ConsumerState<NewProjectDialog> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController(text: "untitled");
  TextEditingController? _locationController;

  String? specialError;

  String get _projectPath =>
      p.join(_locationController?.text ?? "", _nameController.text);

  /// Protection against getting stored in a OneDrive folder
  Directory oneDriveProtection(Directory osDocumentsDirectory) {
    if (p.basename(osDocumentsDirectory.parent.path) == "OneDrive") {
      // Protection against users called "OneDrive"
      if (p.basename(osDocumentsDirectory.parent.parent.path) == "Users") {
        return osDocumentsDirectory;
      }

      final String documentsName = p.basename(osDocumentsDirectory.path);
      return Directory(p.join(osDocumentsDirectory.parent.parent.path, documentsName));
    }

    return osDocumentsDirectory;
  }

  @override
  void initState() {
    super.initState();
    unawaited(
      getApplicationDocumentsDirectory().then((Directory osDocumentsDirectory) {
        final documentsDirectory = oneDriveProtection(osDocumentsDirectory);
        final String projectDir = p.join(documentsDirectory.path, "BlueMapGUI");
        setState(() {
          _locationController = TextEditingController(text: projectDir);
        });
      }),
    );
    _nameController.selection = TextSelection(
      baseOffset: 0,
      extentOffset: _nameController.value.text.length,
    );
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
      //Check if project is already known:
      final knownProjects = ref.read(knownProjectsProvider);
      if (knownProjects.any((projectDir) => p.equals(projectDir.path, _projectPath))) {
        setState(() {
          specialError = "Project is already in the list!";
        });
        return;
      }

      final Directory projectDirectory = Directory(_projectPath);
      try {
        projectDirectory.createSync(recursive: true);
      } on FileSystemException catch (e) {
        if (e.toString().toLowerCase().contains("perm")) {
          setState(() {
            specialError = "No file permissions to create project directory there!";
          });
        } else {
          setState(() {
            specialError = "Failed to create project directory!\n$e";
          });
        }
        return;
      }

      Navigator.of(context).pop();
      ref.read(knownProjectsProvider.notifier).addProject(projectDirectory);
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
                autofocus: true,
                onChanged: (_) => setState(() {
                  specialError = null;
                }),
                decoration: const InputDecoration(labelText: "Name:"),
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.words,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (String? s) {
                  if (s == null || s.trim().isEmpty) {
                    return "Can't be empty";
                  }
                  if (!regexSafeCharacters.hasMatch(s)) {
                    return "Invalid character";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _locationController,
                      onChanged: (_) => setState(() {
                        specialError = null;
                      }),
                      decoration: const InputDecoration(labelText: "Location:"),
                      textInputAction: TextInputAction.done,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (String? s) {
                        if (s == null || s.trim().isEmpty) {
                          return "Can't be empty";
                        }
                        return null;
                      },
                      onFieldSubmitted: (_) => validateAndCreate(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 24, left: 8),
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final String? picked = await FilePicker.platform
                            .getDirectoryPath(dialogTitle: "Pick project location");
                        if (picked == null) return;

                        setState(() {
                          _locationController?.text = picked;
                        });
                      },
                      icon: const Icon(Icons.folder_open),
                      label: const Text("Pick"),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[300]),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                "Project will be created in: $_projectPath",
                style: Theme.of(
                  context,
                ).textTheme.labelMedium?.copyWith(color: Colors.grey),
              ),
              if (specialError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      specialError!,
                      style: TextStyle(color: Colors.red[400], fontSize: 14),
                    ),
                  ),
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
        ElevatedButton(onPressed: validateAndCreate, child: const Text("Create")),
      ],
    );
  }
}

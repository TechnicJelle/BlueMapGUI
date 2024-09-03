import "dart:io";

import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:path/path.dart" as p;

import "dual_pane.dart";
import "main.dart";
import "utils.dart";

final RegExp regexIDValidation = RegExp(r"^[a-zA-Z0-9_-]+$");

class NewMapDialog extends ConsumerStatefulWidget {
  const NewMapDialog({super.key});

  @override
  ConsumerState<NewMapDialog> createState() => _NewMapDialogState();
}

class _NewMapDialogState extends ConsumerState<NewMapDialog> {
  //Widget stuff
  final formKey = GlobalKey<FormState>();
  final idController = TextEditingController();

  //Data stuff
  late final List<DropdownMenuEntry<File>> options;
  late final Directory projectDirectory;

  //Output stuff
  File? selectedTemplate;

  @override
  void initState() {
    super.initState();
    final Directory? projDir = ref.read(projectDirectoryProvider);
    if (projDir == null) return;
    projectDirectory = projDir;

    final Directory mapTemplatesDirectory = Directory(
      p.join(projectDirectory.path, "config", "map-templates"),
    );

    final List<File> mapTemplates =
        mapTemplatesDirectory.listSync().whereType<File>().toList();

    options = mapTemplates
        .map(
          (template) => DropdownMenuEntry(
            value: template,
            label: p.basenameWithoutExtension(template.path).capitalize(),
          ),
        )
        .toList();
  }

  void validateAndCreate() {
    final formState = formKey.currentState;
    if (formState != null && formState.validate()) {
      File template = selectedTemplate!;
      String id = idController.text;

      File newConfig = File(
        p.join(projectDirectory.path, "config", "maps", "$id.conf"),
      );

      template.copySync(newConfig.path);

      Navigator.of(context).pop();

      ref.read(openConfigProvider.notifier).open(newConfig);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("New map"),
      content: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Map type:"),
            const SizedBox(height: 8),
            FormField(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (field) {
                if (selectedTemplate == null) {
                  return "Can't be empty";
                }
                return null;
              },
              builder: (field) => DropdownMenu(
                hintText: "Select a template",
                errorText: field.errorText,
                dropdownMenuEntries: options,
                onSelected: (File? template) {
                  setState(() {
                    selectedTemplate = template;
                    field.didChange(template);
                  });
                },
                width: 200,
              ),
            ),
            const SizedBox(height: 16),
            const Text("Map ID:"),
            TextFormField(
              controller: idController,
              decoration: InputDecoration(
                hintText: selectedTemplate == null
                    ? "my-cool-map"
                    : "my-cool-${p.basenameWithoutExtension(selectedTemplate!.path)}-map",
              ),
              textInputAction: TextInputAction.done,
              textCapitalization: TextCapitalization.none,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (String? s) {
                if (s == null || s.trim().isEmpty) {
                  return "Can't be empty";
                }
                if (!regexIDValidation.hasMatch(s)) {
                  return "Invalid character";
                }
                File potentialNewConfig = File(
                  p.join(projectDirectory.path, "config", "maps", "$s.conf"),
                );
                if (potentialNewConfig.existsSync()) {
                  return "Can't have a duplicate ID";
                }
                return null;
              },
              onFieldSubmitted: (_) => validateAndCreate(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
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

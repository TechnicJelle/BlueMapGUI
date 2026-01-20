import "dart:io";

import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:path/path.dart" as p;

import "../prefs.dart";
import "../project_configs_provider.dart";
import "../utils.dart";
import "configs/models/base.dart";
import "configs/models/map.dart";

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

  //State stuff
  bool validating = false;

  @override
  void initState() {
    super.initState();
    projectDirectory = ref.read(projectProvider)!.projectLocation;

    final mapTemplatesDirectory = getMapTemplatesDirectory(projectDirectory);

    final List<File> mapTemplates = mapTemplatesDirectory
        .listSync()
        .whereType<File>()
        .toList();

    options = mapTemplates
        .map(
          (template) => DropdownMenuEntry(
            value: template,
            label: p.basenameWithoutExtension(template.path).capitalize(),
          ),
        )
        .toList();
  }

  @override
  void dispose() {
    idController.dispose();
    super.dispose();
  }

  Future<void> validateAndCreate() async {
    if (validating) return;
    final formState = formKey.currentState;
    if (formState != null && formState.validate()) {
      setState(() => validating = true);
      final File template = selectedTemplate!;
      final String id = idController.text;

      final File newConfig = File(
        p.join(projectDirectory.path, "config", "maps", "$id.conf"),
      );

      template.copySync(newConfig.path);

      final javaPath = ref.read(javaPathProvider)!;
      final config = await ConfigFile.fromFile(newConfig, javaPath);
      final ConfigFile<MapConfigModel> newMapConfig = ConfigFile(
        config.file,
        config.model as MapConfigModel,
      );

      ref.read(projectProvider.notifier).addMap(newMapConfig);

      if (mounted) {
        final nav = Navigator.of(context);
        if (nav.canPop()) nav.pop();
      }
    }
    setState(() => validating = false);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("New map"),
      content: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: validating ? .center : .start,
          mainAxisSize: .min,
          children: validating
              ? [const CircularProgressIndicator()]
              : [
                  const Text("Map type:"),
                  const SizedBox(height: 8),
                  FormField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (field) {
                      if (selectedTemplate == null) {
                        return "Can't be empty or invalid selection";
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
                      width: 300,
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
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (String? s) {
                      if (s == null || s.trim().isEmpty) {
                        return "Can't be empty";
                      }
                      if (!regexSafeCharacters.hasMatch(s)) {
                        return "Invalid character";
                      }
                      final File potentialNewConfig = File(
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
        ElevatedButton(onPressed: validateAndCreate, child: const Text("Create")),
      ],
    );
  }
}

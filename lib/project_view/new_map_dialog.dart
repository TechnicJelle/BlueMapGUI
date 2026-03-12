import "dart:async";
import "dart:io";
import "dart:math";

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
  bool loading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    projectDirectory = ref.read(openProjectProvider)!;

    final mapTemplatesDirectory = getMapTemplatesDirectory(projectDirectory);

    final List<File> mapTemplates = mapTemplatesDirectory
        .listSync()
        .whereType<File>()
        .toList();

    loading = true;
    final javaPath = ref.read(javaPathProvider)!;
    unawaited(
      ConfigFile.fromFiles(mapTemplates, javaPath, interpretAsMapConfig: true).then(
        (List<ConfigFile<BaseConfigModel>> configs) {
          final List<ConfigFile<MapConfigModel>> mapConfigs = configs
              .map((e) => e as ConfigFile<MapConfigModel>)
              .toList();
          setState(() {
            options = ProjectConfigsNotifier.sortMaps(mapConfigs)
                .map(
                  (template) => DropdownMenuEntry(
                    value: template.file,
                    label: p.basenameWithoutExtension(template.path).capitalize(),
                  ),
                )
                .toList();
            loading = false;
          });
        },
      ),
    );
  }

  @override
  void dispose() {
    idController.dispose();
    super.dispose();
  }

  Future<void> validateAndCreate() async {
    if (loading) return;
    final formState = formKey.currentState;
    if (formState != null && formState.validate()) {
      setState(() => loading = true);
      final File template = selectedTemplate!;
      final String id = idController.text;

      final File newConfig = File(
        p.join(projectDirectory.path, "config", "maps", "$id.conf"),
      );

      try {
        template.copySync(newConfig.path);
      } on FileSystemException catch (e) {
        // This can happen if, for example, the provided map-id is just WAY too long
        setState(() {
          errorMessage = e.message;
          loading = false;
        });
        return;
      }

      final javaPath = ref.read(javaPathProvider)!;
      try {
        final config = await ConfigFile.fromFile(newConfig, javaPath);
        config as ConfigFile<MapConfigModel>;

        ref.read(projectProviderNotifier).addMap(config);
      } on FatalConfigFileLoadException catch (e) {
        setState(() {
          errorMessage = e.getDetails();
          loading = false;
        });
        await newConfig.delete();
        return;
      }
      if (mounted) {
        final nav = Navigator.of(context);
        if (nav.canPop()) nav.pop();
        // Do not continue to the `loading = false` below, so that the popup does not show the form again while the popup is disappearing
        return;
      }
    }
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final String? thisErrorMessage = errorMessage;
    return AlertDialog(
      title: const Text("New map"),
      content: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: loading ? .center : .start,
          mainAxisSize: .min,
          children: thisErrorMessage != null
              ? [
                  Text(
                    "Error:",
                    style: TextTheme.of(context).titleLarge?.copyWith(
                      color: Colors.redAccent,
                    ),
                  ),
                  Text(thisErrorMessage, style: pixelCode200),
                ]
              : loading
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
        if (!loading && errorMessage == null)
          ElevatedButton(onPressed: validateAndCreate, child: const Text("Create")),
      ],
    );
  }
}

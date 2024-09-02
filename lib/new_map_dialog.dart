import "dart:io";
import "dart:math";

import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:path/path.dart" as p;

import "dual_pane.dart";
import "main.dart";
import "utils.dart";

//TODO: Show options dialog
// - which template? (overworld, nether, end) dropdown
// - map name? (gets turned into a map ID and compared against existing map IDs)
// other options won't be in this initial dialog, but in the actual config screen
// which will get opened after this dialog
class NewMapDialog extends ConsumerStatefulWidget {
  const NewMapDialog({super.key});

  @override
  ConsumerState<NewMapDialog> createState() => _NewMapDialogState();
}

class _NewMapDialogState extends ConsumerState<NewMapDialog> {
  late final List<DropdownMenuEntry<File>> options;
  late final Directory projectDirectory;

  File? selectedTemplate;
  String? templateError;

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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("New map"),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Map type:"),
          const SizedBox(height: 8),
          DropdownMenu(
            hintText: "Select a template",
            errorText: templateError,
            dropdownMenuEntries: options,
            onSelected: (File? template) {
              setState(() {
                selectedTemplate = template;
                templateError = null;
              });
            },
            width: 200,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            File? template = selectedTemplate;
            if (template == null) {
              setState(() {
                templateError = "Please select a template";
              });
              return;
            }

            File newConfig = File(
              p.join(projectDirectory.path, "config", "maps",
                  "new-map-${Random().nextInt(999)}.conf"),
            );

            template.copySync(newConfig.path);

            Navigator.of(context).pop();

            ref.read(openConfigProvider.notifier).open(newConfig);
          },
          child: const Text("Create"),
        ),
      ],
    );
  }
}

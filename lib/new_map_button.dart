import "dart:io";
import "dart:math";

import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:path/path.dart" as p;

import "dual_pane.dart";
import "main.dart";
import "utils.dart";

class NewMapButton extends ConsumerWidget {
  const NewMapButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(80),
        ),
        tileColor: Theme.of(context).colorScheme.primary,
        title: const Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add),
            SizedBox(width: 8),
            Text("New map"),
            SizedBox(width: 8),
            Icon(Icons.add, color: Colors.transparent),
          ],
        ),
        onTap: () {
          final Directory? projectDirectory = ref.read(projectDirectoryProvider);
          if (projectDirectory == null) return;

          final Directory mapTemplatesDirectory = Directory(
            p.join(projectDirectory.path, "config", "map-templates"),
          );

          final List<File> mapTemplates =
              mapTemplatesDirectory.listSync().whereType<File>().toList();

          //TODO: Show options dialog
          // - which template? (overworld, nether, end) dropdown
          // - map name? (gets turned into a map ID and compared against existing map IDs)
          // other options won't be in this initial dialog, but in the actual config screen
          // which will get opened after this dialog
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("New map"),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Type:"),
                  for (final File template in mapTemplates)
                    ListTile(
                      title: Text(p.basenameWithoutExtension(template.path).capitalize()),
                      onTap: () {
                        File newConfig = File(
                          p.join(projectDirectory.path, "config", "maps",
                              "new-map-${Random().nextInt(999)}.conf"),
                        );

                        template.copySync(newConfig.path);

                        Navigator.of(context).pop();

                        ref.read(openConfigProvider.notifier).open(newConfig);
                      },
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

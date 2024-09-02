import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "new_map_dialog.dart";

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
          showDialog(
            context: context,
            builder: (context) => const NewMapDialog(),
          );
        },
      ),
    );
  }
}

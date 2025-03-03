import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../new_map_dialog.dart";

class NewMapButton extends ConsumerWidget {
  const NewMapButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Color onPrimary = Theme.of(context).colorScheme.onPrimary;
    return Padding(
      padding: const EdgeInsets.all(8),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(80)),
        tileColor: Theme.of(context).colorScheme.primary,
        title: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: onPrimary),
            const SizedBox(width: 8),
            Text("New map", style: TextStyle(color: onPrimary)),
            const SizedBox(width: 8),
            const Icon(Icons.add, color: Colors.transparent),
          ],
        ),
        onTap: () {
          showDialog(context: context, builder: (context) => const NewMapDialog());
        },
      ),
    );
  }
}

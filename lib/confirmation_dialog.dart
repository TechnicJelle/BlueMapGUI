import "package:flutter/material.dart";

void showConfirmationDialog({
  required BuildContext context,
  required String title,
  required List<Widget> content,
  required String confirmAction,
  required Function onConfirmed,
}) {
  showDialog<bool>(
    context: context,
    builder:
        (context) => _ConfirmationDialog(
          title: title,
          content: content,
          confirmAction: confirmAction,
        ),
  ).then((bool? confirmed) {
    if (confirmed == null || confirmed == false) return;
    onConfirmed();
  });
}

class _ConfirmationDialog extends StatelessWidget {
  final String title;
  final List<Widget> content;
  final String confirmAction;

  const _ConfirmationDialog({
    required this.title,
    required this.content,
    required this.confirmAction,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: content,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(confirmAction),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text("Cancel"),
        ),
      ],
    );
  }
}

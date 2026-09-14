import "dart:async";

import "package:material_ui/material_ui.dart";

///if [dangerous], the default option is the is cancel button
void showConfirmationDialog({
  required BuildContext context,
  required String title,
  required bool dangerous,
  required List<Widget> content,
  required String confirmAction,
  required void Function() onConfirmed,
}) {
  unawaited(
    showDialog<bool>(
      context: context,
      builder: (context) => _ConfirmationDialog(
        title: title,
        dangerous: dangerous,
        content: content,
        confirmAction: confirmAction,
      ),
    ).then((bool? confirmed) {
      if (confirmed == null || !confirmed) return;
      onConfirmed();
    }),
  );
}

class const _ConfirmationDialog({
  required final String title,
  required final bool dangerous,
  required final List<Widget> content,
  required final String confirmAction,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: content,
      ),
      actions: dangerous
          ? [
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                  textStyle: TextTheme.of(context).bodyLarge?.copyWith(
                    fontWeight: .bold,
                    fontSize: 15,
                  ),
                ),
                child: Text(confirmAction),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text("Cancel"),
              ),
            ]
          : [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(confirmAction),
              ),
            ],
    );
  }
}

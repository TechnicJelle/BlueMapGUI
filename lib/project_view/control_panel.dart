import "package:flutter/material.dart";

import "console.dart";
import "control_row.dart";

class ControlPanel extends StatelessWidget {
  const ControlPanel({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 16, left: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          ControlRow(),
          SizedBox(height: 16),
          Expanded(child: Console()),
        ],
      ),
    );
  }
}

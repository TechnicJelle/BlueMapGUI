import "package:flutter/material.dart";
import "package:flutter_list_view/flutter_list_view.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "control_panel.dart";
import "utils.dart";

class Console extends ConsumerStatefulWidget {
  const Console({super.key});

  @override
  ConsoleState createState() => ConsoleState();
}

class ConsoleState extends ConsumerState<Console> {
  final List<String> output = [];

  @override
  Widget build(BuildContext context) {
    ref.listen(logNotifierProvider, (_, next) {
      switch (next) {
        case AsyncData(value: final String? message):
          if (message != null) {
            setState(() => output.add(message));
          }
          break;
        case AsyncError(:final error):
          setState(() => output.add("ERR: $error"));
          break;
      }
    });

    return Container(
      margin: const EdgeInsets.only(bottom: 8, right: 8),
      padding: const EdgeInsets.all(8),
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      child: DefaultTextStyle(
        style: pixelCode,
        child: FlutterListView(
          reverse: true,
          delegate: FlutterListViewDelegate(
            (BuildContext context, int index) {
              String message = output[output.length - 1 - index];
              final Color colour;
              if (message.contains("ERR")) {
                colour = Colors.red;
              } else if (message.contains("WARN")) {
                colour = Colors.yellow;
              } else {
                colour = Colors.white;
              }
              return Text(message, style: TextStyle(color: colour));
            },
            childCount: output.length,
            keepPosition: true,
            keepPositionOffset: 80,
          ),
        ),
      ),
    );
  }
}

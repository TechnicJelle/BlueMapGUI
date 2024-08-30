import "dart:async";

import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "control_panel.dart";
import "utils.dart";

class Console extends ConsumerStatefulWidget {
  const Console({super.key});

  @override
  ConsoleState createState() => ConsoleState();
}

class ConsoleState extends ConsumerState<Console> {
  final ScrollController _scrollController = ScrollController();
  final List<String> output = [];
  Color colour = Colors.white;

  @override
  Widget build(BuildContext context) {
    ref.listen(processOutputProvider, (_, next) {
      switch (next) {
        case AsyncData(value: final String message):
          setState(() => output.add(message));

          //wait a frame, to make sure the text is built before scrolling to the end
          Timer(const Duration(milliseconds: 20), () {
            _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
          });
          break;
        case AsyncError(:final error):
          setState(() => output.add("ERR: $error"));
          break;
      }
    });

    return Container(
      margin: const EdgeInsets.only(bottom: 8, right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      child: DefaultTextStyle(
        style: pixelCode,
        child: ListView.builder(
          controller: _scrollController,
          itemBuilder: (context, index) {
            String message = output[index];
            if (message.contains("ERR")) {
              colour = Colors.red;
            } else if (message.contains("WARN")) {
              colour = Colors.yellow;
            } else if (message.contains("INFO")) {
              colour = Colors.white;
            }
            return Text(message, style: TextStyle(color: colour));
          },
          itemCount: output.length,
        ),
      ),
    );
  }
}

import "package:animated_visibility/animated_visibility.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "control_panel.dart";
import "utils.dart";

class OutputNotifier extends Notifier<List<String>> {
  @override
  List<String> build() {
    ref.listen(processOutputProvider, (_, next) {
      switch (next) {
        case AsyncData(value: final String message):
          state = [...state, message];
          break;
        case AsyncError(:final error):
          state = [...state, "ERR: $error"];
          break;
      }
    });
    return [];
  }
}

final outputNotifierProvider =
    NotifierProvider<OutputNotifier, List<String>>(() => OutputNotifier());

class Console extends ConsumerStatefulWidget {
  const Console({super.key});

  @override
  ConsoleState createState() => ConsoleState();
}

class ConsoleState extends ConsumerState<Console> {
  final ScrollController _scrollController = ScrollController();
  Color colour = Colors.white;

  bool get isScrolledToBottom =>
      _scrollController.hasClients &&
      _scrollController.position.hasContentDimensions &&
      _scrollController.position.pixels == _scrollController.position.maxScrollExtent;

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //scroll down when new output is added
    ref.listen(outputNotifierProvider, (previous, next) {
      if (isScrolledToBottom) {
        //wait a frame, to make sure the text is built before scrolling to the end
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        });
      }
    });

    //rebuild when new output is added
    final List<String> output = ref.watch(outputNotifierProvider);
    return Container(
      margin: const EdgeInsets.only(bottom: 8, right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      child: Stack(
        children: [
          DefaultTextStyle(
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
          Align(
            alignment: Alignment.bottomRight,
            child: ListenableBuilder(
              listenable: _scrollController,
              builder: (context, _) {
                return AnimatedVisibility(
                  visible: !isScrolledToBottom,
                  enter: fadeIn() + scaleIn(),
                  enterDuration: Durations.medium1,
                  exit: fadeOut() + scaleOut(),
                  exitDuration: Durations.medium1,
                  child: FloatingActionButton(
                      mini: true,
                      child: const Icon(Icons.arrow_downward),
                      onPressed: () {
                        _scrollController
                            .animateTo(
                          _scrollController.position.maxScrollExtent,
                          duration: Durations.medium4,
                          curve: Curves.easeInOut,
                        )
                            .then((_) {
                          _scrollController.jumpTo(_scrollController.position
                              .maxScrollExtent); //TODO: remove the need for this. get animateTo to work properly and scroll fully down, instead.
                        });
                      }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

import "dart:async";

import "package:animated_visibility/animated_visibility.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../project_configs_provider.dart";
import "../utils.dart";
import "control_row/control_row.dart";

class OutputNotifier extends Notifier<List<String>> {
  String _convert(AsyncValue<String> next) {
    return switch (next) {
      AsyncData(value: final String message) => message,
      AsyncError(:final error) => "ERR: $error",
      AsyncLoading(progress: null) => "Loading...",
      AsyncLoading(:final num progress) => "Loading... ${(progress * 100).toInt()}%",
    };
  }

  @override
  List<String> build() {
    //clear output when project directory changes
    ref.listen(projectProvider, (_, _) => clear());

    final sub = ref.listen(processOutputProvider, (_, next) {
      state = [...state, _convert(next)];
    });

    return [_convert(sub.read())];
  }

  void clear() {
    state = [];
  }
}

// I don't want these for providers; too long
// ignore: specify_nonobvious_property_types
final outputNotifierProvider = NotifierProvider(OutputNotifier.new);

class Console extends ConsumerStatefulWidget {
  const Console({super.key});

  @override
  ConsumerState<Console> createState() => _ConsoleState();
}

class _ConsoleState extends ConsumerState<Console> {
  final ScrollController _scrollController = ScrollController();
  Color colour = Colors.white;

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    if (!_scrollController.position.hasContentDimensions) return;
    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
  }

  bool get isScrolledToBottom =>
      _scrollController.hasClients &&
      _scrollController.position.hasContentDimensions &&
      _scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent -
              20; //a bit more than the text size

  @override
  void initState() {
    super.initState();

    //scroll down when console is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
      setState(() {
        /*hack to make the FAB disappear when no scrolling yet*/
      });

      //do it again, to really make sure (i hate that this is necessary)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //scroll down when new output is added
    ref.listen(outputNotifierProvider, (previous, next) {
      if (isScrolledToBottom) {
        //wait a frame, to make sure the text is built before scrolling to the end
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });
      }
    });

    //rebuild when new output is added
    final List<String> output = ref.watch(outputNotifierProvider);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
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
                final String message = output[index];
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
                      unawaited(
                        _scrollController
                            .animateTo(
                              _scrollController.position.maxScrollExtent,
                              duration: Durations.medium4,
                              curve: Curves.easeInOut,
                            )
                            .then((_) => _scrollToBottom()),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

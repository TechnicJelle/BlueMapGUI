import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:url_launcher/url_launcher.dart";

import "control_row.dart";

class OpenButton extends ConsumerStatefulWidget {
  const OpenButton({super.key});

  @override
  ConsumerState<OpenButton> createState() => _OpenButtonState();
}

class _OpenButtonState extends ConsumerState<OpenButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _animation = CurveTween(curve: Curves.elasticOut).animate(_controller);

    //set the animation as finished upon start, to prevent scale==0
    _controller.value = 1.0;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isRunning = ref.watch(
      processStateProvider.select(
        (asyncValue) => asyncValue.value == RunningProcessState.running,
      ),
    );

    ref.listen(processStateProvider, (previous, next) {
      if (next.value == RunningProcessState.running) {
        _controller.forward(from: 0);
      }
    });

    return ScaleTransition(
      scale: _animation,
      child: ElevatedButton.icon(
        onPressed: isRunning
            ? () async {
                final int port = ref.read(processProvider)?.port ?? 8100;
                if (!await launchUrl(Uri.parse("http://localhost:$port"))) {
                  throw Exception("Could not launch url!");
                }
              }
            : null,
        label: const Text("Open"),
        icon: const Icon(Icons.open_in_browser),
      ),
    );
  }
}

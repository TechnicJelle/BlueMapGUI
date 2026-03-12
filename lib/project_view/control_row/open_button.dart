import "dart:async";
import "dart:math";

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
      duration: const Duration(milliseconds: 2000),
    );

    // Many many thanks to https://github.com/qwerasd205 for helping me bring my animation idea to maths!
    // https://www.desmos.com/calculator/ri3wqi80au
    const double attackToDecaySwitchMomentFactor = 0.25;
    const double maxHeight = 2;
    const double decaySmooth = 3;
    _animation = Animatable<double>.fromCallback((double x) {
      // shortened variable names for easier mathsing
      const double c = attackToDecaySwitchMomentFactor; // [c]enter
      const double h = maxHeight; // [h]eight,
      const double s = decaySmooth; // [s]moothing of tail end

      final attack = cos(asin(1 - (x / c)));
      final decay = pow(cos((1 / (2 * (1 - c))) * pi * (max(x, c) - c)), s);
      return 1 + (h - 1) * (x < c ? attack : decay);
    }).animate(_controller);
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
        unawaited(_controller.forward(from: 0));
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

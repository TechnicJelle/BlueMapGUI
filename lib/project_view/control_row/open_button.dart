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

class _OpenButtonState extends ConsumerState<OpenButton> with TickerProviderStateMixin {
  late final AnimationController _scaleController;
  late final Animation<double> _scaleAnimation;
  late final AnimationController _glowController;
  late final Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Many many thanks to https://github.com/qwerasd205 for helping me bring my animation idea to maths!
    // https://www.desmos.com/calculator/ri3wqi80au
    const double attackToDecaySwitchMomentFactor = 0.2;
    const double maxHeight = 1.3;
    const double decaySmooth = 5;
    _scaleAnimation = Animatable<double>.fromCallback((double x) {
      // shortened variable names for easier mathsing
      const double c = attackToDecaySwitchMomentFactor; // [c]enter
      const double h = maxHeight; // [h]eight,
      const double s = decaySmooth; // [s]moothing of tail end

      final attack = cos(asin(1 - (x / c)));
      final decay = pow(cos((1 / (2 * (1 - c))) * pi * (max(x, c) - c)), s);
      return 1 + (h - 1) * (x < c ? attack : decay);
    }).animate(_scaleController);

    _glowAnimation = Tween<double>(begin: 0, end: 1).animate(_glowController);
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isRunning = ref.watch(
      processStateProvider.select((asyncValue) => asyncValue.value == .running),
    );

    ref.listen(processStateProvider, (previous, next) {
      if (next.value == .running) {
        unawaited(_scaleController.forward(from: 0));
        unawaited(_glowController.forward(from: 0));
      }
      if (next.value == .stopping) {
        unawaited(_glowController.animateBack(0, duration: Durations.short4));
      }
    });

    return ScaleTransition(
      scale: _scaleAnimation,
      child: AnimatedGlow(
        animation: _glowAnimation,
        controller: _glowController,
        child: ElevatedButton.icon(
          onPressed: isRunning
              ? () async {
                  unawaited(_glowController.animateBack(0, duration: Durations.short4));
                  final int port = ref.read(processProvider)?.port ?? 8100;
                  if (!await launchUrl(Uri.parse("http://localhost:$port"))) {
                    throw Exception("Could not launch url!");
                  }
                }
              : null,
          label: const Text("Open"),
          icon: const Icon(Icons.open_in_browser),
        ),
      ),
    );
  }
}

class AnimatedGlow extends StatelessWidget {
  final AnimationController controller;
  final Animation<double> animation;
  final Widget child;

  const AnimatedGlow({
    required this.controller,
    required this.animation,
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      child: MouseRegion(
        onEnter: (_) => controller.animateBack(0, duration: Durations.short2),
        onHover: (event) => controller.animateBack(0, duration: Durations.short2),
        child: child,
      ),
      builder: (context, child) {
        final double t = animation.value;
        return DecoratedBox(
          decoration: BoxDecoration(
            boxShadow: t > 0
                ? [
                    BoxShadow(color: Colors.lightBlueAccent, blurRadius: t * 10),
                    BoxShadow(color: Colors.lightBlue, blurRadius: t * 50),
                    BoxShadow(color: Colors.blueAccent, blurRadius: t * 100),
                  ]
                : [],
          ),
          child: child,
        );
      },
    );
  }
}

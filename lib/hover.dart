import "package:flutter/material.dart";

class Hover extends StatefulWidget {
  final Widget alwaysChild;
  final Widget hoverChild;

  const Hover({
    super.key,
    required this.alwaysChild,
    required this.hoverChild,
  });

  @override
  State<Hover> createState() => _HoverState();
}

class _HoverState extends State<Hover> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onHover: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: Stack(
        children: [
          widget.alwaysChild,
          if (_isHovering) widget.hoverChild,
        ],
      ),
    );
  }
}

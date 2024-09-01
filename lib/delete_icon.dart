import "package:flutter/material.dart";

class DeleteIcon extends StatefulWidget {
  const DeleteIcon({super.key});

  @override
  State<DeleteIcon> createState() => _DeleteIconState();
}

class _DeleteIconState extends State<DeleteIcon> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onHover: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: _isHovering ? const Icon(Icons.delete_forever) : const Icon(Icons.delete),
    );
  }
}

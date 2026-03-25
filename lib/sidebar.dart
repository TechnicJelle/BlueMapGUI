import "package:flutter/material.dart";

class Sidebar extends StatelessWidget {
  final List<Widget> children;

  const Sidebar({required this.children, super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.brightnessOf(context);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 200),
      child: Material(
        color: switch (brightness) {
          Brightness.dark => Colors.grey.shade900,
          Brightness.light => Colors.grey,
        },
        child: ListView(
          children: children,
        ),
      ),
    );
  }
}

class SidebarTab extends StatelessWidget {
  final bool selected;
  final String title;
  final GestureTapCallback onTap;
  final Widget? trailing;
  final double? minTileHeight;

  const SidebarTab({
    required this.title,
    required this.selected,
    required this.onTap,
    this.trailing,
    this.minTileHeight,
    super.key,
  });

  static const shape = RoundedRectangleBorder(
    borderRadius: BorderRadius.horizontal(left: Radius.circular(80)),
  );

  @override
  Widget build(BuildContext context) {
    final Color primary = Theme.of(context).scaffoldBackgroundColor;
    return ListTile(
      contentPadding: const EdgeInsets.only(left: 20),
      shape: shape,
      tileColor: Colors.black12,
      selectedTileColor: primary,
      selected: selected,
      title: Row(
        mainAxisAlignment: .spaceBetween,
        children: [
          Flexible(child: Text(title)),
          if (trailing != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: trailing,
            ),
        ],
      ),
      onTap: onTap,
      minTileHeight: minTileHeight,
    );
  }
}

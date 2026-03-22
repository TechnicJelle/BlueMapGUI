import "dart:io";

import "package:techs_html_bindings/elements.dart";

Head generateHead({
  String? pageTitle,
  String pageDescription =
      "A GUI wrapper around the BlueMap CLI, mainly to make using BlueMap easier to use on single player worlds.",
  String relativeToRoot = "",
  Iterable<Style> extraStyles = const Iterable.empty(),
}) {
  String fullTitle = "BlueMap GUI";
  if (pageTitle != null) {
    fullTitle = "$pageTitle | $fullTitle";
  }

  return Head(
    title: fullTitle,
    metas: [
      Meta.name(name: "og:title", content: fullTitle),
      Meta.name(name: "description", content: pageDescription),
      Meta.name(name: "og:description", content: pageDescription),
      Meta.name(name: "theme-color", content: "#2196F3"),
      Meta.name(name: "og:image", content: _icon(256)),
      Meta.httpEquiv(httpEquiv: "X-Clacks-Overhead", content: "GNU Terry Pratchett"),
    ],
    links: [
      Link.icon(type: "image/png", sizes: "48x48", href: _icon(48)),
      ...Link.preloadedStylesheet(href: "${relativeToRoot}main.css"),
      Link.stylesheet(href: "${relativeToRoot}fonts/PixelCode_v2.2/PixelCode.css"),
    ],
    styles: [
      Style(css: File("styles/theme.css").readAsStringSync()),
      ...extraStyles,
    ],
  );
}

String _icon(int size) {
  final String filename = "icon_$size.png";
  return "https://technicjelle.com/BlueMapGUI/$filename";
}
